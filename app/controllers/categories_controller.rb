class CategoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :authorize_admin!, only: [:new, :create, :edit, :update, :destroy]

  # GET /categories
  def index
    @categories = Category.all.order(:name)
  end

  # GET /categories/1
  def show
    @posts = @category.posts.includes(:user).order(published_at: :desc).page(params[:page]).per(10)
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      redirect_to @category, notice: 'Category was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
    redirect_to categories_url, notice: 'Category was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find_by!(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.require(:category).permit(:name, :description, :color)
    end
    
    # Only allow admins to manage categories
    def authorize_admin!
      unless current_user&.admin?
        flash[:alert] = "You are not authorized to perform this action."
        redirect_to categories_path
      end
    end
end
