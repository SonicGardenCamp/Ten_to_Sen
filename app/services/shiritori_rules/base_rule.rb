# frozen_string_literal: true

module ShiritoriRules
  class BaseRule
    attr_reader :room, :new_word

    def initialize(room, new_word)
      @room = room
      @new_word = new_word
    end

    def validate
      raise NotImplementedError, "各ルールクラスで実装してください"
    end

    private

    def last_word_record
      @last_word_record ||= room.words.order(:created_at).last
    end

    def last_word
      last_word_record&.body
    end
  end
end