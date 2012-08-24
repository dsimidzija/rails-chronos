class TimeEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  attr_accessible :project_id, :start, :end, :note
end
