require 'test_helper'

class LifestylesControllerTest < ActionController::TestCase
  setup do
    @lifestyle = lifestyles(:one)
    @user = users(:one)
    login_user
  end

  test "should get index" do
    get :index, user_id: @user
    assert_response :success
    assert_not_nil assigns(:lifestyles)
  end
end
