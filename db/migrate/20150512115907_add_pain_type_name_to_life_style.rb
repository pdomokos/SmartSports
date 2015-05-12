class AddPainTypeNameToLifeStyle < ActiveRecord::Migration
  def change
    add_column :lifestyles, :pain_type_name, :string
    add_column :lifestyles, :period_volume, :integer
  end
end
