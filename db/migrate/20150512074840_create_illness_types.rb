class CreateIllnessTypes < ActiveRecord::Migration
  def change
    create_table :illness_types do |t|
      t.string :name
    end
  end
end
