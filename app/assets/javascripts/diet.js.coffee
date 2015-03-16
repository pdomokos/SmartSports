@diet_loaded = () ->
  console.log("diet loaded")

  $("div.appMenu button").removeClass("selected")
  $("#diet-button").addClass("selected")