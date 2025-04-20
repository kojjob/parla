module NotificationsHelper
  def notification_message(notification)
    case notification.action
    when "commented"
      "commented on your post"
    when "replied"
      "replied to your comment"
    when "liked"
      "liked your comment"
    else
      notification.action.humanize.downcase
    end
  end
  
  def unread_notifications_count
    current_user.notifications.unread.count if user_signed_in?
  end
end
