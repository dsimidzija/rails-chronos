class ReportsController < ApplicationController
  before_filter :login_required
  before_filter :user_allowed_access?

  def index
  end

  def month
    if params[:year] and params[:month]
      reference_date = DateTime.strptime("#{params[:year]}-#{params[:month]}", "%Y-%m").to_date
    else
      reference_date = DateTime.now
    end
    @start = reference_date.at_beginning_of_month
    @end = reference_date.at_end_of_month

    prepare_month_report
  end

  protected

  def prepare_month_report
    @entries = TimeEntry.where(
        :user_id => @current_user.id,
        :entry_date => @start..@end)
      .order(:entry_date => :asc, :start_time => :asc)

    @days_in_month = (@start..@end).to_a.size
    @workdays = @current_user.workdays(@start, @end)
    @workdays_in_past = @current_user.workdays(@start, 1.day.ago.to_date)
    @workdays_in_future = @current_user.workdays(Date.today, @end)

    @time_today = TimeEntry.where(
        :user_id => @current_user.id,
        :entry_date => Date.today.to_date)
      .map(&:time_in_hours).inject(0, :+)
    @time_periods = TimeEntry.time_periods_by_day(@start, @end, @entries)
    @time_periods_in_past = TimeEntry.time_periods_by_day(@start, 1.day.ago.to_date, @entries)
    @time_periods_by_project = TimeEntry.time_periods_by_day_and_project(@start, @end, @entries)

    @time_periods_sum = @time_periods.values.inject(0, :+)
    @time_periods_in_past_sum = @time_periods_in_past.values.inject(0, :+)

    @lunch_breaks = TimeEntry.detect_lunch_breaks_by_day(@start, @end, @entries, 30)
    @hours_per_day = 8
    @hours_required = (@workdays * @hours_per_day)
    @hours_required_with_breaks = @hours_required - @lunch_breaks.inject(0) {|res, item| item[1] ? (res+0.5) : res}
  end

end
