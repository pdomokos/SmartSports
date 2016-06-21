class CreateMeasurementType < ActiveRecord::Migration
  def change
    create_table :measurement_types do |t|
      t.string :name
      t.string :category
      t.string :lang
    end
  end
end
