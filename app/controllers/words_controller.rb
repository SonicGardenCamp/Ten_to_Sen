class WordsController < ApplicationController
  def create
    room = Room.find(params[:word][:room_id])
    new_word = params[:word][:body]
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
      room.words.create(body: new_word)
      # 1. ゲームオーバーメッセージを表示する
      # 2. 1.5秒後にリザルトページへ移動するJavaScriptを実行する
      render turbo_stream: [
        turbo_stream.update("flash-messages", partial: "layouts/flash", locals: { message: "ゲーム終了！", type: "danger" }),
        turbo_stream.append_all("body", helpers.javascript_tag("setTimeout(() => { Turbo.visit('#{result_room_path(room)}') }, 1500)"))
      ]

    else # :error の場合
      # 警告メッセージを表示し、フォームをリセット
      render turbo_stream: [
        turbo_stream.update("flash-messages", partial: "layouts/flash", locals: { message: result[:message], type: "warning" }),
        turbo_stream.replace("word_form", partial: "rooms/word_form", locals: { room: room })
      ], status: :unprocessable_entity
    end
  end
end