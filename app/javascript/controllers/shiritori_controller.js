import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import * as wanakana from "wanakana"

export default class extends Controller {
  static targets = ["timer", "input", "form"]
  static values = { roomId: Number }

  connect() {
    this.timeLeft = 30
    wanakana.bind(this.inputTarget)
    this.startTimer()
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }

  // ↓↓↓↓↓↓ このメソッドを追加してください ↓↓↓↓↓↓
  disconnect() {
    // このコントローラがページから削除される時にタイマーを停止する
    clearInterval(this.timerInterval)
  }

  startTimer() {
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
    if (this.hasInputTarget) {
      this.inputTarget.disabled = true
    }
    Turbo.visit(`/rooms/${this.roomIdValue}/result`)
  }

  checkWord() {
    const word = this.inputTarget.value
    if (word.endsWith('ん')) {
      this.formTarget.dataset.turbo = "false"
    } else {
      this.formTarget.dataset.turbo = "true"
    }
  }
}