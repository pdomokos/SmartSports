class PagesController < ApplicationController
  # skip_before_filter :require_login, only: [:index]

  def index
  end

  def health

  end

  def training
    if current_user.connection_id != nil
      sess = { "access_token" => Connection.find(current_user.connection_id).data}
      @moves = Moves::Client.new(sess["access_token"])
    else
      auth = request.env['omniauth.auth']
      conn = Connection.new
      conn.name = 'moves'
      #TODO strore full auth_hash string in connection.data, not only moves access token
      #conn.data = auth.inspect
      conn.data = auth['credentials']['token']
      conn.save!
      current_user.connection_id = conn.id
      current_user.save(validate: false)

      sess = { "access_token" => auth['credentials']['token']}
      @moves = Moves::Client.new(sess["access_token"])
    end
    respond_to do |format|
      format.html
      format.json
    end

    # render :text => "<pre>"+request.env["omniauth.auth"].to_yaml+"</pre>"
  end

  def destroy
    #TODO delete current_user connection where name = moves
    redirect_to pages_index_path
  end

  def lifestyle

  end
  def genetics

  end
  def settings

  end
end
