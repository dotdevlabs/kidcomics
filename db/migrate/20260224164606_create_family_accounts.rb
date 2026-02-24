class CreateFamilyAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :family_accounts do |t|
      t.string :name
      t.references :owner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
