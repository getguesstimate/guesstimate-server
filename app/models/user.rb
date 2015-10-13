class User < ActiveRecord::Base
  has_many :spaces
  validates_uniqueness_of :username, allow_blank: true
  validates :auth0_id, presence: true, uniqueness: true
end
