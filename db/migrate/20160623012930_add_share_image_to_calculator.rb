class AddShareImageToCalculator < ActiveRecord::Migration[4.2]
  def change
    add_column :calculators, :share_image, :string
  end
end
