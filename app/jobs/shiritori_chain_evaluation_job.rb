class ShiritoriChainEvaluationJob < ActiveJob::Base
  queue_as :default

  def perform(current_word, previous_word)
    ShiritoriChainEvaluationService.new(current_word, previous_word).evaluate_and_save
  end
end