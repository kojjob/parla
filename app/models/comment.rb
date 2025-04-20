class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :reports, class_name: "CommentReport", dependent: :destroy

  # Add support for rich text content
  has_rich_text :rich_content

  # Add support for attachments
  has_one_attached :image
  has_one_attached :video
  has_one_attached :gif

  # Validate that at least one type of content is present
  validate :content_presence
  validates :content, length: { maximum: 2000 }, allow_blank: true

  enum :status, { pending: 0, approved: 1, rejected: 2, spam: 3 }

  scope :approved, -> { where(status: :approved) }
  scope :pending, -> { where(status: :pending) }
  scope :root_comments, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Auto-approve comments from trusted users
  after_create :auto_approve_if_trusted

  # Create notifications for comments and replies
  after_create :create_notifications

  # Broadcast comment creation to the post's stream
  after_create_commit :broadcast_create
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy

  def approved?
    status == "approved"
  end

  def pending?
    status == "pending"
  end

  def rejected?
    status == "rejected"
  end

  def spam?
    status == "spam"
  end

  def approve!
    update(status: :approved)
  end

  def reject!
    update(status: :rejected)
  end

  def mark_as_spam!
    update(status: :spam)
  end

  def like!
    increment!(:likes_count)
  end

  def unlike!
    decrement!(:likes_count) if likes_count > 0
  end

  # Helper methods for content types
  def has_rich_content?
    rich_content.present?
  end

  def has_image?
    image.attached?
  end

  def has_video?
    video.attached?
  end

  def has_gif?
    gif.attached?
  end

  def has_attachment?
    has_image? || has_video? || has_gif?
  end

  private

  def content_presence
    # Check if any content type is present
    has_content = content.present? && content.strip.length > 0
    has_rich = has_rich_content? && rich_content.to_plain_text.strip.length > 0
    has_media = has_attachment?

    unless has_content || has_rich || has_media
      errors.add(:base, "Comment must have text, rich content, or an attachment")
    end
  end

  def auto_approve_if_trusted
    # Auto-approve comments from users who have previously approved comments
    if user.comments.approved.exists?
      approve!
    end
  end

  def create_notifications
    # Create notification for post author when someone comments on their post
    if parent_id.nil? # Root comment
      Notification.create_comment_notification(self)
    else # Reply to a comment
      Notification.create_reply_notification(self)
    end
  end

  def broadcast_create
    safe_broadcast(:append_to, "post_#{post_id}_comments", target: "post_#{post_id}_comments", partial: "comments/comment", locals: { comment: self })
  end

  def broadcast_update
    safe_broadcast(:replace_to, "post_#{post_id}_comments", target: "comment_#{id}", partial: "comments/comment", locals: { comment: self })
  end

  def broadcast_destroy
    safe_broadcast(:remove_to, "post_#{post_id}_comments", target: "comment_#{id}")
  end

  private

  # Helper method to safely handle broadcasts without Warden errors
  def safe_broadcast(method, channel, **options)
    begin
      # Call the appropriate broadcast method
      case method
      when :append_to
        broadcast_append_to(channel, **options)
      when :replace_to
        broadcast_replace_to(channel, **options)
      when :remove_to
        broadcast_remove_to(channel, **options)
      end
    rescue => e
      # Log the error but don't crash the application
      Rails.logger.error("Error in broadcast: #{e.message}")
      # Continue with normal operation
    end
  end
end
