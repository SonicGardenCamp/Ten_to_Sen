class ShiritoriEvaluationService
  def initialize(word)
    @word = word
  end

  def evaluate_and_save
    # すでに評価済み、または基本スコアが0の場合は処理しない
    return if @word.ai_score.present? || @word.score == 0

    # プロンプトを評価理由も取得できるように変更
    prompt = "日本のしりとりで使う単語「#{@word.body}」を評価し、0から30の整数でスコアと、その評価理由を日本語で簡潔に付けてください。評価基準は名詞として一般的か、独創性があるかです。\n結果は「スコア: [点数]\\n理由: [評価理由]」の形式で返してください。\n例:\nスコア: 25\n理由: 一般的な名詞でありながら、しりとりではあまり使われない独創性があるため。"

    begin
      response_text = GeminiCraft.generate_content(prompt)
      
      # 正規表現でスコアと理由をそれぞれ抽出
      score = response_text.match(/スコア:\s*(\d+)/)&.captures&.first&.to_i
      comment = response_text.match(/理由:\s*(.+)/)&.captures&.first

      # スコアと理由の両方が取得できた場合のみ更新
      if score && comment
        @word.update!(ai_score: score, ai_evaluation_comment: comment)
      end
    rescue => e
      Rails.logger.error "AI評価中にエラーが発生しました。単語: '#{@word.body}', エラー: #{e.message}"
    end
  end
end