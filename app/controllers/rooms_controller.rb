class RoomsController < ApplicationController
  before_action :set_room, only: %i[ show edit update destroy ]

  def index
    @rooms = Room.all
  end

  def show
  end

  def new
    @room = Room.new
  end

  def edit
  end

  def create
    @room = Room.new
    @room.words.build(body: 'しりとり')

    if @room.save
      redirect_to @room, notice: "ゲーム開始！"
    else
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @room.update(room_params)
      redirect_to @room, notice: "Room was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @room.destroy!

    redirect_to rooms_path, notice: "Room was successfully destroyed.", status: :see_other
  end

  private
    def set_room
      @room = Room.find(params.expect(:id))
    end

    def room_params
      params.expect(room: %w[title])
    end
end
