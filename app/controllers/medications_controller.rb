class MedicationsController < ApplicationController
  def index
    user_id = params[:user_id]

    source = params[:source]
    order = params[:order]
    limit = params[:limit]

    u = User.find(user_id)
    medications = u.medications

    if source and source !=""
      medications = medications.where(source: source)
    end
    if order and order=="desc"
      medications = medications.order(date: :desc)
    else
      medications = medications.order(date: :asc)
    end
    if limit and limit.to_i>0
      medications = medications.limit(limit)
    end
    @user = u

    respond_to do |format|
      format.json {render json: medications}
    end
  end

  # POST /users/[user_id]/medications
  # POST /users/[user_id]/medications.json
  def create
    user_id = params[:user_id]
    par = medication_params
    par.merge!(:user_id => user_id)
    print par
    medication = Medication.new(par)
    medication.date = DateTime.now

    respond_to do |format|
      if medication.save
        format.json { render  json: {:status =>"OK", :result => medication} }
      else
        print medication.errors.full_messages.to_sentence+"\n"
        format.json { render json: medication.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/:user_id/medications/:id
  # PATCH/PUT /users/:user_id/medications/:id
  def update
    medication = Medication.find(params[:id])
    respond_to do |format|
      if medication.update(medication_params)
        format.json { render json: { :status => "OK", :result => medication } }
      else
        format.json { render json: medication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/:user_id/medications/:id
  # DELETE /users/:user_id/medications/:id.json
  def destroy
    medication = Medication.find(params[:id])
    user = medication.user
    medication.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def medication_params
    params.require(:medication).permit(:user_id, :source, :group, :name, :amount, :date)
  end

end
