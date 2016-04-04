require 'test_helper'
module Api::V1
  class MedicationsControllerTest < ActionController::TestCase
    setup do
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should get index" do
      get :index, user_id: @user.id
      assert_response :success
      result = JSON.parse(response.body)
      assert_equal 2, result.size
      assert_equal '3', result[0]['name']
      assert_equal 'insulin', result[0]['category']
      assert_equal '1', result[1]['name']
      assert_equal 'oral', result[1]['category']
    end

    test "should create medication" do
      assert_difference('Medication.count') do
        post :create, user_id: @user.id, medication: {
                 source: 'testsource',
                 date: '2016-03-29 10:11:12',
                 name: '1'
                   }
      end
      result = JSON.parse(response.body)
      assert_response :success
    end

  end
end