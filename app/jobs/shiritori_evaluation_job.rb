class ShiritoriEvaluationJob < ActiveJob::Base
  queue_as :default

  def perform(word)
    # AIによる単語評価を実行して結果を保存する
    ShiritoriEvaluationService.new(word).evaluate_and_save

    # ▼▼▼ 変更箇所 ▼▼▼
    # 評価が完了したので、最新の結果をブロードキャストする
    broadcast_results(word.room)
    # ▲▲▲ 変更箇所 ▲▲▲
  end

  private

  # ▼▼▼ 変更箇所 ▼▼▼
  # 最新のランキング結果を計算し、レンダリングしてブロードキャストするメソッド
  def broadcast_results(room)
    # データベースから最新の参加者と単語の情報を取得
    participants = room.room_participants.includes(:user, :words)

    results = participants.map do |participant|
      words = participant.words
      total_base_score = words.pluck(:score).compact.sum
      total_ai_score = words.pluck(:ai_score).compact.sum
      total_chain_bonus_score = words.pluck(:chain_bonus_score).compact.sum
      {
        user: participant.user,
        guest_name: participant.guest_name,
        result: {
          total_score: total_base_score + total_ai_score + total_chain_bonus_score,
          total_base_score: total_base_score,
          total_ai_score: total_ai_score,
          total_chain_bonus_score: total_chain_bonus_score,
          word_count: words.count,
          words: words.order(created_at: :asc)
        }
      }
    end

    # 最新のスコアに基づいてランキングを再計算
    ranked_results = results.sort_by { |r| -r[:result][:total_score] }.map.with_index(1) do |result, i|
      # is_current_user は各クライアントが自身のビューをレンダリングする際に判断するため、ここでは不要
      result.merge(rank: i)
    end

    # `app/views/rooms/_results.html.erb` パーシャルをHTML文字列としてレンダリングする
    # バックグラウンドジョブ内では'render'を直接使えないため、`ApplicationController.render`を使用する
    html = ApplicationController.render(
      partial: 'rooms/results',
      locals: { ranked_results: ranked_results }
    )

    # ResultChannelを通じて、このルームを購読している全てのクライアントにHTMLを送信
    ResultChannel.broadcast_to(room, { results_html: html })
  end
  # ▲▲▲ 変更箇所 ▲▲▲
end