class Room < ApplicationRecord
  has_many :words, dependent: :destroy
  
end
