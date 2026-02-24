class AddAiFieldsToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :ai_generation_enabled, :boolean, default: true, null: false
    add_column :books, :story_prompt, :text
    add_column :books, :preferred_style, :string
    add_column :books, :last_generated_at, :datetime

    add_index :books, :last_generated_at
  end
end
