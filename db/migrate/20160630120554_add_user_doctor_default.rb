class AddUserDoctorDefault < ActiveRecord::Migration
  def change
    change_column :users, :doctor, :boolean, :default => false
  end
end
