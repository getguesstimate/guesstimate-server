class User < ApplicationRecord
  has_many :spaces
  has_one :account, dependent: :destroy
  has_one :account, class_name: 'UserAccount', dependent: :destroy

  has_many :memberships, class_name: 'UserOrganizationMembership', dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :admistrated_organizations, class_name: 'Organization', foreign_key: 'admin_id'

  after_create :create_account
  after_create :accept_invitations
  after_create :set_needs_tutorial

  validates_presence_of :username
  validates_presence_of :name
  validates :email, presence: true, format: /@/, uniqueness: true
  validates :auth0_id, presence: true, uniqueness: true

  enum plan: Plan.as_enum

  scope :uncategorized_since, -> (date) { where 'categorized IS NOT true AND DATE(created_at) >= ?', date }

  def self.from_token_payload payload
    User.where(auth0_id: payload["sub"]).first
  end

  def self.create_from_auth0_user(auth0_user)
    user = User.find_or_initialize_by(email: auth0_user['email'])
    user.name = auth0_user['name']
    user.username = auth0_user['nickname']
    user.email = auth0_user['email']
    user.company = auth0_user['company']
    user.locale = auth0_user['locale']
    user.location = auth0_user['location']
    user.gender = auth0_user['gender']
    user.picture = auth0_user['picture']
    user.auth0_id = auth0_user['user_id']
    user.save
  end

  def plan_details
    Plan.find(plan)
  end

  def member_of?(organization_id)
    memberships.for_organization(organization_id).any?
  end

  def domain_name
    email[/@(?<domain>[^\.]*).(.*)/,"domain"] if email
  end

  def organization_names
    organizations.map(&:name).join(',')
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

  def nodes_per_model
    return 0 if self.spaces.is_public.empty?

    nodes = 0.0
    total = 0.0
    spaces.is_public.find_each do |space|
      nodes += space.graph["metrics"].length if space.graph && space.graph["metrics"]
      total += 1
    end
    nodes/total
  end

  def private_model_limit
    plan_details.private_model_limit || 0
  end

  def can_create_private_models?
    private_model_limit > private_model_count
  end

  def prefers_private?
    # TODO(matthew): What happens when a free user joins a paid organization?
    can_create_private_models?
  end

  def ensure_account
    account || create_account
  end

  def accept_invitations
    UserOrganizationInvitation.for_email(email).find_each do |invitation|
      UserOrganizationMembership.create user: self, organization_id: invitation.organization_id, invitation: invitation
    end
  end

  def set_needs_tutorial
    update_columns needs_tutorial: true
  end
end
