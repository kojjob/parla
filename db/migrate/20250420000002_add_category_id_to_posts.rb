class AddCategoryIdToPosts < ActiveRecord::Migration[8.0]
  def change
    # Check if category_id column already exists
    unless column_exists?(:posts, :category_id)
      # add_reference automatically creates an index, so we don't need to add it separately
      add_reference :posts, :category, foreign_key: true
    end
  end
end
