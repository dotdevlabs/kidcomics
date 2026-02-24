class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.references :child_profile, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :books, [ :child_profile_id, :created_at ]
  end
end
