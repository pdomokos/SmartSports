@genetics_loaded = () ->
  console.log("genetics loaded")

  $("div.appMenu button").removeClass("selected")
  $("#genetics-button").addClass("selected")

  $('#gen_hist_relative').watermark('Relative, eg: father')
  $('#gen_hist_disease').watermark('Diagnosed disease, eg: diabetes type 1')
  $('#gen_hist_note').watermark('Note, eg: slight obesity')

