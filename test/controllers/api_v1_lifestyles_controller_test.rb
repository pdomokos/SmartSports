require 'test_helper'
module Api::V1
  class LifestylesControllerTest < ActionController::TestCase

    setup do
      @lifestyle = lifestyles(:one)
      @lifestyle_two = lifestyles(:two)
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
      assert_equal 1, json_result[0]['lifestyle_type_id']
      assert_equal nil, json_result[1]['lifestyle_type_id']
    end

    test "should create lifestyle" do
      assert_difference('Lifestyle.count') do
        post :create, user_id: @user.id, lifestyle: {
                        source: @lifestyle.source,
                        lifestyle_type_name: @lifestyle.lifestyle_type_name,
                        start_time: @lifestyle.start_time,
                        end_time: @lifestyle.end_time,
                        amount: @lifestyle.amount
                    }, format: :json
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
      end
    end

    test "should create illness" do
      assert_difference('Lifestyle.count') do
        post :create, user_id: @user.id, lifestyle: {
            source: @lifestyle_two.source,
            lifestyle_type_id: @lifestyle_two.lifestyle_type_id,
            lifestyle_type_name: @lifestyle_two.lifestyle_type_name,
            name: @lifestyle_two.name,
            start_time: @lifestyle_two.start_time,
            end_time: @lifestyle_two.end_time,
            details: @lifestyle_two.details,
            amount: @lifestyle_two.amount
        }, format: :json
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
        newLifestyle = Lifestyle.find_by_id(json_result['id'])
        assert_equal 'illness', newLifestyle.lifestyle_type_name
        assert_equal 'illnesstype1', newLifestyle.name
        assert_equal 3, newLifestyle.amount
      end
    end

  end
  
end
