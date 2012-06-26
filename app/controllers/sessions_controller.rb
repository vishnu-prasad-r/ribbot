class SessionsController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def create
    if auth = request.env['omniauth.auth']
      note = nil
      user = User.find_or_create_from_omniauth( request.env['omniauth.auth'] ) do |u|
	note = 'Your account was imported!'
      end

      if user
	signin! user, note
      else
	flash.now.alert = "Can't login via #{auth.provider} with " +
	    "the Omniauth, because the remote account hasn't verified"
	render "new"
      end
    else
      user = User.first(conditions: {email: params[:email]})
      if user && user.authenticate(params[:password])
	signin! user
      else
	flash.now.alert = "Invalid email or password"
	render "new"
      end
    end
  end

  def destroy
    signout!
  end

end
