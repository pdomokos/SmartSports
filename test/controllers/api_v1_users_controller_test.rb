require 'test_helper'
module Api::V1

  class UsersControllerTest < ActionController::TestCase
    setup do
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should update dev_token" do
      put :update, id: @user.id, user: {
                      dev_token: "AABBCC1234",
                  }, format: :json
      resp = JSON.parse(response.body)

      assert_response :success
      assert_equal "AABBCC1234", User.find(users(:one)).dev_token
      assert resp["ok"]
    end

  end

end
