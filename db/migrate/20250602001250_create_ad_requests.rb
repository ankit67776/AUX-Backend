class CreateAdRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :ad_requests do |t|
      t.references :ad, null: false, foreign_key: true
      t.references :publisher, null: false, foreign_key: { to_table: :users }
      t.string :status, default: "pending"
      t.datetime :requested_at, null: false

      t.timestamps
    end

    add_index :ad_requests, [ :ad_id, :publisher_id ], unique: true
  end
end
