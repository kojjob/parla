class CommentReport < ApplicationRecord
  belongs_to :comment
  belongs_to :user
  
  validates :reason, presence: true
  validates :comment_id, uniqueness: { scope: :user_id, message: "has already been reported by you" }
  
  enum :status, { pending: 0, reviewed: 1, actioned: 2, dismissed: 3 }
  
  REPORT_REASONS = [
    "spam",
    "harassment",
    "hate_speech",
    "misinformation",
    "inappropriate_content",
    "other"
  ]
  
  validates :reason, inclusion: { in: REPORT_REASONS }
  
  after_create :notify_admins
  
  private
  
  def notify_admins
    # In a real application, you would send notifications to admins
    # For now, we'll just mark the comment as potentially problematic
    if comment.reports.count >= 3 && comment.approved?
      comment.update(status: :pending)
    end
  end
end
