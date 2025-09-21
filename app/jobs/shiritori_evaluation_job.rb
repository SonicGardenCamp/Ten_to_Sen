# app/jobs/shiritori_evaluation_job.rb

class ShiritoriEvaluationJob < ActiveJob::Base
  queue_as :default

  def perform(word)
    # AIによる単語評価を実行
    ShiritoriEvaluationService.new(word).evaluate_and_save

    # ▼▼▼ 変更箇所 ▼▼▼
    # broadcast_resultsメソッドは削除し、新しいサービスクラスを呼び出す
    ResultBroadcasterService.call(word.room)
    # ▲▲▲ 変更箇所 ▲▲▲
  end
end