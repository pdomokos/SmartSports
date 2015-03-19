@diet_loaded = () ->
  console.log("diet loaded2")

  $("div.appMenu button").removeClass("selected")
  $("#diet-button").addClass("selected")

  $('#diet_name').watermark('Food name, eg: Chicken soup')
  $('#diet_cal').watermark('Calories, eg: 165')
  $('#diet_fat').watermark('Total Carbs, eg: 3')

  $('#diet_drink_amount').watermark('Amount: 1.5')
  $('#diet_drink_calories').watermark('Calories, eg: 165')
  $('#diet_drink_carbs').watermark('Total Carbs, eg: 3')

  $('#diet_smoking_amount').watermark('Amount, eg: 3')


  $('#diet_food_datepicker').datetimepicker({
      "format": "YYYY-MM-DD HH:mm"
    })
  $('#diet_drink_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })
  $('#diet_smoking_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })

  $("#testbtn").click (evt) ->
    $('#diet_food_datepicker').data("DateTimePicker").toggle()

