class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true
  
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
  
  def self.create_comment_notification(comment)
    # Don't notify if the comment author is the post author
    return if comment.user_id == comment.post.user_id
    
    # Create notification for post author
    create(
      recipient: comment.post.user,
      actor: comment.user,
      action: "commented",
      notifiable: comment
    )
  end
  
  def self.create_reply_notification(comment)
    # Don't notify if the reply author is the parent comment author
    return if comment.user_id == comment.parent.user_id
    
    # Create notification for parent comment author
    create(
      recipient: comment.parent.user,
      actor: comment.user,
      action: "replied",
      notifiable: comment
    )
  end
  
  def mark_as_read!
    update(read: true)
  end
end
