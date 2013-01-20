class User < ActiveRecord::Base
  include HasPreferences
  has_many :projects
  has_many :time_entries

  attr_accessor   :password
  attr_accessible :name, :email, :password, :password_confirmation

  validates_presence_of     :name, :email
  validates_length_of       :email, :within => 5..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_email_format_of :email
  validates_length_of       :password, :within => 8..40, :if => :password_required?
  validates_confirmation_of :password, :if => :should_confirm_password?

  has_preference            :country,
                            :accessible => true,
                            :validate_with => :ensure_country_exists

  before_save :encrypt_password

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}-#{password}--")
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    user && user.authenticated?(password) ? user : nil
  end

  def authenticated?(password)
    encrypted_password == User.encrypt(password, salt)
  end

  def workdays(start_date, end_date)
    workdays = 0

    # workdays: monday to friday minus holidays
    if Holidays.available.include?(country.to_sym)
      (start_date..end_date).each do |day|
        workdays += 1 unless [0, 6].include?(day.wday) or day.holiday?(country)
      end
    else
      (start_date..end_date).each do |day|
        workdays += 1 unless [0, 6].include?(day.wday)
      end
    end

    workdays
  end

  def country_name
    c = Country.find_by_alpha2(country)
    return c[1]['name'] if c
    country.humanize
  end

  protected

  def encrypt_password
    return if password.blank?

    if new_record?
      self.salt = Digest::SHA1.hexdigest("--#{email}-#{name}-#{Time.now}--")
    end

    self.encrypted_password = User.encrypt(password, salt)
  end

  def password_required?
    encrypted_password.blank? || !password.blank?
  end

  def should_confirm_password?
    encrypted_password.blank? || !password.blank? || !password_confirmation.blank?
  end

  def ensure_country_exists
    #c = Country.find_by_alpha2(country)
    errors.add(:country, 'cannot be empty') unless country and Holidays.available.include?(country.to_sym)
  end
end
