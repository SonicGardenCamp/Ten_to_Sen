function createStarParticles(x, y) {
  const starSvgNS = "http://www.w3.org/2000/svg";
  const starCount = 3; // 一度に飛ばす星の数
  for (let i = 0; i < starCount; i++) {
    const star = document.createElementNS(starSvgNS, "svg");
    const size = 18 + Math.random() * 24;
    star.setAttribute("width", size);
    star.setAttribute("height", size);
    star.style.position = "fixed";
    star.style.left = `${x - size / 2}px`;
    star.style.top = `${y - size / 2}px`;
    star.style.pointerEvents = "none";
    star.style.zIndex = "10000";
    star.style.opacity = "0.6";

    // ランダムな薄めの色を生成
    const hue = Math.floor(Math.random() * 360);
    const pastelColor = `hsla(${hue}, 80%, 80%, 0.7)`;

    // 星形パス（ランダムな薄めの色）
    const starPath = document.createElementNS(starSvgNS, "path");
    starPath.setAttribute(
      "d",
      "M16 2 L20 12 L31 12 L22 18 L25 28 L16 22 L7 28 L10 18 L1 12 L12 12 Z"
    );
    starPath.setAttribute("fill", pastelColor);
    starPath.setAttribute("stroke-width", "2");
    star.appendChild(starPath);

    document.body.appendChild(star);

    // ランダムな角度・飛距離（差を大きく）
    const angle = Math.random() * 2 * Math.PI;
    const distance = 10 + Math.random() * 1000; // 最小40px～最大280px
    const velocityX = Math.cos(angle) * distance / 60;
    const velocityY = Math.sin(angle) * distance / 60 - 1.2;

    let frame = 0;
    let posX = x - size / 2;
    let posY = y - size / 2;
    let rotate = Math.random() * 360;
    let scale = Math.random()*3;
    let speed = Math.random()*10;

    function animate() {
      frame++;
      posX += velocityX*speed;
      posY += velocityY + (0.1 * frame)*speed; // 重力加算
      scale += 0.01;
      rotate += 8;
      star.style.left = `${posX}px`;
      star.style.top = `${posY}px`;
      star.style.transform = `scale(${scale}) rotate(${rotate}deg)`;
      star.style.opacity -= 0.005;
      if (frame < 60) {
        requestAnimationFrame(animate);
      } else {
        star.remove();
      }
    }
    animate();
  }
}

// show画面でのみキーボード入力時に星を表示
if (window.location.pathname.match(/\/rooms\/\d+$/)) {
  document.addEventListener("keydown", (e) => {
    if (!/^[a-zA-Z]$/.test(e.key)) return;

    const active = document.activeElement;
    if (active && (active.tagName === "INPUT" || active.tagName === "TEXTAREA")) {
      const rect = active.getBoundingClientRect();
      const x = rect.left + rect.width / 2;
      const y = rect.top + rect.height / 2;
      createStarParticles(x, y);
    }
  });
}