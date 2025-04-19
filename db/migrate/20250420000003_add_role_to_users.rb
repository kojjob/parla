class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def up
    # For PostgreSQL, we need a different approach due to type conversion issues
    if column_exists?(:users, :role)
      # First, rename the existing column
      rename_column :users, :role, :role_str

      # Then add a new integer column
      add_column :users, :role, :integer, default: 0, null: false

      # Update the new column based on the old one
      execute <<-SQL
        UPDATE users
        SET role = CASE
          WHEN role_str = 'admin' THEN 2
          WHEN role_str = 'editor' THEN 1
          ELSE 0
        END
      SQL

      # Remove the old column
      remove_column :users, :role_str

      # Add an index on the new column
      add_index :users, :role
    else
      # If the column doesn't exist, just add it
      add_column :users, :role, :integer, default: 0, null: false
      add_index :users, :role
    end
  end

  def down
    # If we need to rollback, convert back to string
    if column_exists?(:users, :role)
      # First, rename the existing column
      rename_column :users, :role, :role_int

      # Then add a new string column
      add_column :users, :role, :string

      # Update the new column based on the old one
      execute <<-SQL
        UPDATE users
        SET role = CASE
          WHEN role_int = 2 THEN 'admin'
          WHEN role_int = 1 THEN 'editor'
          ELSE 'user'
        END
      SQL

      # Remove the old column
      remove_column :users, :role_int
    end
  end
end
