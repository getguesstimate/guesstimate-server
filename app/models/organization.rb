class Organization < ActiveRecord::Base
  has_many :memberships, class_name: 'UserOrganizationMembership'
  has_many :members, through: :memberships, class_name: 'User', source: :user
  has_many :administratorships, -> { admin }, class_name: 'UserOrganizationMembership'
  has_many :admins, through: :administratorships, class_name: 'User', source: :user

  has_many :permissions, class_name: 'OrganizationSpacePermission'
  has_many :spaces, through: :permissions
end
