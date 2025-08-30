class ShiritoriLogic
  LOSING_CHARS = ['ん']

  def initialize(room)
    @room = room
  end

  def validate(new_word)
    return { status: :error, message: '単語を入力してください。' } if new_word.blank?

    if LOSING_CHARS.include?(new_word[-1])
      return { status: :game_over, message: "「#{new_word[-1]}」で終わる単語は使えません。" }
    end

    last_word = @room.words.order(:created_at).last&.body
    if last_word
      last_char = last_word[-1].tr('ぁぃぅぇぉっゃゅょゎ', 'あいうえおつやゆよわ')
      if last_char != new_word[0]
        return { status: :error, message: "「#{last_char}」から始まる単語を入力してください。" }
      end
    end

    if @room.words.exists?(body: new_word)
      return { status: :error, message: 'その単語は既に使用されています。' }
    end

    { status: :success }
  end
end