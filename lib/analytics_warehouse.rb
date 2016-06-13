require 'pg'

PARAMS = Rails.application.secrets.analytics_database

class AnalyticsWarehouse
  attr_accessor :connection

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
end
