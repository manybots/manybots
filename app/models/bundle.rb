class Bundle < ActiveRecord::Base
  belongs_to :user
  
  before_validation :make_slug, :on => :create
  
  validates :name, :presence => true
  validates :slug, :uniqueness => {:scope => :user_id}, :presence => true, :format => /([a-z]|\d|-|_)+/, :length => {:minimum => 1 }
  
  def activities(start_date=nil, end_date=nil)
    filters = self.user.filters.tagged_with(self.slug)
    these_activities = []
    filters.each do |filter|
      activity_filter = ActivityFilter.new(filter.payload)
      acts = Activity.new_advanced_filter(self.user_id, activity_filter.options, start_date, end_date, 'activities.id').scoped
      if activity_filter.options[:tags].present?
        acts = acts.tagged_with(activity_filter.options[:tags]).scoped
      end
      these_activities.push acts.order('activities.posted_time DESC').collect(&:id) 
    end
    these_activities.compact.flatten.uniq
  end
  
  def self.activities_from_raw_bundle(user_id, filters, start_date=nil, end_date=nil, alimit=nil)
    these_activities = []
    filters.each do |afilter|
      activity_filter = ActivityFilter.new(afilter)
      puts "XXXXX FILTER OPTIONS"
      puts activity_filter.inspect
      
      acts = Activity.new_advanced_filter(user_id, activity_filter.options, start_date, end_date, 'activities.id').scoped
      if activity_filter.options[:tags].present?
        acts = acts.tagged_with(activity_filter.options[:tags]).scoped
      end
      if alimit
        acts = acts.limit(alimit).scoped
      end
      these_activities.push acts.order('activities.posted_time DESC').collect(&:id)
    end
    these_activities.compact.flatten.uniq
  end
  
  def filters
    self.user.filters.tagged_with(self.slug)
  end
  
  def available_filters
    self.user.filters - self.filters
  end
  
  def make_slug
    puts "self.slug.present?"
    self.slug = self.name.parameterize unless self.slug.present?
  end
  
  def to_param
    self.slug
  end
end
