class ShiritoriEvaluationService
  def initialize(word)
    @word = word
  end

  def evaluate_and_save
    return if @word.ai_score.present? || @word.score == 0

    prompt = "日本のしりとりで使う単語「#{@word.body}」を評価し、0から30の整数でスコアを付けてください。評価基準は名詞として一般的か、独創性があるかです。結果は必ずスコアの数字だけを返してください。例: 25"

    begin
      response_text = GeminiCraft.generate_content(prompt)
      score = response_text.match(/\d+/)&.to_s&.to_i

      @word.update!(ai_score: score) if score
    rescue => e
      Rails.logger.error "AI評価中にエラーが発生しました。単語: '#{@word.body}', エラー: #{e.message}"
    end
  end
end