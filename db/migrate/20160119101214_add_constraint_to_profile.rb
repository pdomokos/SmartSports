class AddConstraintToProfile < ActiveRecord::Migration
  def change
    remove_index :profiles, column: :user_id if index_exists?(:profiles, :user_id)
    add_index :profiles, :user_id, unique: true
  end
end
