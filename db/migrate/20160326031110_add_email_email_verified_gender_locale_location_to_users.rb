class AddEmailEmailVerifiedGenderLocaleLocationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :string
    add_column :users, :gender, :string
    add_column :users, :locale, :string
    add_column :users, :location, :string
    add_column :users, :email_verified, :bool
  end
end
