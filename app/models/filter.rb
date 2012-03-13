class Filter < ActiveRecord::Base
  belongs_to :user
  serialize :payload
  
  before_validation :make_slug, :on => :create

  validates :name, :presence => true
  validates :slug, :uniqueness => {:scope => :user_id}, :presence => true, :format => {:with => /([a-z0-9]|-|_)+/}
  
  acts_as_taggable

  
  def bundles
    self.user.bundles.where(:slug => self.tags.collect(&:name))
  end
  
  def available_bundles
    if self.tag_list.present?
      self.user.bundles.where('bundles.slug NOT IN (?)', self.tags.collect(&:name))
    else
      self.user.bundles
    end
  end
  
  def to_param  # overridden
    self.slug
  end
  
  def make_slug
    puts "self.slug.present?"
    self.slug = self.name.parameterize unless self.slug.present?
  end
    
end
