class User < ActiveRecord::Base
  has_many :spaces
  validates_uniqueness_of :username, allow_blank: true
  validates :auth0_id, presence: true, uniqueness: true

  validates :private_access_count, numericality: {greater_than_or_equal_to: 0}

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
