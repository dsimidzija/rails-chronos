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

  def percent_of_month(user)
    (time_in_hours / (user.workdays(entry_date) * 8)) * 100
  end

  class << self

    def time_periods_by_day(start_date, end_date, entries)
      times = {}

      for day in start_date..end_date
        day_entries = entries.select {|e| e.entry_date == day}
        times[day.day.to_s.to_sym] = day_entries.map(&:time_in_hours).inject(0, :+).round(2)
      end

      times
    end

    def time_periods_by_day_and_project(start_date, end_date, entries)
      times = {}

      for day in start_date..end_date
        day_entries = entries.select {|e| e.entry_date == day}

        day_entries.each do |d|
          times[d.project.name] = {} unless times[d.project.name].is_a?(Hash)
          times[d.project.name][day.day.to_s.to_sym] = 0 if times[d.project.name][day.day.to_s.to_sym].nil?
          times[d.project.name][day.day.to_s.to_sym] += d.time_in_hours
        end
      end

      (start_date..end_date).each do |date|
        times.each do |project, day|
          times[project][date.day.to_s.to_sym] = 0 unless times[project][date.day.to_s.to_sym].is_a?(Numeric)
        end
      end

      times
    end

    def time_periods_by_project_totals(start_date, end_date, entries)
      times = {}
      percentages = {}

      projects = entries.map { |t| t.project.name }.uniq

      projects.each do |p|
        times[p] = 0
        percentages[p] = 0
      end

      entries.each do |e|
        times[e.project.name] += e.time_in_hours
      end

      total_hours = times.values.inject(0, :+)

      return {} if total_hours == 0

      times.each do |k, v|
        percentages[k] = v / total_hours * 100;
      end

      percentages
    end

    def detect_lunch_breaks_by_day(start_date, end_date, entries, minimum_time)
      output = {}

      for day in start_date..end_date
        day_entries = entries.select {|e| e.entry_date == day}
        output[day.day.to_s.to_sym] = false
        next if day_entries.length < 2

        for index in 0..(day_entries.length-2)
          difference = (day_entries[index+1].start_time - day_entries[index].end_time).to_f / 60
          output[day.day.to_s.to_sym] = true if difference.minutes >= minimum_time.minutes
        end
      end

      output
    end

  end # class << self

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
