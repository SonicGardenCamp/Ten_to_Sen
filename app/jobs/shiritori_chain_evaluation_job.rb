# app/jobs/shiritori_chain_evaluation_job.rb

class ShiritoriChainEvaluationJob < ActiveJob::Base
  queue_as :default

  def perform(current_word, previous_word)
    # AIによる連鎖評価を実行
    ShiritoriChainEvaluationService.new(current_word, previous_word).evaluate_and_save

    # ▼▼▼ 変更箇所 ▼▼▼
    # broadcast_resultsメソッドは削除し、新しいサービスクラスを呼び出す
    ResultBroadcasterService.call(current_word.room)
    # ▲▲▲ 変更箇所 ▲▲▲
  end
end