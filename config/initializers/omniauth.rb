Rails.application.config.middleware.use OmniAuth::Builder do
  if !ENV['FACEBOOK_KEY'].blank? && !ENV['FACEBOOK_SECRET'].blank?
    provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
	:scope => 'email,user_education_history,user_website'
  end

  if !ENV['TWITTER_KEY'].blank? && !ENV['TWITTER_SECRET'].blank?
    provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  end
end

OmniAuth.config.logger = Rails.logger
