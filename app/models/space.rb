class Space < ActiveRecord::Base
  include AlgoliaSearch
  include FakeNameDetector

  has_many :permissions, class_name: "UserSpacePermission"
  has_many :users, through: :permissions
  has_many :ownerships, -> { own }, class_name: "UserSpacePermission"
  has_many :owners, through: :ownerships, source: :user

  def owned_by?(user)
    owners.exists? user
  end

  belongs_to :creator, class_name: "User"

  belongs_to :copied_from, :class_name => 'Space', foreign_key: 'copied_from_id'
  has_many :copies, :class_name => 'Space', foreign_key: 'copied_from_id'

  validates :creator_id, presence: true
  validate :can_create_private_models
  validates :viewcount, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }

  after_initialize :init
  after_create :make_creator_owner

  scope :is_private, -> { where(is_private: true) }
  scope :is_public, -> { where(is_private: false) }

  def self.visible_by(user)
    (Space.is_public.all + user.spaces.all).uniq
  end

  def init
    self.is_private ||= false
  end

  algoliasearch if: :is_searchable?, per_environment: true, disable_indexing: Rails.env.test? do
    attribute :id, :name, :description, :creator_id, :created_at, :updated_at, :is_private, :viewcount
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
    creator ? creator.as_json : {}
  end

  def can_create_private_models
    if is_private && !creator.try(:can_create_private_models)
      errors.add(:creator_id, 'can not make more private models with current plan')
    end
  end

  def clean_graph!
    update_attributes(graph: cleaned_graph)
  end

  def cleaned_graph
    {'metrics' => Array.wrap(cleaned_metrics), 'guesstimates' => Array.wrap(cleaned_guesstimates)}
  end

  def copy(user)
    space = Space.new(self.attributes.slice('name', 'description', 'graph'))
    space.creator = user
    space.copied_from_id = self.id
    space.is_private = user.prefers_private?
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

  def make_creator_owner
    ownerships.create!(user: creator)
  end
end
