class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.text :content # Plain text content (can be null if using rich_content)
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :comments }
      t.integer :status, default: 0
      t.integer :likes_count, default: 0
      t.integer :replies_count, default: 0
      t.string :content_type, default: 'text' # Can be 'text', 'rich', 'image', 'video', 'gif'

      t.timestamps
    end

    add_index :comments, :status
    add_index :comments, :content_type
  end
end
