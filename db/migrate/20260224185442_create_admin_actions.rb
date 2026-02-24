class CreateAdminActions < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_actions do |t|
      t.bigint :admin_user_id, null: false
      t.string :action_type, null: false
      t.string :target_type
      t.bigint :target_id
      t.jsonb :details, default: {}
      t.string :ip_address

      t.timestamps
    end
    add_index :admin_actions, :admin_user_id
    add_index :admin_actions, :action_type
    add_index :admin_actions, [ :target_type, :target_id ]
    add_index :admin_actions, :created_at
    add_foreign_key :admin_actions, :users, column: :admin_user_id
  end
end
