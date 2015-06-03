require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  setup do
    @activity = activities(:one)
    @user = users(:one)
    login_user
    @act_type = activity_types(:one)
  end

  test "should get index" do
    get :index, user_id: @user
    assert_response :success
    assert_not_nil assigns(:activities)
  end

  test "should get new" do
    get :new, user_id: @user
    assert_response :success
  end

  test "should create activity" do

    assert_difference('Activity.count') do
      post :create, user_id: @user.id, activity: {
          activity: @activity.activity,
          calories: @activity.calories,
          distance: @activity.distance,
          duration: @activity.duration,
          end_time: @activity.end_time,
          game_id: @activity.game_id,
          group: @activity.group,
          manual: @activity.manual,
          source: @activity.source,
          start_time: @activity.start_time,
          steps: @activity.steps,
          activity_type_id: @act_type.id
      }, format: :json
      json_result = JSON.parse(response.body)
      assert_equal json_result["ok"], true
      assert_not json_result["id"].nil?
    end
  end

  test "should show activity" do
    get :show, user_id: @user, id: @activity
    assert_response :success
  end

  test "should get edit" do
    get :edit, user_id: @user, id: @activity
    assert_response :success
  end

  test "should update activity" do
    patch :update, user_id: @user.id, id: @activity.id, activity: {
        activity: @activity.activity,
        calories: @activity.calories,
        distance: @activity.distance,
        duration: @activity.duration,
        end_time: @activity.end_time,
        game_id: @activity.game_id,
        group: @activity.group,
        manual: @activity.manual,
        source: @activity.source,
        start_time: @activity.start_time,
        steps: @activity.steps,
        activity_type_id: @act_type.id,
        favourite: true
    }, format: :json
    json_result = JSON.parse(response.body)
    assert_equal true, json_result["ok"]
  end

  test "should destroy activity" do
    assert_difference('Activity.count', -1) do
      delete :destroy, user_id: @user, id: @activity, format: :json
    end

    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end
end
