class ResultBroadcasterService
  def self.call(room)
    new(room).broadcast
  end

  def initialize(room)
    @room = room
  end

  def broadcast
    # `event`キーを追加してブロードキャストする
    results_data = build_results_data.merge(event: 'update_results')
    ResultChannel.broadcast_to(@room, results_data)
  end


  def build_results_data
    participants = @room.room_participants.includes(:user, :words)

    ranked_results = participants.map do |participant|
      words = participant.words
      
      total_base_score = words.map(&:score).compact.sum
      total_ai_score = words.map(&:ai_score).compact.sum
      total_chain_bonus_score = words.map(&:chain_bonus_score).compact.sum
      
      {
        participant_id: participant.id,
        user_id: participant.user&.id,
        guest_id: participant.guest_id,
        username: participant.user&.username || participant.guest_name,
        total_score: total_base_score + total_ai_score + total_chain_bonus_score,
        total_base_score: total_base_score,
        total_ai_score: total_ai_score,
        total_chain_bonus_score: total_chain_bonus_score,
        word_count: words.size,
        words: words.sort_by(&:created_at).map do |w|
          {
            body: w.body,
            score: w.score,
            ai_score: w.ai_score,
            ai_evaluation_comment: w.ai_evaluation_comment,
            chain_bonus_score: w.chain_bonus_score,
            chain_bonus_comment: w.chain_bonus_comment
          }
        end
      }
    end.sort_by { |r| -r[:total_score] }

    all_words_evaluated = participants.flat_map { |p| p.words.reject { |w| w.score.zero? } }.all? { |w| w.ai_score.present? && w.chain_bonus_score.present? }

    # broadcastメソッドで`event`キーを追加するため、ここでは純粋なデータのみを返す
    {
      all_words_evaluated: all_words_evaluated,
      ranked_results: ranked_results
    }
  end
end