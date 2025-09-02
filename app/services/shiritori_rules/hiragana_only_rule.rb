# frozen_string_literal: true

module ShiritoriRules
  class HiraganaOnlyRule < BaseRule
    HIRAGANA_ONLY_REGEX = /\A[\u3040-\u309Fー]+\z/

    def validate
      return if new_word.match?(HIRAGANA_ONLY_REGEX)

      { status: :error, message: 'ひらがなで入力してください。' }
    end
  end
end
