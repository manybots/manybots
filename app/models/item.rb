class Item
  include MongoMapper::Document
  safe
  
  key :user_id,               Integer
  key :sql_id,                Integer
  key :client_application_id, Integer
  key :uid,                   String
  key :url,                   String
  key :verb,                  String
  key :actor,                 Object
  key :object,                Object
  key :tags,                  Array

  # attr_protected :user_id, :client_application_id
  
  validates_presence_of :uid
  validates_presence_of :url
  validates_presence_of :verb
  validates_presence_of :actor
  validates_presence_of :object
  
  validates_uniqueness_of :uid
  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_blank => true
  
  scope :user, lambda {|user_id|
    where(user_id: user_id)
  }
  
  scope :timeline, lambda {
    sort(published_epoch: -1)
  }
  
  scope :between, lambda {|start, finish|
    where(:published_epoch.gte => start, :published_epoch.lte => finish)
  }
  
  def self.api_filter(user, params=nil)
    query = user(user.id)
    return query if params.nil?
    # fields
    query = query.fields(params[:fields].collect(&:to_sym)) if params[:fields].is_a? Array
    # verb
    query = query.where('verb' => params[:verb]) if params[:verb].present?
    # objectType
    query = query.where(:$or => [{'object.objectType' => params[:objectType]}, {'target.objectType' => params[:objectType]}]) if params[:objectType].present?
    # between
    if params['between'].present? and params['between']['start'].present? and params['between']['finish'].present?
      query = query.between(
        Time.parse(params['between']['start']).beginning_of_day.utc.to_i, 
        Time.parse(params['between']['finish']).end_of_day.utc.to_i
      )
    end
    query
  end
  
  def self.new_from_json_v1(user, params=nil, client_application)
    # cleanup the params before initializing the object
    params['uid'] = params.delete 'id'
    params['user_id'] = user.id
    params['client_application_id'] = client_application.id
    params['published_epoch'] = Time.parse(params['published']).to_i
    params['published'] = Time.parse(params['published']).xmlschema
    # initialize using the params
    self.new(params)
  end
  
  def parse_auto_title
    # return false
    return false unless self.auto_title?
    
    if self.title.match('ACTOR') and self.actor.present? and actor_link = "<a href="+self.actor['url']+">#{self.actor['displayName']}</a>"
      self.title.gsub!('ACTOR', actor_link)
    end
    if self.title.match('OBJECT') and self.object.present? and object_link = "<a href="+self.object['url']+">#{self.object['displayName']}</a>"
      self.title.gsub!('OBJECT', object_link)
    end
    if self.title.match('TARGET') and self.target.present? and target_link = "<a href="+self.target['url']+">#{self.target['displayName']}</a>"
      self.title.gsub!('TARGET', target_link)
    end
    self
  end
  
end
