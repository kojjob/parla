class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    # Only create the table if it doesn't exist
    unless table_exists?(:categories)
      create_table :categories do |t|
        t.string :name, null: false
        t.string :slug, null: false
        t.text :description
        t.string :color, default: "#3B82F6" # Default blue color
        t.integer :posts_count, default: 0   # Counter cache

        t.timestamps
      end

      add_index :categories, :name, unique: true
      add_index :categories, :slug, unique: true
    end
  end
end
