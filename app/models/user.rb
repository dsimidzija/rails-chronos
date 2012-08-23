class User < ActiveRecord::Base
  attr_accessor   :password
  attr_accessible :name, :email

  validates_presence_of     :name
  validates_length_of       :email, :within => 5..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_length_of       :password, :within => 8..40, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?

  before_save :encrypt_password

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}-#{password}--")
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
end
