class Fact < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
  validates :user_id, presence: true

  validates_presence_of :name, :readableId, :input

  def owner
    belongs_to_organization? ? organization : user
  end

  def belongs_to_organization?
    !!organization_id
  end
end
