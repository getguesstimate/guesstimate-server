class Organization < ActiveRecord::Base
  has_many :memberships, class_name: 'UserOrganizationMembership', dependent: :destroy
  has_many :members, through: :memberships, class_name: 'User', source: :user

  has_many :spaces, dependent: :destroy
end
