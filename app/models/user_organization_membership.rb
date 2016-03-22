class UserOrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  enum member_type: {admin: 1}

  validates_presence_of :organization, :user, :member_type
end
