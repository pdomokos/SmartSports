class AddIntervalsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :morning_start, :integer, :default => 6
    add_column :profiles, :noon_start, :integer, :default => 12
    add_column :profiles, :evening_start, :integer, :default => 18
    add_column :profiles, :night_start, :integer, :default => 22
  end
end
