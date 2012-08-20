class PostsController < ApplicationController
  before_filter :require_current_forum!
  before_filter :authenticate_user!, :except => [:show, :index]
  
  def new
    @post = Post.new
  end
  
  def create
    @post = current_forum.posts.new(params[:post])
    @post.user = current_user
    @post.forum = current_forum
    if @post.save
      current_user.vote(@post, :up)
      @post.update_ranking
      redirect_to @post, :notice => "#{current_forum.post_label} created!"
    else
      render :new
    end
  end
  
  def create_comment
    @comment = params[:id].present? &&
	@post.comments.find(params[:id]) ||
	@post.comments.new(params[:comment])
    @comment.forum = current_forum
    @comment.user = current_user
    parent = !params[:comment][:parent_id].blank? &&
	@post.comments.find(params[:comment][:parent_id]) || nil
    @comment.parent = parent if parent

    respond_to do |format|
      format.html do
        if @comment.save
          redirect_to post_path(@comment.post), :notice => "Comment posted!"
        else
          redirect_to post_path(@comment.post)
        end
      end
      format.js
    end

    if parent
      @comment.notify_reply_to_comment parent
    else
      @comment.notify_reply_to_post @post
    end

  end

  def twitter_callback
    if params[:redirect_action].blank?
      twit
    else
      if params[:form_action] =~ /([^\/]+)\/comments$/
	@post = current_forum.posts.find($1)
      end
      eval params[:redirect_action]
    end

    if !params[:callback].blank?
      eval params[:callback]
    end
  end

  def twit
    auth = request.env['omniauth.auth']
    response = nil
    if auth
      access_token = auth.extra.access_token
      options = access_token.consumer.options
      @post ||= current_forum.posts.find(params[:post][:id])
      if @post
	text = (@comment && @comment.text || @post.title)[0..99] +
	    ' ' + post_url(@post)
	response = eval "access_token.#{options[:http_method]}(
	    '#{options[ :site ]}/1/statuses/update.json', { :status => text })"
      end
    end

    if params[:redirect_action].blank?
      if response
	redirect_to @post, :notice => "Story tweeted!"
      else
	redirect_to root_path, :notice => "Story hasn't twitted!"
      end
    end
  end

  def index
    if params[:search].present?
      @posts = Post.solr_search do
        keywords params[:search]
        with :forum_id, current_forum.id
        paginate :page => params[:page]
      end
    else
      cond = { :'votes.point'.gt => -5 }
      cond[:user_id] = params[:user_id] if params[:user_id]
      @posts = current_forum.posts.with_tags(params[:tags], current_forum).
	  where(cond).page(params[:page])
      
      if params[:sort].nil? 
      	@posts = @posts.desc(:created_at)
      elsif params[:sort] == 'top'
        @posts = @posts.desc('votes.point')
      elsif params[:sort] == 'latest'
        @posts = @posts.desc(:created_at)
      elsif params[:sort]=='popular'
        @posts = @posts.desc(:ranking)
      else
      	@posts = @posts.desc(:created_at)
      end            
    end
  end
  
  def show
    @post = current_forum.posts.where(:_id =>params[:id]).first
    if @post.nil?
      redirect_to root_path(:subdomain => current_forum.subdomain), :notice => "That post is no longer available."
      return
    end
    @comment = @post.comments.new
    @comments = @post.comments.asc(:lft).where(:'votes.point'.gt => -5).page(params[:page])
  end
  
  def edit
    @post = current_forum.posts.find(params[:id])
    authorize! :edit, @post
  end
  
  def update
    params[:post][:tag_ids] ||= []
    @post = current_forum.posts.find(params[:id])
    authorize! :update, @post
    if @post.update_attributes(params[:post])
      redirect_to @post, :notice => "Post updated!"
    else
      render :edit
    end
  end
  
  def destroy
    @post = current_forum.posts.find(params[:id])
    authorize! :destroy, @post
    @post.destroy
    redirect_to root_path, :notice => "Post deleted!"
  end
  
end
