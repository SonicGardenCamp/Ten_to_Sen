import { Controller } from "@hotwired/stimulus"

// 警告メッセージなどを自動で削除するコントローラ
export default class extends Controller {
  connect() {
    // 3秒（3000ミリ秒）後に remove メソッドを実行する
    this.timeout = setTimeout(() => {
      this.remove()
    }, 3000)
  }

  disconnect() {
    // 要素が消える前にタイマーを止める（念のため）
    clearTimeout(this.timeout)
  }

  remove() {
    this.element.remove()
  }
}