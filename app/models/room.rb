class Room < ApplicationRecord
  has_many :words, dependent: :destroy
  validates :title, presence: true
end
