require 'pg'

PARAMS = Rails.application.secrets.analytics_database
USER_DIMS = ['id', 'company', 'role', 'industry', 'categorized', 'gender', 'locale', 'location', 'created_at', 'plan']
MEMBERSHIP_DIMS = ['organization_ids']


class AnalyticsWarehouse
  attr_accessor :connection

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

  def create_user_dimensions_table_sql
    "CREATE TABLE guesstimate_#{Rails.env}.user_dimensions (
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
      );"
  end

  def user_dimensions_table_columns
    user_dims = USER_DIMS.collect { |dim| "users.#{dim} AS #{dim}" }
    membership_dims = MEMBERSHIP_DIMS.collect { |dim| "memberships.#{dim} AS #{dim}" }
    return "#{user_dims.join(',')},#{membership_dims.join(',')},GREATEST(users.updated_at, memberships.updated_at) AS updated_at"
  end

  def memberships_query
    UserOrganizationMembership\
      .select('user_id, MAX(updated_at) AS updated_at, ARRAY_AGG(organization_id) AS organization_ids')\
      .group(:user_id)\
  end

  def local_user_dimensions_table_sql(prev_updated_at_date = DateTime.new(2015))
    User\
      .joins("LEFT OUTER JOIN (#{memberships_query.to_sql}) AS memberships ON memberships.user_id = users.id")\
      .where('users.updated_at > ? OR memberships.updated_at > ?', prev_updated_at_date, prev_updated_at_date)\
      .select(user_dimensions_table_columns)\
      .to_sql
  end

  def local_user_dimensions_table(prev_updated_at_date = DateTime.new(2015))
    ActiveRecord::Base.connection.execute(local_user_dimensions_table_sql(prev_updated_at_date))
  end

  def drop_user_dimensions_table_sql
    "DROP TABLE guesstimate_#{Rails.env}.user_dimensions;"
  end

  def reset_user_dimensions_table
    @connection.exec drop_user_dimensions_table_sql + create_user_dimensions_table_sql
  end

  def update_user_dimensions_table
    copy_cmd = "COPY guesstimate_development.user_dimensions(#{USER_DIMS.join(',')},#{MEMBERSHIP_DIMS.join(',')},updated_at) FROM STDIN CSV"
    data = local_user_dimensions_table
    @connection.copy_data copy_cmd do
      data.each { |row| @connection.put_copy_data(AnalyticsWarehouse.to_pg_csv(row)) }
    end
  end
end
