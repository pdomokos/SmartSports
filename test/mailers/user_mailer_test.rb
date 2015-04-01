require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
  end

  test "reset_password_email" do
    mail = UserMailer.reset_password_email(@user)
    assert_equal "Your password has been reset", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["info@smartdiab.com"], mail.from
    assert_match "Hello, "+@user.email, mail.body.encoded
  end

end
