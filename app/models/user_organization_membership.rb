class UserOrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  validates_presence_of :organization, :user
end
