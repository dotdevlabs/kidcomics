class CreateDrawings < ActiveRecord::Migration[8.1]
  def change
    create_table :drawings do |t|
      t.references :book, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.string :tag
      t.text :caption

      t.timestamps
    end

    add_index :drawings, [ :book_id, :position ]
  end
end
