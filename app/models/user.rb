class User < ActiveRecord::Base
  has_many :permissions, class_name: "UserSpacePermission", dependent: :destroy
  has_many :spaces, through: :permissions
  has_many :ownerships, -> { own }, class_name: "UserSpacePermission"
  has_many :owned_spaces, through: :ownerships, source: "space"

  has_many :created_spaces, class_name: "Space", foreign_key: "creator_id"

  has_one :account, dependent: :destroy

  after_create :create_account

  validates_uniqueness_of :username, allow_blank: true
  validates :auth0_id, presence: true, uniqueness: true

  enum plan: Plan.as_enum

  def plan_details
    Plan.find(plan)
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
    plan_details.private_model_limit || 0
  end

  def can_create_private_models
    private_model_limit > private_model_count
  end

  def prefers_private?
    can_create_private_models
  end

  def ensure_account
    account || create_account
  end
end
