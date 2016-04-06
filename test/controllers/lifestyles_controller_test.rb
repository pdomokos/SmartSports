require 'test_helper'

class LifestylesControllerTest < ActionController::TestCase
  setup do
    @lifestyle = lifestyles(:one)
    @user = users(:one)
    login_user
  end

  test "should get index" do
    get :index, {user_id: @user, format: :json}
    assert_response :success
    json_result = JSON.parse(response.body)
    assert_equal 'paintype1', json_result[0]['name']
    assert_equal 'illnesstype1', json_result[1]['name']
  end
end
