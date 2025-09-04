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

      ShiritoriEvaluationJob.perform_later(@word_record)

      render turbo_stream: [
        turbo_stream.append('word-history', partial: 'words/word', locals: { word: @word_record }),
        turbo_stream.replace('word_form', partial: 'rooms/word_form', locals: { room: room }),
      ]

    when :game_over
      score = 100 + (new_word.length * 10)
      room.words.create!(
        body: new_word,
        score: score,
        room_participant: room_participant,
        user: room_participant.user
      )

      ShiritoriEvaluationJob.perform_later(room.words.where(room_participant: room_participant).last)

      render turbo_stream: [
        turbo_stream.update('flash-messages', partial: 'layouts/flash', locals: { message: result[:message], type: 'danger' }),
        turbo_stream.append_all('body', view_context.javascript_tag(<<-JS.squish)),
          document.dispatchEvent(new CustomEvent('game:over', {
            detail: { redirectUrl: '#{result_room_path(room)}' }
          }))
        JS
      ]

    else
      render turbo_stream: [
        turbo_stream.update('flash-messages', partial: 'layouts/flash', locals: { message: result[:message], type: 'warning' }),
        turbo_stream.replace('word_form', partial: 'rooms/word_form', locals: { room: room }),
      ], status: :unprocessable_entity
    end
  end

  private

  def word_params
    params.require(:word).permit(:body, :room_id, :room_participant_id)
  end
end
