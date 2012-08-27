class TimeEntry < ActiveRecord::Base
  include FormatUtility

  belongs_to :user
  belongs_to :project

  attr_accessible :project_id, :entry_date_formatted, :start_time_formatted, :end_time_formatted, :note

  validates_presence_of   :user_id, :project_id, :entry_date_formatted, :start_time_formatted
  validate                :start_time_before_end_time, :if => :both_timestamps_present?
  validates_format_of     :entry_date_formatted, :with => /^\d{2}\.\d{2}\.\d{4}$/
  validates_format_of     :start_time_formatted, :with => /^\d{2}:\d{2}$/
  validates_format_of     :end_time_formatted, :with => /^\d{2}:\d{2}$/, :if => :both_timestamps_present?

  def entry_date_formatted
    self.entry_date.strftime date_input_format unless self.entry_date.nil?
  end

  def entry_date_formatted=(value)
    return if value.nil? or value.blank?
    self.entry_date = DateTime.strptime(value, date_input_format)
  end

  def start_time_formatted
    self.start_time.strftime time_input_format unless self.start_time.nil?
  end

  def start_time_formatted=(value)
    return if value.nil? or value.blank?
    self.start_time = DateTime.strptime(value, time_input_format)
  end

  def end_time_formatted
    return self.end_time.strftime time_input_format unless self.end_time.nil?
  end

  def end_time_formatted=(value)
    # allow blanking end time
    if value.nil? or value.blank?
      self.end_time = nil
      return
    end

    self.end_time = DateTime.strptime(value, time_input_format)
  end

  def time_in_hours
    return [(end_time - start_time).to_f / (60 * 60), 0.0].max unless end_time.nil?

    # calculate the difference from current time
    time_now = Time.now
    current_end_time = start_time.change(:hour => time_now.hour, :min => time_now.min)
    [(current_end_time - start_time).to_f / (60 * 60), 0.0].max
  end

  def percent_of_day
    (time_in_hours / 8) * 100
  end

  def percent_of_month
    workdays = 0

    # workdays: monday to friday
    entry_date.at_beginning_of_month.upto(entry_date.at_end_of_month) do |day|
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
