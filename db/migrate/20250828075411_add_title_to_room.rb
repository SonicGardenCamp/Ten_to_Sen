class AddTitleToRoom < ActiveRecord::Migration[8.0]
  def change
    add_column :rooms, :title, :string, null: false
  end
end
