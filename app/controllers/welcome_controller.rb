class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      if current_user.name.present?
        redirect_to '/calendar/today'
      else
        flash[:notice] = "Almost there. Please complete your profile before continuing."
        redirect_to '/account'
      end
    end
  end
  
  def api
  end
  
  def about
  end
  
  def tos
  end
  
  def privacy
  end
  
  def developers
  end
  
  def botshop
  end
  
  def testimonials
  end
  
  def platform
  end
  
  def rails
    render '/welcome/guides/rails'
  end
end
