class TrackingController < ApplicationController
  before_filter :login_required
  before_filter :user_allowed_access?

  def dashboard
    find_tracking_entries
    @tracking = Tracking.new unless @time_entries.any?
    @tracking = @time_entries.first if @time_entries.any?
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

  def stop
    Tracking.stop(params[:id])
    redirect_to :action => 'dashboard'
  end

  protected

  def find_tracking_entries
    @time_entries = TimeEntry.find(:all,
      :conditions => {
        :entry_date => Date.today,
        :end_time => nil,
        :user_id => @current_user.id
      },
      :order => { :start_time => :asc })
  end
end
