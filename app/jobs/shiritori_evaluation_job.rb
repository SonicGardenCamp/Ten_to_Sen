class ShiritoriEvaluationJob < ActiveJob::Base
  queue_as :default

  def perform(word)
    ShiritoriEvaluationService.new(word).evaluate_and_save
  end
end