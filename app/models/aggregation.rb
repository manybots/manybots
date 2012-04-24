class Aggregation < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :notifications
  has_and_belongs_to_many :predictions
  
  def self.match(aggregation_params)
    if aggregation_params.match '\+'
      @match = 'reunion'
      @match_symbol = '+'
      params_id = aggregation_params.split('+').collect(&:to_i).flatten
    elsif aggregation_params.match '&'
      @match = 'intersection'
      @match_symbol = '&'
      params_id = aggregation_params.split('&').collect(&:to_i).flatten
    else
      params_id = [aggregation_params]
    end
    self.where(id: params_id)
  end
  
  
  def self.bundled_activities(user_id, aggregation_ids)
    a0 = Arel::Table.new(:activities_aggregations)
    bundles = []
    aggregation_ids.each_with_index do |ag, i|
      unless i == 0
        bundles.push a0.alias(i)
      end
    end
    acts = Arel::Table.new(:activities)
    query = a0.project('*')
    bundles.each do |bundle|
      query = query.join(bundle).on(a0[:activity_id].eq(bundle[:activity_id]))
    end
    query = query.join(acts).on(a0[:activity_id].eq(acts[:id]))
    query = query.where(a0[:aggregation_id].eq(aggregation_ids.first.to_i))        
    aggregation_ids.each_with_index do |ag, i|
      unless i == 0
        query = query.where(bundles[i-1][:aggregation_id].eq(ag.to_i))
      end
    end
    query = query.where(acts[:user_id].eq(user_id)).
      order(acts[:posted_time].desc)
    
    query
  end
  
  def self.recalculate_totals!
    Aggregation.find_each do |ag|
      ag.update_attribute :total, (ag.activities.count + ag.notifications.count)
      ag.destroy if ag.total <= 0
    end
  end
  
  def self.aggregates_for_intersection(aggregation_ids)
    bundles = []
    a0 = Arel::Table.new(:activities_aggregations)
    a1 = a0.alias
    aggregation_ids.each_with_index do |ag, i|
      unless i == 0
        bundles.push a0.alias(i)
      end
    end
    a2 = Arel::Table.new(:activities)
    a3 = Arel::Table.new(:aggregations)
    query = a0.project('DISTINCT(aggregations.id), aggregations.name, aggregations.type_string, aggregations.total')
  
    bundles.each do |bundle|
      query = query.join(bundle).on(a0[:activity_id].eq(bundle[:activity_id]))
    end
    query = query.join(a2).on(a0[:activity_id].eq(a2[:id]))
    query = query.join(a1).on(a0[:activity_id].eq(a1[:activity_id]))
    query = query.join(a3).on(a1[:aggregation_id].eq(a3[:id]))
    #query = query.where(a2[:user_id].eq(current_user.id))
    query = query.where(a0[:aggregation_id].in(aggregation_ids.first))
    aggregation_ids.each_with_index do |ag, i|
      unless i == 0
        query = query.where(bundles[i-1][:aggregation_id].eq(ag.to_i))
      end
    end
    query = query.where(a3[:id].in(aggregation_ids).not)
    query = query.order('aggregations.type_string DESC, aggregations.total DESC, aggregations.name DESC, aggregations.id DESC')
  
    Aggregation.find_by_sql(query.to_sql)
  end
  
  def self.new_bundle(aggregrations, name="Bundle")
    aggregration_ids = aggregrations.collect(&:id).join('&')
    this = self.new
    this.path = aggregration_ids
    this.type_string = 'Bundle'
    this.name = aggregrations.collect(&:name).to_sentence
    this
  end
  
  def self.new_date(date)
    reviewed_date = date.to_date
    date_string = "#{reviewed_date.year}/#{reviewed_date.month}/#{reviewed_date.day}"
    this = self.new
    this.path = "/calendar/day/#{date_string}"
    this.type_string = 'Date'
    this.name = date_string
    this
  end
  
  def self.find_aggregations_for_user_and_params(user, params, return_ids=false)
    params = params.first if params.is_a? Array
    
    if params.is_a? Hash
      queries = []
      params.each do |k,v|
        queries.push v if v.present?
      end
    elsif params.is_a? String
      queries = [params]
    end
    
    results = []
    
    queries.each do |query|
      this = Aggregation.where(user_id: user.id).where(object_type: "Activity").where(name:query).first
      results.push this if this
    end
    if return_ids == false
      return results.any? ? [self.new_bundle(results)] : []
    else
      return results.collect(&:id)
    end
  end
  
  
  def to_param
    if self.type_string == 'Bundle'
      self.path #+ '/bundle'
    else
      super
    end
  end
  
  def self.create_all_for_object(obj)
    if obj.is_a? Activity
      object_type = obj.object.object_type if obj.object
      target_type = obj.target.object_type if obj.target
      verb = obj.verb
      user = obj.user
      app = obj.client_application
    else
      object_type = obj.object_type
      target_type = obj.target_type
      verb = obj.verb
      user = obj.user
      app = obj.client_application
    end
    
    ## Add aggregation for developer-specified fields
    raw = YAML::load(obj.payload) rescue(obj.payload)
    if raw 
      if raw[:target].present? 
        if raw[:target][:manybots_search].present? and raw[:target][:manybots_search] != false
          this_type = raw[:target][:objectType]
          display_name = raw[:target][:displayName]
          ag = user.aggregations.find_or_initialize_by_name_and_type_string(display_name, this_type)
          if ag.new_record?
            ag.total = 1
            ag.object_type = obj.class.to_s
          else
            ag.total += 1 if ag
          end
          ag.save
          obj.aggregations << ag if ag
        end
      end
    
      if raw[:object].present? and raw[:object][:manybots_search] == true
        display_name = raw[:object][:displayName]
        ag = user.aggregations.find_or_initialize_by_name_and_type_string(display_name, this_type)
        if ag.new_record?
          ag.total = 1
          ag.object_type = obj.class.to_s
        else
          ag.total += 1 if ag
        end
        ag.save
        obj.aggregations << ag if ag
      end
    end
    ## end developer-specified fields
    
    ## Add aggregation of app
    if app
      ag = user.aggregations.find_or_initialize_by_name_and_type_string(app.name, 'apps')
      if ag.new_record?
        ag.total = 1
        ag.object_type = "ClientApplication"
        ag.path = app.url
        ag.avatar_url = app.app_icon_url
      else
        ag.total += 1 if ag
      end
      ag.save
    end
    obj.aggregations << ag if ag
    
    ## Add aggregation of verb 
    ag = user.aggregations.find_or_initialize_by_name_and_type_string(verb, 'verbs')
    if ag.new_record?
      ag.total = 1
      ag.object_type = obj.class.to_s
    else
      ag.total += 1
    end
    ag.save
    obj.aggregations << ag if ag
  
    ## Add aggregation of object 
    ag = user.aggregations.find_or_initialize_by_name_and_type_string(object_type, 'objects')
    if ag.new_record?
      ag.total = 1
      ag.object_type = obj.class.to_s
    else
      ag.total += 1
    end
    ag.save
    obj.aggregations << ag if ag
  
    ## Add aggregation of target 
    if target_type
      ag = user.aggregations.find_or_initialize_by_name_and_type_string(target_type, 'objects')
      if ag.new_record?
        ag.total = 1
        ag.object_type = obj.class.to_s
      else
        ag.total += 1
      end
      ag.save
      obj.aggregations << ag if ag
    end

    ## Start aggregation of people for activity
    if obj.is_a? Activity
      people = []
      if object_type == 'person'
        people.push 'object'
      end
      if target_type == 'person'
        people.push 'target'
      end
      if object_type == 'group'
        people.push 'group-in-object'
      end
      if target_type == 'group' 
        people.push 'group-in-target'
      end
  
      if people.any?
        for peeps in people
          if peeps.match 'group'
            grouped = case peeps
            when 'group-in-target'
              obj.exotic_payload(:target).collect{ |l| l[:attachments] }.flatten.compact
            when 'group-in-object'
              obj.exotic_payload(:object).collect{ |l| l[:attachments] }.flatten.compact
            end
            grouped.each do |person|
              logger.info person.inspect
              ag = user.aggregations.find_or_initialize_by_name_and_type_string(person["displayName"], 'people')
              if ag.new_record?
                ag.total = 1
                ag.object_type = "Person"
              else
                ag.total += 1
              end
              ag.save
              obj.aggregations << ag
            end
          else
            person = obj.send(peeps).title
            ag = user.aggregations.find_or_initialize_by_name_and_type_string(person, 'people')
            if ag.new_record?
              ag.total = 1
              ag.object_type = "Person"
            else
              ag.total += 1
            end
            ag.save
            obj.aggregations << ag
          end
        end
      end
      ## End aggregation of people for activity
    else
      # Start aggregation of people for notifications and predictions
      people = []
      if object_type == 'person'
        people.push obj.object_name
      end
      if target_type == 'person'
        people.push obj.target_name
      end
      if obj.actor_type == 'person'
        people.push obj.actor_name
      end

      if people.any?
        for peeps in people
          person = peeps
          ag = user.aggregations.find_or_initialize_by_name_and_type_string(person, 'people')
          if ag.new_record?
            ag.total = 1
            ag.object_type = "Person"
          else
            ag.total += 1
          end
          ag.save
          obj.aggregations << ag
        end
      end
      # End aggregation of people for notifications and predictions
    end
    ## End aggregation of people
    
  end
  ## End add all aggregations
  
  end
