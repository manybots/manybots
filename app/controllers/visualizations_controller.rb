class VisualizationsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @visualizations = ClientApplication.visualizations.are_trusted
    @my_visualizations = current_user.client_applications.where(:app_type => 'Visualization')
  end
  
  def show
    @visualization = ClientApplication.where(:app_type => 'Visualization').where(:id => params[:id]).first
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
    @visualization = current_user.client_applications.find(params[:id])
    if @visualization.update_attributes(params[:client_application])
      flash[:notice] = "Visualization updated."
      redirect_to :action => "show", :id => @visualization.id
    else
      render :action => "edit"
    end
  end
  
  
  def edit
    @visualization = current_user.client_applications.find(params[:id])
  end
  
  def destroy
    @visualization = current_user.client_applications.find(params[:id])
    @visualization.destroy
    redirect_to visualizations_path, :notice => 'Visualization deleted.'
  end
end
