#=require TrendChart

class HealthTrendChart extends TrendChart
  get_series: () ->
    daily_data = Object()
    for d in @data
      key = fmt(new Date(Date.parse(d.date)))
      daily_data[key] = d

    return(daily_data)

window.HealthTrendChart = HealthTrendChart