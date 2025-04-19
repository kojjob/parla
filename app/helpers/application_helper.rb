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
end