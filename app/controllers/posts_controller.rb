class PostsController < ApplicationController
  before_action :get_post, only: [:show, :edit, :update, :destroy, :announce]
  after_action :slack, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:search]
  load_and_authorize_resource

  def index
    @search = Post.ransack(params[:q])
    @search.sorts = 'created_at desc' if @search.sorts.empty?
    @posts = @search.result.includes(:created_by, :tags)
  end

  def search
    index
    render :index
  end

  def show
    @tag = Tag.find_by(id: tag_params[:id])
  end

  def new_comment
    show
    render :show
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.created_by = current_user

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to user_path(@post.created_by) }
    end
  end

  def announce
    return if @post.announced
    notify_all(@post.created_by, @post, 'published a new')
    @post.update(announced: true)
    render :edit
  end

  private

  def get_post
    @post = Post.friendly.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :description, :twitter_image, :featured, tags_attributes: [:id, :name, :_destroy])
  end

  def tag_params
    params.permit(:id)
  end

  def slack
    if Rails.env.production?
      Slacked.post "#{@post.created_by.name} published a post: #{@post.title} - #{post_url(@post)}", channel: 'general', username: 'Blogger Bot'
    else
      Slacked.post "#{@post.created_by.name} published a post: #{@post.title} - #{post_url(@post)}", channel: 'testing', username: 'Blogger Bot'
    end
  end
end
