require 'test_helper'

class PersonalRecordsControllerTest < ActionController::TestCase
  setup do
    @personal_records = personal_records(:one)
    @user = users(:one)
    login_user
  end

  test "should get index" do
    get :index, user_id: @user
    assert_response :success, format: :json
    assert_not_nil assigns(:personal_records)
  end

  test "should create personal_records" do
    assert_difference('PersonalRecord.count') do
      post :create, user_id: @user.id, personal_record: {
          source: @personal_records.source,
          diabetes_key: @personal_records.diabetes_key,
          note: @personal_records.note
      }, format: :json
      json_result = JSON.parse(response.body)
      assert_equal json_result["ok"], true
      assert_not json_result["id"].nil?
    end
  end
end
