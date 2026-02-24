class CreatePageGenerations < ActiveRecord::Migration[8.1]
  def change
    create_table :page_generations do |t|
      t.references :story_generation, null: false, foreign_key: true, index: true
      t.references :book, null: false, foreign_key: true, index: true
      t.integer :page_number, null: false
      t.integer :status, null: false, default: 0
      t.text :prompt
      t.jsonb :panel_layout, default: {}
      t.jsonb :dialogue_data, default: {}
      t.text :narration_text
      t.integer :reference_drawing_ids, array: true, default: []
      t.string :generated_image_url
      t.integer :cost_cents, default: 0
      t.float :generation_time_seconds
      t.integer :retry_count, default: 0, null: false
      t.text :error_message

      t.timestamps
    end

    add_index :page_generations, :status
    add_index :page_generations, :page_number
    add_index :page_generations, [ :story_generation_id, :page_number ], unique: true
  end
end
