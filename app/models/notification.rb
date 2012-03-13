class Notification < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = ManybotsServer.host
  
  belongs_to :user
  belongs_to :activity
  has_many :predictions, :as => :predictable
  belongs_to :client_application
  has_and_belongs_to_many :aggregations

  acts_as_taggable
  
  serialize :payload
  
  # after_create :create_activity
  after_create :create_prediction
  after_create  :add_aggregation!
  before_destroy :remove_aggregation!
  
  
  scope :unread, lambda {
    where(is_read: false)
  }
  
  scope :read, lambda {
    where(is_read: true)
  }
  
  scope :timeline, lambda {
    order('notifications.published DESC')
  }
    
  def self.between(start, finish)
    if start and finish
      if start.is_a? String or start.is_a? Integer
        start =  ActiveSupport::TimeZone.new('UTC').parse Time.at(start.to_i).to_s(:db)
        finish =  ActiveSupport::TimeZone.new('UTC').parse Time.at(finish.to_i).to_s(:db)
      else
        start = Time.at(start.to_i)
        finish = Time.at(finish.to_i)
      end
      where('notifications.published >= ? and notifications.published <= ?', start, finish).scoped 
    else
      scoped
    end
  end
  
  
  def self.new_from_json_v1_0(params, client_app_id = nil)
    item = params[:activity]
    activity = self.new
    activity.client_application_id = client_app_id
    
    # save whole payload
    activity.payload = item
    
    # PROPERTIES
    activity.uid = item[:id] || ''
    activity.url = item[:url] || ''
    activity.notification_type = item[:notification][:type] || "Notification"
    activity.notification_level = item[:notification][:level] || "Silent" # can be ['Silent', 'Alert', 'Urgent']
    activity.title = item[:title]
    activity.summary = item[:summary].to_s
    activity.content = item[:content].to_s || activity.summary
    activity.icon_url = item[:icon][:url] rescue('')
    activity.published = item[:published] || Time.now
    
    # VERB
    activity.verb = item[:verb]
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
    activity.object_name = item[:object][:displayName]
    activity.object_url = item[:object][:url]
    activity.object_uid = item[:object][:id]
    activity.object_type = item[:object][:objectType] || "article"

    # TARGET
    if item[:target].present?
      activity.target_name = item[:target][:displayName] 
      activity.target_url = item[:target][:url]
      activity.target_uid = item[:target][:id]
      activity.target_type = item[:target][:objectType] 
    end
    
    activity.auto_title! if item[:auto_title].present?
    
    # ## CREATE PREDICTION
    # if activity.verb == 'predict' and activity.object_type == 'activity'
    #   activity.object_name = item[:object][:title]
    #   prediction = self.predictions.new_from_json_v1(item, activity.client_application_id)
    #   prediction.user_id = self.user_id
    #   prediction.save
    # end
    
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
    activity.actor.url_id = "http://manybots.com/account"
    
    # OBJECT
    activity.object = Activity::Obj.new
    activity.object.title = self.notification_type
    activity.object.url_id = url_for(self)
    activity.object.object_type = 'notification'

    # TARGET
    activity.target = Activity::Target.new
    activity.target.title = self.generator_name
    activity.target.url_id = self.generator_url
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
      :notification => {
        :type => self.notification_type,
        :level => self.notification_level
      },
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
    self.title.gsub!('ACTOR', actor_link) if self.title.match 'ACTOR'
    
    if self.title.match 'OBJECT'
      object_link = "<a href="+self.object_url+">#{self.object_name}</a>"
      self.title.gsub!('OBJECT', object_link) 
    end
    
    if self.target_name.present?
      target_link = "<a href="+self.target_url+">#{self.target_name}</a>"
      self.title.gsub!('TARGET', target_link) if self.title.match 'TARGET'
    end    
  end
  
  def add_aggregation!
    Aggregation.create_all_for_object(self)
  end
  
  def create_prediction
    if self.verb == 'predict' and self.object_type == 'activity'
      pred = self.as_json
      pred.delete :url
      pred.delete :id
      pred[:object].delete :url
      pred[:object].delete :id
      self.predictions.new_from_json_v1_0(pred, self.user, self.client_application_id).save
    end
  end
  
  
  def remove_aggregation!
    self.aggregations.find_each{|g| g.update_attribute :total, (g.total - 1)}
    true    
  end
  
end
