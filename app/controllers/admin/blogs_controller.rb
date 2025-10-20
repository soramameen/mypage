class Admin::BlogsController < ApplicationController
  before_action :set_blog, only: [ :edit, :update, :destroy ]

  def index
    @blogs = Blog.order(created_at: :desc)
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(blog_params)
    if @blog.save
      redirect_to admin_blogs_path, notice: "ブログ記事を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @blog.update(blog_params)
      redirect_to admin_blogs_path, notice: "ブログ記事を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy
    redirect_to admin_blogs_path, notice: "ブログ記事を削除しました"
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content)
  end
end
