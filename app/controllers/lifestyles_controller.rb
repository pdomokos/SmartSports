class LifestylesController < ApplicationController
  before_action :set_lifestyle, only: [:show, :edit, :update, :destroy]
  before_action :check_valid_user, only: [:index]

  include LifestylesCommon

  def index
    user_id = params[:user_id]
    user = User.find_by_id(user_id)
    lang = params[:lang]
    table = params[:table]

    @lifestyles = user.lifestyles
    if params[:source]
      @lifestyles = @lifestyles.where(source: params[:source])
    end
    @lifestyles = @lifestyles.order("start_time desc, id desc")
    if params[:limit]
      @lifestyles = @lifestyles.limit( params[:limit].to_i )
    end

    if table
      @lifestyles = get_table_data(@lifestyles, lang)
    end
    respond_to do |format|
      format.html
      format.json { render json: @lifestyles }
      format.csv { send_data to_csv(@lifestyles,{}, lang).encode("iso-8859-2"), :type => 'text/csv; charset=iso-8859-2; header=present' }
      format.js
    end
  end

  # GET /lifestyles/1
  # GET /lifestyles/1.json
  def show
  end

end
