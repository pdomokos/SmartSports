module DietsCommon

  # PATCH/PUT /diets/1
  # PATCH/PUT /diets/1.json
  def update
    @diet = Diet.find_by_id(params[:id])

    if @diet.nil?
      send_error_json(nil,  "Param 'diet' missing", 400)
      return
    end

    if !check_owner()
      send_error_json(@diet.id,  'Unauthorized', 403)
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
        send_error_json(@diet.id,  "Invalid food type", 400)
        return
      end

    end

    if @diet.update_attributes(update_hash)
      send_success_json(@diet.id, { diet_name: @diet.diet_name})
    else
      send_error_json(@diet.id,  @diet.errors.full_messages.to_sentence, 400)
    end

  end

  # DELETE /diets/1
  # DELETE /diets/1.json
  def destroy
    @diet = Diet.find(params[:id])
    if @diet.nil?
      send_error_json(nil,  "Failed to delete", 400)
      return
    end

    if !check_owner()
      send_error_json(@diet.id,  "Unauthorized", 403)
      return
    end

    if @diet.destroy

      send_success_json(@diet.id, { diet_name: @diet.diet_name})
    else
      send_error_json(@diet.id,  "Delete error", 400)
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