class Preference < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :name, :scope => :user_id

  attr_accessible :name, :value

  def self.countries_with_holidays
    countries = {}

    Holidays.available.each do |country|
      c = Country.find_by_alpha2(country)
      countries[c[1]['name']] = country if c
    end

    countries.sort
  end
end
