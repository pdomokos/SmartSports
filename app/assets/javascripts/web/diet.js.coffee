@diet_loaded = () ->
  console.log("diet loaded2")

  $("div.appMenu button").removeClass("selected")
  $("#diet-button").addClass("selected")

  smokeList = [
    {label: "1 Cigaretta"             ,value: "1 Cigaretta"            },
    {label: "1 Szivar"                ,value: "1 Szivar"               },
    {label: "1 Szivarka"              ,value: "1 Szivarka"             },
    {label: "1 Pipa"                  ,value: "1 Pipa"                 },
    {label: "1 Elektromos cigaretta"  ,value: "1 Elektromos cigaretta" },
    {label: "1 Nikotinos orrspray"    ,value: "1 Nikotinos orrspray"   },
    {label: "1 Nikotinos rágó"        ,value: "1 Nikotinos rágó"       },
    {label: "1 Nikotinos tapasz"      ,value: "1 Nikotinos tapasz"     }]

  $("#diet_smoke_type").autocomplete({
    minLength: 0,
    source: smokeList
  }).focus ->
    $(this).autocomplete("search")

  $('#diet_food_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_drink_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_smoking_datepicker').datetimepicker(timepicker_defaults)


  load_diets()
  document.body.style.cursor = 'wait'
  load_food_types()
  load_drink_types()

  $("#diet_drink_amount").val(2)
  $("#diet_amount").val(2)

  $("#diet_scale").slider({
    min: 0.5,
    max: 5.0,
    step: 0.5,
    value: 1
  }).slider({
    slide: (event, ui) ->
      $("#diet_unit").html(" "+ui.value+" adag ("+ui.value*200+"g)")
    change: (event, ui) ->
      $("#diet_amount").val(ui.value*2)
  })

  $("#diet_drink_scale").slider({
    min: 0.5,
    max: 5,
    step: 0.5,
    value: 1
  }).slider({
    slide: (event, ui) ->
      $("#diet_drink_unit").html(ui.value+" adag ("+ui.value*2+"dl)")
    change: (event, ui) ->
      $("#diet_drink_amount").val(ui.value*2)
  })

  $("form.resource-create-form.diet-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")
    $("#diet_scale").slider({ value: 1 })
    fval = $("#diet_scale").slider("value")
    $("#diet_unit").html(fval+" adag")
    $("#diet_drink_scale").slider({ value: 1 })
    dval = $("#diet_drink_scale").slider("value")
    $("#diet_drink_unit").html(dval+" adag")
    $('#diet_food_datepicker').val(moment().format(moment_fmt))
    $('#diet_drink_datepicker').val(moment().format(moment_fmt))
    $('#diet_smoking_datepicker').val(moment().format(moment_fmt))
    loadDietHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create diet.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "update/delete success "+form_id
    loadDietHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to update/delete diet.")
  )

  $('.hisTitle').click ->
    loadDietHistory()

  $(".favTitle").click ->
    load_favs()
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $("#recentResourcesTable").on("click", "td.dietItem", (e) ->
    console.log "loading diet"
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    console.log data
    if data.type=="Food"
      $("#foodname").val(data.food_name)
      $("#diet_type_id").val(data.food_type_id)
      $("#diet_amount").val(data.amount)
      $("#diet_unit").html(data.amount/2+" adag ("+data.amount*100+"g)")
      $("#diet_scale").slider({value: data.amount/2})
    else if data.type=="Drink"
      $("#drinkname").val(data.food_name)
      $("#drink_type_id").val(data.food_type_id)
      $("#diet_drink_amount").val(data.amount)
      $("#diet_drink_unit").html(data.amount/2+" adag ("+data.amount+"dl)")
      $("#diet_drink_scale").slider({value: data.amount/2})
  )

@loadDietHistory = () ->
  load_diets()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_diets = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent diets"
  $.ajax '/users/' + current_user + '/diets.js?source='+window.default_source+'&order=desc&limit=10',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      $(".deleteDiet").removeClass("hidden")
      console.log "load recent diets  Successful AJAX call"
      console.log textStatus

@load_favs = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent diets"
  $.ajax '/users/' + current_user + '/diets.js?source='+window.default_source+'&favourites=true&order=desc&limit=10',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      $(".deleteDiet").addClass("hidden")
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
        minLength: 3,
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in foods
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          $("#diet_type_id").val(ui.item.id)
        create: (event, ui) ->
          document.body.style.cursor = 'auto'
          $("#foodname").removeAttr("disabled")
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
        minLength: 0,
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in foods
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          $("#diet_drink_type_id").val(ui.item.id)
        create: (event, ui) ->
          $("#drinkname").removeAttr("disabled")
      }).focus ->
        $(this).autocomplete("search")