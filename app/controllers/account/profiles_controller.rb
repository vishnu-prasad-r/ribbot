class Account::ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_superuser, :only => :update,
      :if => lambda {|c| !params[:user_id].blank?}
  
  def show
    @user = current_user
    render :locals => {:admin_update => false}
  end
  
  def update
    @user = (id = params[:user_id]) && User.find(id) || current_user
    path = id && account_users_path || account_profile_path
    authorize! :edit, @user
    
    if @user.update_attributes(params[:user])
      redirect_to path, :notice => "Profile updated!"
    else
      redirect_to path, :notice => @user.errors.full_messages.join(" ")
    end
  end
end
