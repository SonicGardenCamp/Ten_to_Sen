class WordsController < ApplicationController
  def create
    room = Room.find(word_params[:room_id])
    new_word = word_params[:body]
    logic = ShiritoriLogic.new(room)
    result = logic.validate(new_word)

    case result[:status]
    when :success
      score = 100 + (new_word.length * 10)
      @word_record = room.words.create(body: new_word, score: score)

      # 投稿された単語のAI評価を開始
      ShiritoriEvaluationJob.perform_later(@word_record)

      render turbo_stream: [
        turbo_stream.append('word-history', partial: 'words/word', locals: { word: @word_record }),
        turbo_stream.replace('word_form', partial: 'rooms/word_form', locals: { room: room }),
      ]

    when :game_over
      score = 100 + (new_word.length * 10)
      room.words.create!(body: new_word, score: score)

      # 【修正点】ゲームオーバー時の単語もAI評価を開始する
      ShiritoriEvaluationJob.perform_later(room.words.last)

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
    params.require(:word).permit(:body, :room_id)
  end
end