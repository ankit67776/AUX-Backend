class CreateSchemas < ActiveRecord::Migration[8.0]
  def change
    execute 'CREATE SCHEMA IF NOT EXISTS cache'
    execute 'CREATE SCHEMA IF NOT EXISTS queue'
    execute 'CREATE SCHEMA IF NOT EXISTS cable'
  end
end
