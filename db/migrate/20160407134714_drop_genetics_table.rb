class DropGeneticsTable < ActiveRecord::Migration
  def up
    drop_table :genetics
  end

  def down
    create_table :genetics do |t|
      t.integer  "user_id"
      t.string   "source"
      t.string   "relative"
      t.string   "diabetes"
      t.string   "antibody"
      t.text     "note"
      t.string   "group"
      t.integer  "diabetes_type_id"
      t.integer  "antibody_type_id"
      t.integer  "relative_type_id"
      t.boolean  "antibody_kind"
      t.string   "antibody_value"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "relative_type_name"
      t.string   "diabetes_type_name"
      t.string   "antibody_type_name"
    end
    add_index "genetics", ["user_id", "created_at"], name: "index_genetics_on_user_id_and_created_at"
    add_index "genetics", ["user_id", "source"], name: "index_genetics_on_user_id_and_source"
    add_index "genetics", ["user_id"], name: "index_genetics_on_user_id"
  end
end
