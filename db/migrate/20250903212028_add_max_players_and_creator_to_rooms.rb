class AddMaxPlayersAndCreatorToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :max_players, :integer, null: false, default: 2
    add_reference :rooms, :creator, null: false, foreign_key: { to_table: :users }
  end
end
