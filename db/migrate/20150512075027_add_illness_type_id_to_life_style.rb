class AddIllnessTypeIdToLifeStyle < ActiveRecord::Migration
  def change
    add_column :lifestyles, :illness_type_id, :integer
  end
end
