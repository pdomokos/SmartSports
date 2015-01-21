#= require BaseChart

class BarChart extends BaseChart
  constructor: ( @chart_element, data, @datekey, @key) ->
    super(data)

  draw: (date, meas) ->

  get_hourly_data: (data, datekey, key) ->


window.BarChart = BarChart
