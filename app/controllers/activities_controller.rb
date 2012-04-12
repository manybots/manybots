class ActivitiesController < ApplicationController
  before_filter :manybots_oauth_required, :only => [:me, :filter, :create, :index, :show]
  before_filter :authenticate_user!, :except => [:me, :filter, :create, :index, :show]

  # FIXME: THIS SHOULDN'T BE HERE, 
  # it should be in the Users Controller but it doesn't exist :P
  def me
    logger.info current_user.inspect
    user = current_user
    render :json => user.to_json(:only => [:id, :name, :email, :avatar_url])
  end
  
  def bundle
    if params[:filters].present? and params[:filters].any?
      activities_ids = Bundle.activities_from_raw_bundle(current_user.id, params[:filters], @start_date, @finish_date)
      items = {:data => {:items => []}}
      activities_count = activities_ids.count
      @activities = Activity.where(:id => activities_ids).order('posted_time DESC').scoped
      @activities = @activities.scoped.paginate(:per_page => (params[:per_page] || 10), :page => params[:page], :total_entries => activities_count)
      @activities.each do |activity|
        items[:data][:items].push activity.as_activity_v1_0
      end
      render :json => items.to_json
    else
      render :json => {:errors => ['filters', 'parameter must be a non-empty array']}, :status => 422
    end
  end
  
  def filter
    if params[:filter].present?
      @filter = ActivityFilter.new(params[:filter])
      @activities = Activity.new_advanced_filter(current_user.id, @filter.options, @start_date, @finish_date, '').scoped
      if params[:filter][:tags].present?
        @activities = @activities.scoped.tagged_with(params[:filter][:tags]).scoped
      end
      items = {:data => {:items => []}}
      activities_count = @activities.count
      activities_count = activities_count.to_i rescue activities_count.to_a.size
      @activities = @activities.scoped.paginate(:per_page => (params[:per_page] || 10), :page => params[:page], :total_entries => activities_count)
      @activities.each do |activity|
        items[:data][:items].push activity.as_activity_v1_0
      end
      render :json => items.to_json
    else
      render :json => {:errors => ['filter', 'parameter must be present']}, :status => 422
    end
  end
  
  def current
    items = {:data => {:items => []}, :filter => {}}
    if session[:current_aggregation].present?
      aggregation = current_user.aggregations.find(session[:current_aggregation])
      the_filter = [aggregation.id]
      aggregations_sql = Aggregation.bundled_activities(current_user.id, the_filter)
      @activities = Activity.paginate_by_sql(aggregations_sql.to_sql, :per_page => params[:limit] || params[:per_page] || 30, :page => params[:page])
      items[:filter][aggregation.type_string.singularize] = aggregation.name
      items[:data][:items] = @activities.collect(&:as_activity_v1_0)
      
    end
    render :json => items.to_json, :callback => params[:callback].present? ? params[:callback] : false
  end
  
  # GET /activities
  # GET /activities.xml
  def index
    if params[:filter].present?
      the_filter = Aggregation.find_aggregations_for_user_and_params(current_user, params[:filter], true)
      aggregations_sql = Aggregation.bundled_activities(current_user.id, the_filter)
      @activities = Activity.paginate_by_sql(aggregations_sql.to_sql, :per_page => params[:limit] || params[:per_page] || 30, :page => params[:page])
      if params[:filter][:tags].present?
        if @activities.any?
          activities_id = @activities.collect(&:id)
          @activities = Activity.where(id: activities_id).
            tagged_with(params[:filter][:tags]).
            per_page(params[:limit] || 30).
            page(params[:page])
        else
          @activities = current_user.activities.tagged_with(params[:filter][:tags]).
            paginate(:per_page => params[:limit] || 30, :page => params[:page] || 1)
        end
      end
    else
      @activities = current_user.activities.scoped.between(params[:start], params[:end]).
        order("activities.posted_time DESC").scoped
      activities_count = @activities.count
      activities_count = activities_count.to_i rescue activities_count.to_a.size
      @activities = @activities.scoped.paginate(:per_page => 10, :page => params[:page], :total_entries => activities_count)
    end
    
    if params[:format] == 'js'
      @activities = Activity.to_calendar(@activities.includes(:object,:target))
    elsif params[:format] == 'html' or params[:format].nil?
      @apps = ClientApplication.where(is_public: true)
    elsif params[:format] == 'json'
      items = {:data => {:items => []}}
      items[:data][:items] = @activities.collect(&:as_activity_v1_0)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
      format.json { render :json => items.to_json, :callback => params[:callback].present? ? params[:callback] : false}
      format.js { render :json => @activities.to_json}
    end
  end

  # GET /activities/1
  # GET /activities/1.xml
  def show
    @activity = Activity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity }
      format.json  { render :json => @activity.to_json }
      format.js { render :partial => 'activity_calendar', :locals => {:activity => @activity} }
    end
  end

  # GET /activities/new
  # GET /activities/new.xml
  def new
    @activity = Activity.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end
  
  def preview
    @activity = current_user.activities.new(params[:activity])
    @activity.auto_title!    
    respond_to do |format|
      if @activity.valid?
        format.html { render :partial => 'activity', :locals => {:activity => @activity} }
      else
        format.html { render :partial => 'simple_form', :status => :unprocessable_entity }
      end
    end
  end

  # GET /activities/1/edit
  def edit
    @activity = Activity.find(params[:id])
  end

  # POST /activities
  # POST /activities.xml
  def create
    if current_user
      begin
        this_application = current_application 
      rescue
        if params[:client_application_id].present?
          this_application = ClientApplication.find(params[:client_application_id])
        else
          this_application = nil
        end
      end
      if params[:format] == "json" or params['format'] == 'json'
        if (params[:version].present? and params[:version] == '1.0') or params['version'].present? and params['version'] == '1.0'
          @activity = current_user.activities.new_from_json_v1_0(params,current_user, (this_application.id rescue(nil)))
        end
        if params[:activity][:auto_title].present? or params['activity']['auto_title'].present?
          @activity.auto_title!
        end
      else
        @activity = current_user.activities.new(params[:activity])
      end
    else
      raise 'Unauthorized'
    end
    respond_to do |format|
      if @activity.save
        format.html { redirect_to(@activity, :notice => 'Activity was successfully created.') }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
        format.json  { render :json => @activity.to_json, :status => :created, :location => @activity }
      else
        # logger.info @activity.errors.inspect
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
        format.json  { render :json => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.xml
  def update
    @activity = Activity.find(params[:id])

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        format.html { redirect_to(@activity, :notice => 'Activity was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.xml
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to(activities_url) }
      format.xml  { head :ok }
    end
  end
end
