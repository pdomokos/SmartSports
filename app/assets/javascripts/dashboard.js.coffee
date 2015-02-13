
@dashboard_loaded = (is_mobile=false) ->
  if not is_mobile
    @init_browser_dashboard()
  else
    @init_mobile_dashboard()

@init_browser_dashboard = () ->
  self = this
  reset_ui()
  $("#meas-sys").focus()
  $("#dashboard-button").addClass("selected")
  @setdate()
  @update_summary(false)
  self = this

  @load_notifications()

  @register_activity_cbs()
  @register_health_cbs()
  @register_lifestyle_cbs()

  $("#lifestyle-form-sel").click (event) ->
    self.reset_form_sel()
    $("#lifestyle-form-div").removeClass("hidden")
    $("#meas-message").addClass("hidden-placed")
    $("#lifestyle-form-sel div.log-sign").removeClass("hidden-placed")
    $("#lifestyle-form-sel").addClass("selected")
#    $("#meas-sys").focus()

  $("#act-form-sel").click (event) ->
    self.reset_form_sel()
    $("#act-form-div").removeClass("hidden")
    $("#act-form-sel div.log-sign").removeClass("hidden-placed")
    $("#act-form-sel").addClass("selected")
    $("#act-message-item").addClass("hidden")
    $("#act-message-failed").addClass("hidden")
    $("#act-steps").focus()

  # friendship events
  $("#friend-form-sel").click (event) ->
    self.reset_form_sel()
    $("#friend_name").val("")
    $("#friend-message").addClass("hidden-placed")
    $("#friend-form-div").removeClass("hidden")
    $("#friend-form-sel div.log-sign").removeClass("hidden-placed")
    $("#friend-form-sel").addClass("selected")
    $("#friend_name").focus()

  $("#new-friend-button").click (event) ->
    new_friend_submit_handler(event)

@get_days_ago_ymd = (n) ->
  d = new Date()
  d.setDate(d.getDate()-n)
  return fmt(d)

new_friend_submit_handler = (event) ->
  event.preventDefault()
  values = $("#friend-form").serialize()
  console.log values
  $.ajax '/friendships',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (data, textStatus, errorThrown) ->
      console.log "CREATE friend AJAX Error: #{textStatus}"
      console.log data
    success: (data, textStatus, jqXHR) ->
      if data.status == "OK"
        console.log "CREATE friend  Successful AJAX call"
        console.log data
        $("#friend_name").val("")
        $("#friend-message").addClass("hidden-placed")
        load_notifications()
      else
        $("#friend-message").removeClass("hidden-placed")
#        $("#friend-form-div div.friend-message").addClass("red")
        msg = data.msg+" "+"<i class=\"fa fa-exclamation-circle failure\"></i>"
        $("#friend-message").html(msg)
        $("#")

@setdate = () ->
  now = new Date(Date.now())
  $(".logform input.date-input").val(fmt_hms(now))

@reset_form_sel = () ->
  $("#health-form-div").addClass("hidden")
  $("#lifestyle-form-div").addClass("hidden")
  $("#act-form-div").addClass("hidden")
  $("#friend-form-div").addClass("hidden")
  $("#act-form-sel div.log-sign").addClass("hidden-placed")
  $("#lifestyle-form-sel div.log-sign").addClass("hidden-placed")
  $("#heart-form-sel div.log-sign").addClass("hidden-placed")
  $("#friend-form-sel div.log-sign").addClass("hidden-placed")
  $("#heart-form-sel").removeClass("selected")
  $("#lifestyle-form-sel").removeClass("selected")
  $("#act-form-sel").removeClass("selected")
  $("#friend-form-sel").removeClass("selected")
  @setdate()

@add_param = (name, hash) ->
  pname = $("#"+name).attr("name")
  pval = $("#"+name).val()
  # duration is saved in seconds, but displayed in minutes
  if name[-8..] is "duration"
    orig = pval
    pval = Math.round(60.0*orig)
  hash[pname] = pval

@add_m_param = (name, hash) ->
  pname = $("#"+name).attr("name")
  pname = 'measurement['+pname+']'
  pval = $("#"+name).val()
  hash[pname] = pval

@create_params = (par) ->
  result = Object()
  @add_param("activity-form-userid", result)
  for e in $("form#act-form input."+par+"-param")
    console.log "create_params: "+e.id
    @add_param(e.id, result)
  return result

@create_m_params = () ->
  result = Object()
  @add_param("meas-user_id", result)
  @add_param("meas-source", result)
  for e in $("form#heart-form input.measure-param")
    console.log e.id
    @add_m_param(e.id, result)
  return result

@set_param = (element_id, hash) ->
  key = element_id.split("-")[1]
  if key[-4..] is "time"
    val = fmt_hms(new Date(hash[key]))
  else
    val = hash[key]
  # duration is saved in seconds, but displayed in minutes
  if key[-8..] is "duration"
    val = Math.round(hash[key]/60.0*100)/100.0

  $("#"+element_id).val(val)
  console.log "setting "+"#"+element_id+"["+key+"]="+val

@set_m_param = (element_id, hash) ->
  key = element_id.split("-")[1]
  $("#"+element_id).val(hash[key])
  console.log "setting mparam "+"#"+element_id+"["+key+"]="+hash[key]



# DEBUG helpers
@mapit = (d, k) ->
  return d.map( (item) -> item[k])
