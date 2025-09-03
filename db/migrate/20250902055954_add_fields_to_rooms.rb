class AddFieldsToRooms < ActiveRecord::Migration[8.0]
  def change
    add_column :rooms, :name, :string
    add_column :rooms, :theme, :string
    add_column :rooms, :game_mode, :string
    add_column :rooms, :password_digest, :string
  end
end
