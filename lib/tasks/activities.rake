if Rails.env.production?
  ADMIN_USER_IDS = [1, 295]
else
  ADMIN_USER_IDS = [12]
end

namespace :activities do
  desc "Convert URI object_types and verbs to slug"
  task :convert_uris_to_slugs => :environment do
    Activity.find_each do |activity|
      activity.object.object_type = activity.object.object_type.split('/').last if activity.object.present?
      activity.target.object_type = activity.target.object_type.split('/').last if activity.target.present?
      activity.verb = activity.verb.split('/').last
      activity.save
    end
  end
  
  desc "Create aggregations"
  task 'aggregations:create' => :environment do

    User.where('users.id >= 179').each do |the_user|
      if the_user.activities.exists?
        
        the_user.active_apps.find_each do |app|
          app.add_aggregation!(the_user.id)
        end
    
        the_user.activities.find_each do |activity|
          activity.add_aggregation! unless activity.aggregations.exists? or activity.verb == 'update'
        end
        
        the_user.notifications.find_each do |notification|
          notification.add_aggregation! unless notification.aggregations.exists?
        end
        
      end
    end
  end
  
  task 'aggregations:destroy' => :environment do
    Aggregation.destroy_all
  end
  
end
