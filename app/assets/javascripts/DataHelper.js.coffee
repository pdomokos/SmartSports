class DataHelper
  constructor: (@data) ->
    @fmt = d3.time.format("%Y-%m-%d")
    @fmt_words = d3.time.format("%Y %b %e")
    @fmt_day = d3.time.format("%Y-%m-%d %a")
    @fmt_hms = d3.time.format("%Y-%m-%d %H:%M:%S")

  proc_training_data: () ->
    @conv_to_km(@data.walking)
    @conv_to_km(@data.running)
    @conv_to_km(@data.cycling)

  get_daily_activities: (date) ->
    result = {'walking': [], 'running':[], 'cycling': [], 'transport': []}
    walking = if @data.walking then @data.walking else []
    running = if @data.running then @data.running else []
    cycling = if @data.cycling then @data.cycling else []
    transport = if @data.transport then @data.transport else []

    for d in walking.concat(running.concat(cycling.concat(transport)))
      if @fmt(new Date(Date.parse(d.date))) == date
        result[d.group].push(d)
    return result

  get_week_activities: (date_ymd) ->
    console.log "get_week_act"
    result = {'walking': [], 'running':[], 'cycling': [], 'transport': []}
    walking = if @data.walking then @data.walking else []
    running = if @data.running then @data.running else []
    cycling = if @data.cycling then @data.cycling else []
    transport = if @data.transport then @data.transport else []
    monday = @get_monday(date_ymd)
    sunday = @get_sunday(date_ymd)
    console.log "from="+@fmt_hms(monday)+" to="+@fmt_hms(sunday)
    for d in walking.concat(running.concat(cycling.concat(transport)))
      curr = new Date(Date.parse(d.date))
      if curr > monday and curr<=sunday
        result[d.group].push(d)
    return result


  get_hour: (sec) ->
    Math.floor(sec/60.0/60.0).toString()

  get_min: (sec) ->
    Math.floor((sec%(60*60))/60).toString()

  get_data_size: ->
    h = {}
    walking = if @data.walking then @data.walking else []
    running = if @data.running then @data.running else []
    cycling = if @data.cycling then @data.cycling else []
    for d in walking.concat(running.concat(cycling))
      curr = @fmt(new Date(Date.parse(d.date)))
      h[curr] = true
    datanum = Object.keys(h).length
    return datanum

  days_in_month: (year, month) ->
    d = new Date(Date.parse(year+"-"+month))
    return new Date(d.getYear(), d.getMonth()+1, 0).getDate()

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

  get_monday: (date_ymd) ->
    d = new Date(Date.parse(date_ymd))
    dow = d.getDay()
    dow2 = if (dow==0) then 6 else (dow-1)
    d.setDate(d.getDate()-dow2)
    d.setHours(0)
    d.setMinutes(0)
    d.setSeconds(0)
    return new Date(d)

  get_sunday: (date_ymd) ->
    d = new Date(Date.parse(date_ymd))
    dow = d.getDay()
    dow2 = if (dow==0) then 6 else (dow-1)

    d.setDate(d.getDate()+6-dow2)
    d.setHours(23)
    d.setMinutes(59)
    d.setSeconds(59)
    return new Date(d)

window.DataHelper = DataHelper