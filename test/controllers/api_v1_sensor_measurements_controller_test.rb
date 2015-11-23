require 'test_helper'
module Api::V1

  class SensorMeasurementsControllerTest < ActionController::TestCase
    setup do
      @activity = activities(:one)
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should create" do
      post :create, user_id: @user.id, sensor_measurement: {
                      hr_data: "testhr",
                      rr_data: "testrr",
                      cr_data: "testcr",
                      start_time: "2015-05-01 23:21:57 CEST",
                      group: "testgrp",
                      duration: "2344",
                      sensors: "A B C"
                  }, format: :json
      json_result = JSON.parse(response.body)
      assert_response :success
      # assert_not_nil assigns(:activities)
    end

  end

end
