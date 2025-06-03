class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, null: false
      t.string :password_digest
      t.string :role, null: false
      t.timestamps
    end
  end
end
