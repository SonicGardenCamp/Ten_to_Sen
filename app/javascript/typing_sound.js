// タイピング音をゲーム中のみ再生する
const typingAudio = new Audio('/assets/sounds/typing.mp3');

document.addEventListener('keydown', (event) => {
  // ゲーム画面（例: .game-areaクラスがbodyにある場合のみ）でのみ再生
  if (!document.body.classList.contains('game-area')) return;
  const active = document.activeElement;
  if (active && (active.tagName === 'INPUT' || active.tagName === 'TEXTAREA')) {
    typingAudio.currentTime = 0;
    typingAudio.play();
  }
});
