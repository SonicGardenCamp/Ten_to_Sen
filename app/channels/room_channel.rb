require_relative "application_cable/channel"

class RoomChannel < ApplicationCable::Channel
  # "room_channel_#{params[:room_id]}" という名前のチャンネルに接続があった時に呼ばれる
  def subscribed
    # ▼▼▼ 修正点 ▼▼▼
    # find_by を使ってルームを検索し、見つからなければ接続を拒否する
    @room = Room.find_by(id: params[:room_id])
    return reject unless @room
    # ▲▲▲ 修正点 ▲▲▲

    # 特定の部屋のストリームに接続する
    stream_for @room
  end

  # 接続が切れた時に呼ばれる
  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end