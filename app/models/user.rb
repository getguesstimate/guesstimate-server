class User < ActiveRecord::Base
  has_many :spaces
  has_one :account, dependent: :destroy
  after_initialize :init
  after_create :create_account

  validates_uniqueness_of :username, allow_blank: true
  validates :auth0_id, presence: true, uniqueness: true
  validates :private_access_count, numericality: {greater_than_or_equal_to: 0}

  def init
    self.private_access_count ||= 3
  end

  def satisfied_private_model_count
    (self.private_access_count <= self.spaces.is_private.count)
  end

  def private_model_count
    self.spaces.is_private.count
  end

  def public_model_count
    self.spaces.is_public.count
  end

  def private_model_limit
    self.private_access_count || 0
  end

  def can_create_private_models
    self.private_access_count > private_model_count
  end
end
