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

  $('#diet_food_datepicker').datetimepicker({
      "format": "YYYY-MM-DD HH:mm"
    })
  $('#diet_drink_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })
  $('#diet_smoking_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })

  $("#testbtn").click (evt) ->
    $('#diet_food_datepicker').data("DateTimePicker").toggle()

  $("form.resource-create-form.diet-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")

    load_diets()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create diet.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_diets()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

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

