class CommentsController < ApplicationController
  # Ensure user is authenticated for all actions
  before_action :authenticate_user!
  before_action :ensure_warden_available
  before_action :set_post, only: [:create]
  before_action :set_comment, only: [:show, :edit, :update, :destroy, :approve, :reject, :like]
  before_action :authorize_comment!, only: [:edit, :update, :destroy]
  before_action :authorize_admin!, only: [:approve, :reject]

  # GET /comments/1
  def show
    # Used for AJAX loading of a single comment
    respond_to do |format|
      format.html { redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}") }
      format.turbo_stream
    end
  end

  # POST /posts/1/comments
  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user

    # Set parent comment if replying
    if params[:parent_id].present?
      @comment.parent = @post.comments.find_by(id: params[:parent_id])
      # Increment the parent's replies count
      @comment.parent.increment!(:replies_count) if @comment.parent
    end

    # Auto-approve all comments
    @comment.status = :approved

    respond_to do |format|
      if @comment.save
        format.html { redirect_to post_path(@post, anchor: "comment_#{@comment.id}"), notice: "Comment was successfully created." }
        format.turbo_stream
      else
        format.html {
          flash.now[:alert] = "Error creating comment: #{@comment.errors.full_messages.join(', ')}"
          render "posts/show", status: :unprocessable_entity
        }
        format.turbo_stream {
          flash.now[:alert] = "Error creating comment: #{@comment.errors.full_messages.join(', ')}"
          render turbo_stream: turbo_stream.replace("new_comment", partial: "comments/form", locals: { post: @post, comment: @comment })
        }
      end
    end
  end

  # GET /comments/1/edit
  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # PATCH/PUT /comments/1
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}"), notice: "Comment was successfully updated." }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("edit_comment_#{@comment.id}", partial: "comments/form", locals: { post: @comment.post, comment: @comment, parent: @comment.parent }) }
      end
    end
  end

  # DELETE /comments/1
  def destroy
    post = @comment.post

    # If this is a reply, decrement the parent's replies count
    if @comment.parent
      @comment.parent.decrement!(:replies_count)
    end

    @comment.destroy

    respond_to do |format|
      format.html { redirect_to post_path(post), notice: "Comment was successfully deleted." }
      format.turbo_stream
    end
  end

  # POST /comments/1/approve
  def approve
    @comment.approve!

    respond_to do |format|
      format.html { redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}"), notice: "Comment was approved." }
      format.turbo_stream
    end
  end

  # POST /comments/1/reject
  def reject
    @comment.reject!

    respond_to do |format|
      format.html { redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}"), notice: "Comment was rejected." }
      format.turbo_stream
    end
  end

  # POST /comments/1/like
  def like
    @comment.like!

    respond_to do |format|
      format.html { redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}") }
      format.turbo_stream
    end
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(
        :content,
        :parent_id,
        :content_type,
        :rich_content,
        :image,
        :video,
        :gif
      )
    end

    def authorize_comment!
      # authenticate_user! already ensures the user is signed in
      unless current_user == @comment.user || current_user.admin?
        redirect_to post_path(@comment.post), alert: "You are not authorized to perform this action."
      end
    end

    def authorize_admin!
      # authenticate_user! already ensures the user is signed in
      unless current_user.admin?
        redirect_to post_path(@comment.post), alert: "You are not authorized to perform this action."
      end
    end
end
