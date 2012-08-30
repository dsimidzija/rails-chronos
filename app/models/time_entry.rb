class TimeEntry < ActiveRecord::Base
  include FormatUtility

  belongs_to :user
  belongs_to :project

  attr_accessible :project_id,
                  :entry_date_formatted,
                  :start_time_formatted,
                  :end_time_formatted,
                  :note

  validates_presence_of   :user_id, :project_id, :entry_date_formatted, :start_time_formatted
  validate                :start_time_before_end_time, :if => :both_timestamps_present?

  validates_format_of     :entry_date_formatted, :with => /^\d{2}\.\d{2}\.\d{4}$/
  validates_format_of     :start_time_formatted, :with => /^\d{2}:\d{2}$/
  validates_format_of     :end_time_formatted, :with => /^\d{2}:\d{2}$/,
                          :if => :both_timestamps_present?

  validate                :check_input_ranges

  def entry_date_formatted
    self.entry_date.strftime date_input_format unless self.entry_date.nil?
  end

  def entry_date_formatted=(value)
    return if value.nil? or value.blank?

    begin
      self.entry_date = DateTime.strptime(value, date_input_format).to_date
    rescue
      add_input_range_error(:entry_date)
    end
  end

  def start_time_formatted
    self.start_time.strftime time_input_format unless self.start_time.nil?
  end

  def start_time_formatted=(value)
    return if value.nil? or value.blank?

    begin
      self.start_time = DateTime.strptime(value, time_input_format)
    rescue
      add_input_range_error(:start_time)
    end
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

    begin
      self.end_time = DateTime.strptime(value, time_input_format)
    rescue
      add_input_range_error(:end_time)
    end
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
    (time_in_hours / (TimeEntry.workdays(entry_date) * 8)) * 100
  end

  def self.workdays(date)
    workdays = 0

    # workdays: monday to friday
    date.at_beginning_of_month.upto(date.at_end_of_month) do |day|
      workdays += 1 unless [0, 6].include?(day.wday) or day.holiday?(:hr)
    end

    workdays
  end

  protected

  def both_timestamps_present?
    start_time && end_time
  end

  def start_time_before_end_time
    errors.add(:end_time, 'cannot be before start time') unless end_time > start_time
  end

  def check_input_ranges
    return if @input_range_errors.nil?

    @input_range_errors.each do |key, value|
      errors.add(key.to_sym, value)
    end
    @input_range_errors = {}
  end

  def add_input_range_error(field)
    @input_range_errors = Hash.new if @input_range_errors.nil?
    @input_range_errors[field] = 'contains invalid values'
  end

end
