class ReportsController < ApplicationController
  before_filter :login_required
  before_filter :user_allowed_access?

  def current_month
    @today = Date.today
    @start = @today.at_beginning_of_month
    @end = @today.at_end_of_month
    @entries = TimeEntry.where(
        :user_id => @current_user.id,
        :entry_date => @start..@end)
      .order(:entry_date => :asc, :start_time => :asc)

    @times = monthly_times_by_day(@today, @entries)
    @workdays = TimeEntry.workdays(@today)
    @times_sum = @times.values.inject(0, :+)
  end

  protected

  def monthly_times_by_day(date, entries)
    times = {}

    for day in date.at_beginning_of_month..date.at_end_of_month
      day_entries = entries.select {|e| e.entry_date == day}
      times[day.day.to_s.to_sym] = day_entries.map(&:time_in_hours).inject(0, :+).round(2)
    end

    times
  end
end
