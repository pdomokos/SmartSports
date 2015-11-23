require 'test_helper'
require 'json'

class NotificationsHelperTest < ActionView::TestCase
  setup do
    @data = "[{\"id\":\"mon\",\"selected\":false},{\"id\":\"tue\",\"selected\":false},{\"id\":\"wed\",\"selected\":true},{\"id\":\"thu\",\"selected\":false},{\"id\":\"fri\",\"selected\":false},{\"id\":\"sat\",\"selected\":false},{\"id\":\"sun\",\"selected\":false}]"
  end
  test "TestRecurringOnDaySimple" do
    assert recurringOnDay(@data, 'wed')
    assert_not recurringOnDay(@data, 'mon')
  end
end
