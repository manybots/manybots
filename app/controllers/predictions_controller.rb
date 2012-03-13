class PredictionsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def index
    if params[:format] == 'json'
      @predictions = current_user.predictions.order('published DESC').paginate(:per_page => 10, :page => params[:page])
    end
   
    respond_to do |format|
      format.html {}
      format.json { 
        render :json => {:data => {:items =>@predictions}}, :callback => params[:callback].present? ? params[:callback] : false
      }
    end
    
  end
  
  def predict
    prediction = current_user.activities.find(activity_id).as_prediction
    current_user.activities.new_from_json_v1(prediction)
  end
  
  def show
    @prediction = current_user.predictions.find(params[:id])
   
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @prediction }
      format.json { render :json => @prediction}
    end
    
  end

end
