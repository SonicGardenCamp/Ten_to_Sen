class RoomsController < ApplicationController
  # `result`アクションを追加
  before_action :set_room, only: %i[ show result ]

  def index
    # 既存のコードのままでOK
  end

  def show
    @words = @room.words.order(:created_at)
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
    @words = @room.words.order(:created_at)
  end

  private
    def set_room
      @room = Room.find(params[:id])
    end
end