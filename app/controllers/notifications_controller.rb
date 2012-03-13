class NotificationsController < ApplicationController
  before_filter :manybots_oauth_required, :only => [:create, :index, :show]
  before_filter :authenticate_user!, :except => [:create, :index, :show]
  
  def index
    if params[:format] == 'json'
      @notifications = current_user.notifications.unread.timeline.paginate(:per_page => 10, :page => params[:page])
    end
   
    respond_to do |format|
      format.html {}
      format.json { 
        render :json => {:data => {:items =>@notifications}}, :callback => params[:callback].present? ? params[:callback] : false
      }
    end
  end
  
  def all
    if params[:format] == 'json'
      @notifications = current_user.notifications.unread.timeline.paginate(:per_page => 10, :page => params[:page])
    end
   
    respond_to do |format|
      format.html {}
      format.json { 
        render :json => {:data => {:items =>@notifications}}, :callback => params[:callback].present? ? params[:callback] : false
      }
    end    
  end
   
  def show
    @notification = current_user.notifications.find(params[:id])
   
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notification }
      format.json { render :json => @notification}
    end
  end
  
  def toggle_read
    @notification = current_user.notifications.find(params[:id])
    @notification.update_attribute :is_read, !@notification.is_read?
    render :json => @notification
  end
   
  def new
    # @notification = current_user.notifications.new
    #    
    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.xml  { render :xml => @notification }
    # end
  end
   
  def edit
    @notification = current_user.notifications.find(params[:id])
  end
   
  def create
    @notification = current_user.notifications.new_from_json_v1_0(params, (current_client_application.id rescue(nil)) )
   
    respond_to do |format|
      if @notification.save
        format.json { render :json => @notification }
      else
        format.json  { render :json => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end
   
  def update
    @notification = current_user.notifications.find(params[:id])
   
    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        flash[:notice] = 'Notification was successfully updated.'
        format.html { redirect_to(@notification) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end
   
  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
   
    respond_to do |format|
      format.html { redirect_to(notifications_url) }
      format.xml  { head :ok }
    end
  end
end
