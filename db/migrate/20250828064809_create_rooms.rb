class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms, &:timestamps
  end
end
