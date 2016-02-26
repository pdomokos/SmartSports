class CreateLifestyleTypes < ActiveRecord::Migration
  def change
    create_table :lifestyle_types do |t|
        t.string :name
        t.string :category
    end
  end
end
