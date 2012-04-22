class InstalledApplication < ActiveRecord::Base
  belongs_to :user
  belongs_to :client_application
  attr_accessible :in_library, :in_menu, :is_default
  
  scope :in_menu, lambda {
    where(in_menu: true)
  }
  
  scope :in_library, lambda {
    where(in_library: true)
  }
  
  
end
