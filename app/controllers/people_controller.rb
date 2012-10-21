class PeopleController < ApplicationController
  before_filter :login_required
  
  def index
    @people = Person.where(user_id: current_user.id, highjacked: [false, nil]).sort(:name.asc).paginate(limit: 100, page: params[:page] || 1)
  end
  
  def show
    @person = Person.where(id: params[:id], user_id: current_user.id).first
  end
  
  def highjack
    @person = Person.where(id: params[:id], user_id: current_user.id).first
    if highjacker = Person.where(id: params[:highjacker_id].to_s, user_id: current_user.id).first
      @person.highjack!(highjacker.id)
      redirect_to highjacker, notice: "Highjacked!"
    else
      redirect_to :back, alert: "There was an error with your highjack."
    end
  end
  
  def release
    @person = Person.where(id: params[:id], user_id: current_user.id).first
    if highjacker = Person.where(id: params[:highjacker_id].to_s, user_id: current_user.id).first
      @person.release!
      highjacker.update_with_highjacks!
      redirect_to @person, notice: "Released!"
    else
      redirect_to :back, alert: "There was an error with your release."
    end
  end
  
end