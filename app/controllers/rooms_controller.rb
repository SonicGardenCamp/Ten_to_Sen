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

  # 参加ボタン
  def join
    room = Room.find(params[:id])

    if (room.respond_to?(:playing?) && room.playing?) || room.full?
      redirect_to root_path, alert: 'このルームは定員に達しています。' and return
    end

    Room.transaction do
      room.lock!
      if room.full?
        redirect_to root_path, alert: 'このルームは定員に達しています。' and return
      end

      room.room_participants.create!(user: current_user)

      if room.full?
        room.update!(status: :playing) if room.respond_to?(:status)

        # 【修正】各参加者に「しりとり」の初期単語を生成
        room.room_participants.includes(:user).each do |participant|
          unless room.words.where(user: participant.user).exists?
            room.words.create!(body: 'しりとり', score: 0, user: participant.user)
          end
        end
      end
    end

    redirect_to room_path(room)
  end

  def show
    @room = Room.find(params[:id])

    unless @room.room_participants.exists?(user_id: current_user.id)
      redirect_to rooms_path, alert: 'このルームの参加者ではありません。' and return
    end

    if @room.respond_to?(:playing?) && @room.playing?
      # 【修正】現在のユーザーに「しりとり」の初期単語がなければ生成
      unless @room.words.where(user: current_user).exists?
        @room.words.create!(body: 'しりとり', score: 0, user: current_user)
      end

      render :show
    else
      render :waiting
    end
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

    # 参加者とその結果データを正しく設定
    @participants = @room.room_participants.includes(:user)
    @results = {}

    # 参加者がいない場合の対策
    if @participants.empty?
      redirect_to rooms_path, alert: 'このルームには参加者がいません。' and return
    end

    @participants.each do |participant|
      user_words = @room.words.where(user: participant.user).order(:created_at)
      total_base_score = user_words.sum(:score)
      total_ai_score = user_words.sum { |word| word.ai_score || 0 }

      @results[participant.user] = {
        words: user_words,
        total_base_score: total_base_score,
        total_ai_score: total_ai_score,
        total_score: total_base_score + total_ai_score,
        word_count: user_words.count - 1  # 初期単語「しりとり」を除く
      }
    end

    # 勝者を決定
    @winner = @results.max_by { |user, result| result[:total_score] }&.first
  end

  private

    def set_room
      @room = Room.find(params[:id])
    end

    def set_words
      # 【修正】現在のユーザーの単語のみを表示
      @words = @room.words.where(user: current_user).order(:created_at) if @room && current_user
    end

    def room_params
      params.require(:room).permit(:name, :game_mode)
    end
end
