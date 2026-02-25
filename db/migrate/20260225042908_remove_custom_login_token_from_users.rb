class RemoveCustomLoginTokenFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, :login_token, if_exists: true
    remove_column :users, :login_token, :string, if_exists: true
    remove_column :users, :login_token_expires_at, :datetime, if_exists: true
  end
end
