# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def is_valid_gigya_signature
    if !params[:signature].blank? && !params[:timestamp].blank? && !params[:UID].blank?
      gigya_signature = params[:signature]
      base_string = params[:timestamp]+"_"+params[:UID]
      key = ApplicationConfig['gigya']['secret']
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), Base64.decode64(key), base_string)
      if gigya_signature !=  Base64.encode64(digest).chomp
        return false
      end
      return true
    else
      return false
    end
  end

  # Store user information provided by gigya callback
  def store_gigya_user_info
    session[:gigya_user_info] = params
  end

  # Get user object from gigya user information
  def get_gigya_user_info
    user = User.new
    user_info = session[:gigya_user_info]
    user.email = user_info[:email]
    return user
  end
end
