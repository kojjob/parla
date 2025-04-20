module ApplicationHelper
  # Only include Pagy if it's defined
  begin
    require 'pagy'
    include Pagy::Frontend
  rescue LoadError, NameError => e
    # Define a dummy pagy method to prevent errors
    def pagy_nav(pagy)
      content_tag(:div, 'Pagination unavailable', class: 'pagy-nav-placeholder')
    end
  end

  # Check if the current user can edit a post
  def can_edit_post?(post)
    current_user && (current_user.admin? || current_user == post.user)
  end

  # Custom time ago function with different formatting
  def smart_time_ago(datetime)
    return unless datetime

    time_ago = time_ago_in_words(datetime)

    if datetime > 1.week.ago
      "#{time_ago} ago"
    else
      datetime.strftime("%b %d, %Y")
    end
  end

  # Get a truncated version of HTML content
  def truncated_html(html_content, length = 150)
    strip_tags(html_content.to_s).truncate(length)
  end

  # Determine if the current page is active
  def active_class(path)
    current_page?(path) ? 'active' : ''
  end

  # Check if the current user is an admin
  def user_is_admin?
    begin
      # Use a safer check for authentication
      return false unless defined?(current_user) && current_user

      # Use Devise's current_user helper
      current_user.respond_to?(:admin?) && current_user.admin?
    rescue => e
      Rails.logger.error("Error checking admin status: #{e.message}")
      false
    end
  end

  # Check if a user can moderate comments
  def can_moderate_comment?(comment)
    begin
      # Use a safer check for authentication
      return false unless safely_signed_in?

      # If current_user is available, check permissions
      if defined?(current_user) && current_user
        return (current_user.respond_to?(:admin?) && current_user.admin?) ||
               (current_user.id == comment.user_id)
      end

      # If we can't determine permissions, default to false
      false
    rescue => e
      Rails.logger.error("Error checking comment moderation: #{e.message}")
      false
    end
  end

  # Safer version of user_signed_in? that doesn't rely on Warden
  def safely_signed_in?
    begin
      # First try to use Devise's user_signed_in? helper
      return user_signed_in? if defined?(user_signed_in?)

      # Then try to check if current_user is defined and present
      return true if defined?(current_user) && current_user.present?

      # If all else fails, check the session directly
      return true if session[:user_id].present? || (session["warden.user.user.key"].present? rescue false)

      # If that fails, return false safely
      false
    rescue => e
      # Log the error but don't crash
      Rails.logger.error("Error in safely_signed_in?: #{e.message}")
      false
    end
  end
end