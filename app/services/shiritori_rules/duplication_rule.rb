# frozen_string_literal: true

module ShiritoriRules
  class DuplicationRule < BaseRule
    def validate
      return unless room.words.exists?(body: new_word)

      { status: :error, message: 'その単語は既に使用されています。' }
    end
  end
end