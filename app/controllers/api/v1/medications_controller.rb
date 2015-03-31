module Api::V1
  class MedicationsController < ApiController
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
      medications = user.medications.where(source: @default_source).order(date: :desc).limit(lim)
      render json: medications
    end

    def create
      user_id = params[:user_id]
      user = User.find(user_id)

      if current_resource_owner.id != user_id.to_i
        render json: { :ok => false}, status: 403
        return
      end

      medication = Medication.new(medication_params)
      medication.user_id = user.id
      if not medication.date
        medication.date = DateTime.now
      end
      if medication.save
        render json: { :ok => true, :id => medication.id }
      else
        render json: { :ok => false, :message =>  medication.errors.full_messages.to_sentence}, status: 400
      end
    end

    private
    def diet_params
      params.require(:medication).permit(:user_id, :source, :medication_type_id, :amount, :date)
    end

  end

end
