class RemoveCustomLoginTokenFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, :login_token
    remove_column :users, :login_token, :string
    remove_column :users, :login_token_expires_at, :datetime
  end
end
