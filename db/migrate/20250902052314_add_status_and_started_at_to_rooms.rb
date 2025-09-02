class AddStatusAndStartedAtToRooms < ActiveRecord::Migration[8.0]
  # DDLトランザクションを無効化する
  disable_ddl_transaction!

  def up
    add_column :rooms, :status, :integer, default: 0, null: false
    add_column :rooms, :started_at, :datetime
    # algorithm: :concurrently を指定してインデックスを非同期で作成
    add_index :rooms, :status, algorithm: :concurrently
  end

  def down
    # upメソッドで追加したものを逆順で削除していく
    remove_index :rooms, :status
    remove_column :rooms, :started_at
    remove_column :rooms, :status
  end
end