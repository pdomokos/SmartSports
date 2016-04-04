require 'test_helper'
module Api::V1
  class MedicationTypesControllerTest < ActionController::TestCase
    setup do
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should get index" do
      get :index
      result = JSON.parse(response.body)
      assert_response :success
      assert_equal 3, result.size
      assert_equal "kalmopirin", result[0]['hu']
      assert_equal "oral", result[0]['category']
    end
  end
end
