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

      user_obj = @user || (defined?(current_user) ? current_user : nil)
      if user_obj
        @last_word_record = room.words.where(user: user_obj).order(:created_at).last
      else
        raise "ユーザー情報がありません。履歴を取得できません。"
      end
    end

    # 現在のユーザーの最後の単語を取得
    def last_word
      last_word_record&.body
    end

    # 現在のユーザーの単語履歴を取得
    def user_words
      user_obj = @user || (defined?(current_user) ? current_user : nil)
      if user_obj
        room.words.where(user: user_obj)
      else
        raise "ユーザー情報がありません。履歴を取得できません。"
      end
    end
  end
end
