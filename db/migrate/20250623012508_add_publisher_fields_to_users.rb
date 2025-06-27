class AddPublisherFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :company_name, :string
    add_column :users, :contact_name, :string
    add_column :users, :contact_title, :string
    add_column :users, :address, :string
  end
end
