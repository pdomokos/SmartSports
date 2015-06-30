class AddControllTypeToLabResults < ActiveRecord::Migration
  def change
    add_column :lab_results, :controll_type, :string
    add_column :lab_results, :remainder_date, :datetime
  end
end
