class Intensity
  include MongoMapper::Document
  safe

  key :user_id,               String
  key :person_id,             String
  key :name,                  String
  key :genre,                 String
  key :intensity,             Float
  key :start_date,            Integer
  key :end_date,              Integer
  
  INTENSITY_POINTS = {
    'email' => { # 18%
      'send' => 10,
      'receive' => 8
    },
    'phone-call' => { # 65%
      'start' => 20,
      'receive' => 15,
      'fail' => 10,
      'miss' => 20,
    },
    'sms' => { # 27%
      'send' => 15,
      'receive' => 12
    }
  }
  
  def self.calculate_for_person_and_genre(person, genre, between=nil)
    intensity = find_or_create_by_person_id_and_genre(person.id, genre)
    intensity.name = person.name
    intensity.update_for_person(between)
  end
    
  def person
    @person ||= Person.find(person_id)
  end
  
  def update_for_person(between=nil)
    puts name
    # get all the activities for the person
    activities = person.all_activities.fields([:published_epoch, :object, :verb])
    if between and between.is_a? Array
      activities = activities.between(between.first.to_i, between.last.to_i)
    end
    activities = activities.all
    return if activities.empty?
    puts activities.count
    # calculate rythm and volume
    volume = calc_volume(activities)
    rythm = calc_rythm(activities)
    puts volume
    puts rythm
    # get the intensity value
    intensity_calc = (rythm.to_f / volume.to_f) * 100
    puts intensity_calc
    # use a base 10 logarithm to flatten the curve
    intensity_log = Math.log2 intensity_calc
    puts intensity_log
    # save the calculation for this person unless the number is discarded
    start_date = between.first.to_i rescue(nil)
    end_date = between.last.to_i rescue(nil)
    intensity = intensity_log.to_s == "NaN" ? 0 : intensity_log
  end
    
  def calc_volume(activities)
    points = activities.collect do |activity| 
      object_type = activity.object['objectType']
      verb = activity['verb']
      duration = activity.object[duration].to_i if object_type == 'phone-call'
      score = 0
      if INTENSITY_POINTS[object_type].nil?
        score
      else
        score += INTENSITY_POINTS[object_type][verb]
        score += (duration.to_f * INTENSITY_POINTS[object_type][verb] / 100 ).to_f if duration
        score
      end
    end.sum
    activities.count.to_f + points.to_f
  end
  
  def calc_rythm(activities)
    dates = activities.reverse.collect(&:published_epoch)
    previous = dates.first
    first = dates.last
    proximity = (Time.now.to_i - first) / 60 / 60 / 24
    distances = dates.collect {|date|
      rslt = date - previous
      previous = date
      rslt
    }.sum
    average_distance = (distances.to_f / dates.length.to_f) / 60 / 60 / 24
    average_distance = average_distance.abs
    average_distance + proximity
  end
  
end
