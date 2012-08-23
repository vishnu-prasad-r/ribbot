class Mailer < ActionMailer::Base

  def password_reset user, forum
    @user = user
    customize(forum)
    mail :from => @from, :to => user.email, :subject => "Resetting Your Password"
  end
  
  def email_verification user, forum
    @user = user
    customize(forum)
    mail :from => @from, :to => user.email, :subject => "Please Verify Your Email Address"
  end
  
  def notification notification_type, user, post
    @forum = post.forum
    @user = user
    @post = post
    @to = post.user
    #Notification is blocked at mailer level
    return if @to.notification==false
    customize(@forum)
    subject = eval "deploy(@forum.#{notification_type}_notification_subject)"
    content = eval "deploy(@forum.#{notification_type}_notification_content)"
    mail :from => @from, :to => @to.email, :content_type => 'text/html',
	:subject => subject, :body => content
  end

  def reply_to_post_notification user, post
    notification :reply_to_post, user, post
  end

  def reply_to_comment_notification user, post
    notification :reply_to_comment, user, post
  end

  def up_vote_post_notification user, post
    notification :up_vote_post, user, post
  end

  private
  
  def customize forum
    if forum.nil?
      @host = Ribbot::Application.config.action_mailer.default_url_options[:host]
      @from = "Ribbot.com <contact@ribbot.com>"
    else
      @host = forum.hostname
      @from = "#{forum.name} <contact@ribbot.com>"
    end
  end

  def deploy str
    host = Ribbot::Application.config.action_mailer.default_url_options[ :host ]
    str.gsub /%[^%]*%/ do |match|
      case match
      when '%user%'
	@user.name
      when '%user_link%'
	"<a href='http://#{@forum.subdomain}.#{host}/users/#{@user.id}\'>#{@user.name}</a>"
      when '%post_link%'
	"<a href='http://#{@forum.subdomain}.#{host}/posts/#{@post.id}'>#{@post.title}</a>"
      end
    end
  end
end
