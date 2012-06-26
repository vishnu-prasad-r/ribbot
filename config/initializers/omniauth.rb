Rails.application.config.middleware.use OmniAuth::Builder do
  if !ENV['FACEBOOK_KEY'].blank? && !ENV['FACEBOOK_SECRET'].blank?
    provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
	:scope => 'email,user_website'
  end
end

OmniAuth.config.logger = Rails.logger
