require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController
  
  alias :logged_in? :user_signed_in?
  
  alias :login_required :authenticate_user!
  
  
  protected
  def authenticate_user(username,password)
    user = User.find_by_email params[:username]
    if user && user.valid_password?(params[:password])
      user
    else
      nil
    end
  end
  
end
