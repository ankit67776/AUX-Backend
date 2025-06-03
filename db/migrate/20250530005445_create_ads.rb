class CreateAds < ActiveRecord::Migration[8.0]
  def change
    create_table :ads do |t|
      t.string :title
      t.text :description
      t.string :ad_format
      t.string :ad_size
      t.string :custom_width
      t.string :custom_height
      t.text :ad_txt_content
      t.text :header_code
      t.boolean :header_bidding
      t.text :header_bidding_partners
      t.boolean :fallback_image
      t.date :start_date
      t.date :end_date
      t.decimal :budget
      t.string :bid_strategy
      t.text :target_audience
      t.text :target_locations
      t.string :target_devices
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
