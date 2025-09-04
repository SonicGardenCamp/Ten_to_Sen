# frozen_string_literal: true

module ShiritoriRules
  class BaseRule
    attr_reader :room, :new_word, :user

    def initialize(room, new_word, user = nil)
      @room = room
      @new_word = new_word
      @user = user  # 追加：ユーザー情報
    end

    def validate
      raise NotImplementedError, '各ルールクラスで実装してください'
    end

    private

    # 現在のユーザーの最後の単語レコードを取得
    def last_word_record
      return @last_word_record if defined?(@last_word_record)

      if @user
        @last_word_record = room.words.where(user: @user).order(:created_at).last
      else
        # フォールバック（既存の動作を保持）
        @last_word_record = room.words.order(:created_at).last
      end
    end

    # 現在のユーザーの最後の単語を取得
    def last_word
      last_word_record&.body
    end

    # 現在のユーザーの単語履歴を取得
    def user_words
      return room.words if @user.nil?
      room.words.where(user: @user)
    end
  end
end
