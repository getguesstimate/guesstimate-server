class Space < ActiveRecord::Base
  include AlgoliaSearch
  belongs_to :user
  validates :user_id, presence: true
  after_initialize :init
  scope :is_private, -> { where(is_private: true) }

  algoliasearch per_environment: true do
    attribute :id, :name, :description, :user_id, :created_at, :updated_at, :is_private
    add_attribute :user_info

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
    if graph and graph['metrics'].kind_of?(Array)
      graph['metrics'].map{|m| m.slice('name')}
    else
      []
    end
  end

  def named_metrics
      metrics.select{|m| m.keys.length > 0}
  end

  def user_info
    user ? user.as_json : {}
  end

  def init
    self.is_private ||= false
  end
end
