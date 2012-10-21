class ItemsController < ApplicationController
  before_filter :authenticate_user!
  
  def index    
    benchmark 'Fetching items' do
      request_filter = params[:filter]
      @items = Item.api_filter(current_user, request_filter)
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
        data: { items: @items.as_json(:only =>  requested_fields) }
      }
    end
    
    respond_to do |format|
      format.json {
        render json: @items_as_json, callback: params[:callback].present? ? params[:callback] : false
      }
    end
  end
  
end
