class AddRecommendationsToSpaces < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :is_recommended, :bool, default: false
  end
end
