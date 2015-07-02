class AddStressAmountToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :stress_amount, :float
  end
end
