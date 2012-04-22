class VisualizationsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    VisualizationApp.load_all
    @installed_applications = current_user.installed_applications
    @visualizations = ClientApplication.visualizations
  end
  
  def install
    installed = InstalledApplication.find_or_initialize_by_user_id_and_client_application_id(current_user.id, params[:id])
    if installed.new_record?
      installed.in_library = installed.client_application.in_library
      installed.in_menu = installed.client_application.in_menu
      installed.is_default = false
      installed.save
      redirect_to visualization_path(installed.client_application.id), notice: "#{installed.client_application.name} installed."
    else
      redirect_to visualizations_path, alert: 'View was already installed.'
    end
  end
  
  def uninstall
    installed = InstalledApplication.find_or_initialize_by_user_id_and_client_application_id(current_user.id, params[:id])
    installed.destroy
    redirect_to visualizations_path, notice: "#{installed.client_application.name} uninstalled."
  end
  
  def show
    @inline = false
    if params[:aggregation_id].present?
      @inline = true
      session.delete :current_aggregations
      session[:current_aggregation] = params[:aggregation_id] 
    else
      session.delete :current_aggregation
    end
    
    if params[:bundle_id].present?
      @inline = true
      session.delete :current_aggregation
      session[:current_aggregations] = CGI.unescape params[:bundle_id] 
    else
      session.delete :current_aggregations
    end
    
    @visualization = ClientApplication.where(:app_type => 'Visualization').where(:id => params[:id]).first
    logger.info "SESSION #{session.inspect}"
  end
  
  def new
    @visualization = current_user.client_applications.new
    @visualization.app_type = 'Visualization'
  end
  
  def create
    @visualization = current_user.client_applications.build(params[:client_application])
    
    if @visualization.save
      flash[:notice] = "Visualization created."
      redirect_to :action => "show", :id => @visualization.id
    else
      render :action => "new"
    end
  end
  
  def update
    @visualization = ClientApplication.find(params[:id])
    if @visualization.update_attributes(params[:client_application])
      flash[:notice] = "Visualization updated."
      redirect_to :action => "show", :id => @visualization.id
    else
      render :action => "edit"
    end
  end
  
  
  def edit
    @installed_application = InstalledApplication.find_by_user_id_and_client_application_id(current_user.id, params[:id])
    @visualization = @installed_application.client_application
  end
  
  def destroy
    @visualization = ClientApplication.find(params[:id])
    @visualization.destroy
    redirect_to visualizations_path, :notice => 'Visualization deleted.'
  end
end
