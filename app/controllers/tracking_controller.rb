class TrackingController < ApplicationController
  before_filter :login_required
  before_filter :user_allowed_access?

  def dashboard
    find_tracking_entries
    @tracking = Tracking.new
  end

  def start
    @tracking = Tracking.new(params[:tracking])
    @tracking.user_id = @current_user.id

    unless @tracking.valid?
      find_tracking_entries
      flash.now[:notice] = 'Could not start tracking'
      render :action => 'dashboard'
      return
    end

    unless @tracking.start
      find_tracking_entries
      flash.now[:error] = 'Could not start tracking'
      render :action => 'dashboard'
      return
    end

    flash[:info] = 'Tracking started'
    redirect_to :action => 'dashboard'
  end

  protected

  def find_tracking_entries
    @time_entries = TimeEntry.find(:all, :conditions => { :end_time => nil })
  end
end
