require 'test_helper'

class SummariesControllerTest < ActionController::TestCase

  test "should get index" do
    get , {:user_id => 1}
    assert_response :success
  end

end
