require 'oauth'
# require 'oauth/request_proxy/action_controller_request'
class ClientApplication < ActiveRecord::Base
  belongs_to :user
  has_many :tokens, :class_name => "OauthToken"
  has_many :access_tokens
  has_many :oauth2_verifiers
  has_many :oauth_tokens
  validates_presence_of :name, :url, :key, :secret
  validates_uniqueness_of :key
  before_validation :generate_keys, :on => :create

  validates_format_of :url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
  validates_format_of :support_url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true
  validates_format_of :callback_url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true

  attr_accessor :token_callback_url
  
  CATEGORIES = ["Productivity", "Health", "Mobility", "Money", "Communications"]
  APP_TYPES = ["App", "Observer", "Agent", "Visualization"]
  
  scope :are_public, lambda {
    where(is_public: true)
  }
  
  scope :visualizations, lambda {
    where(app_type: 'Visualization')
  }
  
  scope :are_trusted, lambda {
    where(is_trusted: true)
  }
  
  
  
  def self.find_token(token_key)
    token = OauthToken.find_by_token(token_key, :include => :client_application)
    if token && token.authorized?
      token
    else
      nil
    end
  end
  
  def self.verify_request(request, options = {}, &block)
    begin
      signature = OAuth::Signature.build(request, options, &block)
      return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      value = signature.verify
      value
    rescue OAuth::Signature::UnknownSignatureMethod => e
      false
    end
  end
  
  def user_count
    self.tokens.
    select('DISTINCT(oauth_tokens.user_id)').
    where("oauth_tokens.user_id IS NOT NULL").
    count
  end
  
  def oauth_server
    @oauth_server ||= OAuth::Server.new("http://your.site")
  end
  
  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end
    
  # If your application requires passing in extra parameters handle it here
  def create_request_token(params={}) 
    RequestToken.create :client_application => self, :callback_url=>self.token_callback_url
  end
  
  def add_aggregation!(user_id)
    the_user = User.find(user_id)
    # create aggregation for app
    ag = the_user.aggregations.find_or_initialize_by_name_and_type_string(self.name, 'apps')
    if ag.new_record?
      ag.total = 0
      ag.path = self.url
      ag.avatar_url = self.app_icon_url
      ag.object_type = "ClientApplication"
      ag.save
    end
  end
  
protected
  
  def generate_keys
    self.key = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end
end
