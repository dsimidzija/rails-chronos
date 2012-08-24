class Project < ActiveRecord::Base
  belongs_to :user

  attr_accessible :name, :description

  validates_presence_of     :name
  validates_length_of       :name, :within => 3..100
  validates_uniqueness_of   :name, :scope => :user_id
end
