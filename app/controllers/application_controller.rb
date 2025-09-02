class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # ログイン後のリダイレクト先
  def after_sign_in_path_for(resource)
    rooms_path # => rooms#index に移動
  end
end
