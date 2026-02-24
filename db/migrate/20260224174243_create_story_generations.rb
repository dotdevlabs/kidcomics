class CreateStoryGenerations < ActiveRecord::Migration[8.1]
  def change
    create_table :story_generations do |t|
      t.references :book, null: false, foreign_key: true, index: true
      t.integer :status, null: false, default: 0
      t.text :prompt_template
      t.text :story_outline
      t.jsonb :character_data, default: {}
      t.jsonb :style_data, default: {}
      t.jsonb :generation_metadata, default: {}
      t.integer :cost_cents, default: 0
      t.text :error_message
      t.datetime :completed_at

      t.timestamps
    end

    add_index :story_generations, :status
    add_index :story_generations, :completed_at
  end
end
