class Organization < ActiveRecord::Base
  has_many :memberships, class_name: 'UserOrganizationMembership', dependent: :destroy
  has_many :members, through: :memberships, class_name: 'User', source: :user
  has_many :invitations, class_name: 'UserOrganizationInvitation', dependent: :destroy
  has_one :account, class_name: 'OrganizationAccount', dependent: :destroy

  has_many :spaces, dependent: :destroy

  belongs_to :admin, class_name: 'User'

  validates_presence_of :admin
  validates_presence_of :name
  validates_presence_of :plan
  validates_uniqueness_of :name

  after_create :make_admin_member
  after_create :create_account
  after_create :create_trial

  enum plan: Plan.as_enum

  def prefers_private?
    true
  end

  def plan_details
    Plan.find(plan)
  end

  def create_trial
    if self[:plan] == 6
      account.create_subscription(plan)
    end
  end

  private
  def make_admin_member
    memberships.create user: admin
  end
end
