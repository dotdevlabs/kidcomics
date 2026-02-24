class AddAiFieldsToDrawings < ActiveRecord::Migration[8.1]
  def change
    add_column :drawings, :analysis_status, :integer, default: 0
    add_column :drawings, :analysis_data, :jsonb, default: {}
    add_column :drawings, :is_character, :boolean, default: false
    add_column :drawings, :is_background, :boolean, default: false
    add_column :drawings, :extracted_at, :datetime

    add_index :drawings, :analysis_status
    add_index :drawings, :is_character
    add_index :drawings, :is_background
  end
end
