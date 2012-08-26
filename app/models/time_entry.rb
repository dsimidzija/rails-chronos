class TimeEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  attr_accessible :project_id, :entry_date, :start_time, :end_time, :note

  validates_presence_of   :user_id, :project_id, :entry_date, :start_time
  validates_presence_of   :user_id, :project_id, :entry_date, :start_time, :end_time, :on => :update
  validate                :start_time_before_end_time, :if => :both_timestamps_present?
  validates_format_of     :entry_date, :with => /^\d{2}\.\d{2}\.\d{4}$/
  validates_format_of     :start_time, :with => /^\d{2}:\d{2}$/
  validates_format_of     :end_time, :with => /^\d{2}:\d{2}$/

  def time_in_hours
    (end_time - start_time).to_f / (60 * 60)
  end

  def percent_of_day
    time_in_hours / 8
  end

  def percent_of_month
    month_start = Date.new(entry_date.year, entry_date.month, 1)
    month_end = Date.new(entry_date.year, entry_date.month, -1)
    workdays = 0

    # workdays: monday to friday
    month_start.upto(month_end) do |day|
      workdays += 1 unless [0, 6].include?(day.wday)
    end

    (time_in_hours / (workdays * 8)) * 100
  end

  protected

  def both_timestamps_present?
    start_time && end_time
  end

  def start_time_before_end_time
    errors.add(:end_time, 'cannot be before start time') unless end_time > start_time
  end
end
