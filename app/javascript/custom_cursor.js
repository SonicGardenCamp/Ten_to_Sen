document.addEventListener("DOMContentLoaded", () => {
  // カスタムカーソル本体（SVGで作成）
  const cursorSize = 64;
  const cursorSvgNS = "http://www.w3.org/2000/svg";
  const cursorSvg = document.createElementNS(cursorSvgNS, "svg");
  cursorSvg.setAttribute("width", cursorSize);
  cursorSvg.setAttribute("height", cursorSize);
  cursorSvg.style.position = "fixed";
  cursorSvg.style.pointerEvents = "none";
  cursorSvg.style.zIndex = "9999";
  cursorSvg.style.transform = "translate(-50%, -50%)";
  cursorSvg.style.transition = "filter 0.2s";
  cursorSvg.style.filter = "drop-shadow(0 0 8px #00eaff)";

  // 円の中心（黒）
  const centerCircle = document.createElementNS(cursorSvgNS, "circle");
  centerCircle.setAttribute("cx", cursorSize / 2);
  centerCircle.setAttribute("cy", cursorSize / 2);
  centerCircle.setAttribute("r", cursorSize / 4);
  centerCircle.setAttribute("fill", "none");
  cursorSvg.appendChild(centerCircle);

  // 枠線（円）
  const borderCircle = document.createElementNS(cursorSvgNS, "circle");
  borderCircle.setAttribute("cx", 32);
  borderCircle.setAttribute("cy", 32);
  borderCircle.setAttribute("r", 28);
  borderCircle.setAttribute("stroke", "#00eaff");
  borderCircle.setAttribute("stroke-width", "3");
  borderCircle.setAttribute("fill", "none");
  borderCircle.setAttribute("stroke-dasharray", "20 40");
  cursorSvg.appendChild(borderCircle);

  // 回転アニメーション
  cursorSvg.style.transition = "none";
  let rotateDeg = 0;
  function animateCursor() {
    rotateDeg += 10;
    cursorSvg.style.transform = `translate(-50%, -50%) rotate(${rotateDeg}deg)`;
    requestAnimationFrame(animateCursor);
  }
  animateCursor();

  document.body.appendChild(cursorSvg);

  // SVGで軌跡を描画
  const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  svg.style.position = "fixed";
  svg.style.left = "0";
  svg.style.top = "0";
  svg.style.width = "100vw";
  svg.style.height = "100vh";
  svg.style.pointerEvents = "none";
  svg.style.zIndex = "9998";
  document.body.appendChild(svg);

  let lastX = null;
  let lastY = null;
  let lines = [];

  document.addEventListener('mousemove', e => {
    cursorSvg.style.left = e.clientX + 'px';
    cursorSvg.style.top = e.clientY + 'px';

    if (lastX !== null && lastY !== null) {
      // 線を追加
      const line = document.createElementNS("http://www.w3.org/2000/svg", "line");
      line.setAttribute("x1", lastX);
      line.setAttribute("y1", lastY);
      line.setAttribute("x2", e.clientX);
      line.setAttribute("y2", e.clientY);
      line.setAttribute("stroke", "cyan");
      line.setAttribute("stroke-width", "6");
      line.setAttribute("stroke-linecap", "round");
      line.setAttribute("opacity", "0.5");
      svg.appendChild(line);
      lines.push(line);

      // 線を徐々に消す
      setTimeout(() => {
        line.setAttribute("opacity", "0");
        setTimeout(() => {
          svg.removeChild(line);
        }, 100);
      }, 50);
    }
    lastX = e.clientX;
    lastY = e.clientY;
  });
});