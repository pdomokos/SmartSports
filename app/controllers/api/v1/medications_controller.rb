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

    # PATCH/PUT /users/:user_id/medications/:id
    # PATCH/PUT /users/:user_id/medications/:id
    def update
      medication = Medication.find(params[:id])
      if !check(medication)
        return
      end

      if params['medication'] && params['medication']['medication_type_id']
        med = MedicationType.find_by_id( params['medication']['medication_type_id'])
        if med.nil?
          render json: { :ok => false, :msg => "Invalid medication type id" }, status: 400
          return
        end
      end

      if medication.update(medication_params)
        render json: { :ok => true, :result => medication }
      else
        render json: { :ok => false }, status: 400
      end

    end

    # DELETE /users/:user_id/medications/:id
    # DELETE /users/:user_id/medications/:id.json
    def destroy
      medication = Medication.find(params[:id])
      if !check(medication)
        return
      end

      if medication.destroy
        render json: { :ok => true, :msg => "Deleted successfully" }
      else
        render json: { :ok => false, :msg => "Delete errror" }, :status => 400
      end
    end

    private
    def medication_params
      params.require(:medication).permit(:user_id, :source, :medication_type_id, :amount, :date, :favourite)
    end

    def check(medication)
      if medication.nil?
        render json: { :ok => false }, status: 400
        return false
      end
      if medication.user_id != current_resource_owner.id
        render json: { :ok => false }, status: 403
        return false
      end
      return true
    end
  end

end
