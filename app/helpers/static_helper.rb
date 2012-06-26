module StaticHelper
  def checkmark
    "<span style='color: green;'>&#x2713;</span>".html_safe
  end

  def has_omni_provider? provider
    case provider
    when :facebook
      !ENV['FACEBOOK_KEY'].blank? && !ENV['FACEBOOK_SECRET'].blank?
    end
  end
end
