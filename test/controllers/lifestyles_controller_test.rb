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
    puts json_result
    assert_equal 2, json_result[0]['lifestyle_type_id']
    assert_equal 1, json_result[1]['lifestyle_type_id']
  end
end
