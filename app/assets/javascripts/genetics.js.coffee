@genetics_loaded = () ->
  console.log("genetics loaded")

  $("div.appMenu button").removeClass("selected")
  $("#genetics-button").addClass("selected")