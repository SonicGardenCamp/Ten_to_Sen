class ApplicationController < ActionController::Base
    def guest_user?
      cookies.encrypted[:guest_id].present? && cookies.encrypted[:guest_name].present?
    end
    helper_method :guest_user?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
