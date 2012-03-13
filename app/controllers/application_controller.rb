class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  after_filter :set_access_control_headers
  
  layout :specify_layout 
    
  def current_user=(user)
    logger.info user.inspect
    sign_in user
  end
  
  
  def login_required(options = {})
    authenticate_user!
  end
  
  def manybots_oauth_required
    unless user_signed_in?
      unless oauth_required
        if current_client_application.present?
          warden.custom_failure!
        else
          authenticate_user!
        end
      end
    end
  end
  
  private 
  
    def specify_layout 
      request.xhr? ? false : 'application'
    end 
      
    def set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Request-Method'] = '*'
    end
    
  
end
