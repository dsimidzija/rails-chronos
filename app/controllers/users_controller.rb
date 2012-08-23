class UsersController < ApplicationController
  before_filter :find_user, :except => [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if not @user.save
      render :action => 'new'
      return
    end

    @current_user = @user
    session[:user] = @user.id

    flash[:notice] = 'Successfully registered'
    redirect_to user_path(@user)
  end

  def edit
  end

  def update
  end

  def show
  end

  private

  def find_user
    @user = User.find(params[:id])
  end
end
