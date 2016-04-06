class User < ActiveRecord::Base
  has_many :spaces
  has_one :account, dependent: :destroy

  has_many :memberships, class_name: 'UserOrganizationMembership', dependent: :destroy
  has_many :organizations, through: :memberships

  after_create :create_account
  after_save :identify

  validates_presence_of :username
  validates_presence_of :name
  validates :email, presence: true, format: /@/
  validates :auth0_id, presence: true, uniqueness: true

  enum plan: Plan.as_enum

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

  def identify
    Analytics.identify(
      user_id: id,
      traits: {
        name: name,
        email: email,
        company: company,
        domain_name: domain_name,
        organization_names: organization_names,
        public_model_count: public_model_count,
        private_model_count: private_model_count,
        nodes_per_model: nodes_per_model,
        plan: plan,
        industry: industry,
        role: role,
        gender: gender,
        locale: locale,
        location: location,
        created_at: created_at
      }
    )
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
    return 0 if self.spaces.empty?

    nodes = 0.0
    total = 0.0
    spaces.find_each do |space|
      nodes += space.graph["metrics"].length if space.graph && space.graph["metrics"]
      total += 1
    end
    nodes/total
  end

  def private_model_limit
    plan_details.private_model_limit || 0
  end

  def can_create_private_models
    private_model_limit > private_model_count
  end

  def prefers_private?
    # TODO(matthew): What happens when a free user joins a paid organization?
    can_create_private_models
  end

  def ensure_account
    account || create_account
  end
end
