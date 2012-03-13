class OauthAccount < ActiveRecord::Base
  belongs_to :user
  
  store :payload, :accessors => [:status]
end
