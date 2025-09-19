import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ▼▼▼ 変更点 ▼▼▼
  // HTMLからBGMファイルのパスの配列を受け取る
  static values = {
    files: Array
  }
  // ▲▲▲ 変更点 ▲▲▲

  connect() {
    if (window.BGMManager?.isInitialized) {
      return;
    }
    // ▼▼▼ 変更点 ▼▼▼
    // 受け取ったファイルリストをBGMManagerに渡す
    this.initializeBGMManager(this.filesValue);
    // ▲▲▲ 変更点 ▲▲▲
  }

  // ▼▼▼ 変更点 ▼▼▼
  initializeBGMManager(bgmList = []) {
  // ▲▲▲ 変更点 ▲▲▲
    window.BGMManager = (function() {
      // const bgmList = [ ... ]; // この行は削除

      let currentTrack = 0;
      let isPlaying = false;
      let audioPlayer = null;
      let toggleButton = null;
      let nextButton = null;
      let isInitialized = false;

      function initialize() {
        if (isInitialized) return;

        audioPlayer = document.getElementById('bgm-player');
        toggleButton = document.getElementById('bgm-toggle');
        nextButton = document.getElementById('bgm-next');

        if (!audioPlayer || !toggleButton || !nextButton) {
          return;
        }

        // 読み込むべきBGMがない場合は何もしない
        if (bgmList.length === 0) {
          console.warn("BGM files are not provided.");
          return;
        }

        const savedVolume = localStorage.getItem('bgmVolume') || '0.3';
        const savedMuted = localStorage.getItem('bgmMuted') === 'true';
        const savedTrack = parseInt(localStorage.getItem('bgmCurrentTrack')) || 0;
        const wasPlaying = localStorage.getItem('bgmWasPlaying') === 'true';

        audioPlayer.volume = parseFloat(savedVolume);
        audioPlayer.muted = savedMuted;
        currentTrack = savedTrack;

        setupEventListeners();
        loadTrack(currentTrack);

        if (wasPlaying && !savedMuted) {
          setTimeout(() => startPlayback(), 500);
        }

        updateToggleButton();
        isInitialized = true;
        window.BGMManager.isInitialized = true;
      }

      function setupEventListeners() {
        audioPlayer.addEventListener('ended', () => nextTrack());
        audioPlayer.addEventListener('error', (e) => {
          console.error('Audio error:', e);
        });

        toggleButton.addEventListener('click', () => {
          if (isPlaying && !audioPlayer.muted) {
            audioPlayer.muted = true;
            localStorage.setItem('bgmMuted', 'true');
          } else if (isPlaying && audioPlayer.muted) {
            audioPlayer.muted = false;
            localStorage.setItem('bgmMuted', 'false');
          } else {
            startPlayback();
          }
          updateToggleButton();
        });

        nextButton.addEventListener('click', () => nextTrack());

        audioPlayer.addEventListener('volumechange', () => {
          localStorage.setItem('bgmVolume', audioPlayer.volume.toString());
        });

        audioPlayer.addEventListener('play', () => {
          isPlaying = true;
          localStorage.setItem('bgmWasPlaying', 'true');
          updateToggleButton();
        });

        audioPlayer.addEventListener('pause', () => {
          isPlaying = false;
          localStorage.setItem('bgmWasPlaying', 'false');
          updateToggleButton();
        });
      }

      function loadTrack(index) {
        if (bgmList.length === 0) return;
        currentTrack = index % bgmList.length;
        audioPlayer.src = bgmList[currentTrack];
        localStorage.setItem('bgmCurrentTrack', currentTrack.toString());
      }

      function startPlayback() {
        if (!audioPlayer || !audioPlayer.src) return;
        audioPlayer.muted = false;
        audioPlayer.play().catch(error => {
          console.error('Playback failed:', error);
          isPlaying = false;
        });
      }

      function nextTrack() {
        const wasPlayingBeforeNext = isPlaying && !audioPlayer.muted;
        currentTrack = (currentTrack + 1) % bgmList.length;
        loadTrack(currentTrack);
        if (wasPlayingBeforeNext) {
          audioPlayer.play().catch(console.error);
        }
      }

      function updateToggleButton() {
        if (!toggleButton) return;
        if (audioPlayer.muted || !isPlaying) {
          toggleButton.textContent = '🔇 BGM';
        } else {
          toggleButton.textContent = '🔊 BGM';
        }
      }
      
      window.addEventListener('beforeunload', () => {
        if (audioPlayer && !audioPlayer.paused) {
          localStorage.setItem('bgmWasPlaying', 'true');
        }
      });
      
      document.addEventListener('click', function() {
        const wasPlaying = localStorage.getItem('bgmWasPlaying') === 'true';
        const muted = localStorage.getItem('bgmMuted') === 'true';
        if (wasPlaying && !muted && audioPlayer && audioPlayer.paused) {
          audioPlayer.play().catch(console.error);
        }
      }, { once: true });

      return { initialize };
    })();

    window.BGMManager.initialize();
  }

  disconnect() {
  }
}