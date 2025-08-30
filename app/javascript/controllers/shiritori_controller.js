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

  disconnect() {
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
    // endGameは後のステップで完成させます
  }
}