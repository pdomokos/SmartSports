@mdLoaded = () ->
  console.log "md loaded"

  define_globals()

  initDiet()
  initExercise()
  initMeas()
  initMedications()
  initLifestyle()

  initCustomForms()

  $("#patients-link").click (event) ->
    event.preventDefault()
    resetMdUI()
    $("#patients-link").addClass("menulink-selected")
    $("#sectionPatients").removeClass("hiddenSection")

  $("#forms-link").click (event) ->
    event.preventDefault()
    resetMdUI()
    $("#form-link").addClass("menulink-selected")
    $("#sectionForms").removeClass("hiddenSection")

  loadPatients()

@resetMdUI = () ->
  $(".menuitem a.menulink").removeClass("menulink-selected")
  $(".menu-section").addClass("hiddenSection")

@loadPatients = () ->
  $.ajax '/users.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load patients AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load patients  Successful AJAX call"
#      console.log data

      $(".patientName").autocomplete({
        minLength: 0,
        source: (request, response) ->
          console.log request
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in data
            if matcher.test(remove_accents(element.name))
              result.push({label: element.name, value: element.name, obj: element})
              cnt += 1
          response(result)
        select: (event, ui) ->
          $(".patientId").val(ui.item.id)
          console.log ui.item
          $("#patientName").html( ui.item.label.trim() )
          $("#headerItemAvatar").attr( "src", ui.item.obj.avatar_url )
          $("#patientHeader").removeClass("hidden")
          $("#patientHeader").tooltip({
            items: "img",
            content: '<img src="'+ui.item.obj.avatar_url+'" />'
          })
          console.log '<img src="'+ui.item.obj.avatar_url+'" />'
        create: (event, ui) ->
#          document.body.style.cursor = 'auto'
          $(".patientName").removeAttr("disabled")
        change: (event, ui) ->
          console.log "change"
      }).focus ->
        $(this).autocomplete("search")