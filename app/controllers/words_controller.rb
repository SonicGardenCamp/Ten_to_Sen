class WordsController < ApplicationController
  def create
    room = Room.find(params[:word][:room_id])
    new_word = params[:word][:body]
    logic = ShiritoriLogic.new(room)
    result = logic.validate(new_word)

    if result[:status] == :success
      @word_record = room.words.create(body: new_word)
      render turbo_stream: [
        turbo_stream.append("word-history", partial: "words/word", locals: { word_record: @word_record }),
        turbo_stream.replace("word_form", partial: "rooms/word_form", locals: { room: room })
      ]
    else
      head :unprocessable_entity
    end
  end
end