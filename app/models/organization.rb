class Organization < ActiveRecord::Base
  has_many :memberships, class_name: 'UserOrganizationMembership', dependent: :destroy
  has_many :members, through: :memberships, class_name: 'User', source: :user
  has_many :invitations, class_name: 'UserOrganizationInvitation', dependent: :destroy
  has_one :account, class_name: 'OrganizationAccount', dependent: :destroy

  has_many :spaces, dependent: :destroy
  has_many :facts, dependent: :destroy

  belongs_to :admin, class_name: 'User'

  validates_presence_of :admin
  validates_presence_of :name
  validates_presence_of :plan

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
    plan == 'organization_basic'
  end

  private

  def create_trial
    account.create_subscription(plan)
  end

  def make_admin_member
    memberships.create user: admin
  end

  def needs_trial?
    plan == 'organization_basic'
  end
end
