class User < ActiveRecord::Base
  has_many :spaces
  validates_uniqueness_of :username, allow_blank: true
  validates :auth0_id, presence: true, uniqueness: true
  after_initialize :init

  def init
    self.private_access_count ||= 3
  end

  def satisfied_private_model_count
    (self.private_access_count <= self.spaces.is_private.count)
  end

  def private_model_count
    self.spaces.is_private.count
  end

  def available_private_model_count
    self.private_access_count || 0
  end
end
