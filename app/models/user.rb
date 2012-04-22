class User < ActiveRecord::Base
  has_many :client_applications
  has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc", :include=>[:client_application]
  has_many :activities, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :predictions, :dependent => :destroy
  has_many :objects, :through => :activities
  has_many :targets, :through => :activities
  has_many :filters, :dependent => :destroy
  has_many :bundles, :dependent => :destroy
  has_many :aggregations, :dependent => :destroy
  has_many :oauth_accounts

  has_many :installed_applications
  
  validates_uniqueness_of :email
  validates_presence_of :email, :on => :update
  validates_presence_of :name, :on => :update  
  
  after_update :create_first_activity

  devise :trackable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :token_authenticatable

  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :country
  attr_accessible :authentication_token
  
  def update_with_password(params={}) 
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end
  
  def avatar_url
    if @avatar_url
      return @avatar_url
    else
      view = ActionView::Base.new(ManybotsLocal::Application.instance.paths['app/views'])
      view.extend Rails.application.routes.url_helpers
      view.extend ApplicationHelper
      return @avatar_url = view.gravatar_url_for(self.email)
    end
  end
  
  def as_activity_actor(options={})
    @actor ||= {
      id: "#{ManybotsServer.url}/users/#{self.id}",
      url: "#{ManybotsServer.url}/users/#{self.id}",
      displayName: options[:name] || self.name || self.email,
      objectType: 'person',
      email: options[:email] || self.email,
      image: {
        url: options[:avatar_url] || self.avatar_url,
      }
    }
  end
  
  
  def active_apps
    @active_apps ||= ClientApplication.where(
        :id => OauthToken.where(:user_id => self.id).select('DISTINCT client_application_id').collect(&:client_application_id)
    )
  end
  
  def create_first_activity
    if self.is_first_login? and self.name.present?
      activity = self.activities.new
      activity.verb = "join"
      
      # GENERATOR
      activity.generator_title = "Manybots"
      activity.generator_url = "https://www.manybots.com"

      # SERVICE PROVIDER
      activity.service_provider_name = "Manybots"
      #activity.service_provider_icon = item[:serviceProvider][:icon]
      activity.service_provider_uri = "https://www.manybots.com"
      
      # PROPERTIES
      activity.posted_time = Time.now
      activity.tag_list = 'manybots, account'
      activity.title = "ACTOR joined OBJECT."      
      activity.url_id = "https://www.manybots.com/account"
      activity.summary = "Welcome to Manybots"
      
      # ACTOR 
      activity.actor = Activity::Actor.new
      activity.actor.title = self.name
      activity.actor.url_id = activity.url_for("#{ManybotsServer.url}/users/#{self.id}")
      activity.actor.remote_id = activity.url_for("#{ManybotsServer.url}/users/#{self.id}")
      activity.actor.object_type = 'person'
      
      # OBJECT
      activity.object = Activity::Obj.new
      activity.object.title = 'Manybots'
      activity.object.url_id = "https://www.manybots.com"
      activity.object.object_type = "service"

      activity.auto_title!
      activity.save
      
      self.is_first_login = false
      self.save
    end
  end
    
end
