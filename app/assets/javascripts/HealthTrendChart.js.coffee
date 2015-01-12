#=require TrendChart

class HealthTrendChart extends TrendChart
  get_series: () ->
    template = {'date': null, 'systolicbp': null, 'diastolicbp': null, 'pulse': null}
    result = Object()

    daily_data = Object()

    for d in @data
      key = fmt(new Date(Date.parse(d.date)))
      if daily_data[key]
        daily_data[key].push(d)
      else
        daily_data[key] = [d]

    console.log daily_data
    days = Object.keys(daily_data)
    if days == null
      return
    days.sort()

    for day in days
      result_daily = $.extend({}, template)
      result_daily['date'] = day
      result[day] = result_daily
      @aggregate(daily_data[day], result_daily)

    console.log "HEALTH SERIES"
    console.log result
    return(result)

  aggregate: (daily, result_daily) ->
    for k in ['systolicbp', 'diastolicbp', 'pulse']
      values = daily.filter( (d) -> d[k]!= null).map( (d) -> d[k] )
      len = values.length
      if len > 0
        sum = values.reduce( (sum, curr) -> sum+curr)
        result_daily[k] = sum/len

window.HealthTrendChart = HealthTrendChart