import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import * as wanakana from "wanakana"

export default class extends Controller {
  static targets = ["timer", "input", "form"]
  static values = { roomId: Number }

  connect() {
    this.timeLeft = 30;
    const countdownArea = document.getElementById('countdown-area');
    const gameArea = document.getElementById('game-area');
    if (countdownArea && gameArea) {
      let count = 3;
      countdownArea.textContent = count;
      gameArea.style.display = 'none';
      const interval = setInterval(() => {
        count--;
        if (count > 0) {
          countdownArea.textContent = count;
          countdownArea.style.color = "white"; 
        } else if (count === 0) {
          countdownArea.textContent = 'スタート!';
          countdownArea.style.color = "white"; 
        } else {
          clearInterval(interval);
          countdownArea.style.display = 'none';
          gameArea.style.display = '';
          this.startTimer();
          if (this.hasInputTarget) {
            this.inputTarget.focus();
          }
        }
      }, 1000);
    } else {
      this.startTimer();
      if (this.hasInputTarget) {
        this.inputTarget.focus();
      }
    }
    this.boundHandleGameOver = this.handleGameOver.bind(this);
    document.addEventListener('game:over', this.boundHandleGameOver);
  }

  disconnect() {
    clearInterval(this.timerInterval)
    document.removeEventListener('game:over', this.boundHandleGameOver)
  }

  inputTargetConnected() {
    wanakana.bind(this.inputTarget)
  }

  handleGameOver(event) {
    setTimeout(() => {
      Turbo.visit(event.detail.redirectUrl)
    }, 1500)
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
}