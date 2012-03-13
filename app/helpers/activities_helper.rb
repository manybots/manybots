module ActivitiesHelper
  def activities_to_calendar(activity)
    json = "["
      #for activity in activities
        event = "{
          'event': '#{escape_javascript activity.title}',
          'description': '#{raw escape_javascript(render(activity))}',
          'id': '#{activity.id}',
          'start': '#{activity.posted_time.xmlschema}',
          'end': '#{activity.posted_time.xmlschema}'
        }"
        json << event
      #end
    json << "]"
    return json
  end
end
