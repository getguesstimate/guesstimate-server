require 'pg'

PARAMS = Rails.application.secrets.analytics_database

class TableGenerator
  attr_accessor :schema, :columns

  def initialize(params)
    @schema = params[:schema]
    @columns = params[:columns]
    @model = params[:model]
    @sqlFn = params[:sqlFn]
  end

  def getData(prev_updated_at_date)
    return ActiveRecord::Base.connection.execute getSql(prev_updated_at_date)
  end

  private
  def getSql(prev_updated_at_date)
    return @sqlFn.call prev_updated_at_date if @sqlFn.present?

    return @model\
      .where('updated_at > ?', prev_updated_at_date)\
      .select(@columns)\
      .to_sql
  end
end

class AnalyticsWarehouse
  attr_accessor :connection

  USER_DIMS = ['id', 'company', 'role', 'industry', 'categorized', 'gender', 'locale', 'location', 'created_at', 'plan']
  USER_MEMBERSHIP_DIMS = ['organization_ids']
  ORGANIZATION_DIMS = ['id', 'name', 'plan', 'admin_id', 'created_at']
  ORGANIZATION_MEMBERSHIP_DIMS = ['member_ids']

  def self.user_dimensions_table_select
    user_dims = USER_DIMS.collect { |dim| "users.#{dim} AS #{dim}" }.join(',')
    membership_dims = USER_MEMBERSHIP_DIMS.collect { |dim| "memberships.#{dim} AS #{dim}" }.join(',')
    return "#{user_dims},#{membership_dims},GREATEST(users.updated_at, memberships.updated_at) AS updated_at"
  end

  def self.user_memberships_query
    UserOrganizationMembership\
      .select('user_id, MAX(updated_at) AS updated_at, ARRAY_AGG(organization_id) AS organization_ids')\
      .group(:user_id)
  end

  def self.local_user_dimensions_table_sql(prev_updated_at_date = DateTime.new(2015))
    User\
      .joins("LEFT OUTER JOIN (#{user_memberships_query.to_sql}) AS memberships ON memberships.user_id = users.id")\
      .where('users.updated_at > ? OR memberships.updated_at > ?', prev_updated_at_date, prev_updated_at_date)\
      .select(user_dimensions_table_select)\
      .to_sql
  end

  def self.organization_dimensions_table_select
    organization_dims = ORGANIZATION_DIMS.collect { |dim| "organizations.#{dim} AS #{dim}" }.join(',')
    membership_dims = ORGANIZATION_MEMBERSHIP_DIMS.collect { |dim| "memberships.#{dim} AS #{dim}" }.join(',')
    return "#{organization_dims},#{membership_dims},GREATEST(organizations.updated_at, memberships.updated_at) AS updated_at"
  end

  def self.organization_memberships_query
    UserOrganizationMembership\
      .select('organization_id, MAX(updated_at) AS updated_at, ARRAY_AGG(user_id) AS member_ids')\
      .group(:organization_id)
  end

  def self.local_organization_dimensions_table_sql(prev_updated_at_date = DateTime.new(2015))
    Organization\
      .joins("LEFT OUTER JOIN (#{organization_memberships_query.to_sql}) AS memberships ON memberships.organization_id = organizations.id")\
      .where('organizations.updated_at > ? OR memberships.updated_at > ?', prev_updated_at_date, prev_updated_at_date)\
      .select(organization_dimensions_table_select)\
      .to_sql
  end

  # TODO(matthew): SQL Injection worries?
  def self.edits_table_sql(prev_updated_at_date = DateTime.new(2015))
    "
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
        space_id,
        UNNEST(time_windows(array_sort(created_ats))) AS duration
      FROM (
        SELECT
          author_id,
          space_id,
          ARRAY_AGG(created_at) AS created_ats
        FROM
          space_checkpoints
        WHERE created_at > TIMESTAMP '#{prev_updated_at_date}'
        GROUP BY author_id, space_id
      ) AS t1
    "
  end

  TABLES = {
    user_dimensions: TableGenerator.new(
      schema: "
        id int,
        organization_ids int[],
        plan int,
        company text,
        industry text,
        role text,
        categorized bool,
        gender text,
        locale text,
        location text,
        created_at timestamp,
        updated_at timestamp,
        PRIMARY KEY(id)
      ",
      columns: "#{USER_DIMS.join(',')},#{USER_MEMBERSHIP_DIMS.join(',')},updated_at",
      sqlFn: lambda { |prev_updated_at_date| AnalyticsWarehouse::local_user_dimensions_table_sql(prev_updated_at_date) }
    ),
    organization_dimensions: TableGenerator.new(
      schema: "
        id int,
        member_ids int[],
        admin_id int,
        plan int,
        name text,
        created_at timestamp,
        updated_at timestamp,
        PRIMARY KEY(id)
      ",
      columns: "#{ORGANIZATION_DIMS.join(',')},#{ORGANIZATION_MEMBERSHIP_DIMS.join(',')},updated_at",
      sqlFn: lambda { |prev_updated_at_date| AnalyticsWarehouse::local_organization_dimensions_table_sql(prev_updated_at_date) }
    ),
    space_dimensions: TableGenerator.new(
      schema: "
        id int,
        organization_id int,
        user_id int,
        category text,
        categorized bool,
        created_at timestamp,
        updated_at timestamp,
        PRIMARY KEY(id)
      ",
      columns: 'id,organization_id,user_id,category,categorized,created_at,updated_at',
      model: Space
    ),
    edits: TableGenerator.new(
      schema: "
        author_id int,
        space_id int,
        duration tsrange,
        PRIMARY KEY (author_id, space_id, duration)
      ",
      columns: 'author_id, space_id, duration',
      sqlFn: lambda { |prev_updated_at_date| AnalyticsWarehouse::edits_table_sql(prev_updated_at_date) }
    )
  }

  def self.local_sql(query)
    ActiveRecord::Base.connection.execute(query)
  end

  def self.to_pg_csv(res)
    res.to_a.collect {|e| e[1].to_s}.collect {|e| e.starts_with?('{') || e.starts_with?('[') || e.starts_with?('(') ? "\"#{e}\"" : e}.join(',') + "\n"
  end

  def self.update_view_counts!
    instance = self.new()
    view_counts = instance.view_count(10000)
    instance.close()
    puts 'got view_counts'
    puts view_counts

    Space.find_each(batch_size: 100) do |space|
      space_count = view_counts[space.id]
      if space_count
        puts "UPDATING SPACE #{space.id} with count #{space_count}"
        space.update_columns(viewcount: space_count)
      end
    end
  end

  def initialize
    @connection = PG::Connection.open(PARAMS)
  end

  def close
    @connection.close()
  end

  def view_count(limit)
    counts = @connection.exec(view_count_SQL(limit))
    counts.to_a.map{|e| [e['model_id'].to_i, e['views'].to_i]}.to_h
  end

  def view_count_SQL(limit)
    "
      SELECT
        substring(path from 9) AS model_id,
        SUM(1) AS views
      FROM guesstimate_production.pages
      WHERE path SIMILAR TO '/models/\\d+' AND user_id != '240' AND user_id != '1'
      GROUP BY model_id
      LIMIT #{limit};
    "
  end

  def self.full_table_name(name)
    "guesstimate_#{Rails.env}.#{name}"
  end

  def self.create_table_sql(name, schema)
    "CREATE TABLE #{AnalyticsWarehouse::full_table_name name} (#{schema})"
  end

  def self.drop_table_sql(name)
    "DROP TABLE IF EXISTS #{AnalyticsWarehouse::full_table_name name}"
  end

  def reset_table(name)
    return unless AnalyticsWarehouse::TABLES.include? name

    @connection.exec "
      #{AnalyticsWarehouse::drop_table_sql name};
      #{AnalyticsWarehouse::create_table_sql name, AnalyticsWarehouse::TABLES[name].schema};
    "
  end

  def update_table(name, prev_updated_at_date=DateTime.new(2015))
    return unless AnalyticsWarehouse::TABLES.include? name

    copy_cmd = "COPY guesstimate_#{Rails.env}.#{name}(#{AnalyticsWarehouse::TABLES[name].columns}) FROM STDIN CSV"
    data = AnalyticsWarehouse::TABLES[name].getData(prev_updated_at_date)
    @connection.copy_data copy_cmd do
      data.each { |row| @connection.put_copy_data(AnalyticsWarehouse.to_pg_csv(row)) }
    end
  end
end
