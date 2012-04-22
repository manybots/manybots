class AggregationsController < ApplicationController
  
  before_filter :login_required
  
  def index
    @aggregations = current_user.aggregations.order('total desc')#.limit()
  end
  
  def show
    @aggregations = current_user.aggregations.match(params[:id])
    @aggregation = @aggregations.first
    @visualizations = load_related_apps(@aggregations)
    
    @notifications_count = @aggregation.notifications.count #rescue(0)
    @predictions_count = @aggregation.predictions.count #rescue(0)
    
    
    aggregations_sql = Aggregation.bundled_activities(current_user.id, @aggregations.collect(&:id))
    @activities = Activity.paginate_by_sql(aggregations_sql.to_sql, :per_page => 10, :page => params[:page])

    @count = @activities.total_entries rescue(@activities.count)
  end
  
  def aggregates
    @aggregation = current_user.aggregations.find(params[:id])
    @activities = @aggregation.activities.timeline.scoped
    @aggregates = load_aggregates
  end
  
  def filter
    @type_string = params[:id]
    @aggregations = current_user.aggregations.where(:type_string => @type_string).order('aggregations.total DESC')
  end
  
  def activities
    @aggregation = current_user.aggregations.find(params[:id])
    @activities = @aggregation.activities.timeline.includes(:user,:actor,:object,:target,:tags).paginate(:page => params[:page], :per_page => params[:per_page] || 10)
    items = {}
    Activity.benchmark 'ACTIVITY TO JSON BENCHMARK' do
      items = {
        data: {
          totalItems: @activities.total_entries, 
          count: @activities.length,
          items: @activities
        },
        pagination: {current_page: @activities.current_page, per_page: @activities.per_page, next_page: @activities.next_page, previous_page: @activities.previous_page, total_pages: @activities.total_pages}
      }
    end
    respond_to do |format|
      format.html {}
      format.json { render :json => items.to_json }
    end
  end
  
  def notifications
    @aggregation = current_user.aggregations.find(params[:id])
    @notifications = @aggregation.notifications.timeline.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html {}
      format.json { render :json => {:data => {:items =>@notifications}} }
    end
  end
  
  def predictions
    @aggregation = current_user.aggregations.find(params[:id])
    @predictions = @aggregation.predictions.timeline.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html {}
      format.json { render :json => {:data => {:items =>@predictions}} }
    end
  end
  
  def bundle
    @activities = load_bundles
    logger.info @activities.class
    @aggregates = load_aggregates
    @visualizations = load_related_apps(@aggregations)
    @activities = @activities.paginate(:page => params[:page], :per_page => 10) unless 
        @activities.is_a? WillPaginate::Collection
    logger.info @activities.class
    
    @count = @activities.total_entries rescue(@activities.count)
    render
  end
  
  def bundle_aggregates
    @activities = load_bundles
    logger.info @activities.class
    @aggregates = load_aggregates
    render 'aggregates'
  end
  
  def destroy
    @aggregation = current_user.aggregations.find(params[:id])
    @aggregation.activities.find_each{|a| 
      a.aggregations.find_each{|g| g.update_attribute :total, (g.total - 1)}
      a.destroy
    }
    @aggregation.destroy
    redirect_to aggregations_path, :notice => "Deleted all activities related to #{@aggregation.name}."
  end
  
  protected
  
    def match
      if params[:id].match '\+'
        @match = 'reunion'
        @match_symbol = '+'
        params_id = params[:id].split('+')
      elsif params[:id].match '&'
        @match = 'intersection'
        @match_symbol = '&'
        params_id = params[:id].split('&').collect(&:to_i).flatten
      end
      params_id
    end
  
    def load_bundles
      params_id = match
      @aggregations = current_user.aggregations.where(:id => params_id).to_a
      raise ActiveRecord::RecordNotFound if @aggregations.empty?
      
      activities = case @match
      when 'intersection'
        aggregations_sql = Aggregation.bundled_activities(current_user.id, params_id)
        Activity.paginate_by_sql(aggregations_sql.to_sql, :per_page => 10, :page => params[:page])
      else
        current_user.activities.joins(:aggregations).where('activities_aggregations.aggregation_id' => params_id).
        timeline.scoped
      end
      @params_id = params_id
      activities
    end
    
    def load_aggregates
      params_id = params[:id].split(@match_symbol)
      if ['&', nil].include? @match_symbol
        Aggregation.aggregates_for_intersection(params_id)
      else
        aggregates = @activities.scoped.select('activities.id').collect(&:id)
        current_user.aggregations.joins(:activities).
          where('activities.id' => aggregates).
          where('"aggregations".id NOT IN (?)', params[:id].split(@match_symbol)).
          uniq        
      end
    end
    
    def load_related_apps(aggregations)
      visualizations = current_user.installed_applications.in_library.collect(&:client_application)
      aggregates = Aggregation.aggregates_for_intersection(aggregations.collect(&:id))
      related = aggregates.collect(&:name)
      apps = visualizations.collect {|v|
        v if v.target_objects.split(',').collect do |target|
          true if related.include?(target) or v.target_objects == 'all' or aggregations.collect(&:name).include? target
        end.include? true
      }
      apps.uniq.compact
    end
  
end
