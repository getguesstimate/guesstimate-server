class Organization < ApplicationRecord
  # TODO make names unique.
  has_many :memberships, class_name: 'UserOrganizationMembership', dependent: :destroy
  has_many :members, through: :memberships, class_name: 'User', source: :user
  has_many :invitations, class_name: 'UserOrganizationInvitation', dependent: :destroy
  has_many :fact_categories, dependent: :destroy
  has_one :account, class_name: 'OrganizationAccount', dependent: :destroy

  has_many :spaces, dependent: :destroy
  has_many :facts, dependent: :destroy

  belongs_to :admin, class_name: 'User'

  validates_presence_of :admin
  validates_presence_of :name
  validates_presence_of :plan
  validates :api_token, length: { minimum: 32 }, if: :api_enabled
  validates :api_token, absence: true, unless: :api_enabled

  after_create :make_admin_member
  after_create :create_account
  after_create :create_trial, if: :needs_trial?

  enum plan: Plan.as_enum

  def plan_details
    Plan.find(plan)
  end

  def prefers_private?
    can_create_private_models?
  end

  def can_create_private_models?
    plan == 'organization_basic_30'
  end

  def intermediate_spaces
    spaces.has_fact_exports
  end

  def valid_api_token?(passed_api_token)
    passed_api_token.present? && api_enabled && api_token == passed_api_token
  end

  def is_member?(user)
    user.present? && user.member_of?(id)
  end

  def can_access?(user, passed_api_token)
    is_member?(user) || valid_api_token?(passed_api_token)
  end

  def enable_api_access!
    return true if api_enabled
    update(api_token: get_secure_token, api_enabled: true)
  end

  def disable_api_access!
    return true unless api_enabled
    update(api_token: nil, api_enabled: false)
  end

  def rotate_api_token!
    update(api_token: get_secure_token) if api_enabled
  end

  private

  def get_secure_token
    SecureRandom.urlsafe_base64(64, false)
  end

  def create_trial
    account.create_subscription(plan)
  end

  def make_admin_member
    memberships.create user: admin
  end

  def needs_trial?
    plan == 'organization_basic_30'
  end
end
