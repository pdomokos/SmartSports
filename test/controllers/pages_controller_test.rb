require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    login_user
  end

  test "should get dashboard" do
    get :dashboard
    assert_response :success
  end

end
