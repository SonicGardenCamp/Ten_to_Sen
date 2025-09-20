module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Deviseのwarden proxy経由で認証済みユーザーを取得
      if (verified_user = env['warden'].user)
        verified_user
      else
        # ユーザーが認証されていない場合は接続を拒否
        reject_unauthorized_connection
      end
    end
  end
end