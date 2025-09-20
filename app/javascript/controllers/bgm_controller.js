import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["player", "toggleButton"]
  static values = {
    files: Array,
  }

  connect() {
    this.isPlaying = false
    this.currentIndex = 0

    // 再生が終了したら次の曲へ進むイベントリスナーを設定
    this.playerTarget.addEventListener('ended', this.next.bind(this))

    // 自動再生を開始
    this.startPlayback()
  }

  disconnect() {
    // コントローラーがDOMから切り離されたら再生を停止し、イベントリスナーを削除
    this.playerTarget.pause()
    this.playerTarget.removeEventListener('ended', this.next.bind(this))
  }

  // 再生/停止の切り替え
  toggle() {
    if (this.isPlaying) {
      this.playerTarget.pause()
    } else {
      // 停止していた場合は、現在の曲を再生
      this.playCurrentTrack()
    }
    this.isPlaying = !this.isPlaying
    this.updateToggleButton()
  }

  // 次の曲へ
  next() {
    // インデックスを次に進め、リストの最後に到達したら最初に戻る
    this.currentIndex = (this.currentIndex + 1) % this.filesValue.length
    this.playCurrentTrack()
  }

  // 自動再生の開始処理
  startPlayback() {
    // ユーザー操作を待たずに再生しようとするとブラウザにブロックされる可能性があるため、
    // エラーをcatchする
    this.playCurrentTrack().then(() => {
      this.isPlaying = true
      this.updateToggleButton()
    }).catch(error => {
      // 再生がブロックされた場合、isPlayingはfalseのままなので、
      // ユーザーが再生ボタンをクリックするまで待機状態になる
      console.warn("BGMの自動再生がブラウザによってブロックされました。")
      this.isPlaying = false
      this.updateToggleButton()
    })
  }
  
  // 現在のインデックスの曲を再生する
  playCurrentTrack() {
    this.playerTarget.src = this.filesValue[this.currentIndex]
    return this.playerTarget.play() // play()はPromiseを返す
  }

  // 再生ボタンの表示を更新
  updateToggleButton() {
    if (this.isPlaying) {
      this.toggleButtonTarget.textContent = '🔊 BGM'
    } else {
      this.toggleButtonTarget.textContent = '🔇 BGM'
    }
  }
}