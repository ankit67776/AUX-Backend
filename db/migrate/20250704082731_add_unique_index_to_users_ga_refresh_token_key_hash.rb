class AddUniqueIndexToUsersGaRefreshTokenKeyHash < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :ga_refresh_token_key_hash, unique: true
  end
end
