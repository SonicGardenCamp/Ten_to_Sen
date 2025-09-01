# frozen_string_literal: true

module ShiritoriRules
  class LosingCharacterRule < BaseRule
    LOSING_CHARS = ['ん'].freeze

    def validate
      return unless LOSING_CHARS.include?(new_word[-1])

      { status: :game_over, message: "「#{new_word[-1]}」で終わる単語は使えません。" }
    end
  end
end
