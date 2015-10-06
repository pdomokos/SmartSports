@diet_loaded = () ->
  console.log("diet loaded2")

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#diet-link").css
    background: "rgba(87, 200, 138, 0.3)"

  popup_messages = JSON.parse($("#popup-messages").val())

  initDiet()
  load_diets()

  $("form.resource-create-form.diet-form").on("ajax:success", (e, data, status, xhr) ->
    console.log "success diet-form"
    console.log data
    resetDiet()
    loadDietHistory()
    popup_success(data['diet_name']+popup_messages.saved_successfully, $("#addFoodButton").css("background"))
  ).on("ajax:error", (e, xhr, status, error) ->
    $('#diet_type_id').val(null)
    $('#diet_drink_type_id').val(null)
    $('#diet_smoke_type').val(null)
    console.log xhr.responseText
    color = $("#addFoodButton").css("background")
    popup_error(popup_messages.failed_to_add_data, $("#addFoodButton").css("background"))
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "update/delete success "+form_id
    loadDietHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, $("#addFoodButton").css("background"))
  )

  $('.hisTitle').click ->
    loadDietHistory()

  $(".favTitle").click ->
    load_favs()
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $(".diet_food-create-form button").click ->
    validate_diet_food("#diet_forms .diet_food_elem")

@resetDiet = () ->
  $("div.diet > input.dataFormField").val("")
  $("#diet_scale").slider({ value: 2 })
  fval = $("#diet_scale").slider("value")
  $("#diet_unit").html(fval*100+"g")
  $("#diet_drink_scale").slider({ value: 2 })
  dval = $("#diet_drink_scale").slider("value")
  $("#diet_drink_unit").html(dval+" dl")
  $('div.diet > .diet_food_datepicker').val(moment().format(moment_fmt))
  $('#diet_calories_datepicker').val(moment().format(moment_fmt))
  $('#diet_drink_datepicker').val(moment().format(moment_fmt))
  $('#diet_smoking_datepicker').val(moment().format(moment_fmt))
  $('#diet_type_id').val(null)
  $('#diet_drink_type_id').val(null)
  $('#diet_smoke_type').val(null)

@initDiet = () ->
  console.log "initdiet called"
  $('.diet_food_datepicker').datetimepicker(timepicker_defaults)
  $(".diet_food_amount").val(2)
  $('.diet_drink_datepicker').datetimepicker(timepicker_defaults)
  $(".diet_drink_amount").val(2)
  $('#diet_calories_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_smoking_datepicker').datetimepicker(timepicker_defaults)


  $(".diet_food_scale").slider({
    min: 0.25,
    max: 5.0,
    step: 0.25,
    value: 2
  }).slider({
    slide: (event, ui) ->
      $(".diet_food_unit").html(" "+ui.value*100+"g")
    change: (event, ui) ->
      $(".diet_food_amount").val(ui.value)
  })

  $(".diet_drink_scale").slider({
    min: 0.25,
    max: 5,
    step: 0.25,
    value: 2
  }).slider({
    slide: (event, ui) ->
      $(".diet_drink_unit").html(ui.value+" dl")
    change: (event, ui) ->
      $(".diet_drink_amount").val(ui.value)
  })

  document.body.style.cursor = 'wait'
  load_food_types()

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
  popup_messages = JSON.parse($("#popup-messages").val())
  console.log "calling load recent foods"
  $.ajax '/food_types.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent food_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load food_types  Successful AJAX call"

      foods = data.filter( (d) ->
        d['category'] != 'Ital'
      ).map( window.food_map_fn )

      drinks = data.filter( (d) ->
        d['category'] == 'Ital'
      ).map( window.food_map_fn )

      foodSelected = null
      $(".diet_food_name").autocomplete({
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
          $(".diet_type_id").val(ui.item.id)
        create: (event, ui) ->
          document.body.style.cursor = 'auto'
          $(".diet_food_name").removeAttr("disabled")
        change: (event, ui) ->
          foodSelected = ui['item']
      })


      drinkSelected = null
      $("#drinkname").autocomplete({
        minLength: 0,
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in drinks
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          $("#diet_drink_type_id").val(ui.item.id)
        create: (event, ui) ->
          $("#drinkname").removeAttr("disabled")
        change: (event, ui) ->
          drinkSelected = ui['item']
      }).focus ->
        $(this).autocomplete("search")

      $("#drink-create-form button").click ->
        if(!drinkSelected)
          val = $("#dinkname").val()
          if !val
            val = "empty item"
          popup_error(popup_messages.failed_to_add_data, $("#addFoodButton").css("background"))
          drinkSelected = null
          return false
        drinkSelected = null
        return true

      smokeList = [
        {label: "1 Cigaretta"             ,value: "1 Cigaretta"            },
        {label: "1 Szivar"                ,value: "1 Szivar"               },
        {label: "1 Szivarka"              ,value: "1 Szivarka"             },
        {label: "1 Pipa"                  ,value: "1 Pipa"                 },
        {label: "1 Elektromos cigaretta"  ,value: "1 Elektromos cigaretta" },
        {label: "1 Nikotinos orrspray"    ,value: "1 Nikotinos orrspray"   },
        {label: "1 Nikotinos rágó"        ,value: "1 Nikotinos rágó"       },
        {label: "1 Nikotinos tapasz"      ,value: "1 Nikotinos tapasz"     }]

      smokeSelected = null
      $("#diet_smoke_type").autocomplete({
        minLength: 0,
        source: smokeList,
        change: (event, ui) ->
          console.log "change "+ui['item']
          smokeSelected = ui['item']
      }).focus ->
        $(this).autocomplete("search")

      $("#smoke-create-form button").click ->
        if(!smokeSelected)
          val = $("#diet_smoke_type").val()
          if !val
            val = "empty item"
          popup_error(popup_messages.failed_to_add_data, $("#addFoodButton").css("background"))
          smokeSelected = null
          return false
        smokeSelected = null
        return true


      $("#recentResourcesTable").on("click", "td.dietItem", (e) ->
        data = JSON.parse(e.currentTarget.querySelector("input").value)
        if data.diet_type=='Food'
          load_diet_food("#diet_forms .diet_food_elem", data)
      )
@validate_diet_food = (sel) ->
  val = $(sel+" .diet_food_name").val()
  if !val
    val = "empty item"
    popup_error(popup_messages.failed_to_add_data, $("#addFoodButton").css("background"))
    return false
  return true

@load_diet_food =  (sel, data) ->
  console.log "loading diet food: "+sel
  diet = data['diet']
  console.log data
  $(sel+" input[name='food_name']").val(data.food_name)
  $(sel+" input[name='diet[food_type_id]'").val(diet.food_type_id)
  $(sel+" .diet_food_unit").html(diet.amount*100+"g")
  console.log sel+" .diet_food_scale"
  console.log diet.amount
  $(sel+" .diet_food_scale").slider({value: diet.amount})
  $(sel+" input[name='diet[date]'").val(diet.date)

@load_diet_drink =  (sel, data) ->
  console.log "loading diet drink: "+sel
  diet = data['diet']
  console.log data
  $(sel+" input[name='drink_name']").val(data.drink_name)
  $(sel+" input[name='diet[food_type_id]'").val(diet.food_type_id)
  $(sel+" .diet_drink_unit").html(diet.amount+" dl")
  $(sel+" .diet_drink_scale").slider({value: diet.amount})
  $(sel+" input[name='diet[date]'").val(diet.date)

@load_diet_smoke = (sel, data) ->
  console.log "loading diet smoke: "+sel
  diet = data['diet']
  console.log data
  $(sel+" input[name='diet[name]']").val(diet.name)
  $(sel+" input[name='diet[date]']").val(diet.date)
