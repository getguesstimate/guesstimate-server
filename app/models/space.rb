require 'net/http'

class Space < ActiveRecord::Base
  include AlgoliaSearch
  include FakeNameDetector

  belongs_to :user
  belongs_to :copied_from, class_name: 'Space', foreign_key: 'copied_from_id'
  has_many :copies, class_name: 'Space', foreign_key: 'copied_from_id'
  has_many :checkpoints, class_name: 'SpaceCheckpoint', dependent: :destroy
  has_many :calculators, dependent: :destroy

  belongs_to :organization

  validates :user_id, presence: true
  validate :owner_can_create_private_models, if: :is_private
  validates :viewcount, numericality: {allow_nil: true, greater_than_or_equal_to: 0}

  after_initialize :init
  after_save :identify_user
  after_save :take_snapshot, if: :needs_new_snapshot?
  after_destroy :identify_user

  scope :is_private, -> { where(is_private: true) }
  scope :is_public, -> { where(is_private: false) }
  scope :uncategorized_since, -> (date) { where 'categorized IS NOT true AND DATE(created_at) >= ?', date }

  def init
    self.is_private ||= false
  end

  algoliasearch if: :is_searchable?, per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id, :name, :description, :user_id, :created_at, :updated_at, :is_private, :viewcount, :screenshot, :big_screenshot
    add_attribute :user_info
    add_attribute :organization_info

    # We want to rank equally relevant results by viewcount.
    customRanking ['desc(viewcount)']

    attribute :updated_at_i do
      updated_at.to_i
    end

    attribute :created_at_i do
      created_at.to_i
    end

    attribute :metric_count do
      metrics.length.to_i
    end
  end

  def last_updated_at?(datetime_str)
    updated_at.to_datetime.to_s == DateTime.parse(datetime_str).to_datetime.to_s
  end

  def someone_else_editing?(current_user, previous_updated_at_str)
    return false if last_updated_at?(previous_updated_at_str) || checkpoints.last.nil?

    checkpoints.last.author_id != current_user.id
  end

  def metrics
    if graph && graph['metrics'].kind_of?(Array)
      graph['metrics'].map{|m| m.slice('name')}
    else
      []
    end
  end

  def guesstimates_not_of_type(types)
    return [] if graph.nil? || graph['guesstimates'].nil?
    graph['guesstimates'].select {|guesstimate| types.exclude? guesstimate['guesstimateType']}
  end

  def guesstimates_of_type(types)
    return [] if graph.nil? || graph['guesstimates'].nil?
    graph['guesstimates'].select {|guesstimate| types.include? guesstimate['guesstimateType']}
  end

  def is_public?
    !self.is_private
  end

  def is_searchable?
    is_public? &&
    has_real_name? &&
    has_interesting_metrics?
  end

  def has_interesting_metrics?
    guesstimates_not_of_type(['POINT', 'FUNCTION', 'NONE']).any? &&
    guesstimates_of_type(['FUNCTION']).any? &&
    metrics.length > 3
  end

  def editable_by_user?(user)
    if organization
      user.member_of?(organization)
    else
      user_id == user.id
    end
  end

  def user_info
    user ? UserRepresenter.new(user).to_hash(user_options: {is_current_user: false}) : {}
  end

  def organization_info
    organization ? OrganizationRepresenter.new(organization).to_hash(user_options: {current_user_is_member: false, current_user_is_admin: false}) : {}
  end

  def owner
    belongs_to_organization? ? organization : user
  end

  def belongs_to_organization?
    !!organization_id
  end

  def clean_graph!
    update_attributes(graph: cleaned_graph)
  end

  def cleaned_graph
    {'metrics' => Array.wrap(cleaned_metrics), 'guesstimates' => Array.wrap(cleaned_guesstimates)}
  end

  def visible_to?(user)
    is_public? || user.id == self.user_id || user.member_of?(self.organization_id)
  end

  def copy(user)
    space = Space.new(self.attributes.slice('name', 'description', 'graph'))
    space.user = user
    space.copied_from_id = self.id

    # This space should be retained within the organization if it is being copied within the organization.
    if belongs_to_organization? && user.member_of?(organization_id)
      space.organization_id = organization_id
      space.is_private = space.organization.prefers_private?
    else
      space.is_private = user.prefers_private?
    end

    space.save
    return space
  end

  def needs_checkpoint?
    !graph.nil?
  end

  def take_checkpoint(author)
    checkpoints.create author: author, name: name, description: description, graph: graph
    if checkpoints.count > 1000
      checkpoints.order('created_at').first.delete
    end
  end

  def needs_new_snapshot?
    Rails.env == 'production' && is_public? && has_old_snapshot?
  end

  def has_old_snapshot?
    return true unless snapshot_timestamp
    5.minutes.ago >= snapshot_timestamp
  end

  def get_screenshot_url(thumb, force = false)
    url = BASE_URL + "/models/#{id}/embed"

    column_count = [max_columns, 5].max
    width = 212 * (column_count + 1) + 10
    screenshot = Screenshot.new(url, width, thumb, force)
    screenshot.url
  end

  def take_screenshots
    Net::HTTP.get URI.parse(get_screenshot_url(true, true))
    Net::HTTP.get URI.parse(get_screenshot_url(false, true))
  end

  def recache_html
    url = BASE_URL + "models/#{id}"

    uri = URI.parse('http://api.prerender.io')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(
      'http://api.prerender.io/recache',
      initHeader = {'Content-Type' => 'application/json'}
    )
    req.body = JSON.generate prerenderToken: Rails.application.secrets.prerender_token, url: url
    http.request req
  end

  def take_snapshot
    update_columns screenshot: get_screenshot_url(true), big_screenshot: get_screenshot_url(false), snapshot_timestamp: DateTime.now
    Thread.new {
      take_screenshots
      recache_html
    }
    index!
  end

  def max_columns
    if graph && graph['metrics']
      return graph['metrics'].map{|e| (e['location'] && e['location']['column'] || 0)}.max
    else
      return 0
    end
  end

  private
  def clean_items(key, uniqKey)
    graph && graph[key] && graph[key].reverse.uniq{|m| m[uniqKey]}.reverse
  end

  def cleaned_metrics
    clean_items('metrics', 'id')
  end

  def cleaned_guesstimates
    clean_items('guesstimates', 'metric')
  end

  def identify_user
    user && user.identify
  end

  private

  # Validations
  def owner_can_create_private_models
    unless owner.can_create_private_models?
      errors.add(:user_id, 'can not make more private models with current plan')
    end
  end
end
