class AddBookshelfFieldsToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :favorited, :boolean, default: false, null: false
    add_column :books, :view_count, :integer, default: 0, null: false

    add_index :books, :favorited
    add_index :books, :view_count
    add_index :books, :status
  end
end
