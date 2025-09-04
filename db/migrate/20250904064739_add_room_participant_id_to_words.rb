class AddRoomParticipantIdToWords < ActiveRecord::Migration[8.0]
  def change
    add_reference :words, :room_participant, foreign_key: true
  end
end
