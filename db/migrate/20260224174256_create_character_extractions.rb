class CreateCharacterExtractions < ActiveRecord::Migration[8.1]
  def change
    create_table :character_extractions do |t|
      t.references :drawing, null: false, foreign_key: true, index: true
      t.references :story_generation, null: false, foreign_key: true, index: true
      t.string :character_name
      t.text :description
      t.jsonb :color_palette, default: {}
      t.jsonb :proportions, default: {}
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :character_extractions, :status
    add_index :character_extractions, [ :drawing_id, :story_generation_id ], unique: true, name: "index_character_extractions_on_drawing_and_story_gen"
  end
end
