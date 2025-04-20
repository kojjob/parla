class PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_post_owner!, only: %i[edit update destroy]

  # GET /posts or /posts.json
  def index
    # Start with a base scope that includes common eager loading
    @posts = Post.includes(:category, :user)

    # Filter by category if specified
    if params[:category_id].present?
      @category = Category.find_by(id: params[:category_id])
      @posts = @posts.by_category(params[:category_id]) if @category
    end

    # Filter by tag if specified
    if params[:tag].present?
      @tag = params[:tag].strip
      # Use a more precise query to avoid partial matches
      # For example, searching for 'art' shouldn't match 'smart' or 'artificial'
      @posts = @posts.where("tags LIKE ? OR tags LIKE ? OR tags LIKE ? OR tags = ?",
                            "#{@tag},%", "%,#{@tag},%", "%,#{@tag}", @tag)
    end

    # Apply sorting (using a scope for better maintainability)
    @posts = apply_sorting(@posts)

    # Load data for different page sections efficiently
    load_page_sections

    # Pagination for the main posts list
    @pagy, @paginated_posts = pagy(@posts, items: 12)

    respond_to do |format|
      format.html
      format.turbo_stream
      format.json { render :index, status: :ok }
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
    # Add counter cache for views if needed
    # @post.increment!(:view_count) unless request.bot?

    # Load related posts for the sidebar using our smart algorithm
    @related_posts = @post.related_posts(3)
                          .includes(:category, :user)
                          .with_attached_cover_image

    # Get sort parameter (default to newest)
    @comment_sort = params[:comment_sort] || 'newest'

    # Determine sort order
    comment_order = case @comment_sort
                    when 'oldest'
                      { created_at: :asc }
                    when 'most_liked'
                      { likes_count: :desc, created_at: :desc }
                    else # 'newest'
                      { created_at: :desc }
                    end

    # Get filter parameter (default to approved, or all for admins)
    @comment_filter = params[:comment_filter] || (current_user&.admin? ? 'all' : 'approved')

    # Determine filter scope
    comments_scope = @post.comments.root_comments.includes(:user, replies: [:user])
    comments_scope = case @comment_filter
                     when 'pending'
                       comments_scope.pending if current_user&.admin?
                     when 'rejected'
                       comments_scope.rejected if current_user&.admin?
                     when 'all'
                       comments_scope if current_user&.admin?
                     else # 'approved'
                       comments_scope.approved
                     end

    # Load comments for the post with pagination and sorting
    @pagy, @comments = pagy(comments_scope.order(comment_order),
                          items: 10,
                          page_param: :comments_page)
  end

  # GET /posts/new
  def new
    @post = Post.new
    # Preload categories for the form
    @categories = Category.order(:name)
  end

  # GET /posts/1/edit
  def edit
    # Preload categories for the form
    @categories = Category.order(:name)
  end

  # GET /posts/tags
  def tags
    # This action will display all tags
    # The view will handle fetching the tags and counts
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.turbo_stream { flash.now[:notice] = "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        # Reload categories for the form
        @categories = Category.order(:name)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        # Reload categories for the form
        @categories = Category.order(:name)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
      format.turbo_stream { flash.now[:notice] = "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.includes(:category, :user)
                 .with_attached_cover_image
                 .with_attached_gallery_images
                 .with_rich_text_body
                 .find(params[:id])
    end

    # Check if the current user is the owner of the post
    def authorize_post_owner!
      authorize_user_for_post!(@post)
    end

    # Apply sorting based on params
    def apply_sorting(scope)
      case params[:sort]
      when 'oldest'
        scope.order(created_at: :asc)
      when 'title'
        scope.order(title: :asc)
      when 'popular'
        # Assuming we have a column for tracking popularity (like view_count)
        # scope.order(view_count: :desc)
        scope.order(created_at: :desc) # Fallback if no popularity metric
      else
        # Default to newest first
        scope.order(created_at: :desc)
      end
    end

    # Load data for different page sections efficiently
    def load_page_sections
      # Cache key for fragment caching
      @cache_key = "posts/#{params[:category_id]}/#{params[:sort]}/#{Post.maximum(:updated_at)&.to_i}"

      # Efficiently load data only if it's the main index (not filtered)
      # This avoids unnecessary queries for Turbo Stream requests
      unless turbo_stream_request?
        # Featured posts with cover images
        @featured_posts = Post.published
                             .featured
                             .includes(:category, :user)
                             .limit(5)

        @main_post = @featured_posts.first

        # Get top categories with their posts
        @top_categories = Category.order(posts_count: :desc).limit(5)
        @posts_by_category = {}

        # Use a single efficient query instead of multiple queries per category
        category_posts = Post.published
                            .where(category_id: @top_categories.pluck(:id))
                            .includes(:category, :user)
                            .with_attached_cover_image
                            .order(created_at: :desc)
                            .limit(@top_categories.count * 4)
                            .group_by(&:category_id)

        @top_categories.each do |category|
          @posts_by_category[category.id] = category_posts[category.id]&.first(4) || []
        end

        # Recent posts for sidebar
        @recent_posts = Post.published
                           .includes(:category, :user)
                           .order(created_at: :desc)
                           .limit(5)
      end
    end

    # Check if this is a Turbo Stream request
    def turbo_stream_request?
      request.format.turbo_stream?
    end

    # Only allow a list of trusted parameters through.
    def post_params
      # Remove user_id from permitted params to prevent user_id spoofing
      params.require(:post).permit(
        :title, :body, :published_at, :tags, :cover_image,
        :category_id, :published, gallery_images: []
      )
    end
end