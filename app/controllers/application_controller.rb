require 'ostruct'

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Only include Pagy if it's defined
  begin
    require 'pagy'
    include Pagy::Backend
  rescue LoadError, NameError => e
    # Define a dummy pagy method to prevent errors
    def pagy(collection, options = {})
      return [OpenStruct.new(prev: nil, next: nil, items: 20, pages: 1, page: 1), collection]
    end
  end


  # Devise authentication
  before_action :authenticate_user!

  protected

  # Helper method to authorize a user for post actions
  def authorize_user_for_post!(post)
    unless current_user && (current_user.admin? || current_user == post.user)
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to posts_path
    end
  end
end
