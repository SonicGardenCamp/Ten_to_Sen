class WordsController < ApplicationController
  def create
    room = Room.find(word_params[:room_id])
    new_word = word_params[:body]
    logic = ShiritoriLogic.new(room)
    result = logic.validate(new_word)

    case result[:status]
    when :success
      @word_record = room.words.create(body: new_word)
      render turbo_stream: [
        turbo_stream.append("word-history", partial: "words/word", locals: { word_record: @word_record }),
        turbo_stream.replace("word_form", partial: "rooms/word_form", locals: { room: room })
      ]

    when :game_over
      room.words.create!(body: new_word)
      render turbo_stream: [
        turbo_stream.update("flash-messages", partial: "layouts/flash", locals: { message: "ゲーム終了！", type: "danger" }),
        turbo_stream.append_all("body", helpers.javascript_tag("setTimeout(() => { Turbo.visit('#{result_room_path(room)}') }, 1500)"))
      ]

    else
      render turbo_stream: [
        turbo_stream.update("flash-messages", partial: "layouts/flash", locals: { message: result[:message], type: "warning" }),
        turbo_stream.replace("word_form", partial: "rooms/word_form", locals: { room: room })
      ], status: :unprocessable_entity
    end
  end

  private

  def word_params
    params.require(:word).permit(:body, :room_id)
  end
end