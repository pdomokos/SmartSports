class CreateLabResults < ActiveRecord::Migration
  def change
    create_table :lab_results do |t|
      t.integer :user_id
      t.string :source
      t.string :category
      t.float :hba1c
      t.float :ldl_chol
      t.float :egfr_epi
      t.string :ketone
      t.datetime :date

      t.timestamps
    end
  end
end
