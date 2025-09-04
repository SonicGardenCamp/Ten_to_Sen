# frozen_string_literal: true

module ShiritoriRules
  class DuplicationRule < BaseRule
    def validate
      # 【修正】現在のユーザー内での重複チェック
      return unless user_words.exists?(body: new_word)

      { status: :error, message: 'あなたは既にその単語を使用しています。' }
    end
  end
end
