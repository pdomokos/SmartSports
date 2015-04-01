require 'test_helper'

class FriendshipsControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    login_user
  end

  test "should get new" do
    get :new
    assert_response :success
  end

end
