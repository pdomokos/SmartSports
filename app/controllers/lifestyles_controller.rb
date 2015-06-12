class LifestylesController < ApplicationController
  before_action :set_lifestyle, only: [:show, :edit, :update, :destroy]

  include LifestylesCommon

  # GET /lifestyles
  # GET /lifestyles.json
  def index
    user_id = params[:user_id]

    source = params[:source]
    order = params[:order]
    limit = params[:limit]
    lang = params[:lang]

    if lang
      I18n.locale=lang
    end
    @is_mobile = false
    mobile = params[:mobile]
    if mobile and mobile=="true"
      @is_mobile = true
    end
    u = User.find(user_id)
    @lifestyles = u.lifestyles

    if source and source != ''
      @lifestyles = @lifestyles.where(source: source)
    end
    @lifestyles = @lifestyles.order(created_at: :desc)
    # if order and order=="desc"
    #   @lifestyles = @lifestyles.order(created_at: :desc)
    # else
    #   @lifestyles = @lifestyles.order(created_at: :asc)
    # end
    if limit and limit.to_i>0
      @lifestyles = @lifestyles.limit(limit)
    end
    @user = u

    respond_to do |format|
      format.html
      format.json {render json: @lifestyles}
      format.js
    end
  end

  # GET /lifestyles/1
  # GET /lifestyles/1.json
  def show
      set_lifestyle
  end

  # GET /lifestyles/new
  def new
    user_id = params[:user_id]
    @user = User.find(user_id)
    @lifestyle = @user.lifestyles.build
  end

  # GET /lifestyles/1/edit
  def edit
    id = params[:id]
    @lifestyle = Lifestyle.find(id)
    @user = @lifestyle.user
  end

end
