class RenameActivityToSummary < ActiveRecord::Migration
  def change
    rename_table :activities, :summaries
  end
end
