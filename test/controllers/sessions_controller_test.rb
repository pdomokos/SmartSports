require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should get create" do
    get :create, {email: 'balint@abc.de', password: 'testpw'}
    assert_response :success
  end

  test "should get destroy" do
    @user = users(:one)
    login_user
    get :signout
    assert_response :success
  end

end
