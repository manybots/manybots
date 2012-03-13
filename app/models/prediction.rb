class Prediction < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = ManybotsServer.host
  
  belongs_to :user
  belongs_to :predictable, :polymorphic => true, :dependent => :destroy
  belongs_to :client_application
  
  has_and_belongs_to_many :aggregations

  acts_as_taggable
  
  serialize :payload
  
  scope :timeline, lambda {
    order('predictions.published DESC')
  }
  
  after_create  :add_aggregation!
  before_destroy :remove_aggregation!
  
  def self.between(start, finish)
    if start and finish
      if start.is_a? String or start.is_a? Integer
        start =  ActiveSupport::TimeZone.new('UTC').parse Time.at(start.to_i).to_s(:db)
        finish =  ActiveSupport::TimeZone.new('UTC').parse Time.at(finish.to_i).to_s(:db)
      else
        start = Time.at(start.to_i)
        finish = Time.at(finish.to_i)
      end
      where('predictions.published >= ? and predictions.published <= ?', start, finish).scoped 
    else
      scoped
    end
  end
  
  def self.create_from_activity_id(activity_id)
    model_activity = Activity.find(activity_id)
    prediction = model_activity.as_prediction
    activity = Activity.new_from_json_v1_0 prediction, model_activity.user 
    activity.auto_title!
    activity.save
    activity.create_prediction
  end
  
  def self.new_from_json_v1_0(params, user, client_app_id = nil)
    item = params[:object]
    activity = self.new
    activity.user_id = user.id
    activity.client_application_id = client_app_id
    
    # save whole payload
    activity.payload = item
    
    # PROPERTIES
    activity.uid = item[:id] || ''
    activity.url = item[:url] || ''
    # activity.prediction_type = item[:prediction][:type] || "N"
    # activity.prediction_level = item[:prediction][:level] || "Silent" # can be ['Silent', 'Alert', 'Urgent']
    activity.title = item[:title]
    activity.summary = item[:summary].to_s
    activity.content = item[:content].to_s || activity.summary
    activity.icon_url = item[:icon][:url] rescue('')
    activity.published = item[:published] || Time.now
    
    # VERB
    activity.verb = item[:verb] #|| 'predict'
    # TAGS
    activity.tag_list = item[:tags].join(', ') if item[:tags].present?
        
    # GENERATOR
    activity.generator_name = item[:generator][:displayName] 
    activity.generator_url = item[:generator][:url]
    activity.generator_icon = item[:generator][:image][:url] rescue('')
    
    # SERVICE PROVIDER
    activity.provider_name = item[:provider][:displayName]
    activity.provider_icon = item[:provider][:image][:url] rescue('')
    activity.provider_url = item[:provider][:url]

    # ACTOR 
    activity.actor_name = item[:actor][:displayName] 
    activity.actor_type = item[:actor][:objectType]
    activity.actor_uid = item[:actor][:id]
    activity.actor_url = item[:actor][:url]
    activity.actor_avatar_url = item[:actor][:image][:url] rescue('')
    
    # OBJECT
    # if item[:object][:auto_title].present? and item[:object][:auto_title] != false
    #   item[:object][:title] = apply_auto_title item[:object][:title]
    # end
    
    activity.object_name = item[:object][:title] || item[:object][:displayName]
    activity.object_url = item[:object][:url]
    activity.object_uid = item[:object][:id]
    activity.object_type = item[:object][:objectType] #|| "activity"

    # TARGET
    if item[:target].present?
      activity.target_name = item[:target][:displayName] 
      activity.target_url = item[:target][:url]
      activity.target_uid = item[:target][:id]
      activity.target_type = item[:target][:objectType] #|| "application"
    end
    
    activity.auto_title! if item[:auto_title].present?
    
    return activity
  end
  
  def create_activity
    activity = self.user.activities.new
    # TITLE 
    activity.title = "ACTOR received a OBJECT from TARGET"

    # PROPERTIES
    activity.posted_time = self.published
    activity.tag_list = self.tag_list
    activity.url_id = url_for(self)
    activity.summary = self.summary
    activity.content = self.content

    # VERB    
    activity.verb = "receive"
    
    # ACTOR 
    activity.actor = Activity::Actor.new
    activity.actor.object_type = 'person'
    activity.actor.title = self.user.name
    activity.actor.url_id = activity.actor.remote_id = activity.url_for("#{ManybotsServer.url}/users/#{current_user.id}")

    # OBJECT
    activity.object = Activity::Obj.new
    activity.object.title = self.notification_type
    activity.object.url_id = activity.object.remote_id = url_for(self)
    activity.object.object_type = 'notification'

    # TARGET
    activity.target = Activity::Target.new
    activity.target.title = self.generator_name
    activity.target.url_id = activity.target.remote_id = self.generator_url
    activity.target.object_type = "application"
    
    
    # GENERATOR
    activity.generator_title = "Manybots"
    activity.generator_url = "http://manybots.com"

    # PROVIDER
    activity.service_provider_name = self.generator_name
    activity.service_provider_icon = self.generator_icon
    activity.service_provider_uri = self.generator_url

    activity.auto_title!
    activity.save
    self.update_attribute :activity_id, activity.id
  end
  
  def standard_payload_keys(what_for)
    return case what_for
    when :activity
      ["id", "url", "title", "summary", "content", "icon", "published", "verb", "actor", "target", "object", "provider", "generator", "auto_title", "tags"]
    when :object, :target
      ["id", "url", "displayName", "objectType"] # "vehicleType" 
    end
  end
  
  def exotic_payload(what_for)
    if self.payload
      @raw_payload ||= self.payload
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
        keys = @raw_payload[what_for].keys - self.standard_payload_keys(what_for)
        keys.each do |key|
          this = {}
          this[key.to_sym] = @raw_payload[what_for][key]
          result.push this
        end
      end
      result
    else
      []
    end
  end
  
  def as_json(options={})
    a = {
      :user_id => self.user_id,
      :id => url_for(self),
      :url => url_for(self),
      :title => self.title,
      :summary => self.summary,
      :content => self.content,
      # :notification => {
      #   :type => self.notification_type,
      #   :level => self.notification_level
      # },
      :icon => {
        :url => self.generator_icon
      },
      :published => self.published.xmlschema,
      :published_epoch => self.published.to_i,
      :verb => self.verb,
      :tags => self.tag_list,
      :generator => {
        :displayName => self.generator_name,
        :image => {
          :url => self.generator_icon
        },
        :url => self.generator_url
      },
      :provider => {
        :displayName => self.provider_name,
        :url => self.provider_url,
        :image => {
          :url => self.provider_icon
        }
      },
      :actor => {
        :displayName => self.actor_name,
        :url => self.actor_url,
        :id => self.actor_uid,
        :objectType => self.actor_type,
        :image => {
          :url => self.actor_avatar_url
        }
      },
      :object => {
        :displayName => self.object_name,
        :url => self.object_url,
        :id => self.object_uid,
        :objectType => self.object_type
      }
    }
    
    self.exotic_payload(:activity).each do |pair|
      a.merge! pair
    end

    
    self.exotic_payload(:object).each do |pair|
      a[:object].merge! pair
    end
    
    
    if self.target_name.present?
      a[:target] = {
        :displayName => self.target_name,
        :url => self.target_url,
        :id => self.target_uid,
        :objectType => self.target_type
      }
      
      self.exotic_payload(:target).each do |pair|
        a[:target].merge! pair
      end
      
    end
      
    return a
  end
  
  def auto_title!
    actor_link = "<a href="+self.actor_url+">#{self.actor_name}</a>"
    self.title.gsub!('ACTOR', actor_link)
    
    object_link = "<a href="+self.object_url+">#{self.object_name}</a>"
    self.title.gsub!('OBJECT', object_link)
    
    if self.target_name.present?
      target_link = "<a href="+self.target_url+">#{self.target_name}</a>"
      self.title.gsub!('TARGET', target_link)
    end
  end
  
  def add_aggregation!
    Aggregation.create_all_for_object(self)
  end
  
  
  def remove_aggregation!
    self.aggregations.find_each{|g| g.update_attribute :total, (g.total - 1)}
    true    
  end
  
  private 
  
    def apply_auto_title(string, activity_hash)
      actor_link = "<a href="+activity_hash[:actor][:url]+">#{obj.actor_name}</a>"
      string.gsub!('ACTOR', actor_link)

      object_link = "<a href="+self.object_url+">#{self.object_name}</a>"
      self.title.gsub!('OBJECT', object_link)

      if self.target_name.present?
        target_link = "<a href="+self.target_url+">#{self.target_name}</a>"
        self.title.gsub!('TARGET', target_link)
      end
    end
  
end
