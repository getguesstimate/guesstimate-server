class Space < ActiveRecord::Base
  include AlgoliaSearch
  belongs_to :user

  algoliasearch per_environment: true do
    attribute :id, :name, :description, :user_id
    add_attribute :models, :user_info
  end

  def models
    if graph and graph['metrics'].kind_of?(Array)
      graph['metrics'].map{|m| m.slice('id', 'space', 'readableId', 'name')}
    else
      []
    end
  end

  def user_info
    user ? user.as_json : {}
  end
end
