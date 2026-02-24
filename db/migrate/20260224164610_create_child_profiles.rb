class CreateChildProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :child_profiles do |t|
      t.references :family_account, null: false, foreign_key: true
      t.string :name
      t.integer :age

      t.timestamps
    end
  end
end
