module SaveClickRecord
  def save_click_record (user_id, success, data)
    u = User.find(user_id)
    method = request.method.encode('utf-8')
    if method=='POST' && !request.params['_method'].nil?
      method = request.params['_method'].upcase
    end
    clickrecord  = u.click_records.create(user_id: user_id, operation_time: DateTime.now, operation: method, url: request.fullpath.encode('utf-8'), success: success, data: data)
    clickrecord.save!
  end
end