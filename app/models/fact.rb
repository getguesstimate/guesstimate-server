class Fact < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :organization, :name, :variable_name, :expression
  validates :variable_name,
    uniqueness: {scope: :organization_id},
    format: {with: /\A\w+\Z/}
end
