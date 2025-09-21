class RoomsController < ApplicationController
  before_action :set_room, only: %i[show result status]
  before_action :set_words, only: %i[show result]
  skip_before_action :verify_authenticity_token, only: [:join]

  # ソロモードルーム作成
  def solo
    @room = Room.create!(
      name: "ソロモード",
      status: :playing,
      max_players: 1,
      creator_id: current_user&.id,
      game_mode: "score_attack",
      started_at: Time.current + 4.seconds
    )
    participant = if guest_user?
      @room.room_participants.create!(
        guest_id: current_guest_id,
        guest_name: current_guest_name
      )
    else
      @room.room_participants.create!(user: current_user)
    end
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
  end

  def index
    @rooms = Room.available.order(created_at: :desc)
    solo_rooms = Room.where(max_players: 1)
    user_max_scores = {}
    solo_rooms.includes(:room_participants).find_each do |room|
      room.room_participants.each do |participant|
        words = Word.where(room_id: room.id, room_participant_id: participant.id)
        total_score = words.sum(:score).to_i + words.sum(:ai_score).to_i + words.sum(:chain_bonus_score).to_i
        user = participant.user
        next unless user
        if user_max_scores[user.id].nil? || user_max_scores[user.id][:score] < total_score
          user_max_scores[user.id] = { username: user.username, score: total_score }
        end
      end
    end
    @ranking = user_max_scores.values.sort_by { |h| -h[:score] }.first(5)
  end

  # ルーム作成 → ホストは待機画面へ
  def create
    room = Room.create!(creator_id: current_user.id, status: :waiting, max_players: 2)
    room.room_participants.create!(user: current_user)

    html = render_to_string(partial: 'rooms/room', locals: { room: room })
    ActionCable.server.broadcast('lobby_channel', { event: 'room_created', room_html: html })

    redirect_to room_path(room), notice: 'ルームを作成しました。相手を待っています…'
  end

  # 参加ボタン
  def join
    room = Room.find(params[:id])

    if room.room_participants.exists?(user_id: current_user.id)
      redirect_to room_path(room) and return
    end

    if (room.respond_to?(:playing?) && room.playing?) || room.full?
      redirect_to root_path, alert: 'このルームは定員に達しています。' and return
    end

    Room.transaction do
      room.lock!
      if room.full?
        redirect_to root_path, alert: 'このルームは定員に達しています。' and return
      end

      room.room_participants.create!(user: current_user)

      participants_html = render_to_string(
        partial: 'rooms/participant',
        collection: room.participants
      )

      RoomChannel.broadcast_to(room, {
        event: 'participant_joined',
        participants_html: participants_html,
        participant_count: room.room_participants.count
      })

      if room.full?
        room.update!(status: :playing, started_at: Time.current + 4.seconds) if room.respond_to?(:status)

        ActionCable.server.broadcast('lobby_channel', { event: 'room_removed', room_id: room.id })
        RoomChannel.broadcast_to(room, { event: 'game_started' })

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
    is_participant = if guest_user?
      @room.room_participants.exists?(guest_id: current_guest_id)
    else
      @room.room_participants.exists?(user_id: current_user.id)
    end

    unless is_participant
      redirect_to rooms_path, alert: 'このルームの参加者ではありません。' and return
    end

    if @room.finished?
      redirect_to result_room_path(@room) and return
    end

    if @room.playing?
      render :show
    else
      render :waiting
    end
  end

  def status
    render json: {
      status: @room.status,
      participant_count: @room.room_participants.count,
      max_players: @room.max_players
    }
  end

  def leave
    room = Room.find(params[:id])
    room.room_participants.where(user_id: current_user.id).destroy_all

    if room.reload.room_participants.count.zero?
      room.destroy!
      ActionCable.server.broadcast('lobby_channel', { event: 'room_removed', room_id: room.id })
    end

    redirect_to rooms_path, notice: 'ルームを退出しました。'
  end

  def result
    @room.update!(status: :finished) unless @room.finished?

    @all_words_evaluated = @room.words.where.not(score: 0).all? { |word| word.ai_score.present? && word.chain_bonus_score.present? }

    unless @all_words_evaluated
      @room.words.where.not(score: 0).each do |word|
        ShiritoriEvaluationJob.perform_later(word)
        ShiritoriChainEvaluationJob.perform_later(word, word.previous_word) if word.previous_word
      end
    end

    @evaluation_timed_out = false

    if !@all_words_evaluated
      timeout = 60.seconds
      start_time = Time.current
      loop do
        @all_words_evaluated = @room.words.where.not(score: 0).all? { |word| word.ai_score.present? && word.chain_bonus_score.present? }
        break if @all_words_evaluated

        if Time.current - start_time > timeout
          @evaluation_timed_out = true
          break
        end

        sleep 1
        @room.words.reload
      end
    end

    @participants = @room.room_participants.includes(:user)

    results = @participants.map do |participant|
      words = @room.words.where(room_participant_id: participant.id)

      total_base_score = words.pluck(:score).compact.sum
      total_ai_score = words.pluck(:ai_score).compact.sum
      total_chain_bonus_score = words.pluck(:chain_bonus_score).compact.sum

      {
        user: participant.user,
        result: {
          total_score: total_base_score + total_ai_score + total_chain_bonus_score,
          total_base_score: total_base_score,
          total_ai_score: total_ai_score,
          total_chain_bonus_score: total_chain_bonus_score,
          word_count: words.count,
          words: words.order(created_at: :asc)
        }
      }
    end

    @ranked_results = results.sort_by { |r| r[:result][:total_score] }.reverse.map.with_index(1) do |result, i|
      result.merge(rank: i, is_current_user: (result[:user] == current_user))
    end

    @winner = @ranked_results.first[:user] if @ranked_results.present?
  end

  # 全ユーザーのソロスコアランキング
  def solo_ranking
    @ranking = User.joins(:words)
      .select('users.*, SUM(words.score) AS total_score')
      .group('users.id')
      .order('total_score DESC')
  end

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

  private

    def set_room
      @room = Room.find(params[:id])
    end

    def set_words
      return unless @room

      if guest_user?
        @current_participant = @room.room_participants.find_by(guest_id: current_guest_id)
      else
        @current_participant = @room.room_participants.find_by(user_id: current_user.id)
      end

      @words = @room.words.where(room_participant_id: @current_participant&.id).order(:created_at) || []
    end

    def room_params
      params.require(:room).permit(:name, :game_mode)
    end
end