class AddEncryptionColumnsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :ga_refresh_token_ciphertext, :text
    add_column :users, :ga_refresh_token_bidx, :string
    add_column :users, :ga_refresh_token_key_hash, :string
  end
end
