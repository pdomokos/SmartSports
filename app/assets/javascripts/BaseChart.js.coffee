class BaseChart
  constructor: (@data) ->
    @fmt = d3.time.format("%Y-%m-%d")
    @fmt_words = d3.time.format("%Y %b %e")
    @fmt_day = d3.time.format("%Y-%m-%d %a")
    @fmt_hms = d3.time.format("%Y-%m-%d %H:%M:%S")



window.BaseChart = BaseChart
