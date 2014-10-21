require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = User.find_by_name('balint')
    @activity = Activity.new(activity: "running", group: "running", user_id: @user.id)
  end

  test "activity should be valid" do
    assert @activity.valid?
  end

  test "user_id should be required" do
    @activity.user_id = nil
    assert_not @activity.valid?
  end
end
