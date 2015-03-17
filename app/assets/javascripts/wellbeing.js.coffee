@wellbeing_loaded = () ->
  uid = $("#current-user-id")[0].value

  $("div.appMenu button").removeClass("selected")
  $("#wellbeing-button").addClass("selected")

  $('#sleep_duration').watermark('Sleep Duration, eg: 7:20')
  $('#sleep_wakeup').watermark('Times Awake, eg: 2')
  $('#sleep_remark').watermark('Remark, eg: good')

