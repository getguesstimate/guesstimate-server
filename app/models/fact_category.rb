class FactCategory < ActiveRecord::Base
  belongs_to :organization

  has_many :facts, foreign_key: :category_id

  validates_presence_of :name, :organization
  validates_uniqueness_of :name, scope: :organization_id
end
