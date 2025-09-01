# frozen_string_literal: true

require_relative 'shiritori_rules/presence_rule'
require_relative 'shiritori_rules/losing_character_rule'
require_relative 'shiritori_rules/connection_rule'
require_relative 'shiritori_rules/duplication_rule'
require_relative 'shiritori_rules/word_length_rule'
require_relative 'initial_word_service' # この行を追加

class ShiritoriLogic
  # 適用するルールを定義
  RULES = [
    ShiritoriRules::PresenceRule, # この行を追加
    ShiritoriRules::LosingCharacterRule,
    ShiritoriRules::ConnectionRule,
    ShiritoriRules::DuplicationRule,
    ShiritoriRules::WordLengthRule,
  ].freeze

  def initialize(room)
    @room = room
  end

  def validate(new_word)
    # 各ルールを順番にチェック
    RULES.each do |rule_class|
      result = rule_class.new(@room, new_word).validate
      return result if result.present?
    end

    # すべてのチェックを通過
    { status: :success }
  end
end