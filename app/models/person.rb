class Person
  include MongoMapper::Document
  safe
  
  key :user_id,                 Integer
  key :name,                    String
  key :rel,                     String
  key :aggregation_id,          Integer
  key :names,                   Array
  key :original_emails,         Array
  key :emails,                  Array
  key :original_phone_numbers,  Array
  key :phone_numbers,           Array
  key :avatar_url,              String
  key :activities,              Array
  key :highjacked,              Boolean
  key :highjacked_by,           String
  key :intensity,               Float
  
  scope :deduped, lambda { |user_id|
    where(user_id: user_id, highjacked: [false, nil])
  }
  
  def create_year_to_date_intensity
    Intensity.calculate_for_person_and_genre self, 'current_year', nil #[(Time.now.beginning_of_year).to_i, Time.now.to_i]
  end
  
  def duplicates
    # conditions = {:$or => []}
    # if emails.empty?
    #   conditions[:$or].push({emails: all_emails})
    # end
    # unless phone_numbers.empty?
    #   conditions[:$or].push({phone_numbers: all_phone_numbers})
    # end
    # self.class.where(conditions.merge(:id.ne => id)).all

    self.class.where(emails: all_emails, :id.ne => id).all
  end
  
  def update_with_highjacks!
    update_attribute :emails, all_emails
    update_attribute :phone_numbers, all_phone_numbers
    update_attribute :names, all_names
  end
  
  def highjacks
    self.class.where(highjacked_by: id.to_s).all
  end
  
  def highjack_duplicates!
    duplicates.all.each do |dup|
      highjack!(dup)
    end
    highjacks.all
  end
  
  def highjack!(target)
    raise ArgumentError, "Must be a Person" unless target.is_a? Person
    target.highjacked = true
    target.highjacked_by = id
    target.save
    update_with_highjacks!
  end
  
  def release!(target)
    raise ArgumentError, "Must be a Person" unless target.is_a? Person
    target.highjacked = false
    target.highjacked_by = nil
    target.save
    update_attribute :names, names
    update_attribute :emails, emails - target.emails
    update_attribute :phone_numbers, phone_numbers - target.phone_numbers
    update_with_highjacks!
  end
  
  def highjacker
    return unless highjacked?
    self.class.find highjacked_by
  end
  
  def all_emails
    (original_emails + emails + highjacks.collect(&:emails)).flatten.uniq
  end
  
  def all_phone_numbers
    (original_phone_numbers + phone_numbers + highjacks.collect(&:phone_numbers)).flatten.uniq
  end
  
  def all_names
    [name, highjacks.collect(&:name)].flatten.uniq
  end
  
  def all_activities
    options = {
      user_id: user_id,
      :$or => [
        {:'target.email' => {:$in => all_emails}, :'target.displayName' => {:$in => all_names} },
        {:'object.email' => {:$in => all_emails}, :'object.displayName' => {:$in => all_names} },
        {:'target.phone_number' => {:$in => all_phone_numbers}, :'target.displayName' => {:$in => all_names} },
        {:'object.phone_number' => {:$in => all_phone_numbers}, :'object.displayName' => {:$in => all_names} },
      ]
    }
    
    unless @acts
      @acts = []
      @acts += Item.where({'target.objectType' => 'person'}.merge(options)).fields(:id).all.collect(&:id)
      @acts += Item.where({'object.objectType' => 'person'}.merge(options)).fields(:id).all.collect(&:id)
    end
    Item.where(id: @acts)
  end
  
  def self.create_all_for_user(user_id)
    people = uniq_name_matches(user_id)
    for person in people
      pax = new(person)
      pax.user_id = user_id
      pax.rel = 'Contact'
      pax.avatar_url = gravatar_url(pax.original_emails.first) if pax.original_emails.any?
      pax.save
    end
  end
  
  private
  
  def self.uniq_names(user_id)
    names = []
    names += Item.collection.distinct("target.displayName", {'target.objectType' => 'person', 'user_id' => user_id})
    names += Item.collection.distinct("object.displayName", {'object.objectType' => 'person', 'user_id' => user_id})
    names.compact.uniq
    
    # names = Aggregation.where(user_id: user_id, type_string: 'people').map do |aggregation|
    #   {name: aggregation.name, activity_ids: aggregation.activity_ids}
    # end
  end
  
  def self.uniq_emails(user_id)
    emails = []
    emails += Item.collection.distinct("target.email", {'target.objectType' => 'person', 'user_id' => user_id})
    emails += Item.collection.distinct("object.email", {'object.objectType' => 'person', 'user_id' => user_id})
    emails.compact.uniq
  end
  
  def self.uniq_phone_numbers(user_id)
    phone_numbers = []
    phone_numbers += Item.collection.distinct("target.phone_number", {'target.objectType' => 'person', 'user_id' => user_id})
    phone_numbers += Item.collection.distinct("object.phone_number", {'object.objectType' => 'person', 'user_id' => user_id})
    phone_numbers.compact.uniq
  end
  
  
  def self.emails_for_name(user_id, name)
    emails = []
    emails += Item.collection.distinct("target.email", {'target.objectType' => 'person', 'user_id' => user_id, 'target.displayName' => name})
    emails += Item.collection.distinct("object.email", {'object.objectType' => 'person', 'user_id' => user_id, 'object.displayName' => name})
    emails.compact.uniq
  end
  
  def self.phone_numbers_for_name(user_id, name)
    numbers = []
    numbers += Item.collection.distinct("target.phone_number", {'target.objectType' => 'person', 'user_id' => user_id, 'target.displayName' => name})
    numbers += Item.collection.distinct("object.phone_number", {'object.objectType' => 'person', 'user_id' => user_id, 'objectType.displayName' => name})
    numbers.compact.uniq
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
      original_emails = emails_for_name(user_id, name)
      original_phone_numbers = phone_numbers_for_name(user_id, name)
      {
        name: name,
        original_emails: original_emails, 
        emails: original_emails, 
        original_phone_numbers: original_phone_numbers, 
        phone_numbers: original_phone_numbers 
      }
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
