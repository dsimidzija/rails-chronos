class SessionsController < ApplicationController
  before_filter :login_required, :except => [:new, :create]

  def new
  end

  def create
    @current_user = User.authenticate(params[:email], params[:password])

    if @current_user
      session[:user] = @current_user.id
      flash[:info] = 'Login successful'

      redirect_to user_path(@current_user)
    else
      flash.now[:notice] = 'Could not log you in'
      render :action => 'new'
    end
  end

  def destroy
    reset_session

    flash[:info] = 'Logged out successfully'
    redirect_to :root
  end
end
