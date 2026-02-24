class AddTextFieldsToDrawings < ActiveRecord::Migration[8.1]
  def change
    add_column :drawings, :narration_text, :text
    add_column :drawings, :dialogue_text, :text
    add_column :drawings, :is_cover, :boolean, default: false, null: false

    add_index :drawings, :is_cover
  end
end
