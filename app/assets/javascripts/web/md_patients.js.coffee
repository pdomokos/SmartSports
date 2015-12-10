@mdPatientsLoaded = () ->
  console.log "mdPatientsLoaded called"

  registerLogoutHandler()
  registerLangHandler()


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

  $(document).unbind("click.addNotif")
  $(document).on("click.addNotif", "#addNotification", (evt) ->
    $("#notifDate").val(moment().format(moment_fmt))
    userid = $("input[name=patientId").val()
    $("#notificationCreateForm").attr("action", "/users/"+userid+"/notifications")
    location.href = "#openModalAddNotification"
    $("#notifTitle").focus()
  )

  $(document).unbind("click.closeNotif")
  $(document).on("click.closeNotif", "#closeModalAddNotification", (evt) ->
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

  $(document).unbind("click.tagDays")
  $(document).on("click.tagDays", "span.dayTag", (evt) ->
    evt.currentTarget.classList.toggle("selected")
    notifid = $(this).closest('tr').attr('id')
    e = document.getElementById(notifid)
    dayTags = e.getElementsByClassName("dayTag")
    notifs = []
    for j in dayTags
      notifs.push({id: j.id, selected: j.classList.contains("selected")})
    nid = notifid[13..]
    $.ajax '/notifications/'+nid,
      type: 'PUT',
      data: {'notification[notification_data]': JSON.stringify(notifs)}
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "Dayselect clicked AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "Dayselect clicked Successful AJAX call"
  )

  $(document).unbind("click.userDetails")
  $(document).on("click.userDetails", "#headerItemAvatar", () ->
    $(".patientData .patientDetails").toggleClass("hidden")
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
          console.log "select patient"

          $(".patientId").val(ui.item.id)

          $("#patientName").html( ui.item.label.trim() )
          $("input[name=patientId]").val(ui.item.obj.id)

          pic = ui.item.obj.avatar_url
          if pic == "unknown.jpeg"
            pic = "/assets/unknown.jpeg"
          $("#headerItemAvatar").attr( "src", pic )
          $("#patientHeader").removeClass("hidden")
          $(".patientData").removeClass("hidden")
          $(".patientData .patientDetails pre").html(JSON.stringify(ui.item.obj, null, '\t'))
          loadNotifications(ui.item.obj.id)
          $("#headerItemAvatar").tooltip({
            items: "img",
            content: '<img src="'+pic+'" />'
          })

          uid = ui.item.obj.id
          initTimelineDatepicker(uid)
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
  uid = $("#current-user-id").val()
  $.ajax '/users/'+uid+'/custom_forms.json',
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
    success: (jqXHR, textStatus, errorThrown) ->
      console.log "render notifications done"


