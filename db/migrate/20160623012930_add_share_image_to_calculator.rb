class AddShareImageToCalculator < ActiveRecord::Migration
  def change
    add_column :calculators, :share_image, :string
  end
end
