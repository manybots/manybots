class OauthToken < ActiveRecord::Base
  belongs_to :client_application
  belongs_to :user
  validates_uniqueness_of :token
  validates_presence_of :client_application, :token
  before_validation :generate_keys, :on => :create
  
  # after_create :invalidate_others
  
  #after_create :add_aggregation!
  
  scope :active, lambda {
    where('oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
  }
  
  def invalidated?
    invalidated_at != nil
  end
  
  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end
  
  def authorized?
    authorized_at != nil && !invalidated?
  end
    
  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end
    
  
  def invalidate_others
    current = self.id
    others = OauthToken.where('id != ?', current).where('client_application_id = ?', self.client_application_id)
    others.destroy_all
  end
  
  def add_aggregation!
    logger.info "ADDING"
    logger.info "#{self.inspect}"
    self.client_application.add_aggregation!(self.user_id) if self.user_id
  end  
  
  protected
  
  def generate_keys
    self.token = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end
end
