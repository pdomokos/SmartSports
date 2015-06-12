@medications_loaded = () ->
  $('#medications_datepicker').datetimepicker(timepicker_defaults)
  $('#medications_insulin_datepicker').datetimepicker(timepicker_defaults)

  load_medication_types()
  load_medications()

  $(document).on("ajax:success", "form.resource-create-form.medication-form", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")

    $('#medname').val(null)
    $('#insname').val(null)
    $('#oral_medication_name').val(null)
    $('#insulin_name').val(null)
    $("#medication_amount").val(null)
    $("#medication_insulin_dosage").val(null)
    $('#medications_datepicker').val(moment().format(moment_fmt))
    $('#medications_insulin_datepicker').val(moment().format(moment_fmt))

    load_medications()
    $("#successMedicationPopup").popup("open")

  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    $('#medname').val(null)
    $('#insname').val(null)
    $("#failureMedicationPopup").popup("open")
  )

  $(document).on("ajax:success", "#updateMedicationForm", (e, data, status, xhr) ->
    console.log("update successfull")
    $("#medicationPage").attr("data-scrolltotable", true)
    $( ":mobile-pagecontainer" ).pagecontainer("change", "#medicationPage")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to update medication.")
  )

  $(document).on("ajax:success", "#deleteMedicationForm", (e, data, status, xhr) ->
    console.log("delete successfull")
    $("#medicationPage").attr("data-scrolltotable", true)
    $.mobile.navigate( "#medicationPage" )
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete medication.")
  )

  $('#hist-medication-button').click ->
    load_medications()

  $("#fav-medication-button").click ->
    load_medications(true)

  $("#medicationPage").on("click" , "#medicationListView td.medication_item", load_medication_item)

  $(document).on("pagecontainershow", (event, ui) ->
    console.log("medication pagecontainershow")
    load_medications()
  )

load_medication_item = (e) ->
  console.log "loading medication"
  data = JSON.parse(e.currentTarget.querySelector("input").value)
  console.log data
  if data.medication_type=="oral"
    $("#oral_medication_name").val(data.medication_name)
    $("#medname").val(data.medication_type_id)
    $("#medication_amount").val(data.amount)
  else if data.medication_type=="insulin"
    $("#insulin_name").val(data.medication_name)
    $("#insname").val(data.medication_type_id)
    $("#medication_insulin_dosage").val(data.amount)

@load_medications = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent medications"
  lang = $("#data-lang-medication")[0].value
  url = '/users/' + current_user + '/medications.js?source='+window.default_source+'&order=desc&limit=10&mobile=true'
  if lang
    url = url+"&lang="+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent medications AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent medications  Successful AJAX call"
      console.log textStatus
      if fav
        $("#hist-medication-button").removeClass("ui-btn-active")
        $("#fav-medication-button").addClass("ui-btn-active")
      else
        $("#hist-medication-button").addClass("ui-btn-active")
        $("#fav-medication-button").removeClass("ui-btn-active")

      if $("#medicationPage").attr('data-scrolltotable')
        $.mobile.silentScroll($("div.ui-navbar").offset().top)
        $("#medicationPage").attr('data-scrolltotable', null)


@load_medication_types = () ->
  self = this
  console.log "calling load medication types"
  $.ajax '/medication_types.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent medication_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load medication_types  Successful AJAX call"
      pills = data.filter( (d) ->
        d['group'] == 'oral'
      ).map( (d) ->
        {
          label: d['name'],
          id: d['id']
      })
      insulin = data.filter( (d) ->
        d['group'] == 'insulin'
      ).map( (d) ->
        {
        label: d['name'],
        id: d['id']
        })

      $( "#medication_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
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
          for element in pills
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='medication_id_"+val.id+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#medication_autocomplete").on("click", "li", (e) ->
        $("#oral_medication_name").val($(this).text())
        $("#medication_autocomplete").html("")
        [..., medication_id] = $(this)[0].id.split("_")
        $("#medname").val( medication_id )
        console.log $(this).text()+" id: "+medication_id
      )

      $( "#insulin_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
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
          for element in insulin
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='medication_id_"+val.id+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#insulin_autocomplete").on("click", "li", (e) ->
        $("#insulin_name").val($(this).text())
        $("#insulin_autocomplete").html("")
        [..., medication_id] = $(this)[0].id.split("_")
        $("#insname").val( medication_id )
        console.log $(this).text()+" id: "+medication_id
      )
