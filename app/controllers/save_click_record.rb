module SaveClickRecord
  def save_click_record (successSym, row_id=nil, msg=nil, data=nil, u=nil)

    source = 'web'
    if self.class.name.start_with?("Api")
      source = 'api'
    end

    success = false
    if successSym == :success
      success = true
    end

    user = current_user
    if user.nil? && (defined? current_resource_owner)
      user = current_resource_owner
    end

    if user.nil? && !u.nil?
      user = u
    end

    if !user.nil?
      method = request.method.encode('utf-8')
      if method=='POST' && !request.params['_method'].nil?
        method = request.params['_method'].upcase
      end

      clickrecord  = ClickRecord.create(user_id: user.id, operation_time: DateTime.now, operation: method, url: request.fullpath.encode('utf-8'), success: success, row_id: row_id, msg: msg, data: data, source: source)
      clickrecord.save!
    else
      puts "Click record failed: user not defined. email=#{params[:email]}"
    end

  end
end
