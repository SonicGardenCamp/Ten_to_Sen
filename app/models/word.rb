class Word < ApplicationRecord
  belongs_to :room

  after_update_commit -> { broadcast_replace_to "word_evaluation_#{id}" }
end
