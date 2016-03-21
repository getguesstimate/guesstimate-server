class UserSpacePermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :space

  enum access_type: [ :own ]
end
