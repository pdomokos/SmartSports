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
    { label: "blood_glucose", value: "blood_glucose" },
    { label: "blood_pressure", value: "blood_pressure" }
  ]
  $('input[name=attributeName]').autocomplete({
    minLength: 0,
    source: measList,
    change: (event, ui) ->
      measSelected = ui['item']
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
          $(".patientId").val(ui.item.id)

          $(".patientSelectDone").removeClass("grayed")
          $(".attrSelect").removeClass("grayed")
          $(".attrSelect").removeClass("grayed")
          $(".attrSelect").removeAttr("disabled")
#          $("#patientName").html( ui.item.label.trim() )

#          $("input[name=patientId]").val(ui.item.obj.id)
#          $("#headerItemAvatar").attr( "src", ui.item.obj.avatar_url )
#          $("#patientHeader").removeClass("hidden")
#          $(".patientData").removeClass("hidden")
#          $("#patientHeader").tooltip({
#            items: "img",
#            content: '<img src="'+ui.item.obj.avatar_url+'" />'
#          })
          initStatistics()
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


@loadBgData = (uid) ->
  d3.json("/users/"+uid+"/measurements.json?meas_type=blood_sugar", stat_bg_data_received)

  $(document).on("click", "#closeModalStat", (evt) ->
    location.href = "#close"
  )


