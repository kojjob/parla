class CommentAnalytics
  def self.most_active_commenters(limit = 5)
    User.joins(:comments)
        .select('users.*, COUNT(comments.id) as comments_count')
        .group('users.id')
        .order('comments_count DESC')
        .limit(limit)
  end
  
  def self.most_commented_posts(limit = 5)
    Post.joins(:comments)
        .select('posts.*, COUNT(comments.id) as comments_count')
        .group('posts.id')
        .order('comments_count DESC')
        .limit(limit)
  end
  
  def self.comments_by_day(days = 30)
    Comment.where('created_at >= ?', days.days.ago)
           .group("DATE(created_at)")
           .count
  end
  
  def self.comments_by_status
    Comment.group(:status).count
  end
  
  def self.average_comment_length
    Comment.where.not(content: nil)
           .average("LENGTH(content)")
           .to_f
  end
  
  def self.comments_with_attachments_percentage
    total = Comment.count
    return 0 if total == 0
    
    with_attachments = Comment.joins("LEFT JOIN active_storage_attachments ON active_storage_attachments.record_id = comments.id AND active_storage_attachments.record_type = 'Comment'")
                             .where("active_storage_attachments.id IS NOT NULL")
                             .distinct
                             .count
    
    (with_attachments.to_f / total * 100).round(2)
  end
end
