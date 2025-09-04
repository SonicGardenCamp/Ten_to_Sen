  # 全ユーザーのソロスコアランキング（JSON返却）
  def solo_ranking_json
    ranking = Word.joins(:user)
      .group('users.id', 'users.username')
      .select('users.id, users.username, SUM(words.score) AS total_score')
      .order('total_score DESC')

    render json: ranking.map.with_index(1) { |row, i|
      {
        rank: i,
        username: row.username,
        total_score: row.total_score
      }
    }
  end
class RoomsController < ApplicationController
  before_action :set_room, only: %i[show result status]
  before_action :set_words, only: %i[show result]

  # ソロモードルーム作成
  def solo
    @room = Room.create!(
      name: "ソロモード",
      status: :playing,
      max_players: 1,
      creator_id: current_user&.id
    )

    # プレイヤー情報を作成（ログインユーザーまたはゲスト）
    participant = if guest_user?
      @room.room_participants.create!(
        guest_id: current_guest_id,
        guest_name: current_guest_name
      )
    else
      @room.room_participants.create!(user: current_user)
    end


    # 3秒待機
    sleep 3
    # 初期単語「しりとり」を追加
    @room.words.create!(
      body: 'しりとり',
      score: 0,
      room_participant: participant,
      user: participant.user
    )

    redirect_to room_path(@room), notice: 'ソロモードを開始しました'
  end

  def new
    @room = Room.new
    @room.save
  end

  def index
    @rooms = Room.available.order(created_at: :desc)
    @ranking = Word.joins(:user)
      .group('users.id', 'users.username')
      .select('users.id, users.username, SUM(words.score) AS total_score')
      .order('total_score DESC')
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

        # 3秒待機
        sleep 3
        # 各参加者に「しりとり」の初期単語を生成
        room.room_participants.includes(:user).each do |participant|
          unless room.words.where(user: participant.user).exists?
            room.words.create!(body: 'しりとり', score: 0, user: participant.user, room_participant: participant)
          end
        end
      end
    end

    redirect_to room_path(room)
  end

  def show
    @room = Room.find(params[:id])

    # 参加確認（ログインユーザーまたはゲストユーザー）
    is_participant = if guest_user?
      @room.room_participants.exists?(guest_id: current_guest_id)
    else
      @room.room_participants.exists?(user_id: current_user.id)
    end

    unless is_participant
      redirect_to rooms_path, alert: 'このルームの参加者ではありません。' and return
    end

    if @room.respond_to?(:playing?) && @room.playing?
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
    results_data = {}

    # 参加者がいない場合の対策
    if @participants.empty?
      redirect_to rooms_path, alert: 'このルームには参加者がいません。' and return
    end

    @participants.each do |participant|
      user_words = @room.words.where(user: participant.user).order(:created_at)
      total_base_score = user_words.sum(:score)
      total_ai_score = user_words.sum { |word| word.ai_score || 0 }

      results_data[participant.user] = {
        words: user_words,
        total_base_score: total_base_score,
        total_ai_score: total_ai_score,
        total_score: total_base_score + total_ai_score,
        word_count: user_words.count - 1  # 初期単語「しりとり」を除く
      }
    end

    # 【新規追加】総合スコア順にソートして順位付け
    @ranked_results = results_data.sort_by { |user, result| -result[:total_score] }
                                  .map.with_index(1) { |(user, result), rank|
      {
        rank: rank,
        user: user,
        result: result,
        is_current_user: user == current_user
      }
    }

    # 勝者を決定（1位のユーザー）
    @winner = @ranked_results.first[:user] if @ranked_results.any?
  end

  # 全ユーザーのソロスコアランキング
  def solo_ranking
    @ranking = User.joins(:words)
      .select('users.*, SUM(words.score) AS total_score')
      .group('users.id')
      .order('total_score DESC')
  end

  private

    def set_room
      @room = Room.find(params[:id])
    end

    def set_words
      return unless @room

      if guest_user?
        participant = @room.room_participants.find_by(guest_id: current_guest_id)
      else
        participant = @room.room_participants.find_by(user_id: current_user.id)
      end

      @words = @room.words.where(room_participant_id: participant&.id).order(:created_at)
    end

    def room_params
      params.require(:room).permit(:name, :game_mode)
    end
end
