module DietsCommon

  # PATCH/PUT /diets/1
  # PATCH/PUT /diets/1.json
  def update
    @diet = Diet.find_by_id(params[:id])

    if @diet.nil?
      render json: { :ok => false, :msg => "Param 'diet' missing"}, status: 400
      return
    end

    if !check_owner()
      render json: { :ok => false}, status: 403
      return
    end

    fav = true
    if params['diet'].nil? || params['diet']['favourite'].nil? || params['diet']['favourite']=='false'
      fav = false
    end
    update_hash = {:favourite => fav}
    if params['diet'] && params['diet']['amount']
      update_hash[:amount] = params['diet']['amount'].to_f
    end
    if params['diet'] && params['diet']['food_type_id']
      ft = FoodType.find_by_id(params['diet']['food_type_id'].to_i)
      if !ft.nil?
        amount = @diet.amount
        if !update_hash[:amount].nil?
          amount = update_hash[:amount].to_f
        end
        update_hash[:food_type_id] = ft.id
        update_hash[:calories] = amount*ft.kcal
        update_hash[:carbs] = amount*ft.carb
        update_hash[:fat] = amount*ft.fat
        update_hash[:prot] = amount*ft.prot
      else
        save_click_record(current_user.id, false, "Invalid food_type_id")
        render json: { :ok => false, :msg => "Invalid food_type_id"}, status: 400
        return
      end

    end
    respond_to do |format|
      if @diet.update_attributes(update_hash)
        save_click_record(current_user.id, true, nil)
        format.json { render json: { :ok => true, :msg => "Updated successfully" } }
      else
        save_click_record(current_user.id, false, "Update error")
        format.json { render json: { :ok => false, :msg => "Update errror" }, :status => 400 }
      end
    end

  end

  # DELETE /diets/1
  # DELETE /diets/1.json
  def destroy
    @diet = Diet.find(params[:id])
    if @diet.nil?
      render json: { :ok => false}, status: 400
      return
    end

    if !check_owner()
      render json: { :ok => false}, status: 403
      return
    end

    respond_to do |format|
      if @diet.destroy
        save_click_record(current_user.id, true, nil)
        format.json { render json: { :ok => true, :msg => "Deleted successfully" } }
      else
        save_click_record(current_user.id, false, "Delete error")
        format.json { render json: { :ok => false, :msg => "Delete errror" }, :status => 400 }
      end
    end
  end

  def check_owner()
    puts "try"
    if self.try(:current_user)
      puts "current_user defined"
    else
      puts "current_user NOT defined"
    end
    if self.try(:current_resource_owner)
      puts "current_resource_owner defined"
    else
      puts "current_resource_owner NOT defined"
    end

    if self.try(:current_user).try(:id) == @diet.user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @diet.user_id
      return true
    end
    return false
  end
end