class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.datetime :published_at
      t.string :tags
      t.string :cover_image_url

      t.timestamps
    end
  end
end
