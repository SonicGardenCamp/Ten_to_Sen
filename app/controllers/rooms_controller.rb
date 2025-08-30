class RoomsController < ApplicationController
  # `result`アクションを追加
  before_action :set_room, only: %i[ show result ]

  def index
    # 既存のコードのままでOK
  end

  def show
    # 既存のコードのままでOK
  end

  def create
    @room = Room.new

    if @room.save
      redirect_to @room # noticeは不要なので削除
    else
      # エラーの場合はトップページに戻すなど
      redirect_to root_path, alert: "ゲームの開始に失敗しました。"
    end
  end

  def result
    # この行を追加して、ビューで@roomが確実に使えるようにします
    @room = Room.find(params[:id])
  end

  private
    def set_room
      @room = Room.find(params[:id])
    end
end