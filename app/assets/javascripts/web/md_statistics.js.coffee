@loadStatistics = () ->
  resetMdUI()
  $("#statistics-link").addClass("menulink-selected")
  define_globals()

  loadStatisticsPatients()

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
          console.log ui.item
          $("#patientName").html( ui.item.label.trim() )
          $("input[name=patientId]").val(ui.item.obj.id)
          $("#headerItemAvatar").attr( "src", ui.item.obj.avatar_url )
          $("#patientHeader").removeClass("hidden")
          $(".patientData").removeClass("hidden")
          $("#patientHeader").tooltip({
            items: "img",
            content: '<img src="'+ui.item.obj.avatar_url+'" />'
          })

          analytics2_loaded()

        create: (event, ui) ->
#          document.body.style.cursor = 'auto'
          $(".patientName").removeAttr("disabled")
        change: (event, ui) ->
          console.log "change"
      }).focus ->
        $(this).autocomplete("search")

