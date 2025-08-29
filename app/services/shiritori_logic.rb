# app/services/shiritori_logic.rb
class ShiritoriLogic
  def initialize(room)
    @room = room
  end

  def validate(new_word)
    last_word = @room.words.last&.body

    # 接続ルール
    if last_word && last_word[-1] != new_word[0]
      return { status: :error, message: '前の単語の最後の文字から始めてください。' }
    end

    # 終了ルール
    if new_word[-1] == 'ん'
      return { status: :error, message: '「ん」で終わる単語は使えません。' }
    end

    # 重複ルール
    if @room.words.exists?(body: new_word)
      return { status: :error, message: 'この単語は既に使用されています。' }
    end

    { status: :success }
  end
end
