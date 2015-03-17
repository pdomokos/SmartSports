@medications_loaded = () ->
  console.log("medications loaded")

  $("div.appMenu button").removeClass("selected")
  $("#medication-button").addClass("selected")
  $('#medication_name').watermark('Medication Name, eg: insulin')
  $('#medication_dosage').watermark('Unit Dosage, eg: 500')
  $('#medication_amount').watermark('Amount Taken, eg: 1')
