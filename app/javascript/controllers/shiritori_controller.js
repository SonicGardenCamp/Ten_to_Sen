// app/javascript/controllers/shiritori_controller.js
import { Controller } from "@hotwired/stimulus"
import * as wanakana from "wanakana"

export default class extends Controller {
  static targets = ["timer", "input", "form"]

  connect() {
    this.timeLeft = 30
    wanakana.bind(this.inputTarget)
    this.startTimer()
    this.inputTarget.focus()
  }

  startTimer() {
    // 既存のタイマーが動いていれば停止する
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }

    this.timerInterval = setInterval(() => {
      this.timeLeft--
      this.timerTarget.textContent = this.timeLeft

      if (this.timeLeft <= 0) {
        this.endGame()
      }
    }, 1000)
  }

  endGame() {
    clearInterval(this.timerInterval)
    this.timerTarget.textContent = "0"
    this.inputTarget.disabled = true
    document.getElementById("game-over-message").classList.remove("d-none")
  }


  resetTimerOnSubmit(event) {
    // フォーム送信が成功した場合のみタイマーをリセット
    if (event.detail.success) {
      this.timeLeft = 30
      this.timerTarget.textContent = this.timeLeft
      this.inputTarget.value = "" // 入力欄をクリア
      this.startTimer() // タイマーを再スタート
    }
  }
}