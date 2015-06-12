@diet_loaded = () ->
  console.log("diet loaded2")

  $('#diet_food_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_drink_datepicker').datetimepicker(timepicker_defaults)
  $('#diet_smoking_datepicker').datetimepicker(timepicker_defaults)

  load_food_types()
  load_drink_types()
  load_diets()

  $(document).on("ajax:success", "form.resource-create-form.diet-form", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log xhr.responseText
    $("#foodname").val("")
    $('#diet_food_datepicker').val(moment().format(moment_fmt))
    $('#diet_drink_datepicker').val(moment().format(moment_fmt))
    $('#diet_smoking_datepicker').val(moment().format(moment_fmt))
    $("#diet_scale").val(2.5).slider("refresh")
    $("#drink_scale").val(2.5).slider("refresh")

    load_diets()
    $("#successPopup").popup("open")

  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    $("#failurePopup").popup("open")
  )

  $(document).on("ajax:success", "#updateFoodForm", (e, data, status, xhr) ->
    console.log("update successfull")
    $("#dietPage").attr("data-scrolltotable", true)
    $( ":mobile-pagecontainer" ).pagecontainer("change", "#dietPage")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to update diet.")
  )
  $(document).on("ajax:success", "#deleteFoodForm", (e, data, status, xhr) ->
    console.log("delete successfull")
    $("#dietPage").attr("data-scrolltotable", true)
    $.mobile.navigate( "#dietPage" )
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete diet.")
  )
  $(document).on("ajax:success", "#createNewFoodForm", (e, data, status, xhr) ->
    console.log("add new diet successfull")
    $("#dietPage").attr("data-scrolltotable", true)
    $.mobile.navigate( "#dietPage" )
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to add new diet.")
  )

  $('#hist-button').click ->
    load_diets()

  $("#fav-button").click ->
    load_diets(true)

  $("#dietPage").on("click" , ".recentResourcesListview a", () ->
    $("#editFoodPage").attr("data-foodid", this.dataset.foodid)
  )

  $("#dietPage").on("click" , "#dietListView td.diet_item", load_diet_item)

  $(document).on("pagecontainershow", (event, ui) ->
    console.log("diet pagecontainershow")
    load_diets()
  )

load_diet_item =  (e) ->
    console.log "loading diet"
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    console.log data
    if data.type=="Food"
      $("#foodname").val(data.food_name)
      $("#diet_type_id").val(data.food_type_id)
      $("#diet_scale").val(data.amount).slider("refresh")
    else if data.type=="Drink"
      $("#drinkname").val(data.food_name)
      $("#drink_type_id").val(data.food_type_id)
      $("#drink_scale").val(data.amount).slider("refresh")
    else if data.type=="Smoke"
      $("#diet_smoke_type").val(data.name).selectmenu("refresh",true)

@load_diets = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  lang = $("#data-lang-diet")[0].value
  console.log "calling load recent diets"
  url = '/users/' + current_user + '/diets.js?source='+window.default_source+'&order=desc&limit=10&mobile=true'
  if lang
    url = url+"&lang="+lang
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
      if fav
        $("#hist-button").removeClass("ui-btn-active")
        $("#fav-button").addClass("ui-btn-active")
        $("#editFoodPage").attr("data-isfavourite", true)
      else
        $("#hist-button").addClass("ui-btn-active")
        $("#fav-button").removeClass("ui-btn-active")
        $("#editFoodPage").attr("data-isfavourite", null)

      if $("#dietPage").attr('data-scrolltotable')
        $.mobile.silentScroll($("div.ui-navbar").offset().top)
        $("#dietPage").attr('data-scrolltotable', null)


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
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )

          matcher = new RegExp(remove_accents(value), "i")
          result = []
          cnt = 0
          for element in foods
            if matcher.test(remove_accents(element.label))
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

          matcher = new RegExp(remove_accents($input.val()), "i")
          result = []
          cnt = 0
          for element in drinks
            if matcher.test(remove_accents(element.label))
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

  if $("#editFoodPage").attr("data-isfavourite")
    $("#deleteFoodForm").addClass("ui-screen-hidden")
    $("#updateFoodForm").addClass("ui-screen-hidden")
    $("#createNewFoodForm").removeClass("ui-screen-hidden")
  else
    $("#deleteFoodForm").removeClass("ui-screen-hidden")
    $("#updateFoodForm").removeClass("ui-screen-hidden")
    $("#createNewFoodForm").addClass("ui-screen-hidden")

  $.ajax foodurl,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load diet AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load diet  Successful AJAX call    "
      console.log data
      $("#editFoodPage h1.diet-group").html(data.type)

      f = $("#updateFoodForm")[0]
      f.action = "/users/"+current_user+"/diets/"+foodid
      f = $("#deleteFoodForm")[0]
      f.action = "/users/"+current_user+"/diets/"+foodid
      f = $("#createNewFoodForm")[0]
      f.action = "/users/"+current_user+"/diets"

      if(data.type=="Smoke")
        $("#edit_food_category_label").hide()
        $("#edit_food_category").hide()
        $("#new_food_category_label").hide()
        $("#new_food_category").hide()
        $("#new_food_amount_edit_scale_label").hide()
        $("#createNewFoodForm div.ui-slider").hide()

        $("#edit_food_name").val(data.name)
        $("#edit_food_date").val(moment(data.date).format("YYYY-MM-DD HH:mm"))
        $("#food_favorite").prop("checked", data.favourite).flipswitch("refresh")

        $("#new_diet_type").val("Smoke")
        $("#new_food_name").val(data.name)
        $("#new_food_date").val(moment().format("YYYY-MM-DD HH:mm"))
      else
        $("#edit_food_category_label").show()
        $("#edit_food_category").show()
        $("#new_food_amount_edit_scale_label").show()
        $("#createNewFoodForm div.ui-slider").show()

        $("#edit_food_name").val(data.food_name)
        $("#edit_food_category").val(data.food_category)
        $("#edit_food_date").val(moment(data.date).format("YYYY-MM-DD HH:mm"))
        $("#food_amount_edit_scale").val(data.amount).slider("refresh")
        $("#food_favorite").prop("checked", data.favourite).flipswitch("refresh")

        $("#new_food_category_label").show()
        $("#new_food_category").show()
        $("#new_food_name").val(data.food_name)
        $("#new_food_category").val(data.food_category)
        $("#new_food_date").val(moment().format("YYYY-MM-DD HH:mm"))
        $("#new_food_amount_edit_scale").val(data.amount).slider("refresh")
        $("#new_food_favorite").prop("checked", data.favourite).flipswitch("refresh")

        $("#new_diet_type").val(data.type)
        $("#new_diet_type_id").val(data.food_type_id)
