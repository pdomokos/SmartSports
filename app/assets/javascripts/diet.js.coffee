@diet_loaded = () ->
  console.log("diet loaded2")

  $("div.appMenu button").removeClass("selected")
  $("#diet-button").addClass("selected")

  $('#diet_name').watermark('Food name, eg: Chicken soup')
  $('#diet_cal').watermark('Calories, eg: 165')
  $('#diet_fat').watermark('Total Carbs, eg: 3')

  $('#diet_drink_amount').watermark('Amount: 1.5')
  $('#diet_drink_calories').watermark('Calories, eg: 165')
  $('#diet_drink_carbs').watermark('Total Carbs, eg: 3')

  $('#diet_smoking_amount').watermark('Amount, eg: 3')

  $('#diet_food_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_drink_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_smoking_datepicker').datetimepicker(timepicker_defaults)

  $("#diet_drink_type").selectmenu()
  $("#diet_smoke_type").selectmenu()

  $("form.resource-create-form.diet-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")
    $('#diet_food_datepicker').val(moment().format(moment_fmt))
    $('#diet_drink_datepicker').val(moment().format(moment_fmt))
    $('#diet_smoking_datepicker').val(moment().format(moment_fmt))
    loadHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create diet.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "update/delete success "+form_id
    loadHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to update/delete diet.")
  )

  $('.hisTitle').click ->
    loadHistory()

  $(".favTitle").click ->
    load_favs()
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

@loadHistory = () ->
  load_diets()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@fill_form = (type, name, calories, carbs, amount) ->
  if type == 'Food'
    $('#diet_name').val(name);
    $('#diet_cal').val(calories);
    $('#diet_fat').val(carbs);
  else if type == 'Drink'
    $('#diet_drink_type').val(name);
    $('#diet_drink_amount').val(amount);
    $('#diet_drink_calories').val(calories);
    $('#diet_drink_carbs').val(carbs);
  else if type == 'Smoke'
    $('#diet_smoke_type').val(name);

@load_diets = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent diets"
  $.ajax '/users/' + current_user + '/diets.js?source='+window.default_source+'&order=desc&limit=4',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent diets  Successful AJAX call"
      console.log textStatus

@load_favs = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent diets"
  $.ajax '/users/' + current_user + '/diets.js?source='+window.default_source+'&favourites=true&order=desc&limit=4',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent diets  Successful AJAX call"
      console.log textStatus