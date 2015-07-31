module Api::V1
  class MedicationsController < ApiController

    include MedicationsCommon

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
      medications = user.medications.where(source: @default_source).order(created_at: :desc).limit(lim)
      render json: medications
    end
  end
end
