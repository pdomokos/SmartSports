
class DataHelper
  constructor: (@data) ->

  proc_training_data: () ->
    if @data.walking
      @conv_to_km(@data.walking)
    if @data.running
      @conv_to_km(@data.running)
    if @data.cycling
      @conv_to_km(@data.cycling)

  get_daily_activities: (date) ->
    result = {'walking': [], 'running':[], 'cycling': [], 'transport': []}
    walking = if @data.walking then @data.walking else []
    running = if @data.running then @data.running else []
    cycling = if @data.cycling then @data.cycling else []
    transport = if @data.transport then @data.transport else []

    for d in walking.concat(running.concat(cycling.concat(transport)))
      if fmt(new Date(Date.parse(d.date))) == date
        if d.group
          result[d.group].push(d)
        else
          result['walking'].push(d)
    return result

  get_week_activities: (date_ymd) ->
    result = {'walking': [], 'running':[], 'cycling': [], 'transport': []}
    walking = if @data.walking then @data.walking else []
    running = if @data.running then @data.running else []
    cycling = if @data.cycling then @data.cycling else []
    transport = if @data.transport then @data.transport else []
    monday = get_monday(date_ymd)
    sunday = get_sunday(date_ymd)
    for d in walking.concat(running.concat(cycling.concat(transport)))
      curr = new Date(Date.parse(d.date))
      if curr > monday and curr<=sunday
        if d.group
          result[d.group].push(d)
        else
          result['walking'].push(d)
    return result

  get_data_size: ->
    h = {}
    walking = if @data.walking then @data.walking else []
    running = if @data.running then @data.running else []
    cycling = if @data.cycling then @data.cycling else []
    for d in walking.concat(running.concat(cycling))
      curr = fmt(new Date(Date.parse(d.date)))
      h[curr] = true
    datanum = Object.keys(h).length
    return datanum

  conv_to_km: (data) ->
    for d in data
      d.distance = d.distance/1000

  get_sum_measure: (dat, measure, activity_types) ->
    result = 0.0
    for k in activity_types
      if dat[k]
        for item in dat[k]
          result = result + item[measure]
    return result

  days_in_month: (year, month) ->
    d = new Date(Date.parse(year+"-"+month))
    return new Date(d.getYear(), d.getMonth()+1, 0).getDate()

window.DataHelper = DataHelper
