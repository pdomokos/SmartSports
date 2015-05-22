class LifestylesController < ApplicationController
  before_action :set_lifestyle, only: [:show, :edit, :update, :destroy]

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

  # POST /lifestyles
  # POST /lifestyles.json
  def create
    @user = User.find(params[:user_id])

    user_id = @user.id
    par = lifestyle_params
    par.merge!(:user_id => user_id)
    print par
    @lifestyle = Lifestyle.new(par)
    if not @lifestyle.start_time
      @lifestyle.start_time = DateTime.now
    end

    if @lifestyle.save
      illness_name = nil
      if @lifestyle.illness_type
        illness_name = @lifestyle.illness_type.name
      end
      send_success_json(@lifestyle.id, {group: @lifestyle.group,
                                        pain_name: @lifestyle.pain_type_name,
                                        illness_name: illness_name})
    else
      send_error_json(nil, @lifestyle.errors.full_messages.to_sentence, 400)
    end
  end

  # PATCH/PUT /lifestyles/1
  # PATCH/PUT /lifestyles/1.json
  def update
    if @lifestyle.update(lifestyle_params)
      send_success_json(@lifestyle.id, {})
    else
      send_error_json(@lifestyle.id, @lifestyle.errors.full_messages.to_sentence, 400)
    end
  end

  # DELETE /lifestyles/1
  # DELETE /lifestyles/1.json
  def destroy
    user = @lifestyle.user
    if @lifestyle.destroy
      send_success_json(@lifestyle.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@lifestyle.id, "Delete failed", 400)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lifestyle
      @lifestyle = Lifestyle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lifestyle_params
      params.require(:lifestyle).permit(:user_id, :illness_type_id, :pain_type_name, :source, :group, :name, :amount, :period_volume, :start_time, :end_time, :favourite)
    end
end
