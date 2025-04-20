class AddCommentsCountToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :comments_count, :integer, default: 0
    
    # Update existing posts with the correct count
    reversible do |dir|
      dir.up do
        # This will be executed when migrating up
        execute <<-SQL
          UPDATE posts
          SET comments_count = (
            SELECT COUNT(*)
            FROM comments
            WHERE comments.post_id = posts.id
          )
        SQL
      end
    end
  end
end
