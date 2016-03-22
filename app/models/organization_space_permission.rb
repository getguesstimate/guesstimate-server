class OrganizationSpacePermission < ActiveRecord::Base
  belongs_to :organization
  belongs_to :space

  validates_presence_of :organization, :space
end
