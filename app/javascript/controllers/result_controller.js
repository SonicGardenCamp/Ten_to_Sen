// app/javascript/controllers/result_controller.js

import { Controller } from "@hotwired/stimulus"
// 共有されたAction Cableの接続インスタンスをインポートします
import consumer from "../channels/consumer"

// Stimulusコントローラーを定義します
export default class extends Controller {
  // HTML側から `data-result-room-id-value` という形で渡される値を受け取ります
  static values = { roomId: Number }
  // HTML側で `data-result-target="resultsWrapper"` と指定された要素を操作対象にします
  static targets = ["resultsWrapper"]

  /**
   * このコントローラーがページ上の要素に接続されたときに自動的に呼び出されるメソッドです。
   */
  connect() {
    // 【デバッグ用ログ1】
    // このコントローラーが起動し、正しいルームIDを受け取れているかを確認します。
    // ブラウザのコンソールに "ResultController connected for Room ID: (ルームのID)" と表示されるはずです。
    console.log(`ResultController connected for Room ID: ${this.roomIdValue}`);

    // Action Cableの購読（subscription）を開始します。
    // これにより、サーバーからのリアルタイム通知を受け取れるようになります。
    this.subscription = consumer.subscriptions.create(
      // どのチャンネルを購読するかを指定します。
      // Ruby側の "ResultChannel" に、このルームのIDを渡して接続します。
      { channel: "ResultChannel", room_id: this.roomIdValue },
      {
        /**
         * サーバーからデータがブロードキャストされたときに呼び出されるコールバック関数です。
         * @param {object} data - サーバーから送られてきたデータ（{ results_html: "..." } という形式）
         */
        received: (data) => {
          // 【デバッグ用ログ2】
          // サーバーからデータを受信したことを確認します。
          // AIの評価が終わるたびに、コンソールに "Received data from ResultChannel:" と、
          // サーバーから送られてきたHTMLが表示されるはずです。
          console.log("Received data from ResultChannel:", data);
          
          // `resultsWrapper` ターゲット（ランキング表示エリアのdiv）の中身を、
          // 受け取った新しいHTMLでまるごと更新します。
          this.resultsWrapperTarget.innerHTML = data.results_html
        }
      }
    )
  }

  /**
   * ユーザーがページを離れるなど、コントローラーとの接続が解除されたときに呼び出されるメソッドです。
   */
  disconnect() {
    // サーバーへの不要な接続が残らないように、購読をきれいに解除します。
    this.subscription.unsubscribe()
  }
}