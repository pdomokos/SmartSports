class AddIntensityToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :intensity, :float
  end
end
