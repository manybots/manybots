class Activity < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = ManybotsServer.host
  
  acts_as_taggable
  
  attr_accessible :user
  attr_accessible :url_id, :posted_time, :verb, :title, :summary, :lang
  attr_accessible :actor_attributes, :target_attributes, :object_attributes
  attr_accessible :generator_url, :generator_title
  attr_accessible :service_provider_icon, :service_provider_name, :service_provider_uri
  attr_accessible :tags, :tag_list
  #attr_accessible :generator, :permalinkUrl, :object, :actor, :application, :target, :serviceProvider

  has_many :activity_objects, :dependent => :destroy

  has_one :actor
  has_one :object, :class_name => 'Obj'
  has_one :target
  has_many :predictions, :as => :predictable
  
  has_and_belongs_to_many :aggregations

  belongs_to :user
  belongs_to :client_application
  
  scope :oldest, lambda {
    select('posted_time').order('posted_time ASC').limit(1)
  }
  scope :latest, lambda {
    select('posted_time').order('posted_time DESC').limit(1)
  }
  
  scope :timeline, lambda {
    order('activities.posted_time DESC')
  }
  
  scope :reverse, :order => 'created_at DESC'
  scope :are_public, :conditions => {:is_public => true}
  scope :filter_advanced,     lambda{ |options|
      where, arguments = [], []
      objs = []
      if Rails.env.development? 
        cols = "activities.id"
      else
        cols = Activity.column_names.reverse.collect {|c| "activities.#{c}"}.join(",")
      end
      
      # actor as user
      where << "activities.user_id IN (?)" and 
        arguments << options[:actors] if 
          options[:actors].present?

      # verbs
      where << "activities.verb IN (?)" and 
        arguments << options[:verbs] if 
          options[:verbs].present?
      
      # object-types
      objs << "(activity_objects.type='Obj' AND activity_objects.object_type = ?)" and 
        arguments << options[:objects] if 
          options[:objects].present?
      
      # targets
      objs << "(activity_objects.type='Target' AND activity_objects.object_type = ?)" and 
        arguments << options[:targets] if 
          options[:targets].present?
      objs << "(activity_objects.type = 'Target' AND activity_objects.title = ?)" and 
        arguments << options[:target_values] if 
          options[:target_values].present?
      
      where << objs.join(" OR ") unless objs.empty?
      
      { :joins => [:activity_objects], :conditions => [where.join(" AND "), *arguments], :group => "#{cols}" }
  }
  
  # scope :filter_advanced, lambda { |options| 
  #   self. }

  validates_presence_of   :actor
  validates_presence_of   :verb
  validates_presence_of   :object
  validates_presence_of   :posted_time

  validates_uniqueness_of :url_id, :scope => [:user_id, :client_application_id], :allow_nil => true, :allow_blank => true
  
  after_create  :add_aggregation!
  after_create  :create_item
  after_create  :create_prediction  
  before_destroy :remove_aggregation!

  accepts_nested_attributes_for :actor, :object, :target, :reject_if => proc { |p| p['url_id'].blank? }, :allow_destroy => true
  
  def self.between(start, finish)
    if start and finish
      if start.is_a? String or start.is_a? Integer
        start =  ActiveSupport::TimeZone.new('UTC').parse Time.at(start.to_i).to_s(:db)
        finish =  ActiveSupport::TimeZone.new('UTC').parse Time.at(finish.to_i).to_s(:db)
        logger.info "String"
        logger.info start
        logger.info finish
      else
        start = Time.at(start.to_i)
        finish = Time.at(finish.to_i)
        logger.info "Time or Date"
        logger.info start.utc
        logger.info finish.utc
      end
      where('activities.posted_time >= ? and activities.posted_time <= ?', start, finish).scoped 
    else
      scoped
    end
  end
  
  def self.new_advanced_filter(user_id, options, start=nil, finish=nil, output=nil)
    
    activities = self.where(:user_id => user_id).select('activities.id').scoped
    
    if options[:start_date].present? and options[:end_date].present?
      activities = activities.between(options[:start_date], options[:end_date]).scoped
    elsif options[:selected_month].present? and options[:selected_year].present?
      activities = activities.between(options[:selected_month], options[:selected_year]).scoped
    else
      activities = activities.between(start, finish).scoped
    end
    
    if options[:verbs].present?
      activities_ids = activities = activities.where('verb' => options[:verbs]).scoped
    end
    
    activities_ids = activities.collect(&:id)
    
    if options[:objects].present?
      objects = activities.joins(:activity_objects).where('activity_objects.type' => 'Obj').select('activity_objects.activity_id').scoped
      objects = objects.where('activity_objects.object_type' => options[:objects]).scoped
      activities_ids = objects.collect(&:id)
    end
    
    if options[:targets].present?
      targets = activities.joins(:activity_objects).where('activity_objects.type' => 'Target').select('activity_objects.activity_id').scoped
      targets = targets.where('activity_objects.object_type' => options[:targets]).scoped
      activities_ids = targets.collect(&:id)
    end
    
    if options[:target_values].present?
      target_values = ActivityObject.where(:type => 'Target').where(:activity_id => activities_ids).select('activity_id').scoped
      target_values = target_values.where('activity_objects.title' => options[:target_values]).scoped
      activities_ids = target_values.collect(&:activity_id)
    end
    
    activities = self.where(:id => activities_ids).scoped
    if output.present?
      return activities.select(output).scoped
    else
      return activities.scoped
    end
  end

  def self.verbs_to_select
    [
      ['POST', "http://activitystrea.ms/schema/1.0/post"],
      ['FAVORITE', "http://activitystrea.ms/schema/1.0/favorite"],
      ['FOLLOW', 'http://activitystrea.ms/schema/1.0/follow'],
      ['LIKE', 'http://activitystrea.ms/schema/1.0/like'],
      ['MAKE-FRIEND', 'http://activitystrea.ms/schema/1.0/make-friend'],
      ['JOIN', 'http://activitystrea.ms/schema/1.0/join'],
      ['PLAY', 'http://activitystrea.ms/schema/1.0/play'],
      ['SAVE', 'http://activitystrea.ms/schema/1.0/save'],
      ['SHARE', 'http://activitystrea.ms/schema/1.0/share'],
      ['TAG', 'http://activitystrea.ms/schema/1.0/tag'],
      ['UPDATE', 'http://activitystrea.ms/schema/1.0/update']
    ]
  end
  
  def self.to_calendar(activities)
    json = []
    activities.each do |activity|
      event = {}
      event[:title] = "#{activity.verb_title.to_s} a #{activity.object_title.to_s}"
      event[:title] << " in #{activity.target.title.to_s}" if activity.target
      event[:title] << ": #{activity.summary.to_s}" unless activity.summary.nil? or activity.summary.blank?
      event[:description] = "/activities/#{activity.id}.js"
      event[:id] = activity.id
      event[:start] = activity.posted_time.to_s(:db)
      event[:end] = activity.posted_time.to_s(:db)
      event[:allDay] = false
      json.push event
    end
    return json
  end
    
  def self.new_from_json_v1_0(params, current_user, client_app_id = nil)
    item = params[:activity]
    activity = self.new
    activity.user_id ||= current_user.id
    activity.client_application_id = client_app_id
    
    # save whole payload
    activity.payload = item
    
    # PROPERTIES
    activity.url_id = item[:id] || ''
    
    activity.permalink = item[:url] || ''
    activity.title = item[:title].to_s
    activity.clean_title = Sanitize.clean(activity.title)
    activity.summary = item[:summary].to_s
    activity.clean_summary = Sanitize.clean(activity.summary)
    activity.content = item[:content].to_s
    activity.stream_favicon_url = item[:icon][:url] rescue('')
    activity.posted_time = item[:published] || Time.now
    
    # VERB
    activity.verb = item[:verb]
    # TAGS
    if item[:tags].present?
      if item[:tags].is_a? Array
        activity.tag_list = item[:tags].join(', ') 
      else
        activity.tag_list = item[:tags]
      end
    end
      
        
    # GENERATOR
    activity.generator_title = item[:generator][:displayName]
    activity.generator_url = item[:generator][:url]
    
    # SERVICE PROVIDER
    activity.service_provider_name = item[:provider][:displayName]
    activity.service_provider_icon = item[:provider][:image][:url] rescue('')
    activity.service_provider_uri = item[:provider][:url]

    # ACTOR 
    activity.actor = Actor.new
    if item[:actor].present?
      activity.actor.title = item[:actor][:displayName]
      activity.actor.url_id = item[:actor][:url]
      activity.actor.remote_id = item[:actor][:id]
      activity.actor.object_type = item[:actor][:objectType]
      activity.actor.payload = item[:actor]
    else
      activity.actor.title = current_user.name
      activity.actor.url_id = activity.url_for("#{ManybotsServer.url}/users/#{current_user.id}")
      activity.actor.remote_id = activity.url_for("#{ManybotsServer.url}/users/#{current_user.id}")
      activity.actor.object_type = 'person'
    end
    
    # OBJECT
    activity.object = Obj.new
    activity.object.title = item[:object][:displayName]
    activity.object.url_id = item[:object][:url]
    activity.object.remote_id = item[:object][:id]
    activity.object.object_type = item[:object][:objectType] || "article"
    activity.object.payload = item[:object]

    # TARGET
    if item[:target].present?
      activity.target = Target.new
      activity.target.title = item[:target][:displayName]
      activity.target.url_id = item[:target][:url]
      activity.target.remote_id = item[:target][:id]
      activity.target.object_type = item[:target][:objectType]
      activity.target.payload = item[:target]
    end
        
    return activity
  end
  
  def auto_title!
    unless self.actor.nil? or self.object.nil? 
      if self.title.match 'ACTOR'      
        actor_link = "<a href="+self.actor.url_id+">#{self.actor.title}</a>"
        self.title.gsub!('ACTOR', actor_link)
      end
      if self.title.match 'OBJECT'
        object_link = "<a href="+self.object.url_id+">#{self.object.title}</a>"
        self.title.gsub!('OBJECT', object_link)
      end
    else 
      return false
    end
    
    unless self.target.nil?
      target_link = "<a href="+self.target.url_id+">#{self.target.title}</a>"
      self.title.gsub!('TARGET', target_link)
    end    
  end
  
  def verb_title
    verb.split('/').last.upcase
  end
  
  def object_title
    object.object_type.split('/').last.upcase
  end
  
  def standard_payload_keys(what_for)
    return case what_for
    when :activity
      ["id", "url", "title", "summary", "content", "icon", "published", "verb", "actor", "target", "object", "provider", "generator", "auto_title", "tags"]
    when :object, :target
      ["id", "url", "displayName", "objectType"] # "vehicleType" 
    end
  end
  
  def parsed_payload
    @parse_payload ||= YAML::load(self.payload) rescue(self.payload)
  end
  
  def exotic_payload(what_for)
    @raw_payload ||= YAML::load(self.payload) rescue(self.payload)
    result = []
    go = case what_for
    when :activity
      keys = @raw_payload.keys - self.standard_payload_keys(:activity)
      keys.each do |key|
        this = {}
        this[key.to_sym] = @raw_payload[key]
        result.push this
      end
    else
      keys = @raw_payload[what_for.to_s].keys - self.standard_payload_keys(what_for)
      keys.each do |key|
        this = {}
        this[key.to_sym] = @raw_payload[what_for.to_s][key]
        result.push this
      end
    end
    result
  end
  
  def as_item
    a = self.as_json
    a[:uid] = a[:id]
    a[:sql_id] = self.id
    a.delete :id
    a.merge :itemType => 'Activity'
  end
    
  def as_activity_v1_0
    a = {
      :user_id => self.user_id,
      :client_application_id => self.client_application_id,
      :id => url_for(self),
      :url => url_for(self),
      :title => self.title,
      :summary => self.summary,
      :content => self.content || self.summary,
      :icon => {
        :url => self.stream_favicon_url
      },
      :published => self.posted_time.xmlschema,
      :published_epoch => self.posted_time.to_i,
      :verb => self.verb,
      :tags => self.tags.collect(&:name),
      :generator => {
        :displayName => self.generator_title,
        :url => self.generator_url,
        :image => {
          :url => self.stream_favicon_url
        }
      },
      :provider => {
        :displayName => self.service_provider_name,
        :url => self.service_provider_uri,
        :image => {
          :url => self.service_provider_icon
        }
      },
      :actor => {
        :displayName => self.user.name,
        :url => "#{ManybotsServer.url}/users/#{self.user_id}",
        :id => "#{ManybotsServer.url}/users/#{self.user_id}",
        :objectType => self.actor.object_type || "person",
        :image => {
          :url => self.user.avatar_url
        }
      },
      :object => {
        :displayName => self.object.title,
        :url => self.object.url_id,
        :id => self.object.remote_id || self.object.url_id,
        :objectType => self.object.object_type
      }
    }
    

    self.exotic_payload(:activity).each do |pair|
      a.merge! pair
    end if self.payload

    
    self.exotic_payload(:object).each do |pair|
      a[:object].merge! pair
    end if self.payload
    
    
    if self.target.present?
      a[:target] = {
        :displayName => self.target.title,
        :url => self.target.url_id,
        :id => self.target.remote_id || self.target.url_id,
        :objectType => self.target.object_type
      }
      
      self.exotic_payload(:target).each do |pair|
        a[:target].merge! pair
      end if self.payload
    end
      
    return a
  end
  
  def as_json(options={})
    self.as_activity_v1_0
  end
  
  def add_aggregation!
    Aggregation.create_all_for_object(self)
  end
    
  def remove_aggregation!
    self.aggregations.find_each{|g| g.update_attribute :total, (g.total - 1)}
    true
  end
  
  
  def as_prediction(at_time=nil)
    at_time = Time.now + 1.day if at_time.nil?
    at_time_as_date = at_time.to_date
    activity = self.as_json
    puts 'ACTOR'
    puts activity[:actor]
    puts 'ACTOR ----'
    prediction = {}
    # prediction[:id] = "#{ManybotsServer.url}/predictions/new/#{Time.now.to_i}"
    # prediction[:url] = "#{ManybotsServer.url}/predictions/new/#{Time.now.to_i}"
    prediction[:published] = Time.now
    prediction[:title] = 'ACTOR predicts on TARGET: OBJECT'
    prediction[:auto_title] = true
    prediction[:actor] = activity[:actor]
    prediction[:verb] = 'predict'
    prediction[:object] = activity
    prediction[:object][:objectType] = 'activity'
    prediction[:object][:displayName] = prediction[:object][:title]
    prediction[:object][:published] = at_time
    prediction[:target] = {
      :id => "#{ManybotsServer.url}/calendar/day/#{at_time_as_date.year}/#{at_time_as_date.month}/#{at_time_as_date.day}",
      :url => "#{ManybotsServer.url}/calendar/day/#{at_time_as_date.year}/#{at_time_as_date.month}/#{at_time_as_date.day}",
      :displayName => at_time.strftime('%a, %b %d %Y at %H:%M'),
      :objectType => 'date'
    }
    prediction[:generator] = {
      :id => ManybotsServer.url,
      :url => ManybotsServer.url,
      :displayName => ManybotsServer.server_name,
      :image => {
        :url => ManybotsServer.icon_url
      }
    }
    prediction[:provider] = prediction[:generator]
    {:activity => prediction}
  end

  ## CREATE PREDICTION  
  def create_prediction
    if self.verb == 'predict' and self.object.object_type == 'activity'
      # self.object.title = self.parsed_payload[:object][:displayName]
      # self.save!
      pred = self.as_json
      pred.delete :url
      pred.delete :id
      pred[:object].delete :url
      pred[:object].delete :id
      puts pred
      prediction = self.predictions.new_from_json_v1_0(pred, User.find(self.user_id), self.client_application_id)
      prediction.save
    end
  end
  
  def create_item
    Item.create self.as_item
  end
  
  private
      
    def hash_gen(activity)
      return Digest::SHA1.hexdigest(activity.verb.to_s+activity.title.to_s+activity.summary.to_s+Time.now.to_f.to_s).to_s
    end
end
