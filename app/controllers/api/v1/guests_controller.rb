class Api::V1::GuestsController < ApplicationController
  def create
    guest_id = SecureRandom.uuid
    guest_name = params[:name] || "ゲスト"
  cookies.encrypted[:guest_id] = guest_id
  cookies.encrypted[:guest_name] = guest_name
    render json: { guest_id: guest_id, guest_name: guest_name }
  end
end
