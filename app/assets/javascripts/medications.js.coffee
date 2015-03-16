@medications_loaded = () ->
  console.log("medications loaded")

  $("div.appMenu button").removeClass("selected")
  $("#medication-button").addClass("selected")