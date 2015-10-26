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

  $("#notifDate").datetimepicker(timepicker_defaults)

  $(document).on("click", "#addNotification", (evt) ->
    $("#notifDate").val(moment().format(moment_fmt))
    userid = $("input[name=patientId").val()
    $("#notificationCreateForm").attr("action", "/users/"+userid+"/notifications")
    location.href = "#openModalAddNotification"
    $("#notifTitle").focus()
  )
  $(document).on("click", "#closeModalAddNotification", (evt) ->
    location.href = "#close"
  )

  $("form#notificationCreateForm").on("ajax:success", (e, data, status, xhr) ->
    location.href = "#close"
    userid = $("input[name=patientId").val()
    loadNotifications(userid)
  )
  $("table.notificationTable tbody.recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    console.log "delete success"
    userid = $("input[name=patientId").val()
    loadNotifications(userid)
  )

  $(document).on("click", "span.dayTag", (evt) ->
    console.log evt.target.classList
    evt.target.classList.toggle("selected")
  )

@resetMdUI = () ->
  $(".menuitem a.menulink").removeClass("menulink-selected")
  $(".menu-section").addClass("hiddenSection")

@loadNotifications = (userId) ->
  console.log "calling load notifications for: "+userId
  $.ajax '/users/' + userId + '/notifications.js?order=desc&limit=10',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent notifications Successful AJAX call"

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
          $("input[name=patientId]").val(ui.item.obj.id)
          $("#headerItemAvatar").attr( "src", ui.item.obj.avatar_url )
          $("#patientHeader").removeClass("hidden")
          $("#patientNotifications").removeClass("hidden")
          loadNotifications(ui.item.obj.id)
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