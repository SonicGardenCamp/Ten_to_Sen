class RoomsController < ApplicationController
  # `show`と`result`アクションの前にset_roomとset_wordsを実行する
  before_action :set_room, only: %i[show result]
  before_action :set_words, only: %i[show result]

  def index
  end

  def show
  end

  def create
    @room = Room.new

    if @room.save
      redirect_to @room
    else
      redirect_to root_path, alert: 'ゲームの開始に失敗しました。'
    end
  end

  def result
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def set_words
    @words = @room.words.order(:created_at)
  end
end
