desc "Export Activities to MongoDB Items export"
task "mongodb:export:activities" => :environment do
  
  activity_count = Activity.count
  puts "Migrating #{activity_count} activities"
  
  start_time = Time.now
  Activity.find_each do |activity|
    Item.create activity.as_item
  end
  
  puts "Migrated #{Item.count} activities in #{(Time.now.to_i - start_time.to_i).to_f / 60.0} minutes"
  
end
