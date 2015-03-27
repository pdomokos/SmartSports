module Api::V1
  class DietsController < ApiController
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
      diets = user.diets.where(source: @default_source).order(date: :desc).limit(lim)
      render json: diets
    end

    def create
      user_id = params[:user_id]
      user = User.find(user_id)

      if current_resource_owner.id != user_id.to_i
        render json: { :ok => false}, status: 403
        return
      end

      diet = Diet.new(diet_params)
      diet.user_id = user.id
      if not diet.date
        diet.date = DateTime.now
      end
      if diet.save
        render json: { :ok => true, :id => diet.id }
      else
        render json: { :ok => false, :message =>  diet.errors.full_messages.to_sentence}, status: 400
      end
    end

    private
    def diet_params
      params.require(:diet).permit(:source, :name, :date, :calories, :carbs, :amount, :type, :user_id)
    end

    def general_error_handler(ex)
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      render json: nil, status: 400
    end
  end

end
