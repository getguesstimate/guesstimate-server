class AddRecommendationsToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :is_recommended, :bool, default: false
  end
end
