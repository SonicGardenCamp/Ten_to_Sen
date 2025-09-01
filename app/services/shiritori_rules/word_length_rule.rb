# frozen_string_literal: true

module ShiritoriRules
  class WordLengthRule < BaseRule
    MAX_LENGTH = 100

    def validate
      return if new_word.length <= MAX_LENGTH

      { status: :error, message: "単語は#{MAX_LENGTH}文字以内で入力してください。" }
    end
  end
end
