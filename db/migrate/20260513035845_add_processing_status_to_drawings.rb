class AddProcessingStatusToDrawings < ActiveRecord::Migration[8.1]
  def change
    add_column :drawings, :processing_status, :integer, default: 0
    add_index :drawings, :processing_status
  end
end
