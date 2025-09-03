class RoomsController < ApplicationController
  before_action :set_room, only: %i[show result status]
  before_action :set_words, only: %i[show result]

  def new
    @room = Room.new
    @room.save
  end

  def index
    @rooms = Room.available.order(created_at: :desc)
  end

  # ルーム作成 → ホストは待機画面へ
  def create
    room = Room.create!(creator_id: current_user.id, status: :waiting, max_players: 2)
    room.room_participants.create!(user: current_user) # ホストも参加者に含める
    redirect_to room_path(room), notice: 'ルームを作成しました。相手を待っています…'
  end

  # 待機 or 対戦画面
  def show
    @room = Room.find(params[:id])

    # 参加者以外は参加ページへ誘導
    unless @room.room_participants.exists?(user_id: current_user.id)
      redirect_to rooms_path, alert: 'このルームの参加者ではありません。' and return
    end

    # 対戦中に入ってきたら、対戦画面へ（ここであなたの既存ゲーム画面を出す）
    if @room.respond_to?(:playing?) && @room.playing?
      # 初期単語がなければ生成
      unless @room.words.exists?
        initial_word = InitialWordService.generate
        @room.words.create!(body: initial_word, score: 0)
      end
      render :show
    else
      render :waiting
    end
  end

  # 参加ボタン
  def join
    room = Room.find(params[:id])

    if (room.respond_to?(:playing?) && room.playing?) || room.full?
      redirect_to root_path, alert: 'このルームは定員に達しています。' and return
    end

    Room.transaction do
      room.lock!           # 競合対策
      if room.full?
        redirect_to root_path, alert: 'このルームは定員に達しています。' and return
      end

      room.room_participants.create!(user: current_user)

      # 定員に達したら開始
      if room.full?
        room.update!(status: :playing) if room.respond_to?(:status)
        # ゲーム開始時に初期単語を生成
        unless room.words.exists?
          initial_word = InitialWordService.generate
          room.words.create!(body: initial_word, score: 0)
        end
      end
    end

    redirect_to room_path(room)
  end

  # ステータス確認用API（AJAX用）
  def status
    render json: {
      status: @room.status,
      participant_count: @room.room_participants.count,
      max_players: @room.max_players
    }
  end

  # 退出
  def leave
    room = Room.find(params[:id])
    room.room_participants.where(user_id: current_user.id).destroy_all

    # 参加者が0なら部屋ごと削除（掃除）
    if room.room_participants.count.zero?
      room.destroy!
    end

    redirect_to rooms_path, notice: 'ルームを退出しました。'
  end

  # 結果表示（勝敗判定はあなたのスコア算出ロジックに合わせて実装）
  def result
    @room = Room.find(params[:id])
    # 例）@scores = { user_id => score, ... } を用意して勝敗を決定する
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
