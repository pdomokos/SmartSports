class InputPanel
  constructor: (@name, @model_name) ->
    @validate_cb = null
    @validate_save_cb = null
    @preproc_cb = null
    if @model_name != null
      if @model_name == 'activity'
        @model_name_plural = "activities"
      else
        @model_name_plural = @model_name+"s"

  start: () ->
    console.log @name+" input started"
    self = this

    $("#"+@name+"-form i.add-icon").click (event) ->
      self.add_data_handler(event)

    $("#"+@name+"-table").on("click", "div.edit-control",
      (event) ->
        self.edit_data_handler(event)
      )
    $("#"+@name+"-table").on("click", "div.cancel-control",
      (event) ->
        self.cancel_edit_handler(event)
      )
    $("#"+@name+"-table").on("click", "div.delete-control",
      (event) ->
        self.delete_data_handler(event)
      )
    $("#"+@name+"-table").on("click", "div.save-control",
      (event) ->
        self.save_data_handler(event)
      )
    @fill_recent_meas()

  add_data_handler: (event) ->
    self = this
    event.preventDefault()
    target = event.target

    values = @create_values(@name+"-form")
    values[@model_name+"[source]"] = $("#form-source")[0].value

    if self.validate_cb
      if not self.validate_cb(target, values)
        return


    current_user = $("#form-user-id")[0].value

    console.log values
    $.ajax '/users/' + current_user + '/'+self.model_name+"s",
      type: 'POST',
      data: values,
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "CREATE measurement AJAX Error: #{textStatus}"
        alert("Failed to add measurement.")
      success: (data, textStatus, jqXHR) ->
        console.log "CREATE measurement  Successful AJAX call"
        console.log data
        console.log data.status
        if data.status == "OK"
          $("#"+self.name+"-form input").val("")
          self.fill_recent_meas()
        else
          alert("Failed to add measurement.")

  edit_data_handler: (event) ->
    event.preventDefault()
    rowid = event.target.parentNode.parentNode.id
    $("#" + rowid + " span.list-edit").removeClass("hidden")
    $("#" + rowid + " span.list-attr").addClass("hidden")
    $("#" + rowid + " span.list-ctrl.show").addClass("hidden")
    $("#" + rowid + " span.list-ctrl.edit").removeClass("hidden")

  cancel_edit_handler: (event) ->
    event.preventDefault()
    rowid = event.target.parentNode.parentNode.id
    $("#" + rowid + " span.list-edit").addClass("hidden")
    $("#" + rowid + " span.list-attr").removeClass("hidden")
    $("#" + rowid + " span.list-ctrl.show").removeClass("hidden")
    $("#" + rowid + " span.list-ctrl.edit").addClass("hidden")


  delete_data_handler: (event) ->
    self = this
    event.preventDefault()
    id = event.target.parentNode.parentNode.id.split("-")[-1..]
    current_user = $("#form-user-id")[0].value
    $.ajax '/users/' + current_user + '/'+@model_name_plural+'/' + id,
      type: 'DELETE',
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "Destroy measurement AJAX Error: #{textStatus}"
        alert("Failed to delete measurement")
      success: (data, textStatus, jqXHR) ->
        console.log "Destroy measurement  Successful AJAX call"
        self.fill_recent_meas()

  save_data_handler: (event) ->
    self = this
    event.preventDefault()
    parent_id = event.target.parentNode.parentNode.id
    meas_id = parent_id.split("-")[-1..]
    console.log "save pressed " + parent_id + " " + meas_id
    values = @create_values(parent_id)
    if @validate_save_cb
      if not @validate_save_cb(values)
        return

    values_processed = Object()
    for k in Object.keys(values)
      values_processed[@model_name+'['+k+']'] = values[k]

    current_user = $("#form-user-id")[0].value

    $.ajax '/users/' + current_user + '/'+@model_name_plural+'/' + meas_id,
      type: 'PUT',
      data: values_processed,
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "UPDATE measurement AJAX Error: #{textStatus}"
        alert("Failed to update measurement")

      success: (data, textStatus, jqXHR) ->
        console.log "UPDATE measurement  Successful AJAX call"
        console.log data
        if data.status == "OK"
          $("#" + parent_id + " span.list-edit").addClass("hidden")
          $("#" + parent_id + " span.list-attr").removeClass("hidden")
          $("#" + parent_id + " span.list-ctrl.show").removeClass("hidden")
          $("#" + parent_id + " span.list-ctrl.edit").addClass("hidden")
          self.fill_recent_meas()
        else
          alert("Failed to update measurement")

  fill_recent_meas: () ->
    self = this
    current_user = $("#form-user-id")[0].value
    $("#"+@name+"-table .row-item").remove()
    $.ajax '/users/' + current_user + '/'+@model_name_plural+'.json?source=smartsport&order=desc&limit=4',
      type: 'GET',
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "list measurement AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "list measurement  Successful AJAX call"
        console.log data

        params = []
        for cl in $("#"+self.name+" .row-template .list-attr")
          for class_name in cl.classList
            if class_name.startsWith("attr-")
              params.push(class_name.substr(5))

        for d in data
          new_row = $("#"+self.name+" div.row-template").children().first().clone()
          new_id = "data-row-" + d.id
          new_row.attr('id', new_id)
          new_row.insertAfter($("#"+self.name+"-table > div:last-of-type"))

          if self.preproc_cb
            self.preproc_cb(d)

          console.log d
          for p in params

            console.log "   "+p+" ->"+d[p]
            $("#" + new_id + " span.attr-"+p).html(d[p])
            $("#" + new_id + " input.attr-"+p).val(d[p])


  # Helpers

  create_values: (parent_id) ->
    result = Object()
    for e in $("#"+parent_id+" input")
      name = e.name
      value = e.value
      result[name] = value
    return result

window.InputPanel = InputPanel