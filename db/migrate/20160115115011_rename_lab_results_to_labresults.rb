class RenameLabResultsToLabresults < ActiveRecord::Migration
  def change
    rename_table :lab_results, :labresults
  end
end
