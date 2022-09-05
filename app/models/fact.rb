class Fact < ApplicationRecord
  belongs_to :organization
  belongs_to :exported_from, class_name: 'Space'
  belongs_to :category, class_name: 'FactCategory'

  has_many :checkpoints, class_name: 'FactCheckpoint', dependent: :destroy

  validates_presence_of :organization, :variable_name, :simulation
  validates :variable_name,
    uniqueness: {scope: :organization_id},
    format: {with: /\A\w+\Z/}
  validate :fact_has_values, :fact_has_no_errors, :fact_has_stats, unless: :exported_by_space?
  validates_presence_of :expression, unless: :exported_by_space?
  validates :metric_id,
    presence: true,
    uniqueness: {scope: :exported_from_id},
    if: :exported_by_space?

  scope :exported_by_space, -> { where.not(exported_space_id: nil) }
  scope :imported_by_space, -> (space) { where('id IN (?)', space.imported_fact_ids) }

  after_create :increment_exported_from_count, if: :exported_by_space?
  after_destroy :decrement_exported_from_count, if: :exported_by_space?

  CHECKPOINT_LIMIT = 1000

  def take_checkpoint(author, by_api)
    checkpoint = checkpoints.create(
      author: author,
      by_api: by_api,
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

  def imported_to_intermediate_space_ids
    imported_to_intermediate_spaces.all.map { |s| s.id }
  end

  def imported_to_intermediate_spaces
    organization.spaces.has_fact_exports.imports_fact(self)
  end

  private

  def exported_by_space?
    return exported_from_id.present?
  end

  def increment_exported_from_count
    exported_from.increment_exported_facts_count!
  end

  def decrement_exported_from_count
    exported_from.decrement_exported_facts_count!
  end

  def fact_has_stats
    stats = simulation && simulation['stats']
    stats_present_and_valid = stats && (
      stats['length'].to_i == 1 || (stats['percentiles'] && stats['percentiles']['5'] && stats['percentiles']['95'])
    )
    errors.add(:base, 'must have stats') unless stats_present_and_valid
  end
  def fact_has_values
    values_present = simulation && simulation['sample'] && simulation['sample']['values'] && simulation['sample']['values'].length > 0
    errors.add(:base, 'must have values') unless values_present
  end
  def fact_has_no_errors
    errors_present = simulation && simulation['sample'] && simulation['sample']['errors'] && simulation['sample']['errors'].length > 0
    errors.add(:base, 'can not have errors') if errors_present
  end
end
