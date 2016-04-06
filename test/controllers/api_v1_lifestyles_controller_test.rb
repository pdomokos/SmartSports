require 'test_helper'
module Api::V1
  class LifestylesControllerTest < ActionController::TestCase

    setup do
      @lt1 = lifestyle_types(:ltone)
      @lt2= lifestyle_types(:lttwo)

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
      assert_equal 'paintype1', json_result[0]['name']
      assert_equal 'illnesstype1', json_result[1]['name']
    end

    test "should create pain" do
      assert_difference('Lifestyle.count') do
        post :create, user_id: @user.id, lifestyle: {
                        source: 'smartdiab',
                        name: @lt2.name,
                        start_time: Time.zone.now-3.days,
                        end_time: Time.zone.now-2.days,
                        amount: 1
                    }, format: :json
        assert_response :success
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
      end
    end

    test "should create illness" do
      assert_difference('Lifestyle.count') do
        post :create, user_id: @user.id, lifestyle: {
            source: 'smartdiab',
            name: @lt1.name,
            start_time: Time.zone.yesterday,
            end_time: Time.zone.now,
            details: "illness test",
            amount: 3
        }, format: :json
        assert_response :success
        json_result = JSON.parse(response.body)
        assert_not json_result["id"].nil?
        newLifestyle = Lifestyle.find_by_id(json_result['id'])
        assert_equal 'illness', newLifestyle.lifestyle_type.category
        assert_equal 'illnesstype1', newLifestyle.lifestyle_type.name
        assert_equal 3, newLifestyle.amount
      end
    end

  end
  
end
