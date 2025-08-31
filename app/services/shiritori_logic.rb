class ShiritoriLogic
  LOSING_CHARS = ['ん']

  def initialize(room)
    @room = room
  end

  def validate(new_word)
    # 空の単語はエラー
    return { status: :error, message: '単語を入力してください。' } if new_word.blank?

    last_word_record = @room.words.order(:created_at).last
    last_word = last_word_record&.body

    # 終了ルールを最優先でチェック
    if LOSING_CHARS.include?(new_word[-1]) # 文字列の最後の文字を取得
      return { status: :game_over, message: "「#{new_word[-1]}」で終わる単語は使えません。" }
    end

    # 接続ルール (最初の単語でない場合)
    if last_word
      # 「っ」や「ゃ」などの小さい文字を大きい文字に変換して比較
      last_char = last_word[-1].tr('ぁぃぅぇぉっゃゅょゎ', 'あいうえおつやゆよわ')
      if last_char != new_word[0]
        return { status: :error, message: "「#{last_char}」から始まる単語を入力してください。" }
      end
    end

    # 重複ルール
    if @room.words.exists?(body: new_word)
      return { status: :error, message: 'その単語は既に使用されています。' }
    end

    # すべてのチェックを通過
    { status: :success }
  end
end