# frozen_string_literal: true

require_relative 'shiritori_rules/presence_rule'
require_relative 'shiritori_rules/hiragana_only_rule'
require_relative 'shiritori_rules/losing_character_rule'
require_relative 'shiritori_rules/connection_rule'
require_relative 'shiritori_rules/duplication_rule'
require_relative 'shiritori_rules/word_length_rule'

class ShiritoriLogic
  # 適用するルールを定義
  RULES = [
    ShiritoriRules::PresenceRule,
    ShiritoriRules::HiraganaOnlyRule,
    ShiritoriRules::LosingCharacterRule,
    ShiritoriRules::ConnectionRule,
    ShiritoriRules::DuplicationRule,
    ShiritoriRules::WordLengthRule,
  ].freeze

  def initialize(room, user = nil)
    @room = room
    @user = user  # 【修正】ユーザー情報を保持
  end

  def validate(new_word)
    RULES.each do |rule_class|
      # 【修正】ユーザー情報もルールクラスに渡す
      result = rule_class.new(@room, new_word, @user).validate
      return result if result.present?
    end

    { status: :success }
  end
end
