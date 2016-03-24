class UserSpacePermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :space

  enum access_type: { own: 1 }

  validates_presence_of :user, :space, :access_type
end
