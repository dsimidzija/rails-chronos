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

  def user_allowed_access?
#    params.each do |k, v|
#      logger.debug "#{k} = #{v}"
#    end
#    logger.debug @current_user.id
#    logger.debug params[:user_id]

    return unless params.has_key?(:user_id)
    redirect_to root_path if params[:user_id].blank?

    if not @current_user.id == params[:user_id].to_i
      new_params = params.clone
      new_params[:user_id] = @current_user.id
      redirect_to new_params
    end
  end

  def load_user
    @current_user = User.find_by_id(session[:user]) if session[:user]
  end
end
