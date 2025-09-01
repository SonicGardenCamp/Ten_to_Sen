# frozen_string_literal: true

require_relative 'shiritori_rules/base_rule'
require_relative 'shiritori_rules/losing_character_rule'
require_relative 'shiritori_rules/connection_rule'
require_relative 'shiritori_rules/duplication_rule'
require_relative 'shiritori_rules/word_length_rule' # この行を追加

class ShiritoriLogic
  # 適用するルールを定義
  RULES = [
    ShiritoriRules::LosingCharacterRule,
    ShiritoriRules::ConnectionRule,
    ShiritoriRules::DuplicationRule,
    ShiritoriRules::WordLengthRule # この行を追加
  ].freeze

  def initialize(room)
    @room = room
  end

  def validate(new_word)
    return { status: :error, message: '単語を入力してください。' } if new_word.blank?

    # 各ルールを順番にチェック
    RULES.each do |rule_class|
      result = rule_class.new(@room, new_word).validate
      return result if result.present?
    end

    { status: :success }
  end
end