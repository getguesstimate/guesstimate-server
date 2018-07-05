class AddEmailGenderLocaleLocationToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email, :string
    add_column :users, :gender, :string
    add_column :users, :locale, :string
    add_column :users, :location, :string
  end
end
