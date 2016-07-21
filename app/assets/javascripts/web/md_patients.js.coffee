@mdPatientsLoaded = () ->
  console.log "mdPatientsLoaded called"

  define_globals()
  @popup_messages = JSON.parse($("#popup-messages").val())
  $("select.patientName").on("change", () ->
    uid = $(this).val()
    start = moment().subtract(2, 'months').format(moment_fmt)
    url = "users/" + uid + "/measurements.json?meas_type=blood_sugar&start="+start
    console.log "select patient: "+urlPrefix()+url
    chartElement = $("#bg-container")[0]
    chartElement.dataset.uid = uid
    chartElement.dataset.bgmin = $("select.patientName option:selected")[0].dataset.bgmin
    chartElement.dataset.bgmax = $("select.patientName option:selected")[0].dataset.bgmax
    $("#bg-container svg").html("")
    $("#timeline svg").html("")
    $("table.notificationTable tbody").html("")
    d3.json(urlPrefix() + url, draw_bg_data)
  )

  uid = $("select.patientName").val()
  start = moment().subtract(2, 'months').format(moment_fmt)
  url = "users/" + uid + "/measurements.json?meas_type=blood_sugar&start="+start
  console.log "select patient: "+urlPrefix()+url
  chartElement = $("#bg-container")[0]
  chartElement.dataset.bgmin = $("select.patientName option:selected")[0].dataset.bgmin
  chartElement.dataset.bgmax = $("select.patientName option:selected")[0].dataset.bgmax
  chartElement.dataset.uid = uid

  $(document).unbind("click.userDetails")
  $(document).on("click.userDetails", "#headerItemAvatar", (evt) ->
    if evt.altKey
      $(".patientData .patientDetails").toggleClass("hidden")
  )

  d3.json(urlPrefix() + url, draw_bg_data)

  loadNotifications(uid);

  $(document).unbind("click.addNotif")
  $(document).on("click.addNotif", "#addNotification", (evt) ->
    $("#notifDate").val(moment().format(moment_fmt))
    userid = $("input[name=patientId").val()
    $("#notificationCreateForm").attr("action", "/users/"+userid+"/notifications")
    $("#openModalAddNotification").modal('toggle')
    $("#notifTime").datetimepicker(timepicker_defaults)
    $("#notifTime").val(moment().format(moment_fmt))
#    resetNotifForm()
#    $("#notifTitle").focus()
#    getFormElement("notification_date", "#openModalAddNotification div.formContents", false)
  )
  $(document).unbind("click.sendNotifButton")
  $(document).on("click.sendNotifButton", "#openModalAddNotification .sendNotifButton", (evt) ->
    chartElement = $("#bg-container")[0]
    uid = chartElement.dataset.uid
#    $("#notificationCreateForm").attr("action", "/user/"+uid+"/notifications")
    defaultParams = paramsToHash($("#notificationCreateForm"))
    if $("#notificationCreateForm button").hasClass('collapsed')
      delete(defaultParams['notification[form_name]'])
    console.log(defaultParams)
    $.ajax "/users/"+uid+"/notifications",
      type: 'POST',
      data: defaultParams
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "Addnotif AJAX Error: "+errorThrown
      success: (data, textStatus, jqXHR) ->
        console.log "Addnotif AJAX success: "+data
        $("#openModalAddNotification").modal('toggle')
        loadNotifications(uid)
  )

  $("table.notificationTable tbody.recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    console.log "delete success"
    chartElement = $("#bg-container")[0]
    uid = chartElement.dataset.uid
    loadNotifications(uid)
  )

@old = () ->
  registerLogoutHandler()
  registerPopupHandler()
  registerLangHandler()

  resetMdUI()
  $("#patients-link").addClass("menulink-selected")

  @dateToShow = moment().format("YYYY-MM-DD")

  $("#patients-link").click (event) ->
    event.preventDefault()
    resetMdUI()
    $("#patients-link").addClass("menulink-selected")
    $("#sectionPatients").removeClass("hiddenSection")

  $("#notifDate").datetimepicker(timepicker_defaults)

  $(document).unbind("click.fillForm")
  $(document).on("click.fillForm", "#fillForm", (evt) ->

    if $("#fillForm").prop("checked")
      console.log "ch"
      $("#formDetails").removeClass("hidden")
      $("#openModalAddNotification .formContents").addClass("hidden")
      $("#elementName").val("")
      $("#openModalAddNotification div.formContents").empty()
    else
      console.log "no ch"
      $("#formDetails").addClass("hidden")
      $("#openModalAddNotification .formContents").addClass("hidden")
      $("#elementName").val("")
      $("#openModalAddNotification div.formContents").empty()
      getFormElement("notification_date", "#openModalAddNotification div.formContents", false)
  )

  $(document).unbind("click.addNotif")
  $(document).on("click.addNotif", "#addNotification", (evt) ->
    $("#notifDate").val(moment().format(moment_fmt))
    userid = $("input[name=patientId").val()
    $("#notificationCreateForm").attr("action", "/users/"+userid+"/notifications")
    location.href = "#openModalAddNotification"
    resetNotifForm()
    $("#notifTitle").focus()
    getFormElement("notification_date", "#openModalAddNotification div.formContents", false)
  )

  $("#openModalAddNotification").on("click", ".add-notification-button", (evt) ->
    evt.preventDefault()
    console.log("add notif clicked")

    window.tgt = evt.target
    addForm = evt.target.closest("form")
    action = addForm.getAttribute("action")
    params = decodeURIComponent($("#"+addForm.id).serialize())

    data = paramsToHash(params)
    fname = data['elementName']
    delete data['elementName']
    data["notification[form_name]"] = fname
    k = fname.split("_")[0]
    console.log("k = "+k)
    defaultForm = $(".formContents form")
    defaultParams = decodeURIComponent(defaultForm.serialize())
    defaultValues = generateDefaults(defaultParams)['custom_form_element[defaults]']
    defaultHashVal = paramsToHash(defaultParams)
    console.log defaultHashVal

    if defaultHashVal.hasOwnProperty("notification[date]")
      data["notification[date]"] = defaultHashVal["notification[date]"]
      data["notification[form_name]"] = "No form"

    timeKey = k+"[date]"
    console.log "checking "+timeKey
    if defaultHashVal.hasOwnProperty(timeKey)
      data["notification[date]"] = defaultHashVal[k+"[date]"]

    timeKey = k+"[start_time]"
    window.timeKey = timeKey
    window.defaultHashVal = defaultHashVal
    console.log "checking "+timeKey
    if defaultHashVal.hasOwnProperty(timeKey)
      console.log "defaulhash starttime:"
      console.log defaultHashVal[timeKey]
      data["notification[date]"] = defaultHashVal[timeKey]

    data["notification[default_data]"] = defaultValues
    $.ajax action,
      type: 'POST',
      data: data
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "Addnotif AJAX Error: "+errorThrown
      success: (data, textStatus, jqXHR) ->
        console.log "Addnotif Successful AJAX call"
        location.href = "#close"
        console.log(data)
        userid = $("input.patientId").val()
        loadNotifications(userid)
  )

  $(document).unbind("click.closeNotif")
  $(document).on("click.closeNotif", "#closeModalAddNotification", (evt) ->

    location.href = "#close"
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
    url = 'notifications/'+nid
    $.ajax urlPrefix()+url,
      type: 'PUT',
      data: {'notification[recurrence_data]': JSON.stringify(notifs)}
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "Dayselect clicked AJAX Error: "+errorThrown
      success: (data, textStatus, jqXHR) ->
        console.log "Dayselect clicked Successful AJAX call"
  )

  $(document).unbind("click.userDetails")
  $(document).on("click.userDetails", "#headerItemAvatar", (evt) ->
    if evt.altKey
      $(".patientData .patientDetails").toggleClass("hidden")
  )
  loadPatients()

@initNotification = () ->
  $("#notifSimpleDate").datetimepicker(timepicker_defaults)

@resetNotifForm = () ->
  $("#notifTitle").val("")
  $("#notificationContainer textarea").val("")
  $("#fillForm").prop("checked", false)
  $("#elementName").val("")
  $("#formDetails").addClass("hidden")

  $(".formContents").addClass("hidden")
  $(".formContents").html("")


@loadPatients = () ->
  self = this
  $.ajax urlPrefix()+'users.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load patients AJAX Error: "+errorThrown
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
              result.push({label: element.name, value: element.name, obj: element, id: element.id})
              cnt += 1
          response(result)
        select: (event, ui) ->

          uid = ui.item.id
          start = moment().subtract(2, 'months').format(moment_fmt)
          $("#analytics-container").removeClass("hidden")
          url = "users/" + uid + "/measurements.json?meas_type=blood_sugar&start="+start

          console.log "select patient: "+urlPrefix()+url
          d3.json(urlPrefix() + url, draw_bg_data)

        create: (event, ui) ->
#          document.body.style.cursor = 'auto'
          $(".patientName").removeAttr("disabled")
        change: (event, ui) ->
          console.log "change"

      }).focus ->
        $(this).autocomplete("search")


@loadNotifications = (userId) ->
  lang = $("#user-lang")[0].value
  url = 'users/' + userId + '/notifications.js?order=desc&limit=10&active=true&locale='+lang
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: "+errorThrown
    success: (jqXHR, textStatus, errorThrown) ->
      console.log "render notifications done"

@registerShowPatientData = (uid) ->
  $(document).unbind("click.showPatientData")
  $(document).on("click.showPatientData", ".md-show-table", (evt) ->
    console.log "datatable clicked"
    get_table_row = (item ) ->
      e = ""
      if item.end
        e = moment(item.end).format(moment_fmt)

      return ([moment(item.start).format(moment_fmt), e, item.evt_type, item.group, item.value1, item.value2 ])

    url = 'users/' + uid + '/analysis_data.json?tabular=true'
    $.ajax urlPrefix()+url,
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "datatable measurements AJAX Error: "+errorThrown
      success: (data, textStatus, jqXHR) ->
        tblData = $.map(data, (item) ->
          return([get_table_row(item)])
        ).filter( (v) ->
          return(v!=null)
        )
        $("#patient-data-container").html("<table id=\"patient-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>")
        $("#patient-data").dataTable({
          "data": tblData,
          "columns": [
            {"title": "start"},
            {"title": "end"},
            {"title": "type"},
            {"title": "group"}
            {"title": "value1"}
            {"title": "value2"}
          ],
          "order": [[1, "desc"]],
          "lengthMenu": [5]
        })
        location.href = "#openModal"
  )

  $(document).unbind("click.downloadPatient")
  $(document).on("click.downloadPatient", "#download-patient-data", (evt) ->
    url = '/users/' + uid + '/analysis_data.csv?tabular=true'
    location.href = url
  )

  $(document).unbind("click.closePatient")
  $(document).on("click.closePatient", "#close-patient-data", (evt) ->
    $("#health-data-container").html("")
    location.href = "#close"
  )

@draw_patient_activity_data = (jsondata) ->
  console.log "patient data"
  getters = {
    cycling: (d) ->
      return d.distance
    running: (d) ->
      return d.steps
    walking: (d) ->
      return d.steps
  }
  Object.keys(jsondata).forEach( (src)->
    dev_chart = $("#device-data-template").children().first().clone()
    container_name = src+"_data-container"
    dev_chart.attr("id", container_name)
    $("#analytics-container").append(dev_chart)

    $(dev_chart).find("div.training-type").html(capitalize(src))
    devData = {}
    keys = Object.keys(jsondata[src])
    keys.forEach( (k) ->
      if k!="sleep" && k!="transport"
        grpData = $.map(jsondata[src][k], (d) ->
          return {date: d.date, value: getters[k](d), group: k};
        )
        grpData = grpData.filter((d) -> d.value!=0)

        devData[k] = grpData
    )
    chartParams = {
      leftLabel: "distance(m)",
      rightLabel: "steps",
      leftGroups: ["cycling"]
    }
    graph = new LineChart(container_name, devData, chartParams)
    graph.draw()
  )