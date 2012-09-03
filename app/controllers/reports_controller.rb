class ReportsController < ApplicationController
  before_filter :login_required
  before_filter :user_allowed_access?

  def index
  end

  def month
    reference_date = DateTime.strptime("#{params[:year]}-#{params[:month]}", "%Y-%m").to_date
    @start = reference_date.at_beginning_of_month
    @end = reference_date.at_end_of_month

    @entries = TimeEntry.where(
        :user_id => @current_user.id,
        :entry_date => @start..@end)
      .order(:entry_date => :asc, :start_time => :asc)

    @days_in_month = (@start..@end).to_a.size
    @workdays = TimeEntry.workdays(@start, @end)
    @workdays_in_past = TimeEntry.workdays(@start, 1.day.ago.to_date)
    @workdays_in_future = TimeEntry.workdays(Date.today, @end)

    @time_today = TimeEntry.where(
        :user_id => @current_user.id,
        :entry_date => Date.today.to_date)
      .map(&:time_in_hours).inject(0, :+)
    @times = TimeEntry.times_by_day(@start, @end, @entries)
    @times_by_project = TimeEntry.times_by_day_and_project(@start, @end, @entries)
    @times_sum = @times.values.inject(0, :+)
  end

end
