class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_user

  helper_method :logged_in?

  protected

  def logged_in?
    @current_user.is_a?(User)
  end

  def login_required
    redirect_to new_session_path unless logged_in?
  end

  def load_user
    @current_user = User.find_by_id(session[:user]) if session[:user]
  end
end
