module SaveClickRecord
  def save_click_record (successSym, row_id, msg=nil, data=nil)
    success = false
    if successSym == :success
      success = true
    end

    method = request.method.encode('utf-8')
    if method=='POST' && !request.params['_method'].nil?
      method = request.params['_method'].upcase
    end
    clickrecord  = ClickRecord.create(user_id: current_user.id, operation_time: DateTime.now, operation: method, url: request.fullpath.encode('utf-8'), success: success, row_id: row_id, msg: msg, data: data)
    clickrecord.save!
  end
end