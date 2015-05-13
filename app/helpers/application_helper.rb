module ApplicationHelper
  def get_duration(secs)
    if secs.nil?
      return "-"
    end
    if secs<60
      return "#{secs} sec"
    elsif secs < 3600
      return "%02d:%02d"%[secs/60, secs % 60]
    end
    h = secs/60/60
    secs = secs - h*60*60
    m = secs/60
    s = secs-m*60
    return "%02d:%02d:%02d"%[h, m, s]
  end

  def get_sensor_image(group)
    if /sleep/i =~ group
      return "sleep40.png"
    end
    if /ping/i =~ group
      return "pingpong40.png"
    end
    if /cycl/i =~ group
      return "cycling40.png"
    end
    if /walk/i =~ group
      return "walking40.png"
    end
    if /run/i =~ group
      return "running40.png"
    end
    if /work/i =~ group
      return "regular40.png"
    end

    return "sensor40.png"
  end
end
