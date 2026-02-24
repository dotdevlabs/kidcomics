class AddEditorFieldsToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :dedication, :text
    add_column :books, :edit_mode, :string, default: "shared", null: false
    add_column :books, :last_edited_at, :datetime

    add_index :books, :edit_mode
    add_index :books, :last_edited_at
  end
end
