@loadStatistics = () ->
  resetMdUI()
  console.log "md_statistics"
  $("#statistics-link").addClass("menulink-selected")
  define_globals()

  initStatUI()
  loadStatisticsPatients()

  $(document).on("click", "#add-analysis", (evt) ->
    if self.currdata
      a = new Date(self.currextent[0])
      b = new Date(self.currextent[1])

      diff = moment(a).diff(moment(b))
      mid = moment(moment(a)-diff/2).format("YYYY-MM-DD")

      $("#bg_from").html(fmt(a))
      $("#bg_to").html(fmt(b))

      $("#start_a").datetimepicker({value: moment(a).format("YYYY-MM-DD")})
      $("#end_a").datetimepicker({value: mid})
      $("#start_b").datetimepicker({value: mid})
      $("#end_b").datetimepicker({value: moment(b).format("YYYY-MM-DD")})

      self.update_elements()

      location.href = "#openModalStat"
  )

  $(document).on("click", "#analysis-params", (evt) ->
    console.log("add analysis clicked")
    if !self.bg_trend_chart
      return

    data = self.bg_trend_chart.data

    rangeA = [$("#start_a").val(), $("#end_a").val()]
    rangeB = [$("#start_b").val(), $("#end_b").val()]
    self.bg_trend_chart.add_highlight(rangeA[0], rangeA[1], "selA")
    self.bg_trend_chart.add_highlight(rangeB[0], rangeB[1], "selB")

    location.href = "#close"

    eid = "stat-"+self.statnum+"-container"
    self.statnum = self.statnum+1
    h = $("#stat-template").clone()
    window.h = h
    h.attr('id', eid)
    h.prependTo("#allstats")

    $("#"+eid+" div.title").html($("#title").val())
    draw_boxplot(eid, data, rangeA, rangeB)
    draw_parallelplot(eid, data, rangeA, rangeB)
  )

@initStatUI = () ->
  measList = [
    { label: "blood_glucose", value: "blood_sugar" },
    { label: "systolic", value: "systolic" },
    { label: "diastolic", value: "diastolic" },
    { label: "pulse", value: "pulse" }
  ]
  $('input[name=attributeName]').autocomplete({
    minLength: 0,
    source: measList,
    change: (event, ui) ->
      measSelected = ui['item']
    select: (event, ui) ->

      measureSelected(ui['item'].value)
  }).focus ->
    $(this).autocomplete("search")

  $('input[name=startA]').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.update_elements()
    todayButton: true
  })
  $('input[name=endA]').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.update_elements()
    todayButton: true
  })
  $('input[name=startB]').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.update_elements()
    todayButton: true
  })
  $('input[name=endB]').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.update_elements()
    todayButton: true
  })

@loadStatisticsPatients = () ->
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
          patientSelected(ui.item.obj.id)

#          $("#patientName").html( ui.item.label.trim() )

#          $("input[name=patientId]").val(ui.item.obj.id)
#          $("#headerItemAvatar").attr( "src", ui.item.obj.avatar_url )
#          $("#patientHeader").removeClass("hidden")
#          $(".patientData").removeClass("hidden")
#          $("#patientHeader").tooltip({
#            items: "img",
#            content: '<img src="'+ui.item.obj.avatar_url+'" />'
#          })
#          initStatistics()
#          uid = ui.item.obj.id
#          console.log "loadBgData for "+uid
#          loadBgData(uid)


        create: (event, ui) ->
#          document.body.style.cursor = 'auto'
          $(".patientName").removeAttr("disabled")
        change: (event, ui) ->
          console.log "change"
      }).focus ->
        $(this).autocomplete("search")

@patientSelected = (uid) ->
  console.log "patientSelected "+uid
  $(".patientId").val(uid)
  $(".patientSelectDone").removeClass("grayed")
  $(".attrSelect").removeClass("grayed")
  $(".attrSelect").removeClass("grayed")
  $(".attrSelect").removeAttr("disabled")

@measureSelected = (measure) ->
  console.log measure
  uid = $(".patientId").val()
  $(".measureName").val(measure)
  initStatistics()
  meas = "blood_pressure"
  if measure == "blood_sugar"
    meas = "blood_sugar"
  loadBgData(uid, meas)

@loadBgData = (uid, measure) ->
  d3.json("/users/"+uid+"/measurements.json?meas_type="+measure, stat_bg_data_received)

@getMeasGroup = (d) ->
  ret = "unspecified"
  if moment(d).hour() >= 5 && moment(d).hour() <= 10
    ret = "breakfast"
  else if moment(d).hour() >= 10 && moment(d).hour() <= 14
    ret = "lunch"
  else if moment(d).hour() >= 18 && moment(d).hour() <= 22
    ret = "dinner"
  return ret
@getBgGroup = (d) ->
  return d.blood_sugar_time
@mapDia = (d) ->
  return( {date: d.date, value: d.diastolicbp, group: getMeasGroup(d.date)})
@mapSys = (d) ->
  return( {date: d.date, value: d.systolicbp, group: getMeasGroup(d.date)})
@mapPulse = (d) ->
  return( {date: d.date, value: d.pulse, group: getMeasGroup(d.date)})
@mapBG = (d) ->
  return( {date: d.date, value: d.blood_sugar, group: getMeasGroup(d.date)})
@stat_bg_data_received = (jsondata) ->
  console.log "stat bg_data_received, size="+jsondata.length
  console.log jsondata[0]
  @currdata = jsondata
  if jsondata && jsondata.length>0
    $("section.sectionPatients").removeClass("hidden")
    meas = $(".measureName").val()
    $(".bg-chart-svg").html("")
    if meas=="blood_sugar"
#      @bg_trend_chart = new BGChart("bg", jsondata, 1.0/8)
#      @bg_trend_chart.draw()
      bg_trend_chart = new LineChart("bg", jsondata.map(  mapBG ), "BG (mmol/L)");
      bg_trend_chart.draw()
    else if meas=="systolic"
      bp_trend_chart = new LineChart("bg", jsondata.map(  mapSys ), "SYS (mmHg)");
      bp_trend_chart.draw()
    else if meas=="diastolic"
      bp_trend_chart = new LineChart("bg", jsondata.map(  mapDia ), "DIA (mmHg)");
      bp_trend_chart.draw()
    else if meas=="pulse"
      bp_trend_chart = new LineChart("bg", jsondata.map(  mapPulse ), "Pulse (1/min)");
      bp_trend_chart.draw()