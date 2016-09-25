require 'net/http'

class Space < ActiveRecord::Base
  include AlgoliaSearch
  include FakeNameDetector

  belongs_to :user
  belongs_to :copied_from, class_name: 'Space', foreign_key: 'copied_from_id'
  has_many :copies, class_name: 'Space', foreign_key: 'copied_from_id'
  has_many :checkpoints, class_name: 'SpaceCheckpoint', dependent: :destroy
  has_many :calculators, dependent: :destroy
  has_many :exported_facts, foreign_key: 'exported_from_id', class_name: 'Fact', dependent: :destroy

  belongs_to :organization

  validates :user_id, presence: true
  validate :owner_can_create_private_models, if: :is_private
  validates :viewcount, numericality: {allow_nil: true, greater_than_or_equal_to: 0}
  validates :shareable_link_token, length: { minimum: 32 }, if: :shareable_link_enabled
  validates_presence_of :is_private, if: :shareable_link_enabled # Booleans are only considered 'present' on 'true'

  after_initialize :init
  after_save :identify_user
  before_save :update_imported_fact_ids!
  after_destroy :identify_user

  scope :is_private, -> { where(is_private: true) }
  scope :is_public, -> { where(is_private: false) }
  scope :uncategorized_since, -> (date) { where 'categorized IS NOT true AND DATE(created_at) >= ?', date }
  scope :has_fact_exports, -> { where('exported_facts_count > 0') }
  scope :imports_fact, -> (fact) { where('? = ANY(imported_fact_ids)', fact.id) }

  def init
    self.is_private ||= false
  end

  algoliasearch if: :is_searchable?, per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id, :name, :description, :user_id, :created_at, :updated_at, :is_private, :viewcount, :screenshot, :big_screenshot, :is_recommended
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

  def guesstimate_expressions
    return [] unless graph.present? && graph['guesstimates'].present?
    graph['guesstimates'].map { |g| g['expression'] }
  end

  def imported_facts
    imported_fact_ids.any? ? organization.facts.imported_by_space(self) : Fact.none
  end

  def get_imported_fact_ids()
    guesstimate_expressions.map {|e| e.scan(/\$\{fact:(\d+)/) unless e.blank? }.flatten.uniq.keep_if { |e| e.present? }
  end

  def update_exported_facts_count!()
    update_columns(exported_facts_count: exported_facts.count)
  end

  def update_imported_fact_ids!()
    self.imported_fact_ids = get_imported_fact_ids
  end

  def metrics
    if graph && graph['metrics'].kind_of?(Array)
      graph['metrics'].map{|m| m.slice('name')}
    else
      []
    end
  end

  def metric_readable_ids_to_ids_map
    idMap = {}
    graph['metrics'].each{|m| idMap[m['readableId']] = m['id']} if graph && graph['metrics'].kind_of?(Array)
    idMap
  end

  def has_been_migrated?
    graph.present? && graph['guesstimates'].kind_of?(Array) && graph['guesstimates'].all? {|g| g['input'].nil? || g['expression'].present?}
  end

  def migrate_inputs_to_expressions
    return if !graph.present? || !graph['guesstimates'].kind_of?(Array) || has_been_migrated?
    idRe = Regexp.new(metric_readable_ids_to_ids_map.keys.join('|'))
    idMap = metric_readable_ids_to_ids_map.transform_values {|v| "${metric:#{v}}"}
    graph['guesstimates'].each { |g| g.merge!({'input' => nil, 'expression' => g['input'].gsub(idRe, idMap)}) if g['input'].present? }
    update_columns graph: graph
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

  def viewable_by_user?(user)
    is_public? || (user.present? && editable_by_user?(user))
  end

  def editable_by_user?(user)
    if organization
      user.member_of?(organization)
    else
      user_id == user.id
    end
  end

  def editors_by_time
    query = "
      CREATE OR REPLACE FUNCTION array_sort (ANYARRAY)
      RETURNS ANYARRAY LANGUAGE SQL
      AS $$
        SELECT ARRAY(SELECT unnest($1) ORDER BY 1 ASC)
      $$;

      CREATE OR REPLACE FUNCTION time_windows(timestamp[]) RETURNS tsrange[] AS $$
        DECLARE
          s tsrange[] := ARRAY[]::tsrange[];
          running_start timestamp;
          prev timestamp;
          curr timestamp;
        BEGIN

          running_start := $1[1];
          prev := $1[1];
          curr := $1[1];

          FOREACH curr IN ARRAY $1 LOOP
            IF (curr - prev > INTERVAL '15 minutes') THEN
              s := s || tsrange(running_start, prev, '[]');
              running_start := curr;
            END IF;

            prev := curr;
          END LOOP;

          s := s || tsrange(running_start, curr, '[]');

          RETURN s;
        END;
      $$ LANGUAGE plpgsql;

      SELECT
        author_id,
        space_id,
        UNNEST(time_windows(array_sort(created_ats))) AS duration
      FROM (
        SELECT
          author_id,
          space_id,
          ARRAY_AGG(created_at) AS created_ats
        FROM
          space_checkpoints
        WHERE author_id IS NOT NULL AND space_id = #{id}
        GROUP BY author_id, space_id
      ) AS t1
    "
    editing_sessions = ActiveRecord::Base.connection.execute(query).to_a

    editing_stats = {}
    editing_sessions.each do |session|
      user_id = session['author_id'].to_i
      time_range = session['duration'].slice(1, session['duration'].length - 2).split(',').map{|s| DateTime.parse s.slice(1, s.length - 2)}
      duration = (time_range[1] - time_range[0]).days
      curr_data = editing_stats[user_id]
      editing_stats[user_id] = {
        duration: (curr_data.present? ? curr_data[:duration] : 0.seconds) + (duration > 0 ? duration : 30.seconds),
        num_sessions: (curr_data.present? ? curr_data[:num_sessions] : 0) + 1,
      }
    end

    editing_stats_arr = editing_stats.map { |k, v| {user_id: k, duration: v[:duration], num_sessions: v[:num_sessions] } }
    editing_stats_arr.sort { |x, y| y[:duration] <=> x[:duration] }
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

  def recommend!
    update_columns is_recommended: true
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

  def get_screenshot_url(thumb, force = false)
    url = "#{client_url}/embed"

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
    uri = URI.parse('http://api.prerender.io')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(
      'http://api.prerender.io/recache',
      initHeader = {'Content-Type' => 'application/json'}
    )
    req.body = JSON.generate prerenderToken: Rails.application.secrets.prerender_token, url: client_url
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

  def to_text
    return "#{name}
      #{description}
      #{metrics.zip(guesstimates).map {|m, g| "Metric #{m['name']}: #{g['description']}"}.join("\n")}
    "
  end

  def increment_exported_facts_count!
    update_columns(exported_facts_count: exported_facts_count + 1)
  end

  def decrement_exported_facts_count!
    update_columns(exported_facts_count: exported_facts_count - 1)
  end

  def enable_shareable_link!
    return true if shareable_link_enabled
    update_attributes shareable_link_token: get_secure_token, shareable_link_enabled: true
  end

  def disable_shareable_link!
    return true unless shareable_link_enabled
    update_attributes shareable_link_token: nil, shareable_link_enabled: false
  end

  def rotate_shareable_link!
    update_attributes shareable_link_token: get_secure_token if shareable_link_enabled
  end

  def shareable_link_url
    shareable_link_enabled ? "#{client_url}?token=#{shareable_link_token}" : ''
  end

  private

  def get_secure_token
    SecureRandom.urlsafe_base64(64, false)
  end

  def client_url
    BASE_URL + "models/#{id}"
  end

  def guesstimates
    if graph && graph['guesstimates']
      return graph['guesstimates']
    else
      return []
    end
  end
  def metrics
    if graph && graph['metrics']
      return graph['metrics']
    else
      return []
    end
  end

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

  # Validations
  def owner_can_create_private_models
    unless owner.can_create_private_models?
      errors.add(:user_id, 'can not make more private models with current plan')
    end
  end
end
