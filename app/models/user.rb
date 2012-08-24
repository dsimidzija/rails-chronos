class User < ActiveRecord::Base
  has_many :projects
  has_many :time_entries

  attr_accessor   :password
  attr_accessible :name, :email, :password, :password_confirmation
  attr_readonly   :email

  validates_presence_of     :name
  validates_length_of       :email, :within => 5..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_email_format_of :email, :on => :create
  validates_length_of       :password, :within => 8..40, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?

  before_save :encrypt_password

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}-#{password}--")
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    user && user.authenticated?(password) ? user : nil
  end

  protected

  def encrypt_password
    return if password.blank?

    if new_record?
      self.salt = Digest::SHA1.hexdigest("--#{email}-#{name}-#{Time.now}--")
    end

    self.encrypted_password = User.encrypt(password, salt)
  end

  def authenticated?(password)
    encrypted_password == User.encrypt(password, salt)
  end

  def password_required?
    encrypted_password.blank? || !password.blank?
  end
end
