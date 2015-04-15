#=require common/TrendChart

class TrainingTrendChart extends TrendChart
  get_series: () ->
    template = {'date': null, 'walking_duration': 0, 'running_duration': 0, 'cycling_duration': 0, 'transport_duration': 0, 'sleep_duration': 0, 'steps': 0}
    result = Object()

    for actkey in ['walking', 'running', 'cycling', 'transport']
      daily_activity = Object()
      if @data[actkey]
        for d in @data[actkey]
          key = fmt(new Date(Date.parse(d.date)))
          if daily_activity[key]
            daily_activity[key].push(d)
          else
            daily_activity[key] = [d]

      days = Object.keys(daily_activity)
      if days == null
        continue
      days.sort()

      for day in days
        daily_data = daily_activity[day]
        result_daily = result[day]
        if !result_daily
          result_daily = $.extend({}, template)
          result_daily['date'] = day
          result[day] = result_daily
        @aggregate(daily_data, result_daily)

    res = []
    keys = Object.keys(result)
    keys.sort()
    for k in keys
      res.push( result[k] )
    return(res)

  aggregate: (data, result) ->
    len = data.length
    if len==0
      if @zero_when_missing
        return 0
      else
        return null

    current_items = data.filter( (d) -> d['group'] == 'walking')
    if current_items.length != 0
      result['walking_duration'] = current_items[0]['total_duration']
      result['steps'] = current_items[0]['steps']

    current_items = data.filter( (d) -> d['group'] == 'running')
    if current_items.length != 0
      result['running_duration'] = current_items[0]['total_duration']

    current_items = data.filter( (d) -> d['group'] == 'cycling')
    if current_items.length != 0
      result['cycling_duration'] = current_items[0]['total_duration']

    current_items =  data.filter( (d) -> d['source'] == 'fitbit')
    if current_items.length != 0
      walk_times = current_items.filter( (d) -> d['group'] == 'walking')
      if walk_times.length != 0
        result['walking_duration'] = walk_times[0]['total_duration']
        result['steps'] = walk_times[0]['steps']

    current_items =  data.filter( (d) -> d['source'] == 'withings' )
    if current_items.length != 0
      walk_times = current_items.filter( (d) -> d['group'] == 'walking')
      if walk_times.length != 0
        result['walking_duration'] = walk_times[0]['total_duration']
        result['steps'] = walk_times[0]['steps']


window.TrainingTrendChart = TrainingTrendChart