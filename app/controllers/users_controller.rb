class UsersController < ApplicationController
  before_filter :find_user, :except => [:new, :create]
  before_filter :login_required, :except => [:new, :create]
  before_filter :confirm_user_owns_record, :except => [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if not @user.save
      flash.now[:notice] = 'Could not complete the registration'
      render :action => 'new'
      return
    end

    @current_user = @user
    session[:user] = @user.id

    flash[:success] = 'Successfully registered'
    redirect_to user_path(@user)
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = 'Profile updated'
      redirect_to user_path(@user)
    else
      flash.now[:notice] = 'Could not save your profile'
      render :action => 'edit'
    end
  end

  def show
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def confirm_user_owns_record
    redirect_to new_session_path unless logged_in?

    if @user.id != @current_user.id
      flash[:error] = 'You\'re not allowed to go there'
      redirect_to user_path(@current_user)
    end
  end
end
