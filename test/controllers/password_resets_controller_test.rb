require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase

  test "should get create" do
    get :create, email: 'balint@abc.de'
    assert_redirected_to root_path
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
