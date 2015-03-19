@medications_loaded = () ->
  console.log("medications loaded")

  $("div.appMenu button").removeClass("selected")
  $("#medication-button").addClass("selected")

  $('#medication_name').watermark('Medication Name, eg: Aspirin')
  $('#medication_dosage').watermark('Unit Dosage, eg: 2')
  $('#medication_amount').watermark('Amount Taken, eg: 1')

  $('#medication_insulin_type').watermark('Insulin Type, eg: NPH')
  $('#medication_insulin_dosage').watermark('Dosage, eg: 2')

  $('#medications_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })
  $('#medications_insulin_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })

  $("#oral_medication_name").scombobox()
  $("#insulin_name").scombobox()
