@diet_loaded = () ->
  console.log("diet loaded2")

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#diet-link").css
    background: "rgba(87, 200, 138, 0.3)"

  popup_messages = JSON.parse($("#popup-messages").val())
  amount_values = $("#amount_values").val().split(",")

  document.body.style.cursor = 'wait'
  loadFoodTypes( () ->
    console.log("foodtypes loaded")
    document.body.style.cursor = 'auto'
    initDiet()
    loadDiets()
  )

  $("#recentResourcesTable").on("click", "td.dietItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    diet = data['diet']
    if data.diet_category=='Food'
      load_diet_food("#diet_forms .diet_food", data)
    else if data.diet_category=='Drink'
      load_diet_drink("#diet_forms .diet_drink", data)
    else if data.diet_category=='Smoke'
      load_diet_smoke("#diet_forms .diet_smoke", data)
    else if data.diet_category=='Calory'
      load_diet_quick_calories("#diet_forms .diet_quick_calories", data)
  )

  $("form.resource-create-form.diet-form").on("ajax:success", (e, data, status, xhr) ->
    resetDiet()
    loadDietHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    resp = JSON.parse(xhr.responseText)
    popup_error(resp.msg)
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    loadDietHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data)
  )

  $('.hisTitle').click ->
    loadDietHistory()

  $(".favTitle").click ->
    load_favs()
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $(".diet_food-create-form button").click ->
    validate_diet_form(".diet_food-create-form")

  $(".diet_drink-create-form button").click ->
    validate_diet_form(".diet_drink-create-form")

  $(".diet_smoke-create-form button").click ->
    validate_diet_form(".diet_smoke-create-form")

  $(".diet_quick_calories-create-form button").click ->
    validate_diet_form(".diet_quick_calories-create-form")

  $(document).unbind("click.dietShow")
  $(document).on("click.dietShow", "#diet-show-table", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    diet_header = $("#diet_header_values").val().split(",")
    url = 'users/' + current_user + '/diets.json'+'?table=true&lang='+lang
    show_table(url, lang, diet_header, 'get_diet_table_row', 'show_diet_table')
  )

  $(document).unbind("click.downloadDiet")
  $(document).on("click.downloadDiet", "#download-diet-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    url = '/users/' + current_user + '/diets.csv?order=desc&lang='+lang
    location.href = url
  )

  $(document).unbind("click.closeDiet")
  $(document).on("click.closeDiet", "#close-diet-data", (evt) ->
    $("#diet-data-container").html("")
    location.href = "#close"
  )

@get_diet_table_row = (item) ->
  ret = [moment(item.date).format(moment_fmt), item.category, item.name, item.amount, item.calories, item.carbs]
  return ret

@show_diet_table = (tblData, header, plugin) ->
  $("#diet-data-container").html("<table id=\"diet-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>")
  $("#diet-data").dataTable({
    data: tblData,
    columns: [
      {"title": header[0]},
      {"title": header[1]},
      {"title": header[2]},
      {"title": header[3]},
      {"title": header[4]},
      {"title": header[5]}
    ],
    order: [
      [0, "desc"]
    ],
    lengthMenu: [10],
    language: plugin
  })
  location.href = "#openModalDiet"

@resetDiet = () ->
  amount_values = $("#amount_values").val().split(",")
  $("div.diet > input.dataFormField").val("")
  $(".diet_food_scale").slider({ value: 1 })
  fval = $(".diet_food_scale").slider("value")
  $(".diet_food_unit").html(amount_values[fval])
  $(".diet_drink_scale").slider({ value: 2 })
  dval = $(".diet_drink_scale").slider("value")
  $(".diet_drink_unit").html(dval+" dl")

  $(".diet_food_datepicker").val(moment().format(moment_fmt))
  $(".diet_calories_datepicker").val(moment().format(moment_fmt))
  $(".diet_drink_datepicker").val(moment().format(moment_fmt))
  $(".diet_smoking_datepicker").val(moment().format(moment_fmt))

@initDiet = () ->
  self = this
  amount_values = $("#amount_values").val().split(",")
  $(".diet_food_datepicker").datetimepicker(timepicker_defaults)
  $(".diet_food_amount").val(1)
  $(".diet_drink_datepicker").datetimepicker(timepicker_defaults)
  $(".diet_drink_amount").val(2)
  $(".diet_calories_datepicker").datetimepicker(timepicker_defaults)
  $(".diet_smoking_datepicker").datetimepicker(timepicker_defaults)

  $(".diet_food_scale").slider({
    min: 0,
    max: 2,
    step: 1,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("div.diet_food_unit").innerHTML = " "+amount_values[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("input.diet_food_amount").value = ui.value
  })

  $(".diet_drink_scale").slider({
    min: 0.25,
    max: 5,
    step: 0.25,
    value: 2
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("div.diet_drink_unit").innerHTML = " "+ui.value+"dl"
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("input.diet_drink_amount").value = ui.value
  })

  user_lang = $("#user-lang")[0].value
  diet_food_select = $(".diet_food_name")
  diet_drink_select = $(".diet_drink_name")
  diet_smoke_select = $(".diet_smoke_name")
  if user_lang
    foodkey = 'sd_foods_'+user_lang
    drinkkey = 'sd_drinks_'+user_lang
    smokekey = 'sd_smoke_'+user_lang
  else
    foodkey = 'sd_foods_hu'
    drinkkey = 'sd_drinks_hu'
    smokekey = 'sd_smoke_hu'
  for element in getStored(foodkey)
    diet_food_select.append($("<option />").val(element.id).text(element.label))

  for element in getStored(drinkkey)
    diet_drink_select.append($("<option />").val(element.id).text(element.label))

  for element in getStored(smokekey)
    diet_smoke_select.append($("<option />").val(element.id).text(element.label))

@loadDietHistory = () ->
  loadDiets()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@loadDiets = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  lang = $("#data-lang-diet")[0].value
  url = 'users/' + current_user + '/diets.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang

  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: "+errorThrown
    success: (data, textStatus, jqXHR) ->
      $(".deleteDiet").removeClass("hidden")

@get_food_label = (key) ->
  user_lang = $("#user-lang")[0].value
  arr = ['sd_foods_', 'sd_drinks_', 'sd_smoke_']

  value = null
  console.log "get_label "+key
  if(key=='calory')
    if user_lang && user_lang=='hu'
      value = 'Gyors kalória'
    if user_lang && user_lang=='en'
      value = 'Quick calory'
  if value != null
    return value

  arr.forEach((item) ->
    if user_lang
      food_db = item+user_lang
    else
      food_db = item+'hu'

    if getStored(food_db)!=undefined && getStored(food_db).length!=0
      tmp = getStored(food_db).filter((d) ->
        return d.id==key;
      )
      if tmp.length!=0
        value = tmp[0].label
  )
  if value==null
    value = 'Unknown'
  return value

@load_favs = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  url = 'users/' + current_user + '/diets.js?source='+window.default_source+'&favourites=true&order=desc&limit=10'
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: "+errorThrown
    success: (data, textStatus, jqXHR) ->
      $(".deleteDiet").addClass("hidden")

@loadFoodTypes = (cb) ->
  self = this
  current_user = $("#current-user-id")[0].value
  popup_messages = JSON.parse($("#popup-messages").val())
  user_lang = $("#user-lang")[0].value
  db_version = $("#db-version")[0].value

  if user_lang
    foodkey = 'sd_foods_'+user_lang
  else
    foodkey = 'sd_foods_hu'

  if getStored(foodkey)==undefined || getStored(foodkey).length==0 || testDbVer(db_version, ['sd_foods_hu','sd_drinks_hu','sd_smoke_hu','sd_foods_en','sd_drinks_en','sd_smoke_en'])
    ret = $.ajax urlPrefix()+'food_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load recent food_types AJAX Error: "+errorThrown
      success: (data, textStatus, jqXHR) ->
        console.log "load food_types  Successful AJAX call"

        setStored('sd_foods_hu', data.filter( (d) ->
          d['category'] == "Food"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))


        setStored('sd_drinks_hu', data.filter( (d) ->
          d['category'] == "Drink"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))

        setStored('sd_smoke_hu', data.filter( (d) ->
          d['category'] == "Smoke"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))

        setStored('sd_foods_en', data.filter( (d) ->
          d['category'] == "Food"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('sd_drinks_en', data.filter( (d) ->
          d['category'] == "Drink"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('sd_smoke_en', data.filter( (d) ->
          d['category'] == "Smoke"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('db_version', db_version)

        cb()
  else
    console.log "food types already loaded"
    ret = new Promise( (resolve, reject) ->
      console.log("food promise fn called")
      cb()
      resolve("food cbs called")
    )
  return ret

@validate_diet_form = (sel) ->
  console.log sel
  popup_messages = JSON.parse($("#popup-messages").val())
  val = $(sel+" select[name='diet[name]']").val()
  if !val
     val = $(sel+" input[name='diet[name]']").val()
  if !val
    val = "empty item"
    popup_error(popup_messages.failed_to_add_data)
    return false
  if val == 'calory'
    if !$(sel+" input[name='diet[calories]']").val() && !$(sel+" input[name='diet[carbs]']").val()
      popup_error(popup_messages.no_value)
      return false
    else if $(sel+" input[name='diet[calories]']").val() && ($(sel+" input[name='diet[calories]']").val() < 1 || $(sel+" input[name='diet[calories]']").val() > 4000)
      popup_error(popup_messages.calory_range_error)
      return false
    else if $(sel+" input[name='diet[carbs]']").val() && ($(sel+" input[name='diet[carbs]']").val() < 0 || $(sel+" input[name='diet[carbs]']").val() > 200)
      popup_error(popup_messages.carb_range_error)
      return false
  return true

@load_diet_food =  (sel, data) ->
  amount_values = $("#amount_values").val().split(",")
  diet = data['diet']
  console.log "load diet food to:"+sel+" diet: "+diet.name
  $(".diet_food_name").val(data['diet_name'])
  $(sel+" .diet_food_unit").html(amount_values[diet.amount])
  $(sel+" .diet_food_scale").slider({value: diet.amount})
  $(sel+" input[name='diet[date]']").val(moment().format(moment_fmt))

@load_diet_drink =  (sel, data) ->
  diet = data['diet']
  $(".diet_drink_name").val(data['diet_name'])
  $(sel+" .diet_drink_unit").html(diet.amount+" dl")
  $(sel+" .diet_drink_scale").slider({value: diet.amount})
  $(sel+" input[name='diet[date]']").val(moment().format(moment_fmt))

@load_diet_smoke = (sel, data) ->
  diet = data['diet']
  $(".diet_smoke_name").val(data['diet_name'])
  $(sel+" input[name='diet[date]']").val(moment().format(moment_fmt))

@load_diet_quick_calories = (sel, data) ->
  diet = data['diet']
  $(sel+" input[name='diet[calories]']").val(diet.calories)
  $(sel+" input[name='diet[carbs]']").val(diet.carbs)
  $(sel+" input[name='diet[date]']").val(moment().format(moment_fmt))
