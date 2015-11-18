require 'json'
module NotificationsHelper
  def recurringOnDay(data, day)
    if !data
      return false
    end
    json = JSON.parse(data)
    return (not json.select{ |it| it['id']==day && it['selected']}.empty?)
  end
end
