class Tracking
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user_id, :project_id, :note

  validates_presence_of :user_id, :project_id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
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
    t.start_time = Time.now
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
