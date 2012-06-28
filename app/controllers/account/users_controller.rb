class Account::UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    authorize! :edit, current_forum

    respond_to do |format|
      format.html do
	@participations = current_forum.participations
	    .includes(:user)
	    .desc(:created_at)
	    .page(params[:page])
      end
      format.xls do
	render :xls => User.all,
	    :columns => [ :name, :email, :superuser, :location,
		:school, :website, :about ],
	    :headers => %w[ Name Email Superuser? Localtion School
		Website About ]
      end
    end
  end
end
