module Api::V1
  class LifestylesController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:index, :create]
    respond_to :json

    def index
      lim = 10
      if params[:limit]
        lim = params[:limit].to_i
      end
      user_id = params[:user_id]

      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      lifestyles = user.lifestyles.where(source: @default_source).order(start_time: :desc).limit(lim)
      render json: lifestyles
    end

    def create
      user_id = params[:user_id]
      user = User.find(user_id)

      if current_resource_owner.id != user_id.to_i
        render json: { :ok => false}, status: 403
        return
      end

      lifestyle =Lifestyle.new(lifestyle_params)
      lifestyle.user_id = user.id
      if not lifestyle.start_time
        lifestyle.start_time = DateTime.now
      end
      if lifestyle.save
        render json: { :ok => true, :id => lifestyle.id }
      else
        render json: { :ok => false, :message =>  lifestyle.errors.full_messages.to_sentence}, status: 400
      end
    end

    private
    def lifestyle_params
      params.require(:lifestyle).permit(:source, :name, :group, :amount, :start_time, :end_time, :user_id)
    end

  end

end
