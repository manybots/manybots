class Person
  include MongoMapper::Document
  safe
  
  key :user_id,               Integer
  key :name,                  String
  key :rel,                   String
  key :aggregation_id,        Integer
  key :names,                 Array
  key :emails,                Array
  key :avatar_url,            String
  key :activities,            Array
  key :highjacked,            Boolean
  key :highjacked_by,         String
  
  def duplicates
    @duplicates ||= self.class.where(emails: emails, :id.ne => id).all
  end
  
  def update_with_highjacks!
    update_attribute :emails, all_emails
    update_attribute :names, all_names
  end
    
  def highjacks
    self.class.where(highjacked_by: id.to_s).all
  end
  
  def highjack_duplicates!
    duplicates.all.each do |dup|
      dup.highjack!(id)
    end
    highjacks.all
  end
  
  def highjack!(person_id)
    self.highjacked = true
    self.highjacked_by = person_id
    save
  end
  
  def release!
    self.highjacked = false
    self.highjacked_by = nil
    save
  end
  
  def all_emails
    @all_emails ||= (emails + highjacks.collect(&:emails)).flatten.uniq
  end
  
  def all_names
    @all_names ||= [name, highjacks.collect(&:name)].flatten.uniq
  end
  
  def all_activities
    options = {
      user_id: user_id,
      :$or => [
        {:'target.email' => {:$in => all_emails}, :'target.displayName' => {:$in => all_names} },
        {:'object.email' => {:$in => all_emails}, :'object.displayName' => {:$in => all_names} },
      ]
    }
    
    unless @acts
      @acts = []
      @acts += Item.where({'target.objectType' => 'person'}.merge(options)).fields(:id).all.collect(&:id)
      @acts += Item.where({'object.objectType' => 'person'}.merge(options)).fields(:id).all.collect(&:id)
    end
    @all_activities ||= Item.where(id: @acts)
  end
  
  def self.create_all_for_user(user_id)
    people = uniq_name_matches(user_id)
    for person in people
      pax = new(person)
      pax.user_id = user_id
      pax.rel = 'Contact'
      pax.avatar_url = gravatar_url(pax.emails.first) if pax.emails.any?
      pax.save
    end
  end
  
  private
  
  def self.uniq_names(user_id)
    names = []
    names += Item.collection.distinct("target.displayName", {'target.objectType' => 'person', 'user_id' => user_id})
    names += Item.collection.distinct("object.displayName", {'object.objectType' => 'person', 'user_id' => user_id})
    names.compact.uniq
  end
  
  def self.uniq_emails(user_id)
    emails = []
    emails += Item.collection.distinct("target.email", {'target.objectType' => 'person', 'user_id' => user_id})
    emails += Item.collection.distinct("object.email", {'object.objectType' => 'person', 'user_id' => user_id})
    emails.compact.uniq
  end
  
  def self.emails_for_name(user_id, name)
    emails = []
    emails += Item.collection.distinct("target.email", {'target.objectType' => 'person', 'user_id' => user_id, 'target.displayName' => name})
    emails += Item.collection.distinct("object.email", {'object.objectType' => 'person', 'user_id' => user_id, 'object.displayName' => name})
    emails.compact.uniq
  end
  
  def self.names_for_email(user_id, email)
    names = []
    names += Item.collection.distinct("target.displayName", {'target.objectType' => 'person', 'user_id' => user_id, 'target.email' => email})
    names += Item.collection.distinct("object.displayName", {'object.objectType' => 'person', 'user_id' => user_id, 'object.email' => email})
    names.compact.uniq
  end
  
  def self.uniq_name_matches(user_id)
    names = uniq_names(user_id)
    uniqs = names.collect do |name|
      { name: name, emails: emails_for_name(user_id, name) }
    end
  end
  
  def self.uniq_email_matches(user_id)
    emails = uniq_emails(user_id)
    uniqs = emails.collect do |email|
      { email: email, names: names_for_email(user_id, email) }
    end
  end
  
  def self.gravatar_url(email)
    gravatar_url = "https://secure.gravatar.com/avatar/"
    gravatar_url << Digest::MD5.hexdigest(email)
  end
  
end
