class PeopleController < ApplicationController
  before_filter :login_required
  
  def index
    @people = Person.deduped(current_user.id).sort(:intensity.asc).paginate(limit: 100, page: params[:page] || 1)
  end
  
  def show
    @person = Person.where(id: params[:id], user_id: current_user.id).first
    respond_to do |format|
      format.html {}
      format.json {
        render json: @person
      }
    end
  end
    
  def highjack
    target = Person.where(id: params[:id].to_s, user_id: current_user.id).first
    if highjacker = Person.where(id: params[:highjacker_id].to_s, user_id: current_user.id).first
      highjacker.highjack!(target)
      redirect_to highjacker, notice: "Highjacked!"
    else
      redirect_to :back, alert: "There was an error with your highjack."
    end
  end
    
  def release
    target = Person.where(id: params[:id], user_id: current_user.id).first
    if highjacker = Person.where(id: params[:highjacker_id].to_s, user_id: current_user.id).first
      highjacker.release!(target)
      redirect_to highjacker, notice: "Released!"
    else
      redirect_to :back, alert: "There was an error with your release."
    end
  end
  
  def activities
    @person = Person.find(params[:id])
    @items = @person.all_activities
    benchmark 'Fetching items' do
      request_filter = params[:filter]
      @items = @items.api_filter(current_user, request_filter)
      unless request_filter.present? and request_filter['between'].present? and request_filter['between']['start'].present? and request_filter['between']['finish'].present?
        @items = @items.paginate({
          :order    => :published_epoch.desc,
          :per_page => params['limit'] || params['per_page'] || 30,
          :page     => params['page'] || 1,
        })
      end
    end
    
    benchmark 'Formatting items' do
      requested_fields = (params[:filter].present? and params[:filter][:fields].present?) ? params[:filter][:fields] : nil
      @items_as_json = {
        data: { person: @person.as_json, items: @items.as_json(:only =>  requested_fields) }
      }
    end
    
    respond_to do |format|
      format.json {
        render json: @items_as_json, callback: params[:callback].present? ? params[:callback] : false
      }
    end
  end
  
end