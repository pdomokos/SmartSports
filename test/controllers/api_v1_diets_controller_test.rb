require 'test_helper'
module Api::V1
  class DietsControllerTest < ActionController::TestCase

    setup do
      @diet = diets(:one)
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
      assert_equal 'water', json_result[0]['name']
      assert_equal 'breakfast', json_result[1]['name']
    end

    test "should create diet" do
      assert_difference('Diet.count') do
        post :create, user_id: @user.id, diet: {
                        source: 'testdata',
                        date: '2016-01-27 16:17:17',
                        name: 'breakfast'
                    }, format: :json
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
        newdiet = Diet.find_by_id(json_result['id'])
        assert_equal 'breakfast', newdiet.food_type.name
      end
    end

    test "should create quick calory" do
      assert_difference('Diet.count') do
        post :create, user_id: @user.id, diet: {
                        source: 'testdata',
                        date: '2016-01-27 16:17:17',
                        name: 'calory',
                        calories: 37,
                        carbs: 176
                    }, format: :json
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
        newdiet = Diet.find_by_id(json_result['id'])
        assert_equal 'calory', newdiet.food_type.name
        assert_equal 37, newdiet.calories
        assert_equal 176, newdiet.carbs
      end
    end
  end
  
end
