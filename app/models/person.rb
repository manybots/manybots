class Person
  include MongoMapper::Document
  safe
  
  key :user_id,                 Integer
  key :name,                    String
  key :rel,                     String
  key :aggregation_id,          Integer
  key :activity_ids,            Array
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
    
  def duplicates
    (
      self.class.where(emails: all_emails, :id.ne => id).all +
      self.class.where(phone_numbers: all_phone_numbers, :id.ne => id).all
    ).compact.uniq
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
  
  def calculate_global_intensity!
    intensity = Intensity.calculate_for_person_and_genre self, 'global', nil #[(Time.now.beginning_of_year).to_i, Time.now.to_i]
    update_attribute :intensity, intensity
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
  
  def all_activity_ids
    [activity_ids, highjacks.collect(&:activity_ids)].flatten.uniq
  end
  
  def all_activities
    Item.where(sql_id: all_activity_ids)
  end
  
  def load_details_from_aggregation!
    self.names = names_for_aggregation
    self.emails = emails_for_aggregation
    self.phone_numbers = phone_numbers_for_aggregation
    save
  end
  
  def self.new_from_aggregation(aggregation)
    activity_ids = aggregation.activity_ids
    return if activity_ids.empty?
    person = new
    person.name = aggregation.name
    person.aggregation_id = aggregation.id
    person.activity_ids = activity_ids
    person.user_id = aggregation.user_id
    person.rel = "Contact"
    person
  end
  
  def update_from_aggregation(aggregation)
    name = aggregation.name
    activity_ids = aggregation.activity_ids
    save
    load_details_from_aggregation!
  end
  
  def self.create_from_aggregation(aggregation)
    person = new_from_aggregation(aggregation)
    return unless person
    person.load_details_from_aggregation! 
    person.update_attribute(:avatar_url, gravatar_url(person.emails.first)) if person.emails.any?
    person
  end
    
  def self.create_all_for_user(user_id)
    aggregations = Aggregation.where(user_id: user_id, type_string: 'people').all
    for aggregation in aggregations
      create_from_aggregation(aggregation)
    end
  end
  
  def self.calculate_intensity_for_user(user_id)
    where(user_id: user_id).all.each do |person|
      person.calculate_global_intensity!
    end
  end
  
  private
  
  def names_for_aggregation
    names = []
    ['target', 'object'].each do |field|
      names += Item.where("#{field}.objectType" => 'person', 'sql_id' => activity_ids).
        fields(["#{field}.displayName"]).all.collect {|item|
          item.send(field)['displayName']
        }
    end
    names = names.compact.uniq
    update_attribute :names, names
    names
  end
  
  def emails_for_aggregation
    emails = []
    ['target', 'object'].each do |field|
      emails += Item.where("#{field}.objectType" => 'person', 'sql_id' => activity_ids).
        fields(["#{field}.email"]).all.collect {|item|
          item.send(field)['email']
        }
    end
    emails = emails.compact.uniq
    update_attribute :original_emails, emails
    emails
  end
  
  def phone_numbers_for_aggregation
    phone_numbers = []
    ['target', 'object'].each do |field|
      phone_numbers += Item.where("#{field}.objectType" => 'person', 'sql_id' => activity_ids).
        fields(["#{field}.phone_number"]).all.collect {|item|
          item.send(field)['phone_number']
        }
    end
    phone_numbers = phone_numbers.compact.uniq
    update_attribute :original_phone_numbers, phone_numbers
    phone_numbers
  end
  
  def self.names_for_email(user_id, email)
    names = []
    names += Item.collection.distinct("target.displayName", {'target.objectType' => 'person', 'user_id' => user_id, 'target.email' => email})
    names += Item.collection.distinct("object.displayName", {'object.objectType' => 'person', 'user_id' => user_id, 'object.email' => email})
    names.compact.uniq
  end

  def self.gravatar_url(email)
    gravatar_url = "https://secure.gravatar.com/avatar/"
    gravatar_url << Digest::MD5.hexdigest(email)
  end
  
end
