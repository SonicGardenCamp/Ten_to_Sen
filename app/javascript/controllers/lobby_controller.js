import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {

    console.log("Lobby Controller: CONNECTED at", new Date().toLocaleTimeString());
    // ▼▼▼ 変更点：新しいconsumerを作成する代わりに、共有のconsumerを使用する ▼▼▼
    this.subscription = consumer.subscriptions.create("LobbyChannel", {
      // ▲▲▲ 変更点 ▲▲▲

      // サーバーからデータを受信したときに呼び出される
      received: (data) => {
        // 'room_created' イベントを受信した場合
        if (data.event === 'room_created') {
          // 部屋リストの先頭に新しい部屋のHTMLを追加
          this.element.insertAdjacentHTML('afterbegin', data.room_html)
        }
        // 'room_removed' イベントを受信した場合
        if (data.event === 'room_removed') {
          // 該当するIDの部屋要素を探して削除
          const roomElement = document.getElementById(`room_${data.room_id}`)
          if (roomElement) {
            roomElement.remove()
          }
        }
      }
    })
  }

  disconnect() {
    console.log("Lobby Controller: DISCONNECTED at", new Date().toLocaleTimeString());
    // ページを離れるときにサブスクリプションを解除
    this.subscription.unsubscribe()
  }
}