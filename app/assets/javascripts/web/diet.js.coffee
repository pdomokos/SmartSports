@diet_loaded = () ->
  console.log("diet loaded2")

  $("div.appMenu button").removeClass("selected")
  $("#diet-button").addClass("selected")

  $('#diet_food_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_drink_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_smoking_datepicker').datetimepicker(timepicker_defaults)

  $("#diet_smoke_type").selectmenu()

  load_food_types()
  load_drink_types()

  $("#diet_scale").slider({
    min: 0.5,
    max: 5,
    step: 0.5,
    value: 2.5
  }).slider({
    slide: (event, ui) ->
      $("#diet_unit").html(ui.value*100+"g")
    change: (event, ui) ->
      $("#diet_amount").val(ui.value)
  })

  $("#diet_drink_scale").slider({
    min: 0.5,
    max: 5,
    step: 0.5,
    value: 2.5
  }).slider({
    slide: (event, ui) ->
      $("#diet_drink_unit").html(ui.value+"dl")
    change: (event, ui) ->
      $("#diet_drink_amount").val(ui.value)
  })

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
    $('#diet_name').val(name)
    $('#diet_cal').val(calories)
    $('#diet_fat').val(carbs)
  else if type == 'Drink'
    $('#diet_drink_type').val(name)
    $('#diet_drink_amount').val(amount)
    $('#diet_drink_calories').val(calories)
    $('#diet_drink_carbs').val(carbs)
  else if type == 'Smoke'
    $("#diet_smoke_type" ).val(name).change()

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


@load_food_types = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent foods"
  $.ajax '/food_types.json?type=food',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent food_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load food_types  Successful AJAX call"

      foods = data.map( window.food_map_fn )

      $("#foodname").autocomplete({
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          for element in foods
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
            if cnt >= 20
              break
          response(result)
        select: (event, ui) ->
          $("#diet_type_id").val(ui.item.id)
          $("#diet_unit").text("250g")
          $("#diet_scale" ).slider({
              value: "2.5"
            })
          $("#diet_amount").val(2.5)
      })

@load_drink_types = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load rdrinks"
  $.ajax '/food_types.json?type=drink',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load drink_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load drink_types  Successful AJAX call"

      foods = data.map( window.food_map_fn )

      $("#drinkname").autocomplete({
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          for element in foods
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
            if cnt >= 20
              break
          response(result)
        select: (event, ui) ->
          $("#diet_drink_type_id").val(ui.item.id)
          $("#diet_drink_unit").text("2.5dl")
          $("#diet_drink_scale" ).slider({
            value: "2.5"
          })
#          $("#diet_drink_name").val(ui.item.label)
          $("#diet_drink_amount").val(2.5)
          $("#diet_drink_cal").val(ui.item.kcal*2.5)
          $("#diet_drink_fat").val(ui.item.fat*2.5)
          $("#diet_drink_carbs").val(ui.item.carb*2.5)
          $("#diet_drink_prot").val(ui.item.prot*2.5)
          $("#diet_drink_category").val(ui.item.categ)
      })