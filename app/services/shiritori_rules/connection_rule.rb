# frozen_string_literal: true

module ShiritoriRules
  class ConnectionRule < BaseRule
    def validate
      return unless last_word

      last_char = get_last_char_for_shiritori(last_word)
      first_char = new_word[0]

      # 濁点・半濁点を無視して比較
      normalized_last_char = normalize_char(last_char)
      normalized_first_char = normalize_char(first_char)

      return if valid_connection?(normalized_last_char, normalized_first_char)

      { status: :error, message: "「#{last_char}」から始まる単語を入力してください。" }
    end

    private

    def get_last_char_for_shiritori(word)
      char = word[-1]
      return convert_to_vowel(word[-2]) if char == 'ー'

      char.tr('ぁぃぅぇぉっゃゅょゎ', 'あいうえおつやゆよわ')
    end

    def convert_to_vowel(char)
      case char
      when *%w[か が さ ざ た だ な は ば ぱ ま や ら わ] then 'あ'
      when *%w[き ぎ し じ ち ぢ に ひ び ぴ み り] then 'い'
      when *%w[く ぐ す ず つ づ ぬ ふ ぶ ぷ む ゆ る] then 'う'
      when *%w[け げ せ ぜ て で ね へ べ ぺ め れ] then 'え'
      when *%w[こ ご そ ぞ と ど の ほ ぼ ぽ も よ ろ を] then 'お'
      else char
      end
    end

    # 濁点・半濁点を削除するメソッドを追加
    def normalize_char(char)
      # 濁点・半濁点付きの文字と、そのベースとなる文字のマッピング
      mapping = {
        'が' => 'か', 'ぎ' => 'き', 'ぐ' => 'く', 'げ' => 'け', 'ご' => 'こ',
        'ざ' => 'さ', 'じ' => 'し', 'ず' => 'す', 'ぜ' => 'せ', 'ぞ' => 'そ',
        'だ' => 'た', 'ぢ' => 'ち', 'づ' => 'つ', 'で' => 'て', 'ど' => 'と',
        'ば' => 'は', 'び' => 'ひ', 'ぶ' => 'ふ', 'べ' => 'へ', 'ぼ' => 'ほ',
        'ぱ' => 'は', 'ぴ' => 'ひ', 'ぷ' => 'ふ', 'ぺ' => 'へ', 'ぽ' => 'ほ'
      }
      mapping[char] || char
    end


    def valid_connection?(last_char, first_char)
      # 濁点・半濁点を無視した文字で比較
      normalize_char(last_char) == normalize_char(first_char) || special_char_connection?(last_char, first_char)
    end

    def special_char_connection?(last_char, first_char)
      (last_char == 'ぢ' && first_char == 'じ') || (last_char == 'づ' && first_char == 'ず')
    end
  end
end