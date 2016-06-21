class AddBloodGlucoseNoteToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :blood_glucose_note, :string
  end
end
