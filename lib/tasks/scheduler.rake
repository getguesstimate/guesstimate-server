desc 'This task takes screenshots of any spaces that need them.'
task take_snapshots: :environment do
  spaces = Space.is_public.where('updated_at > snapshot_timestamp OR snapshot_timestamp IS NULL')
  puts "Taking snapshots of #{spaces.count} #{'space'.pluralize spaces.count}"
  spaces.find_each do |space|
    space.take_snapshot
    while (Thread.list.count > 10)
      sleep 0.01
    end
  end
end
