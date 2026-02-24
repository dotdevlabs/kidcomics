class AddModerationStatusToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :moderation_status, :integer, default: 0, null: false
    add_index :books, :moderation_status
  end
end
