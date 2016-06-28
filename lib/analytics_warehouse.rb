require 'pg'

PARAMS = Rails.application.secrets.analytics_database

class DimensionTableGenerator
  attr_accessor :schema, :columns

  def initialize(schema, columns, model = nil, sql_fn = false)
    @schema = schema
    @columns = columns
  end

  def getData(prev_updated_at_date)
    return ActiveRecord::Base.connection.execute getSql(prev_updated_at_date)
  end

  private
  def getSql(prev_updated_at_date)
    return sql_fn(prev_updated_at_date) if (sql_fn)

    return model\
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

  def user_dimensions_table_select
    user_dims = USER_DIMS.collect { |dim| "users.#{dim} AS #{dim}" }.join(',')
    membership_dims = USER_MEMBERSHIP_DIMS.collect { |dim| "memberships.#{dim} AS #{dim}" }.join(',')
    return "#{user_dims},#{membership_dims},GREATEST(users.updated_at, memberships.updated_at) AS updated_at"
  end

  def user_memberships_query
    UserOrganizationMembership\
      .select('user_id, MAX(updated_at) AS updated_at, ARRAY_AGG(organization_id) AS organization_ids')\
      .group(:user_id)
  end

  def local_user_dimensions_table(prev_updated_at_date = DateTime.new(2015))
    ActiveRecord::Base.connection.execute(
      User\
        .joins("LEFT OUTER JOIN (#{user_memberships_query.to_sql}) AS memberships ON memberships.user_id = users.id")\
        .where('users.updated_at > ? OR memberships.updated_at > ?', prev_updated_at_date, prev_updated_at_date)\
        .select(user_dimensions_table_select)\
        .to_sql
    )
  end

  def organization_dimensions_table_select
    organization_dims = ORGANIZATION_DIMS.collect { |dim| "organizations.#{dim} AS #{dim}" }.join(',')
    membership_dims = ORGANIZATION_MEMBERSHIP_DIMS.collect { |dim| "memberships.#{dim} AS #{dim}" }.join(',')
    return "#{organization_dims},#{membership_dims},GREATEST(organizations.updated_at, memberships.updated_at) AS updated_at"
  end

  def organization_memberships_query
    UserOrganizationMembership\
      .select('organization_id, MAX(updated_at) AS updated_at, ARRAY_AGG(user_id) AS user_ids')\
      .group(:organization_id)
  end

  def local_organization_dimensions_table(prev_updated_at_date = DateTime.new(2015))
    ActiveRecord::Base.connection.execute(
      Organization\
        .joins("LEFT OUTER JOIN (#{organization_memberships_query.to_sql}) AS memberships ON memberships.organization_id = organizations.id")\
        .where('organizations.updated_at > ? OR memberships.updated_at > ?', prev_updated_at_date, prev_updated_at_date)\
        .select(organization_dimensions_table_select)\
        .to_sql
    )
  end

  TABLES = {
    user_dimensions: {
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
      sql: '',
    },
    organization_dimensions: {
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
      sql: ''
    },
    space_dimensions: DimensionTableGenerator.new(
      "
        id int,
        organization_id int,
        user_id int,
        category text,
        categorized bool,
        created_at timestamp,
        updated_at timestamp,
        PRIMARY KEY(id)
      ",
      'id,organization_id,user_id,category,categorized,created_at,updated_at',
      Space
    ),
    edits: {
      schema: "
        user_id int,
        space_id int,
        duration tstzrange,
        PRIMARY KEY (user_id, space_id, duration)
      ",
      columns: '',
      sql: ''
    }
  }

  def self.local_sql(query)
    query)
  end

  def self.to_pg_csv(res)
    res.to_a.collect {|e| e[1].to_s}.collect {|e| e.starts_with?('{') ? "\"#{e}\"" : e}.join(',') + "\n"
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

  def create_table_sql(name, schema)
    "CREATE TABLE guesstimate_#{Rails.env}.#{name} (#{schema})"
  end

  def drop_table_sql(name)
    "DROP TABLE guesstimate_#{Rails.env}.#{name}"
  end

  def reset_table(name)
    @connection.exec "#{drop_table_sql name}; #{create_table_sql name, AnalyticsWarehouse::TABLES[name].schema};"
  end

  def update_dimension_table(name, prev_updated_at_date=DateTime.new(2015))
    copy_cmd = "COPY guesstimate_development.#{name}(#{AnalyticsWarehouse::TABLES[name].columns}) FROM STDIN CSV"
    data = AnalyticsWarehouse::TABLES[name].getData(prev_updated_at_date)
    @connection.copy_data copy_cmd do
      data.each { |row| @connection.put_copy_data(AnalyticsWarehouse.to_pg_csv(row)) }
    end
  end
end
