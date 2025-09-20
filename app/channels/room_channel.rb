require_relative "application_cable/channel"

class RoomChannel < ApplicationCable::Channel
  # "room_channel_#{params[:room_id]}" という名前のチャンネルに接続があった時に呼ばれる
  def subscribed
    # params[:room_id] を使って、特定の部屋のストリームに接続する
    @room = Room.find(params[:room_id])
    stream_for @room
  end

  # 接続が切れた時に呼ばれる
  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end