module GuestUserHelper
  def guest_user?
    !user_signed_in?
  end

  def current_guest_id
    cookies.encrypted[:guest_id]
  end

  def current_guest_name
    cookies.encrypted[:guest_name]
  end
end
