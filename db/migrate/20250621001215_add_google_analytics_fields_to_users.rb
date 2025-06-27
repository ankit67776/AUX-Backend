class AddGoogleAnalyticsFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :ga_refresh_token, :text
    add_column :users, :ga_property_id, :string
  end
end
