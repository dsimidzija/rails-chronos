class TimeEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  attr_accessible :project_id, :start_time, :end_time, :note

  validates_presence_of   :user_id, :project_id, :start_time
  validates_presence_of   :user_id, :project_id, :start_time, :end_time, :on => :update
  validate                :start_time_before_end_time, :if => :both_timestamps_present?

  protected

  def both_timestamps_present?
    start_time && end_time
  end

  def start_time_before_end_time
    errors.add(:end_time, 'cannot be before start time') unless end_time > start_time
  end
end
