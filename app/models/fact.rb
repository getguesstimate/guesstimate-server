class Fact < ActiveRecord::Base
  belongs_to :organization
  belongs_to :defining_space, class_name: 'Space'

  has_many :checkpoints, class_name: 'FactCheckpoint', dependent: :destroy

  validates_presence_of :organization, :variable_name, :simulation
  validates :variable_name,
    uniqueness: {scope: :organization_id},
    format: {with: /\A\w+\Z/}
  validate :fact_has_values, :fact_has_no_errors, :fact_has_stats, unless: :defined_by_space?
  validates_presence_of :expression, unless: :defined_by_space?
  validates_presence_of :metric_id, if: :defined_by_space?

  scope :defined_by_space, -> { where.not(defining_space_id: nil) }

  CHECKPOINT_LIMIT = 1000

  def take_checkpoint(author)
    checkpoint = checkpoints.create(
      author: author,
      simulation: simulation,
      name: name,
      variable_name: variable_name,
      expression: expression,
    )
    num_checkpoints = checkpoints.count
    if num_checkpoints > CHECKPOINT_LIMIT
      checkpoints.order('created_at').limit(num_checkpoints - CHECKPOINT_LIMIT).destroy_all
    end
    return checkpoint
  end

  def dependent_fact_defining_spaces
    organization.spaces.defines_fact.uses_fact(self)
  end

  private

  def defined_by_space?
    return defining_space_id.present?
  end

  def fact_has_stats
    stats = simulation && simulation['stats']
    stats_present_and_valid = stats && (
      stats['length'].to_i == 1 || (stats['percentiles'] && stats['percentiles']['5'] && stats['percentiles']['95'])
    )
    errors[:base] << 'must have stats' unless stats_present_and_valid
  end
  def fact_has_values
    values_present = simulation && simulation['sample'] && simulation['sample']['values'] && simulation['sample']['values'].length > 0
    errors[:base] << 'must have values' unless values_present
  end
  def fact_has_no_errors
    errors_present = simulation && simulation['sample'] && simulation['sample']['errors'] && simulation['sample']['errors'].length > 0
    errors[:base] << 'can not have errors' if errors_present
  end
end
