@diet_loaded = () ->
  console.log("diet loaded")

  $("div.appMenu button").removeClass("selected")
  $("#diet-button").addClass("selected")
  $('#diet_name').watermark('Food name, eg: Chicken soup')
  $('#diet_cal').watermark('Calories, eg: 165')
  $('#diet_fat').watermark('Total Carbs, eg: 3')
  $('#diet_prot').watermark('Protein, eg: 10')
