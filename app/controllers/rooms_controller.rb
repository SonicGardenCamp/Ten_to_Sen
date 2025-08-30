class RoomsController < ApplicationController
  before_action :set_room, only: %i[ show result ]

  def index
  end

  def show
  end

  def create
    @room = Room.new
    if @room.save
      redirect_to @room
    else
      redirect_to root_path, alert: "ゲームの開始に失敗しました。"
    end
  end

  def result
    @room = Room.find(params[:id])
  end

  private
    def set_room
      @room = Room.find(params[:id])
    end
end