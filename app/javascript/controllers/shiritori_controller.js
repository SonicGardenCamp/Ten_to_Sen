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
}