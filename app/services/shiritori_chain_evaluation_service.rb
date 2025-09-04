class ShiritoriChainEvaluationService
  def initialize(current_word, previous_word)
    @current_word = current_word
    @previous_word = previous_word
  end

  def evaluate_and_save
    # 既に評価済み、または前の単語が存在しない場合は処理しない
    return if @current_word.chain_bonus_score.present? || @previous_word.nil?

    prompt = <<-PROMPT
日本のしりとりで、前の単語「#{@previous_word.body}」に続く単語として「#{@current_word.body}」が使われました。
この2つの単語の関連性を評価し、0から15点の整数でボーナススコアを付けてください。
評価基準は、意味的な繋がり、連想の自然さ、意外性や面白さです。
結果は「スコア: [点数]\\n理由: [評価理由]」の形式で返してください。
例:
スコア: 12
理由: 「りんご」の次に「ゴリラ」と続いており、動物という繋がりで自然な連想です。
    PROMPT

    begin
      response_text = GeminiCraft.generate_content(prompt)
      
      score = response_text.match(/スコア:\s*(\d+)/)&.captures&.first&.to_i
      comment = response_text.match(/理由:\s*(.+)/)&.captures&.first

      if score && comment
        @current_word.update!(chain_bonus_score: score, chain_bonus_comment: comment)
      end
    rescue => e
      Rails.logger.error "AI連鎖評価中にエラーが発生しました。単語: '#{@current_word.body}', エラー: #{e.message}"
    end
  end
end