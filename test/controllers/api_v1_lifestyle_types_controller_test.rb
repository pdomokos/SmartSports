require 'test_helper'
module Api::V1
  class LifestyleTypesControllerTest < ActionController::TestCase
    setup do
      @user = users(:one)
      @lt = lifestyle_types(:ltone)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should get index" do
      get :index
      assert_response :success
      result = JSON.parse(response.body)
      assert_equal 2, result.size
      assert_equal "illnesstype1", result[0]['name']
      assert_equal "illnesses", result[0]['category']
    end
  end
end
