class Fact < ActiveRecord::Base
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
  validates_presence_of :metric_id, if: :exported_by_space?

  scope :exported_by_space, -> { where.not(exported_space_id: nil) }
  scope :imported_by_space, -> (space) { where('id IN (?)', space.imported_fact_ids) }

  after_create :increment_exported_from_count, if: :exported_by_space?
  after_destroy :decrement_exported_from_count, if: :exported_by_space?

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

  def imported_to_intermediate_space_ids
    imported_to_intermediate_spaces.all.map { |s| s.id }
  end

  def imported_to_intermediate_spaces
    organization.spaces.has_fact_exports.imports_fact(self)
  end

  def editors_by_time
    query = "
      CREATE OR REPLACE FUNCTION array_sort (ANYARRAY)
      RETURNS ANYARRAY LANGUAGE SQL
      AS $$
        SELECT ARRAY(SELECT unnest($1) ORDER BY 1 ASC)
      $$;

      CREATE OR REPLACE FUNCTION time_windows(timestamp[]) RETURNS tsrange[] AS $$
        DECLARE
          s tsrange[] := ARRAY[]::tsrange[];
          running_start timestamp;
          prev timestamp;
          curr timestamp;
        BEGIN

          running_start := $1[1];
          prev := $1[1];
          curr := $1[1];

          FOREACH curr IN ARRAY $1 LOOP
            IF (curr - prev > INTERVAL '15 minutes') THEN
              s := s || tsrange(running_start, prev, '[]');
              running_start := curr;
            END IF;

            prev := curr;
          END LOOP;

          s := s || tsrange(running_start, curr, '[]');

          RETURN s;
        END;
      $$ LANGUAGE plpgsql;

      SELECT
        author_id,
        fact_id,
        UNNEST(time_windows(array_sort(created_ats))) AS duration
      FROM (
        SELECT
          author_id,
          fact_id,
          ARRAY_AGG(created_at) AS created_ats
        FROM
          fact_checkpoints
        WHERE author_id IS NOT NULL AND fact_id = #{id}
        GROUP BY author_id, fact_id
      ) AS t1
    "
    editing_sessions = ActiveRecord::Base.connection.execute(query).to_a

    editing_stats = {}
    editing_sessions.each do |session|
      user_id = session['author_id'].to_i
      time_range = session['duration'].slice(1, session['duration'].length - 2).split(',').map{|s| DateTime.parse s.slice(1, s.length - 2)}
      duration = (time_range[1] - time_range[0]).days
      curr_data = editing_stats[user_id]
      editing_stats[user_id] = {
        duration: (curr_data.present? ? curr_data[:duration] : 0.seconds) + (duration > 0 ? duration : 30.seconds),
        num_sessions: (curr_data.present? ? curr_data[:num_sessions] : 0) + 1,
      }
    end

    editing_stats_arr = editing_stats.map { |k, v| {user_id: k, duration: v[:duration], num_sessions: v[:num_sessions] } }
    editing_stats_arr.sort { |x, y| y[:duration] <=> x[:duration] }
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
