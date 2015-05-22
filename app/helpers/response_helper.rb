module ResponseHelper

  def send_success_json(id, data={})
    save_click_record( :success, id )
    resp = data.merge({id: id, ok: true})
    render json: resp
  end

  def send_error_json(id, msg, status)
    save_click_record( :failure, id, msg )
    render json: { msg:  msg, ok: false }, :status => status
  end

end
