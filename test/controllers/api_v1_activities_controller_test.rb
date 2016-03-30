require 'test_helper'
module Api::V1
  class ActivitiesControllerTest < ActionController::TestCase
    setup do
      @activity = activities(:one)
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should get index" do
      get :index, user_id: @user.id
      assert_response :success
      json_result = JSON.parse(response.body)
      assert_equal "test activity", json_result[0]['name']
      assert_equal "test2", json_result[1]['name']
    end

    test "should create activity" do
      assert_difference('Activity.count') do
        post :create, user_id: @user.id, activity: {
                        name: "test2",
                        calories: @activity.calories,
                        distance: @activity.distance,
                        duration: @activity.duration,
                        end_time: @activity.end_time,
                        game_id: @activity.game_id,
                        group: @activity.group,
                        manual: @activity.manual,
                        source: @activity.source,
                        start_time: @activity.start_time,
                        steps: @activity.steps
                    }, format: :json
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
      end
    end
  end
end
