class Fact < ActiveRecord::Base
  belongs_to :organization
  has_many :checkpoints, class_name: 'FactCheckpoint', dependent: :destroy

  validates_presence_of :organization, :variable_name, :expression, :simulation
  validates :variable_name,
    uniqueness: {scope: :organization_id},
    format: {with: /\A\w+\Z/}
  validate :fact_has_values, :fact_has_no_errors

  private

  def fact_has_values
    values_present = simulation && simulation['sample'] && simulation['sample']['values'] && simulation['sample']['values'].length > 0
    errors[:base] << 'must have values' unless values_present
  end
  def fact_has_no_errors
    errors_present = simulation && simulation['sample'] && simulation['sample']['errors'] && simulation['sample']['errors'].length > 0
    errors[:base] << 'can not have errors' if errors_present
  end
end
