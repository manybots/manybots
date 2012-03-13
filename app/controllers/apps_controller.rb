class AppsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  
  def index
    @apps = ClientApplication.where({:is_public => true})
    if current_user
      @client_applications = current_user.client_applications
      # @tokens = current_user.tokens.where('oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
      @tokens = current_user.tokens.select('DISTINCT(oauth_tokens.client_application_id), auth_tokens.authorized_at')
          .where('oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
    end
  end
  
  def show
    @client_application = current_user.client_applications.find_by_id(params[:id])
    render 'oauth_clients/show'
  end
  
  def destroy
    tokens = current_user.tokens.where(:client_application_id => params[:id]).destroy_all
    if tokens
      flash[:notice] = "Access revoked. The application can no longer access Manybots on your behalf."
      redirect_to apps_path
    else
      flash[:error] = "There was an error. Please try again or ask for Help."
      redirect_to apps_path
    end
  end
  
end
