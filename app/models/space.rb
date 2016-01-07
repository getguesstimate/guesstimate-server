class Space < ActiveRecord::Base
  include AlgoliaSearch
  belongs_to :user

  algoliasearch per_environment: true do
    attribute :id, :name, :description, :user_id, :created_at, :updated_at
    add_attribute :models, :metrics, :user_info

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

  def models
    if graph and graph['metrics'].kind_of?(Array)
      graph['metrics'].map{|m| m.slice('name')}
    else
      []
    end
  end

  #this should be named metrics
  def metrics
    if graph and graph['metrics'].kind_of?(Array)
      graph['metrics'].map{|m| m.slice('name')}.select{|m| m.keys.length > 0}
    else
      []
    end
  end

  def user_info
    user ? user.as_json : {}
  end
end
