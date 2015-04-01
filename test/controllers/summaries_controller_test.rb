require 'test_helper'

class SummariesControllerTest < ActionController::TestCase
  setup do
    @summary = summaries(:one)
    @user = users(:one)
    login_user
  end

  test "should get index" do
    get :index, user_id: @user
    assert_response :success
  end

end
