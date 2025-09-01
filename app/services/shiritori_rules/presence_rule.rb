# frozen_string_literal: true

module ShiritoriRules
  class PresenceRule < BaseRule
    def validate
      return if new_word.present?

      { status: :error, message: '単語を入力してください。' }
    end
  end
end
