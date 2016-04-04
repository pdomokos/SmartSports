module Api::V1
  class MedicationsController < ApiController

    include MedicationsCommon

    def index
      user_id = params[:user_id]
      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end
      user = User.find(user_id)
      @medications = user.medications
      if params[:source]
        @medications = @medications.where(source: params[:source])
      end
      @medications = @medications.order(date: :desc)
      if params[:limit]
        @medications = @medications.limit(params[:limit].to_i)
      end

      render :template => 'medications/index.json'
    end
  end
end
