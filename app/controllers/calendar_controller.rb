class CalendarController < ApplicationController
  
  before_filter :authenticate_user!
  
  def index

    if params[:format] == 'js'
      @activities = current_user.activities.scoped.between(params[:start], params[:end]).
        order("activities.posted_time DESC").scoped
      
      @activities = Activity.to_calendar(@activities.includes(:object,:target))
    end
    
    respond_to do |format|
      format.html {}
      format.js   { render :json => @activities.to_json }
    end
    
    
  end
    
  def yesterday
    @start_date = Time.now.beginning_of_day - 1.day
    @finish_date = @start_date.end_of_day
    @apps = ClientApplication.where(is_public: true)
    if params[:what].nil? or params[:what] == 'activities'
      @items = current_user.activities.between(@start_date, @finish_date).timeline
    elsif params[:what] == 'notifications'
      @items = current_user.notifications.between(@start_date, @finish_date).timeline
    elsif params[:what] == 'predictions'
      @items = current_user.predictions.between(@start_date, @finish_date).timeline
    end
    
    respond_to do |format|
      format.html {}
      format.json { render json:{data:{:items => @items} } }
    end
    
  end
  
  def tomorrow
    @start_date = Time.now.beginning_of_day + 1.day
    @finish_date = @start_date.end_of_day
    @apps = ClientApplication.where(is_public: true)
    @items = current_user.predictions.between(@start_date, @finish_date).timeline
    respond_to do |format|
      format.html {}
      format.json { render json:{data:{:items => @items} } }
    end
    
  end
  
  def today
    @start_date = Time.now.beginning_of_day
    @finish_date = @start_date.end_of_day
    @apps = ClientApplication.where(is_public: true)
    if params[:what].nil? or params[:what] == 'activities'
      @items = current_user.activities.between(@start_date, @finish_date).timeline
    elsif params[:what] == 'notifications'
      @items = current_user.notifications.between(@start_date, @finish_date).timeline
    elsif params[:what] == 'predictions'
      @items = current_user.predictions.between(@start_date, @finish_date).timeline
    end
    
    respond_to do |format|
      format.html {}
      format.json { render json:{data:{:items => @items} } }
    end
  end
  
  def show
  end
  
  def day

    if params[:filter]
      filtered = params[:filter]
      filtered.delete :start_date
      filtered.delete :end_date
    
      @filter = ActivityFilter.new(filtered)
    end
    
    @start_date = Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i).to_time.beginning_of_day#_in_zone#.to_time
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
    
    if params[:what].nil? or params[:what] == 'activities'
      @items = current_user.activities.between(@start_date, @finish_date).timeline
    elsif params[:what] == 'notifications'
      @items = current_user.notifications.between(@start_date, @finish_date).timeline
    elsif params[:what] == 'predictions'
      @items = current_user.predictions.between(@start_date, @finish_date).timeline
    end
    
    if params[:format] == 'js'
      @activities = Activity.to_calendar(@activities) 
    else
      load_details
    end
    
    respond_to do |format|
      format.html {}
      format.json { render json:{data:{:items => @items} } }
      format.js   { render :json => @activities.to_json }
    end
  end
  
    
  def year
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
