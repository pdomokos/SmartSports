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
      # assert_not_nil assigns(:activities)
    end
  end
end
