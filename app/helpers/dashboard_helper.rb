module DashboardHelper
  
  def monthly_activity_chart(activities)
    activities = activities.sort_by(&:posted_time)
    start_date = activities.first.posted_time.to_date
    end_date = activities.last.posted_time.to_date
    grouped_activities = activities.group_by { |activity| 
      activity.posted_time.to_time.to_date
    }
    result = []
    (start_date..end_date).each do |day|
      result.push [day.to_s, grouped_activities[day].try(:length) || 0]
    end
    raw result
  end
  
  def sparkline_activity_chart(activities, start_date=nil, end_date=nil, bundle_index=0)
    result = []
    unless activities.empty?
      activities = activities.sort_by(&:posted_time)
      start_date = activities.first.posted_time.to_date if start_date.nil?
      end_date = activities.last.posted_time.to_date if end_date.nil?
      grouped_activities = activities.group_by { |activity| 
        activity.posted_time.to_date
      }    
      (start_date..end_date).each_with_index do |day, index|
        result.push [index, bundle_index, grouped_activities[day].try(:length) || 0]
      end
    else
      result.push [0, 0, 1]
    end
    result
  end
      
  def target_cloud(targets, classes)
    return [] if targets.empty?

    max_count = targets.sort_by{|target| target.last.size}.last.last.count.to_f

    targets.each do |target|
      index = ((target.last.size / max_count) * (classes.size - 1)).round
      yield target.first, target.last.size, classes[index]
    end
  end
  
end
