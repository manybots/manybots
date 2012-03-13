class FiltersController < ApplicationController

  before_filter :authenticate_user!
    
  def new
    @new_filter = current_user.filters.new
    @filter = ActivityFilter.new(params[:filter])
    @filters = current_user.filters.order('created_at DESC').limit(5)

    load_periodical_activities

    if params[:filter].present?
      @activities = Activity.new_advanced_filter(current_user.id, @filter.options, @start_date, @finish_date, 'activities.id, activities.posted_time, activities.verb').scoped
      if params[:filter][:tags].present?
       @activities = @activities.scoped.tagged_with(params[:filter][:tags]).scoped
      end
    end

     load_details
  end
  
  private 
  
    def load_periodical_activities
      @oldest = current_user.activities.oldest.first.posted_time.beginning_of_day
      @latest = current_user.activities.latest.first.posted_time.end_of_day
      if @latest > Date.today
        @latest = Time.now.end_of_day
      end
      
      if params[:period].present?
        @start_date = Date.civil(params[:period][:"start(1i)"].to_i,params[:period][:"start(2i)"].to_i,params[:period][:"start(3i)"].to_i).beginning_of_day_in_zone
        @finish_date = Date.civil(params[:period][:"end(1i)"].to_i,params[:period][:"end(2i)"].to_i,params[:period][:"end(3i)"].to_i).end_of_day_in_zone
      else
        if params[:filter].present?
          if params[:filter][:start_date].present?
            @start_date = Date.civil(params[:filter][:start_date][:year].to_i,params[:filter][:start_date][:month].to_i,params[:filter][:start_date][:day].to_i).beginning_of_day_in_zone
          else
            @start_date = @oldest
          end
          if params[:filter][:end_date].present?
            @finish_date = Date.civil(params[:filter][:end_date][:year].to_i,params[:filter][:end_date][:month].to_i,params[:filter][:end_date][:day].to_i).beginning_of_day_in_zone
          else
            @finish_date = @latest
          end
        else
          @start_date = (Time.zone.now).beginning_of_day.beginning_of_month
          @finish_date = @start_date.end_of_month.end_of_day
        end
      end
      unless params[:filter].present?
        @activities = current_user.activities.scoped.
          between(@start_date, @finish_date).select('id, posted_time, verb')
      end
    end

    def load_details
      if @activities
        @verbs = @activities.group_by {|activity| activity.verb }
        @objects = ActivityObject.where('type' => 'Obj').where('activity_id' => @activities.collect(&:id)).select('object_type').group_by {|obj| obj.object_type }
        # @object_values = @activities.group_by {|activity| activity.object.title}
        @targets = ActivityObject.where('type' => 'Target').where('activity_id' => @activities.collect(&:id)).select('object_type').group_by {|obj| obj.object_type }
        @target_values = ActivityObject.where('type' => 'Target').where('activity_id' => @activities.collect(&:id)).select('title').group_by {|obj| obj.title }
        @tags = Activity.where(:id => @activities.collect(&:id)).tag_counts_on(:tags)
      end
      @apps = ClientApplication.find(current_user.tokens.active.collect(&:client_application_id)).reverse
    end
end
