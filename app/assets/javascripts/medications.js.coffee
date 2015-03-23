@medications_loaded = () ->
  console.log("medications loaded")

  $("div.appMenu button").removeClass("selected")
  $("#medication-button").addClass("selected")

  $('#medication_dosage').watermark('Unit Dosage, eg: 2')
  $('#medication_amount').watermark('Amount Taken, eg: 1')

  $('#medication_insulin_dosage').watermark('Dosage, eg: 2')


  $('#medications_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })

  $('#medications_insulin_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })


  $("#oral_medication_name").scombobox()
  $('#oral_medication_name input').watermark('Medication Name, eg: Aspirin')

  $("#insulin_name").scombobox()
  $('#insulin_name input').watermark('Insulin Type, eg: Exubera')