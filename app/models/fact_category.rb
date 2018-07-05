class FactCategory < ApplicationRecord
  belongs_to :organization

  has_many :facts, foreign_key: :category_id

  validates_presence_of :name, :organization
  validates_uniqueness_of :name, scope: :organization_id

  before_destroy { |category| category.facts.update_all category_id: nil }
end
