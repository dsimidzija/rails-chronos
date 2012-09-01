require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

  test "validation of blank user" do
    user = User.new
    user.save

    expected = {
      :name => ["can't be blank"],
      :email => [
        "can't be blank",
        "is too short (minimum is 5 characters)",
        "does not appear to be valid"
      ],
      :password => ["is too short (minimum is 8 characters)"],
    }

    assert user.errors.messages.any?
    assert_equal expected, user.errors.messages
  end

  test "skipping password validation on existing user" do
    user = users(:delboy)
    user.name = 'Del Boy'

    assert user.save
    assert !user.errors.any?
  end

  test "password validation and encryption" do
    user = User.new
    user.name = 'Sarah'
    user.email = 'jessica@parker.com'
    user.password = 'horsey'

    assert !user.valid?

    user.password = 'horsey123'
    assert user.valid?
    assert user.save

    assert_equal user.encrypted_password.length, 40
    assert_equal user.salt.length, 40
  end

  test "user authentication" do
    user = users(:delboy)

    assert !user.authenticated?('drink')
    assert user.authenticated?('he who dares wins!')

    assert_instance_of User, User.authenticate('del@trotterindependenttraders.com', 'he who dares wins!')
    assert_nil User.authenticate('albert@ww2.com', 'during the war')
  end
end
