require 'test_helper'

class FamilyHistoriesControllerTest < ActionController::TestCase
  setup do
    @family_history = family_histories(:one)
    @user = users(:one)
    login_user
  end

  test "should get index" do
    get :index, user_id: @user
    assert_response :success, format: :json
    assert_not_nil assigns(:family_histories)
  end

  test "should create family history" do
    assert_difference('FamilyHistory.count') do
      post :create, user_id: @user.id, family_history: {
          source: @family_history.source,
          relative: @family_history.relative,
          disease: @family_history.disease,
          note: @family_history.note
      }, format: :json
    end
    json_result = JSON.parse(response.body)
    assert_equal json_result["status"], "OK"
    assert_not json_result["result"]["id"].nil?
  end
end
