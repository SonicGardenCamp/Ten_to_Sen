class RoomsController < ApplicationController
  before_action :set_room, only: %i[show result]
  before_action :set_words, only: %i[show result]

  def new
    @room = Room.new
    @room.save
  end

  def index
  end

  def show
  end

  def create
    @room = Room.new

    if @room.save
      initial_word = InitialWordService.generate
      @room.words.create!(body: initial_word, score: 0)
      redirect_to @room
    else
      redirect_to root_path, alert: 'ゲームの開始に失敗しました。'
    end
  end

  def result
    @total_score = @words.sum(:score)
  end

  private

    def set_room
      @room = Room.find(params[:id])
    end

    def set_words
      @words = @room.words.order(:created_at)
    end

    def room_params
      params.require(:room).permit(:name, :game_mode)
    end
end
