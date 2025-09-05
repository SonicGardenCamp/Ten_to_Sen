class WordsController < ApplicationController
  def create
    room = Room.find(word_params[:room_id])
    new_word = word_params[:body]

    # 参加者情報を取得
    room_participant = RoomParticipant.find(word_params[:room_participant_id])

    # ロジックを初期化
    logic = ShiritoriLogic.new(room, room_participant)
    result = logic.validate(new_word)

    case result[:status]
    when :success
      score = 100 + (new_word.length * 10)
      @word_record = room.words.create(
        body: new_word,
        score: score,
        room_participant: room_participant,
        user: room_participant.user
      )

      # 単体評価Job
      ShiritoriEvaluationJob.perform_later(@word_record)
      # 連鎖ボーナス評価Job
      previous_word = room.words.where.not(id: @word_record.id).order(created_at: :desc).first
      ShiritoriChainEvaluationJob.perform_later(@word_record, previous_word) if previous_word

      render turbo_stream: [
        turbo_stream.append('word-history', partial: 'words/word', locals: { word: @word_record }),
        turbo_stream.replace('word_form', partial: 'rooms/word_form', locals: { room: room }),
      ]

    when :game_over
      score = 100 + (new_word.length * 10)
      word_record = room.words.create!(
        body: new_word,
        score: score,
        room_participant: room_participant,
        user: room_participant.user
      )

      # 単体評価Job
      ShiritoriEvaluationJob.perform_later(word_record)
      # 連鎖ボーナス評価Job
      previous_word = room.words.where.not(id: word_record.id).order(created_at: :desc).first
      ShiritoriChainEvaluationJob.perform_later(word_record, previous_word) if previous_word

      if room.game_mode == "score_attack"
        # スコアアタック
        render turbo_stream: [
          turbo_stream.update('flash-messages',
            partial: 'layouts/flash',
            locals: { message: result[:message], type: 'danger' }
          ),
          turbo_stream.append_all('body', view_context.javascript_tag(<<-JS.squish))
            setTimeout(function() {
              window.location.href = '#{result_room_path(room)}';
            }, 1000);
          JS
        ]

      else
        # ★ 対戦モード
        alive_participants = room.room_participants.any? do |p|
          last_word = room.words.where(room_participant: p).last
          last_word && !last_word.body.ends_with?("ん")
        end

        if alive_participants
          # まだ続いてる人がいる → 待機
          render turbo_stream: [
            turbo_stream.update('flash-messages',
              partial: 'layouts/flash',
              locals: { message: result[:message], type: 'danger' }
            ),
            turbo_stream.append('word-history',
              partial: 'words/word',
              locals: { word: word_record }
            ),
            turbo_stream.append_all('body', view_context.javascript_tag(<<-JS.squish))
              document.dispatchEvent(new CustomEvent('game:over', {
                detail: { message: '#{result[:message]}' }
              }))
            JS
          ]
        else
          # 対戦モード（全員「ん」で終了 → 即リザルト）
          render turbo_stream: [
            turbo_stream.append_all('body', view_context.javascript_tag(<<-JS.squish))
              setTimeout(function() {
                window.location.href = '#{result_room_path(room)}';
              }, 1000);
            JS
          ]
        end
      end
    else
      # ❗️このブロックを戻さないと警告表示されない
      render turbo_stream: [
        turbo_stream.update('flash-messages',
          partial: 'layouts/flash',
          locals: { message: result[:message], type: 'warning' }
        ),
        turbo_stream.replace('word_form', partial: 'rooms/word_form', locals: { room: room }),
      ], status: :unprocessable_entity
    end
  end

  private

  def word_params
    params.require(:word).permit(:body, :room_id, :room_participant_id)
  end
end