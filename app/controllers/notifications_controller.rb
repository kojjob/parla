class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:show, :mark_as_read]

  def index
    @pagy, @notifications = pagy(current_user.notifications.order(created_at: :desc), items: 20)
  end

  def show
    @notification.mark_as_read!

    # Redirect to the appropriate resource based on notification type
    redirect_to notification_redirect_path
  end

  def mark_as_read
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.turbo_stream
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true)

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.turbo_stream
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  def notification_redirect_path
    case @notification.notifiable_type
    when "Comment"
      comment = @notification.notifiable
      post_path(comment.post, anchor: "comment_#{comment.id}")
    else
      root_path
    end
  end
end
