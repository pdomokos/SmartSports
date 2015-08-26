class ExtendActivitiesModel < ActiveRecord::Migration
  def change
    change_table :activities do |t|
      t.rename :duration, :total_duration
      t.float :soft_duration
      t.float :moderate_duration
      t.float :hard_duration
      t.boolean :sync_final
      t.rename :last_update, :synced_at
    end
  end
end
