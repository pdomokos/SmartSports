require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase

  test "should get create" do
    post :create, email: 'balint@abc.de', locale: "en"
    assert_response :success
  end

  # TODO fix these

  # test "should get edit" do
  #   get :edit
  #   assert_response :success
  # end
  #
  # test "should get update" do
  #   get :update
  #   assert_response :success
  # end

end
