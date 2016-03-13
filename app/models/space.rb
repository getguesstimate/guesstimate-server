class Space < ActiveRecord::Base
  include AlgoliaSearch
  include FakeNameDetector

  belongs_to :user
  belongs_to :forked_from, :class_name => 'Space', foreign_key: 'forked_from_id'
  has_many :forks, :class_name => 'Space', foreign_key: 'forked_from_id'

  validates :user_id, presence: true
  validate :can_create_private_models
  validates :viewcount, numericality: {allow_nil: true, greater_than_or_equal_to: 0}

  after_initialize :init
  after_create :ensure_metric_space_ids

  scope :is_private, -> { where(is_private: true) }
  scope :is_public, -> { where(is_private: false) }
  scope :visible_by, -> (user) { where 'is_private IS false OR user_id = ?', user.try(:id) }

  def init
    self.is_private ||= false
  end

  algoliasearch if: :is_searchable?, per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id, :name, :description, :user_id, :created_at, :updated_at, :is_private, :viewcount
    add_attribute :user_info

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

  def metrics
    if graph && graph['metrics'].kind_of?(Array)
      graph['metrics'].map{|m| m.slice('name')}
    else
      []
    end
  end

  def guesstimates_of_type(types)
    return [] if graph.nil? || graph['guesstimates'].nil?

    return graph['guesstimates'].select {|guesstimate| types.include? guesstimate['guesstimateType']}
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
    guesstimates_of_type(['UNIFORM', 'NORMAL']).any? &&
    guesstimates_of_type(['FUNCTION']).any? &&
    metrics.length > 3
  end

  def user_info
    user ? user.as_json : {}
  end

  def ensure_metric_space_ids
    if graph
      graph['metrics'].each do |metric|
        metric['space'] = self.id
      end
      self.save
    end
  end

  def can_create_private_models
    if is_private && !user.try(:can_create_private_models)
      errors.add(:user_id, 'can not make more private models with current plan')
    end
  end

  def clean_graph!
    update_attributes(graph: cleaned_graph)
  end

  def cleaned_graph
    {'metrics' => Array.wrap(cleaned_metrics), 'guesstimates' => Array.wrap(cleaned_guesstimates)}
  end

  def fork(user)
    # We copy the graph directly here as it is handled natively in the after_create call.
    space = Space.new(self.attributes.slice('name', 'description', 'graph'))
    space.user = user
    space.forked_from_id = self.id
    space.is_private = user.preferred_privacy
    space.save
    return space
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
end
