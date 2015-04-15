#=require common/TrendChart

class HealthTrendChart extends TrendChart
  get_series1: () ->
    console.log @data
    template = Object()
    keys = @series_keys
    template['date'] = ""
    for k in keys
      template[k] = 0

    daily_data = Object()
    for d in @data
      key = fmt(new Date(Date.parse(d.date)))
      if daily_data[key]
        daily_data[key].append(d)
      else
        daily_data[key] = [d]

    result_hash = Object()
    days = Object.keys(daily_data)
    for day in days
      daily_arr = daily_data[day]
      for k in keys
        daily_k = daily_arr.filter( (d) -> d[k] != null )
        len = daily_k.length
        if len>0
          total = daily_arr.map( (d) -> d[k] ).reduce( (a, b) -> a+b )
          if result_hash[day]
            result_curr = result_hash[day]
          else
            result_curr = $.extend({}, template)
            result_curr['date'] = day
            result_hash[day] = result_curr
          result_curr[k] = total/len

    days = Object.keys(result_hash)
    days.sort()
    result = []
    for day in days
      result.push(result_hash[day])

    console.log "RESULT"
    console.log result
    return(result)

window.HealthTrendChart = HealthTrendChart