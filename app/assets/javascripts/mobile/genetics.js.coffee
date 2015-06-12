@genetics_loaded = () ->
  console.log("genetics loaded")
  $("#genetics-link").css
    background: "rgba(56, 199, 234, 0.3)"
  load_family_histories()
  load_fh_item_types()

  $(document).on("ajax:success", "#familyhist-create-form", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log xhr.responseText
    $('#gen_hist_relative').val(null)
    $('#gen_hist_disease').val(null)
    $('#relative').val(null)
    $('#disease').val(null)
    $('#gen_hist_note').val(null)
    load_family_histories()
    $("#successGeneticsPopup").popup("open")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    $("#failureGeneticsPopup").popup("open")
  )

  $(document).on("ajax:success", "#delete_family_history", (e, data, status, xhr) ->
    console.log("delete successfull")
    $("#geneticsPage").attr("data-scrolltotable", true)
    $.mobile.navigate( "#geneticsPage" )
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete fh.")
  )

  $(document).on("pagecontainershow", (event, ui) ->
    console.log("fh pagecontainershow")
    load_family_histories()
  )

@load_family_histories = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  lang = $("#data-lang-training")[0].value
  url = '/users/' + current_user + '/family_histories.js?source='+window.default_source+'&order=desc&limit=10&mobile=true'
  if lang
    url = url+"&lang="+lang
  console.log "calling load recent family histories"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent family hist AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent family hist  Successful AJAX call"
      console.log textStatus
      if $("#geneticsPage").attr('data-scrolltotable')
        $.mobile.silentScroll($("div.ui-navbar").offset().top)
        $("#geneticsPage").attr('data-scrolltotable', null)

@load_fh_item_types = () ->
  self = this
  console.log "calling load fh item types"
  $.ajax '/activity_types.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load fh_item_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load fh_item_types  Successful AJAX call"
      relativeList = JSON.parse($("#relativeList").val())
      diseaseList = JSON.parse($("#diseaseList").val())

      $( "#relative_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
        $ul = $( this )
        $input = $( data.input )
        value = $input.val()

        html = ""
        $ul.html( "" )
        if ( value )
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )
          matcher = new RegExp(remove_accents(value), "i")
          result = []
          cnt = 0
          for element in relativeList
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='relative_id_"+val.value+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#relative_autocomplete").on("click", "li", (e) ->
        $("#gen_hist_relative").val($(this).text())
        $("#relative_autocomplete").html("")
        [..., relative_id] = $(this)[0].id.split("_")
        $("#relative").val( relative_id )
        console.log $(this).text()+" id: "+relative_id
      )

      $( "#disease_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
        $ul = $( this )
        $input = $( data.input )
        value = $input.val()

        html = ""
        $ul.html( "" )
        if ( value )
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )
          matcher = new RegExp(remove_accents(value), "i")
          result = []
          cnt = 0
          for element in diseaseList
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='disease_id_"+val.value+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#disease_autocomplete").on("click", "li", (e) ->
        $("#gen_hist_disease").val($(this).text())
        $("#disease_autocomplete").html("")
        [..., disease_id] = $(this)[0].id.split("_")
        $("#disease").val( disease_id )
        console.log $(this).text()+" id: "+disease_id
      )