require 'net/https'

class DashboardController < ApplicationController
  before_filter :authenticate_user!
  
  def reset_user_token
    current_user.reset_authentication_token!
    redirect_to account_path, :notice => "A new API Token was generated."
  end
  
  def visualizations
  end
  
  def password
    @user = current_user
  end
  
  def update_password
    @user = User.find(current_user.id)
    if params[:user][:password].present? and params[:user][:password_confirmation].present? 
      if @user.update_attributes(params[:user])
        # Sign in the user by passing validation in case his password changed
        sign_in @user, :bypass => true
        redirect_to account_path, :notice => 'Your password was changed successfully.'
      else
        redirect_to account_password_path, :alert => 'Your password was not changed. Please try again.'
      end
    else
      redirect_to account_password_path, :alert => 'Your password was not changed.'
    end
  end
  
  def day

    if params[:filter]
      filtered = params[:filter]
      filtered.delete :start_date
      filtered.delete :end_date
    
      @filter = ActivityFilter.new(filtered)
    end
    
    @start_date = Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i).beginning_of_day_in_zone#.to_time
    @finish_date = @start_date.end_of_day
    
        
    if params[:filter].present? and params[:filter][:actors].present?
      if params[:filter][:actors].to_s != current_user.id.to_s
        flash[:error] = "Unauthorized."
        redirect_to activities_path
        return
      end
    end

    if params[:filter].present?
      @activities = Activity.new_advanced_filter(current_user.id, @filter.options, @start_date, @finish_date).scoped
      if params[:filter][:tags].present?
        @activities = @activities.scoped.tagged_with(params[:filter][:tags]).scoped
      end
    else
      @activities = current_user.activities.between(@start_date, @finish_date).order('activities.posted_time ASC').scoped
    end  
    
    if params[:format] == 'js'
      @activities = Activity.to_calendar(@activities) 
    else
      load_details
    end
    
    respond_to do |format|
      format.html {}
      format.js   { render :json => @activities.to_json }
    end
  end
    
  private 


    def load_details
      if @activities
        @verbs = @activities.group_by {|activity| activity.verb }
        @objects = ActivityObject.where('type' => 'Obj').where('activity_id' => @activities.collect(&:id)).select('object_type').group_by {|obj| obj.object_type }
        # @object_values = @activities.group_by {|activity| activity.object.title}
        @targets = ActivityObject.where('type' => 'Target').where('activity_id' => @activities.collect(&:id)).select('object_type').group_by {|obj| obj.object_type }
        @target_values = ActivityObject.where('type' => 'Target').where('activity_id' => @activities.collect(&:id)).select('title').group_by {|obj| obj.title }
        @tags = Activity.where(:id => @activities.collect(&:id)).tag_counts_on(:tags)
      end
      @apps = ClientApplication.find(current_user.tokens.active.collect(&:client_application_id).uniq).reverse
    end
    
end
