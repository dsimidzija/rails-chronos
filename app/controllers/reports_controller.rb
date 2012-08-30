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

    @times = monthly_times_by_day(reference_date, @entries)
    @times_by_project = monthly_times_by_day_and_project(reference_date, @entries)
    @days_in_month = (@start..@end).to_a.size
    @workdays = TimeEntry.workdays(reference_date)
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

  def monthly_times_by_day_and_project(date, entries)
    times = {}

    for day in date.at_beginning_of_month..date.at_end_of_month
      day_entries = entries.select {|e| e.entry_date == day}

      day_entries.each do |d|
        times[d.project.name] = {} unless times[d.project.name].is_a?(Hash)
        times[d.project.name][day.day.to_s.to_sym] = 0 if times[d.project.name][day.day.to_s.to_sym].nil?
        times[d.project.name][day.day.to_s.to_sym] += d.time_in_hours
      end
    end

    (date.at_beginning_of_month..date.at_end_of_month).each do |date|
      times.each do |project, day|
        times[project][date.day.to_s.to_sym] = 0 unless times[project][date.day.to_s.to_sym].is_a?(Numeric)
      end
    end

    times
  end
end
