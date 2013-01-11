class Tracking
  include FormatUtility
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user_id, :project_id, :start_time, :note

  validates_presence_of :user_id, :project_id, :start_time_formatted

  validates_format_of :start_time_formatted, :with => /^\d{2}:\d{2}$/

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
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
      errors.add(:start_time_formatted, 'does not appear to be valid')
    end
  end

  def persisted?
    false
  end

  def start
    t = TimeEntry.new
    t.user_id = user_id
    t.project_id = project_id
    t.entry_date = Date.today
    t.start_time = self.start_time #.now
    t.note = note

    t.save
  end

  def self.stop(time_entry_id)
    t = TimeEntry.find(time_entry_id)
    # check if empty
    t.end_time = Time.now
    t.save
  end
end
