class Word < ApplicationRecord
  belongs_to :room
  belongs_to :user

  after_update_commit -> { broadcast_replace_to "word_evaluation_#{id}" }

  validates :body, presence: true
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # ユーザー別の単語を取得するスコープを追加
  scope :for_user, ->(user) { where(user: user) }
  scope :ordered, -> { order(:created_at) }
end
