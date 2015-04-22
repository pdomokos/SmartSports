@diet_loaded = () ->
  console.log("diet loaded2")

  $('#diet_food_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_drink_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_smoking_datepicker').datetimepicker(timepicker_defaults)

  load_food_types()
  load_drink_types()
  load_diets()

  $("form.resource-create-form.diet-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")
    $('#diet_food_datepicker').val(moment().format(moment_fmt))
    $('#diet_drink_datepicker').val(moment().format(moment_fmt))
    $('#diet_smoking_datepicker').val(moment().format(moment_fmt))
    load_diets()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create diet.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "update/delete success "+form_id
    load_diets()
    $("#hist-button").addClass("ui-btn-active")
    $("#fav-button").removeClass("ui-btn-active")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to update/delete diet.")
  )

  $('#hist-button').click ->
    load_diets()

  $("#fav-button").click ->
    load_diets(true)

  $("#dietPage").on("click" , ".recentResourcesListview a", () ->
    $("#editFoodPage").attr("data-foodid", this.dataset.foodid)
  )

@load_diets = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent diets"
  url = '/users/' + current_user + '/diets.js?source='+window.default_source+'&order=desc&limit=10&mobile=true'
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent diets  Successful AJAX call"
      console.log textStatus

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


@load_food_types = () ->
  self = this
  console.log "calling load recent foods"
  $.ajax '/food_types.json?type=food',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent food_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load food_types  Successful AJAX call"

      foods = data.map( food_map_fn )

      $( "#food_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
        $ul = $( this )
        $input = $( data.input )
        value = $input.val()

        html = ""
        $ul.html( "" )
        if ( value && value.length > 1 )
          console.log "started "+value
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )

          matcher = new RegExp($input.val(), "i")
          result = []
          cnt = 0
          for element in foods
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='food_id_"+val.id+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#food_autocomplete").on("click", "li", (e) ->
        $("#foodname").val($(this).text())
        $("#food_autocomplete").html("")
        [..., food_id] = $(this)[0].id.split("_")
        $("#diet_type_id").val( food_id )
        console.log $(this).text()+" id: "+food_id
      )

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

      drinks = data.map( food_map_fn )

      $( "#drink_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
        $ul = $( this )
        $input = $( data.input )
        value = $input.val()

        html = ""
        $ul.html( "" )
        if ( value && value.length > 1 )
          console.log "started "+value
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )

          matcher = new RegExp($input.val(), "i")
          result = []
          cnt = 0
          for element in drinks
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='food_id_"+val.id+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#drink_autocomplete").on("click", "li", (e) ->
        $("#drinkname").val($(this).text())
        $("#drink_autocomplete").html("")
        [..., food_id] = $(this)[0].id.split("_")
        $("#drink_type_id").val( food_id )
        console.log $(this).text()+" id: "+food_id
      )

@show_food = (e, ui) ->
  foodid = ui.toPage[0].dataset.foodid
  console.log("show food id cb: "+foodid)
  current_user = $("#current-user-id")[0].value
  foodurl = '/users/' + current_user + '/diets/'+foodid+'.json'
  $.ajax foodurl,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load diet AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load diet  Successful AJAX call"
      console.log data
      $("#editFoodPage h1.diet-group").html(data.type)

      if(data.type=="Smoke")
        $("#edit_food_category_label").hide()
        $("#edit_food_category").hide()
      else
        $("#edit_food_category_label").show()
        $("#edit_food_category").show()
        $("#edit_food_name").val(data.food_name)
        $("#edit_food_category").val(data.food_category)
        $("#edit_food_date").val(moment(data.date).format("YYYY-MM-DD HH:mm"))
        $("#food_amount_edit_scale").val(data.amount).slider("refresh")
        $("#food_favorite").prop("checked", data.favourite).flipswitch("refresh")
