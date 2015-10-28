@mdPatientsLoaded = () ->
  resetMdUI()
  $("#patients-link").addClass("menulink-selected")

  @dateToShow = moment().format("YYYY-MM-DD")
  define_globals()

  notifTypeList = [ { label: "doctor", value: "doctor" },
    { label: "medication", value: "medication" },
    { label: "reminder", value: "reminder" },
    { label: "motivation", value: "motivation" }
  ]
  $("#notifType").autocomplete({
    minLength: 0,
    source: notifTypeList
  }).focus ->
    $(this).autocomplete("search")
  $("#notifType").val("reminder")

  $("#patients-link").click (event) ->
    event.preventDefault()
    resetMdUI()
    $("#patients-link").addClass("menulink-selected")
    $("#sectionPatients").removeClass("hiddenSection")

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
    evt.currentTarget.classList.toggle("selected")
  )

  loadPatients()
  loadForms()

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
          $(".patientData").removeClass("hidden")
          loadNotifications(ui.item.obj.id)
          $("#patientHeader").tooltip({
            items: "img",
            content: '<img src="'+ui.item.obj.avatar_url+'" />'
          })
          uid = ui.item.obj.id
          d3.json("/users/"+uid+"/analysis_data.json?date="+@dateToShow, timeline_data_received)
          d3.json("/users/"+uid+"/measurements.json?meas_type=blood_sugar", bg_data_received)
          meas_summary_url = "/users/" + uid + "/measurements.json?summary=true"
          d3.json(meas_summary_url, draw_health_trend)

        create: (event, ui) ->
#          document.body.style.cursor = 'auto'
          $(".patientName").removeAttr("disabled")
        change: (event, ui) ->
          console.log "change"
      }).focus ->
        $(this).autocomplete("search")

@loadForms = () ->
  $.ajax '/custom_forms.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load forms AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load forms  Successful AJAX call"
      document.body.style.cursor = 'auto'
      #      console.log data
      $("input[name=form_name]").autocomplete({
        minLength: 0,
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in data
            if matcher.test(remove_accents(element.form_tag))
              result.push({label: element.form_tag, value: element.form_tag, id: element.id})
              cnt += 1
          response(result)
        select: (event, ui) ->
          $("input[name='notification[custom_form_id]']").val(ui.item.id)
          console.log ui.item
        create: (event, ui) ->
#          document.body.style.cursor = 'auto'
          $("input[name=form_name]").removeAttr("disabled")
        change: (event, ui) ->
          console.log "change"
      }).focus ->
        $(this).autocomplete("search")
      if data.length>0
        $("input[name='form_name']").val(data[0].form_tag)
        $("input[name='notification[custom_form_id]']").val(data[0].id)

@loadNotifications = (userId) ->
  console.log "calling load notifications for: "+userId
  $.ajax '/users/' + userId + '/notifications.js?order=desc&limit=10',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent notifications Successful AJAX call"

