class PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authorize_post_owner!, only: %i[ edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all

    # Filter by category if specified
    if params[:category_id].present?
      @category = Category.find_by(id: params[:category_id])
      @posts = @posts.by_category(params[:category_id])
    end

    # Apply sorting
    case params[:sort]
    when 'oldest'
      @posts = @posts.order(created_at: :asc)
    else # default to newest first
      @posts = @posts.order(created_at: :desc)
    end

    # Add eager loading to improve performance
    @posts = @posts.includes(:category, :user)

    # Find featured posts for the layout sections
    @featured_posts = @posts.with_attached_cover_image.order(created_at: :desc).limit(5)
    @main_post = @featured_posts.first

    # Get posts with images for the featured sections
    @posts_with_images = @posts.joins(
      "LEFT JOIN active_storage_attachments ON " +
      "active_storage_attachments.record_id = posts.id AND " +
      "active_storage_attachments.record_type = 'Post' AND " +
      "active_storage_attachments.name = 'cover_image'"
    ).where.not(active_storage_attachments: { id: nil }).distinct

    # Get posts by category for the category sections
    @categories = Category.all.limit(5)
    @posts_by_category = {}
    @categories.each do |category|
      @posts_by_category[category.id] = @posts.where(category_id: category.id).limit(4)
    end

    # Get recent posts for the sidebar
    @recent_posts = @posts.order(created_at: :desc).limit(5)

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
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
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
        format.json { render :show, status: :ok, location: @post }
      else
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
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.require(:id))
    end

    # Check if the current user is the owner of the post
    def authorize_post_owner!
      authorize_user_for_post!(@post)
    end

    # Only allow a list of trusted parameters through.
    def post_params
      # Remove user_id from permitted params to prevent user_id spoofing
      params.require(:post).permit(:title, :body, :published_at, :tags, :cover_image, :category_id, :featured, :published, gallery_images: [])
    end
end