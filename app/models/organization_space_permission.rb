class OrganizationSpacePermission < ActiveRecord::Base
  belongs_to :organization
  belongs_to :space

  enum access_type: {exposed: 1}

  validates_presence_of :organization, :space, :access_type
end
