# frozen_string_literal: true

module ShiritoriRules
  class ConnectionRule < BaseRule
    # 濁点・半濁点付きの文字と、そのベースとなる文字のマッピング
    DAKUTEN_MAPPING = {
      'が' => 'か',
      'ぎ' => 'き',
      'ぐ' => 'く',
      'げ' => 'け',
      'ご' => 'こ',
      'ざ' => 'さ',
      'じ' => 'し',
      'ず' => 'す',
      'ぜ' => 'せ',
      'ぞ' => 'そ',
      'だ' => 'た',
      'ぢ' => 'ち',
      'づ' => 'つ',
      'で' => 'て',
      'ど' => 'と',
      'ば' => 'は',
      'び' => 'ひ',
      'ぶ' => 'ふ',
      'べ' => 'へ',
      'ぼ' => 'ほ',
      'ぱ' => 'は',
      'ぴ' => 'ひ',
      'ぷ' => 'ふ',
      'ぺ' => 'へ',
      'ぽ' => 'ほ',
    }.freeze

    # 濁点・半濁点の文字を正規化するためのマッピング
    NORMALIZED_DAKUTEN_MAPPING = {
      'が' => 'か',
      'ぎ' => 'き',
      'ぐ' => 'く',
      'げ' => 'け',
      'ご' => 'こ',
      'ざ' => 'さ',
      'じ' => 'し',
      'ず' => 'す',
      'ぜ' => 'せ',
      'ぞ' => 'そ',
      'だ' => 'た',
      'ぢ' => 'ち',
      'づ' => 'つ',
      'で' => 'て',
      'ど' => 'と',
      'ば' => 'は',
      'び' => 'ひ',
      'ぶ' => 'ふ',
      'べ' => 'へ',
      'ぼ' => 'ほ',
      'ぱ' => 'は',
      'ぴ' => 'ひ',
      'ぷ' => 'ふ',
      'ぺ' => 'へ',
      'ぽ' => 'ほ',
    }.freeze

    # 長音符(ー)の前の文字を母音に変換するためのマッピング
    VOWEL_MAPPING = {
      %w[か が さ ざ た だ な は ば ぱ ま や ら わ].freeze => 'あ',
      %w[き ぎ し じ ち ぢ に ひ び ぴ み り].freeze => 'い',
      %w[く ぐ す ず つ づ ぬ ふ ぶ ぷ む ゆ る].freeze => 'う',
      %w[け げ せ ぜ て で ね へ べ ぺ め れ].freeze => 'え',
      %w[こ ご そ ぞ と ど の ほ ぼ ぽ も よ ろ を].freeze => 'お',
    }.freeze

    def validate
      return unless last_word

      last_char = get_last_char_for_shiritori(last_word)
      first_char = new_word[0]

      normalized_last_char = normalize_char(last_char)
      normalized_first_char = normalize_char(first_char)

      return if (normalized_last_char == normalized_first_char) || special_char_connection?(last_char, first_char)

      { status: :error, message: "「#{last_char}」から始まる単語を入力してください。" }
    end

    private

    def get_last_char_for_shiritori(word)
      char = word[-1]

      if char == 'ー'
        prev_char = word[-2].tr('ぁぃぅぇぉ', 'あいうえお')
        return convert_to_vowel(prev_char)
      end

      char.tr('ぁぃぅぇぉっゃゅょゎ', 'あいうえおつやゆよわ')
    end

    def convert_to_vowel(char)
      VOWEL_MAPPING.each do |keys, vowel|
        return vowel if keys.include?(char)
      end
      char
    end

    def normalize_char(char)
      NORMALIZED_DAKUTEN_MAPPING.fetch(char, char)
    end

    def special_char_connection?(last_char, first_char)
      (last_char == 'ぢ' && first_char == 'じ') || (last_char == 'づ' && first_char == 'ず')
    end
  end
end