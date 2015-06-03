require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    login_user
  end

  test "should get index if admin" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should NOT get index if NOT admin" do
    @user = users(:two)
    login_user
    get :index, format: :json
    assert_response 403
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: {
          email: "xxx@ab.cd",
          password: "abcd",
          password_confirmation: "abcd"
          }, format: :json
    end

    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user.id, user: {
        name: "newname",
        password: "pwx",
        password_confirmation: "pwx"
      }, format: :json
    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end

  test "should destroy user" do
    user2 = users(:two)
    assert_difference('User.count', -1) do
      delete :destroy, id: user2, format: :json
    end

    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end
end
