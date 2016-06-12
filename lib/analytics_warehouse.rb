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

  #The select below filters for integers only
  #As opposed to faulty urls like '%3CA%20href='
  def view_count(limit)
    counts = @connection.exec(view_count_SQL(limit))
    counts.to_a
      .select{|e| e['substring'].to_i.to_s == e['substring'].to_s}
      .map{|e| [e['substring'].to_i, e['views'].to_i]}
      .to_h
  end

  def view_count_SQL(limit)
    "
      SELECT
        SUBSTRING(path, 9, 20),
        COUNT(*) AS Views
      FROM guesstimate_production.pages
      WHERE path LIKE '%models/%'
      AND path NOT LIKE '%/embed'
      AND path NOT LIKE '%/models/new'
      GROUP BY path
      ORDER BY views DESC
      LIMIT #{limit};
    "
  end
end
