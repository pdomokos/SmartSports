class PagesController < ApplicationController
  # skip_before_filter :require_login, only: [:index]

  def index
  end

  def health

  end

  def training


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
