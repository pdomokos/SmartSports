#=require TrendChart

class TrainingTrendChart extends TrendChart
  get_series: () ->
    template = {'date': null, 'walking_duration': 0, 'running_duration': 0, 'cycling_duration': 0, 'transport_duration': 0, 'sleep_duration': 0, 'steps': 0}
    result = Object()

    for actkey in ['walking', 'running', 'cycling', 'transport']
      daily_activity = Object()
      for d in @data['activities'][actkey]
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
    return(result)

  aggregate: (data, result) ->
    len = data.length
    if len==0
      if @zero_when_missing
        return 0
      else
        return null

    current_item =  data.filter( (d) -> d['source'] == 'withings' )
    if current_item.length != 0
      result['walking_duration'] = current_item[0]['total_duration']
      result['steps'] = current_item[0]['steps']
    else
      current_item =  data.filter( (d) -> d['source'] == 'fitbit')
      if current_item.length != 0
        result['walking_duration'] = current_item[0]['total_duration']
        result['steps'] = current_item[0]['steps']
      else
        current_item = data
        switch data[0]['group']
          when 'walking'
            result['walking_duration'] = current_item[0]['total_duration']
            result['steps'] = current_item[0]['steps']
          when 'running'
            result['running_duration'] = current_item[0]['total_duration']
          when 'cycling'
            result['cycling_duration'] = current_item[0]['total_duration']
          when 'transport'
            result['transport_duration'] = current_item[0]['total_duration']
          else
            console.log "not found: "+data[0]['group']


window.TrainingTrendChart = TrainingTrendChart