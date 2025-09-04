class AddGuestInfoToRoomParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :room_participants, :guest_id, :string
    add_column :room_participants, :guest_name, :string
  end
end
