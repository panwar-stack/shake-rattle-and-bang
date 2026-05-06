// ===== LEVELS & ASSETS (Sections 4, 5, 6) =====

// ========== SECTION 4: AUDIO SYSTEM ==========

let audioCtx;
let soundBuffers = {};
let bossMusicNode = null;
let bossMusicGain = null;

function initAudio() {
  try {
    audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  } catch (e) {
    console.warn('Web Audio API not available');
    return;
  }

  soundBuffers.jump    = createToneBuffer(audioCtx, [[200, 0.08], [600, 0.08]], 0.16, 'sine');
  soundBuffers.coin    = createToneBuffer(audioCtx, [[523, 0.05], [659, 0.05]], 0.1, 'square');
  soundBuffers.stomp   = createToneBuffer(audioCtx, [[80, 0.12]], 0.12, 'square');
  soundBuffers.hurt    = createNoiseBuffer(audioCtx, 0.15);
  soundBuffers.powerup = createToneBuffer(audioCtx, [[523, 0.08], [659, 0.08], [784, 0.08], [1047, 0.15]], 0.4, 'sine');
  soundBuffers.checkpoint = createToneBuffer(audioCtx, [[523, 0.08], [659, 0.08], [784, 0.15]], 0.3, 'triangle');
  soundBuffers.levelComplete = createToneBuffer(audioCtx, [[523, 0.1], [659, 0.1], [784, 0.1], [1047, 0.3]], 0.6, 'triangle');
  soundBuffers.gameOver = createToneBuffer(audioCtx, [[400, 0.2], [300, 0.2], [200, 0.5]], 0.9, 'sawtooth');
  soundBuffers.victory  = createToneBuffer(audioCtx, [[523, 0.15], [659, 0.15], [784, 0.15], [1047, 0.15], [1318, 0.4]], 1.0, 'sine');
  soundBuffers.fireball = createNoiseBuffer(audioCtx, 0.2);
  soundBuffers.bossHit  = createToneBuffer(audioCtx, [[100, 0.15], [60, 0.2]], 0.35, 'sawtooth');
  soundBuffers.doubleJump = createToneBuffer(audioCtx, [[400, 0.06], [800, 0.06]], 0.12, 'sine');
  soundBuffers.extraLife  = createToneBuffer(audioCtx, [[523, 0.08], [659, 0.08], [784, 0.08], [1047, 0.2]], 0.45, 'sine');
  soundBuffers.boneThrow  = createToneBuffer(audioCtx, [[150, 0.1]], 0.1, 'square');
  soundBuffers.charge     = createToneBuffer(audioCtx, [[60, 0.2], [80, 0.2], [100, 0.2]], 0.6, 'sawtooth');
}

function playSound(name) {
  if (!audioCtx || !soundBuffers[name]) return;
  try {
    const source = audioCtx.createBufferSource();
    source.buffer = soundBuffers[name];
    source.connect(audioCtx.destination);
    source.start(0);
  } catch (e) {
    // ignore audio errors
  }
}

function createToneBuffer(ctx, segments, totalDuration, waveType) {
  const sampleRate = ctx.sampleRate;
  const length = Math.floor(sampleRate * totalDuration);
  const buffer = ctx.createBuffer(1, length, sampleRate);
  const data = buffer.getChannelData(0);
  let pos = 0;

  for (const seg of segments) {
    const freq = seg[0];
    const dur = seg[1];
    const segLen = Math.floor(sampleRate * dur);
    for (let i = 0; i < segLen && pos < length; i++, pos++) {
      const t = i / sampleRate;
      let sample = 0;
      switch (waveType) {
        case 'sine':     sample = Math.sin(2 * Math.PI * freq * t); break;
        case 'square':   sample = Math.sin(2 * Math.PI * freq * t) > 0 ? 0.5 : -0.5; break;
        case 'triangle': sample = 2 * Math.abs(2 * (t * freq - Math.floor(t * freq + 0.5))) - 0.5; break;
        case 'sawtooth': sample = 2 * (t * freq - Math.floor(t * freq)) - 1; break;
        default: sample = Math.sin(2 * Math.PI * freq * t); break;
      }
      const envPos = pos / length;
      const env = Math.min(envPos * 10, 1) * Math.max(0, 1 - (envPos - 0.7) * 3.33);
      data[pos] = sample * env * 0.3;
    }
  }
  return buffer;
}

function createNoiseBuffer(ctx, duration) {
  const sampleRate = ctx.sampleRate;
  const length = Math.floor(sampleRate * duration);
  const buffer = ctx.createBuffer(1, length, sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < length; i++) {
    data[i] = (Math.random() * 2 - 1) * 0.3 * Math.max(0, 1 - i / length);
  }
  return buffer;
}

function startBossMusic() {
  if (!audioCtx) return;
  stopBossMusic();

  bossMusicNode = audioCtx.createOscillator();
  bossMusicGain = audioCtx.createGain();
  bossMusicGain.gain.value = 0.08;
  bossMusicNode.type = 'sawtooth';
  bossMusicNode.frequency.value = 110;
  bossMusicNode.connect(bossMusicGain);
  bossMusicGain.connect(audioCtx.destination);

  // Create a slow tremolo by modulating frequency with an LFO
  const lfo = audioCtx.createOscillator();
  const lfoGain = audioCtx.createGain();
  lfo.frequency.value = 3;
  lfoGain.gain.value = 20;
  lfo.connect(lfoGain);
  lfoGain.connect(bossMusicNode.frequency);
  lfo.start();
  bossMusicNode._lfo = lfo;
  bossMusicNode._lfoGain = lfoGain;

  bossMusicNode.start();
}

function stopBossMusic() {
  if (bossMusicNode) {
    try {
      if (bossMusicNode._lfo) {
        bossMusicNode._lfo.stop();
        bossMusicNode._lfo.disconnect();
      }
      if (bossMusicNode._lfoGain) {
        bossMusicNode._lfoGain.disconnect();
      }
      bossMusicNode.stop();
      bossMusicNode.disconnect();
      if (bossMusicGain) bossMusicGain.disconnect();
    } catch (e) { /* ignore */ }
    bossMusicNode = null;
    bossMusicGain = null;
  }
}


// ========== SECTION 5: SPRITE DRAWING ==========

// -- Player Sprite --
function drawPlayerSprite(ctx, x, y, w, h, facing, frame, state, invincible, flashOn) {
  ctx.save();

  // Invincibility flash
  if (invincible && flashOn) {
    if (invincibleCycle === undefined) {
      // rely on caller passing flashOn to toggle visibility
      ctx.globalAlpha = 0.5;
    }
  }

  const cx = x + w / 2;
  const cy = y + h / 2;

  // Color cycle for invincible powerup
  if (invincible) {
    const hue = (Date.now() / 5) % 360;
    ctx.fillStyle = 'hsl(' + hue + ', 80%, 50%)';
  } else {
    ctx.fillStyle = '#3366FF';
  }

  // Body
  const bodyH = (state === 'dead') ? h * 0.35 : h * 0.55;
  const bodyY = y + h * 0.25;
  roundRect(ctx, x + 2, bodyY, w - 4, bodyH, 3);
  ctx.fill();

  // Dead state: X shape
  if (state === 'dead') {
    ctx.strokeStyle = '#FF4444';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(x + 4, y + 4);
    ctx.lineTo(x + w - 4, y + h - 4);
    ctx.moveTo(x + w - 4, y + 4);
    ctx.lineTo(x + 4, y + h - 4);
    ctx.stroke();
    ctx.restore();
    return;
  }

  // Hat
  ctx.fillStyle = '#FF3333';
  ctx.fillRect(x + 2, y + h * 0.1, w - 4, h * 0.18);
  ctx.fillRect(x + w * 0.15, y, w * 0.7, h * 0.15);

  // Eyes
  const eyeSize = w * 0.2;
  const eyeY = bodyY + bodyH * 0.2;
  const pupilDir = facing === 1 ? 2 : -2;

  ctx.fillStyle = '#FFF';
  ctx.fillRect(cx - w * 0.22 + pupilDir, eyeY, eyeSize, eyeSize);
  ctx.fillRect(cx + w * 0.02 + pupilDir, eyeY, eyeSize, eyeSize);

  // Pupils
  ctx.fillStyle = '#000';
  ctx.fillRect(cx - w * 0.22 + pupilDir + 2, eyeY + 1, eyeSize * 0.45, eyeSize * 0.45);
  ctx.fillRect(cx + w * 0.02 + pupilDir + 2, eyeY + 1, eyeSize * 0.45, eyeSize * 0.45);

  // Arms
  const armW = w * 0.15;
  const armH = bodyH * 0.45;
  const armY = bodyY + bodyH * 0.1;
  if (state === 'jump' || state === 'fall') {
    // Arms up
    ctx.fillStyle = invincible ? ctx.fillStyle : '#2255CC';
    ctx.fillRect(x, armY - bodyH * 0.2, armW, armH);
    ctx.fillRect(x + w - armW, armY - bodyH * 0.2, armW, armH);
  } else {
    ctx.fillStyle = invincible ? ctx.fillStyle : '#2255CC';
    ctx.fillRect(x, armY + bodyH * 0.1, armW, armH);
    ctx.fillRect(x + w - armW, armY + bodyH * 0.1, armW, armH);
  }

  // Legs
  ctx.fillStyle = invincible ? ctx.fillStyle : '#2255CC';
  const legW = w * 0.2;
  const legBaseY = bodyY + bodyH;
  const legH = h - legBaseY;

  if (state === 'jump' || state === 'fall') {
    // Legs tucked
    ctx.fillRect(x + 4, legBaseY, legW, legH * 0.5);
    ctx.fillRect(x + w - 4 - legW, legBaseY, legW, legH * 0.5);
  } else if (state === 'walk') {
    const walkFrame = frame % 4;
    const legOffsets = [[0, legH * 0.3], [legH * 0.3, 0], [legH * 0.7, 0], [0, legH * 0.7]];
    ctx.fillRect(x + 4, legBaseY + legOffsets[walkFrame][0], legW, legH - legOffsets[walkFrame][0]);
    ctx.fillRect(x + w - 4 - legW, legBaseY + legOffsets[walkFrame][1], legW, legH - legOffsets[walkFrame][1]);
  } else {
    // Idle legs
    ctx.fillRect(x + 4, legBaseY, legW, legH);
    ctx.fillRect(x + w - 4 - legW, legBaseY, legW, legH);
  }

  ctx.restore();
}

// -- Slime Sprite --
function drawSlimeSprite(ctx, x, y, w, h, frame) {
  const squish = (frame % 2 === 0) ? 1 : 0;
  const hMod = h - squish * 3;
  const wMod = w + squish * 3;

  ctx.save();
  // Shadow
  ctx.fillStyle = 'rgba(0,0,0,0.2)';
  ctx.beginPath();
  ctx.ellipse(x + w / 2, y + h - 3, w * 0.4, 3, 0, 0, Math.PI * 2);
  ctx.fill();

  // Body - green blob wider at bottom
  ctx.fillStyle = '#44CC44';
  ctx.beginPath();
  ctx.moveTo(x + wMod * 0.25, y + hMod);
  ctx.quadraticCurveTo(x, y + hMod * 0.5, x + wMod * 0.15, y + hMod * 0.3);
  ctx.quadraticCurveTo(x + wMod * 0.05, y, x + wMod * 0.5, y);
  ctx.quadraticCurveTo(x + wMod * 0.95, y, x + wMod * 0.85, y + hMod * 0.3);
  ctx.quadraticCurveTo(x + wMod, y + hMod * 0.5, x + wMod * 0.75, y + hMod);
  ctx.closePath();
  ctx.fill();

  // Highlight
  ctx.fillStyle = 'rgba(255,255,255,0.25)';
  ctx.beginPath();
  ctx.ellipse(x + w * 0.35, y + h * 0.35, w * 0.2, h * 0.15, 0, 0, Math.PI * 2);
  ctx.fill();

  // Eyes
  ctx.fillStyle = '#FFF';
  ctx.beginPath();
  ctx.arc(x + w * 0.3, y + h * 0.35, w * 0.12, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(x + w * 0.7, y + h * 0.35, w * 0.12, 0, Math.PI * 2);
  ctx.fill();

  // Pupils
  ctx.fillStyle = '#000';
  ctx.beginPath();
  ctx.arc(x + w * 0.3, y + h * 0.36, w * 0.06, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(x + w * 0.7, y + h * 0.36, w * 0.06, 0, Math.PI * 2);
  ctx.fill();

  ctx.restore();
}

// -- Bat Sprite --
function drawBatSprite(ctx, x, y, w, h, frame) {
  ctx.save();

  // Body
  ctx.fillStyle = '#8844CC';
  ctx.beginPath();
  ctx.ellipse(x + w / 2, y + h / 2, w * 0.2, h * 0.25, 0, 0, Math.PI * 2);
  ctx.fill();

  // Wings - flap based on frame
  const wingPhase = frame % 4;
  let wingAngleUp, wingAngleDown;
  if (wingPhase === 0) { wingAngleUp = -0.4; wingAngleDown = 0.5; }
  else if (wingPhase === 1) { wingAngleUp = -0.1; wingAngleDown = 0.2; }
  else if (wingPhase === 2) { wingAngleUp = -0.4; wingAngleDown = 0.5; }
  else { wingAngleUp = -0.7; wingAngleDown = 0.8; }

  ctx.fillStyle = '#7733AA';
  // Left wing
  ctx.beginPath();
  ctx.moveTo(x + w / 2 - w * 0.15, y + h / 2 - h * 0.1);
  ctx.lineTo(x, y + h * 0.15 + wingAngleUp * h * 0.4);
  ctx.lineTo(x + w * 0.05, y + h * 0.3);
  ctx.lineTo(x, y + h * 0.5 + wingAngleDown * h * 0.4);
  ctx.lineTo(x + w / 2 - w * 0.15, y + h / 2 + h * 0.1);
  ctx.closePath();
  ctx.fill();

  // Right wing
  ctx.beginPath();
  ctx.moveTo(x + w / 2 + w * 0.15, y + h / 2 - h * 0.1);
  ctx.lineTo(x + w, y + h * 0.15 + wingAngleUp * h * 0.4);
  ctx.lineTo(x + w - w * 0.05, y + h * 0.3);
  ctx.lineTo(x + w, y + h * 0.5 + wingAngleDown * h * 0.4);
  ctx.lineTo(x + w / 2 + w * 0.15, y + h / 2 + h * 0.1);
  ctx.closePath();
  ctx.fill();

  // Eyes
  ctx.fillStyle = '#FF4444';
  ctx.beginPath();
  ctx.arc(x + w * 0.38, y + h * 0.4, w * 0.06, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(x + w * 0.62, y + h * 0.4, w * 0.06, 0, Math.PI * 2);
  ctx.fill();

  // Ear points
  ctx.fillStyle = '#8844CC';
  ctx.beginPath();
  ctx.moveTo(x + w * 0.42, y + h * 0.2);
  ctx.lineTo(x + w * 0.35, y);
  ctx.lineTo(x + w * 0.48, y + h * 0.2);
  ctx.fill();
  ctx.beginPath();
  ctx.moveTo(x + w * 0.58, y + h * 0.2);
  ctx.lineTo(x + w * 0.65, y);
  ctx.lineTo(x + w * 0.52, y + h * 0.2);
  ctx.fill();

  ctx.restore();
}

// -- Skeleton Sprite --
function drawSkeletonSprite(ctx, x, y, w, h, frame) {
  ctx.save();

  // Skull
  ctx.fillStyle = '#DDD';
  ctx.beginPath();
  ctx.arc(x + w / 2, y + h * 0.15, w * 0.22, 0, Math.PI * 2);
  ctx.fill();

  // Skull outline
  ctx.strokeStyle = '#999';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.arc(x + w / 2, y + h * 0.15, w * 0.22, 0, Math.PI * 2);
  ctx.stroke();

  // Eye sockets
  ctx.fillStyle = '#000';
  ctx.beginPath();
  ctx.arc(x + w * 0.4, y + h * 0.13, w * 0.06, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(x + w * 0.6, y + h * 0.13, w * 0.06, 0, Math.PI * 2);
  ctx.fill();

  // Nose hole
  ctx.beginPath();
  ctx.moveTo(x + w * 0.48, y + h * 0.18);
  ctx.lineTo(x + w * 0.5, y + h * 0.21);
  ctx.lineTo(x + w * 0.52, y + h * 0.18);
  ctx.fill();

  // Jaw
  ctx.fillStyle = '#CCC';
  ctx.fillRect(x + w * 0.32, y + h * 0.22, w * 0.36, h * 0.08);

  // Spine
  ctx.fillStyle = '#BBB';
  const spine = h * 0.12;
  ctx.fillRect(x + w / 2 - 2, y + h * 0.28, 4, h * 0.12);

  // Ribs
  const ribY = y + h * 0.35;
  ctx.strokeStyle = '#BBB';
  ctx.lineWidth = 2;
  for (let i = 0; i < 3; i++) {
    const ribOffset = i * h * 0.08;
    ctx.beginPath();
    ctx.moveTo(x + w / 2, ribY + ribOffset);
    ctx.lineTo(x + w * 0.25, ribY + ribOffset + h * 0.02);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(x + w / 2, ribY + ribOffset);
    ctx.lineTo(x + w * 0.75, ribY + ribOffset + h * 0.02);
    ctx.stroke();
  }

  // Pelvis
  ctx.fillStyle = '#CCC';
  ctx.fillRect(x + w * 0.3, y + h * 0.55, w * 0.4, h * 0.08);

  // Arms
  const armTop = y + h * 0.32;
  const armLen = h * 0.25;
  const armOffset = frame % 4 < 2 ? -1 : 1;
  ctx.strokeStyle = '#BBB';
  ctx.lineWidth = 3;
  // Left arm
  ctx.beginPath();
  ctx.moveTo(x + w * 0.2, armTop);
  ctx.lineTo(x + w * 0.08, armTop + armLen * 0.6 + armOffset * 3);
  ctx.lineTo(x + w * 0.1, armTop + armLen + armOffset * 3);
  ctx.stroke();
  // Right arm
  ctx.beginPath();
  ctx.moveTo(x + w * 0.8, armTop);
  ctx.lineTo(x + w * 0.92, armTop + armLen * 0.6 - armOffset * 3);
  ctx.lineTo(x + w * 0.9, armTop + armLen - armOffset * 3);
  ctx.stroke();

  // Legs
  const legTop = y + h * 0.62;
  const legLen = h * 0.35;
  const legOffsets = [[0, 0], [4, -4], [0, -2], [-4, 4]];
  const lf = frame % 4;

  ctx.beginPath();
  ctx.moveTo(x + w * 0.35, legTop);
  ctx.lineTo(x + w * 0.3 + legOffsets[lf][0] * 0.5, legTop + legLen * 0.5 + legOffsets[lf][0]);
  ctx.lineTo(x + w * 0.28 + legOffsets[lf][0] * 0.5, legTop + legLen + legOffsets[lf][0]);
  ctx.stroke();

  ctx.beginPath();
  ctx.moveTo(x + w * 0.65, legTop);
  ctx.lineTo(x + w * 0.7 - legOffsets[lf][1] * 0.5, legTop + legLen * 0.5 - legOffsets[lf][1]);
  ctx.lineTo(x + w * 0.72 - legOffsets[lf][1] * 0.5, legTop + legLen - legOffsets[lf][1]);
  ctx.stroke();

  ctx.restore();
}

// -- Ghost Sprite --
function drawGhostSprite(ctx, x, y, w, h, frame, opacity) {
  ctx.save();
  ctx.globalAlpha = opacity || 0.7;

  // Body shape
  ctx.fillStyle = 'rgba(200, 200, 255, 1)';

  ctx.beginPath();
  // Rounded top
  ctx.arc(x + w / 2, y + h * 0.3, w * 0.4, Math.PI, 0);
  // Sides
  ctx.lineTo(x + w - w * 0.08, y + h * 0.8);
  // Wavy bottom
  for (var i = 0; i < 4; i++) {
    var waveX = x + w - w * 0.08 - (i * w * 0.23);
    var waveY = y + h * 0.8 + ((i % 2 === 0) ? h * 0.12 : 0);
    ctx.lineTo(waveX - w * 0.12, waveY);
  }
  ctx.lineTo(x + w * 0.08, y + h * 0.8);
  ctx.closePath();
  ctx.fill();

  // Eyes
  ctx.fillStyle = '#334';
  ctx.beginPath();
  ctx.arc(x + w * 0.33, y + h * 0.3, w * 0.08, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(x + w * 0.67, y + h * 0.3, w * 0.08, 0, Math.PI * 2);
  ctx.fill();

  // Eye highlights
  ctx.fillStyle = '#FFF';
  ctx.beginPath();
  ctx.arc(x + w * 0.35, y + h * 0.28, w * 0.03, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(x + w * 0.69, y + h * 0.28, w * 0.03, 0, Math.PI * 2);
  ctx.fill();

  // Mouth
  ctx.strokeStyle = '#334';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.arc(x + w / 2, y + h * 0.42, w * 0.12, 0, Math.PI);
  ctx.stroke();

  ctx.restore();
}

// -- Boss Sprite --
function drawBossSprite(ctx, x, y, w, h, phase, frame, flashOn) {
  ctx.save();

  if (flashOn) {
    ctx.globalAlpha = 0.5;
  }

  // Body
  var bodyColor = '#FF4444';
  if (phase === 3) bodyColor = '#FF2222';
  else if (phase === 2) bodyColor = '#FF3333';

  ctx.fillStyle = bodyColor;
  roundRect(ctx, x + w * 0.15, y + h * 0.3, w * 0.7, h * 0.55, 6);
  ctx.fill();

  // Body outline
  ctx.strokeStyle = '#990000';
  ctx.lineWidth = 2;
  roundRect(ctx, x + w * 0.15, y + h * 0.3, w * 0.7, h * 0.55, 6);
  ctx.stroke();

  // Phase 3 cracks
  if (phase === 3) {
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(x + w * 0.35, y + h * 0.35);
    ctx.lineTo(x + w * 0.5, y + h * 0.5);
    ctx.lineTo(x + w * 0.45, y + h * 0.65);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(x + w * 0.65, y + h * 0.4);
    ctx.lineTo(x + w * 0.55, y + h * 0.55);
    ctx.lineTo(x + w * 0.6, y + h * 0.7);
    ctx.stroke();
  }

  // Head
  ctx.fillStyle = bodyColor;
  ctx.beginPath();
  ctx.arc(x + w / 2, y + h * 0.22, w * 0.22, 0, Math.PI * 2);
  ctx.fill();
  ctx.strokeStyle = '#990000';
  ctx.beginPath();
  ctx.arc(x + w / 2, y + h * 0.22, w * 0.22, 0, Math.PI * 2);
  ctx.stroke();

  // Horns - grow with phase
  var hornH = h * (0.15 + phase * 0.06);
  var hornW = w * (0.04 + phase * 0.02);
  ctx.fillStyle = '#CCCCCC';
  ctx.beginPath();
  ctx.moveTo(x + w * 0.38, y + h * 0.15);
  ctx.lineTo(x + w * 0.35, y + h * 0.15 - hornH);
  ctx.lineTo(x + w * 0.42, y + h * 0.15);
  ctx.fill();
  ctx.beginPath();
  ctx.moveTo(x + w * 0.62, y + h * 0.15);
  ctx.lineTo(x + w * 0.65, y + h * 0.15 - hornH);
  ctx.lineTo(x + w * 0.58, y + h * 0.15);
  ctx.fill();

  // Eyes
  var eyeColor = phase >= 2 ? '#FFFF00' : '#FFF';
  var eyeGlow = phase >= 2;
  if (eyeGlow) {
    ctx.fillStyle = 'rgba(255,255,0,0.3)';
    ctx.beginPath();
    ctx.arc(x + w * 0.4, y + h * 0.2, w * 0.1, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(x + w * 0.6, y + h * 0.2, w * 0.1, 0, Math.PI * 2);
    ctx.fill();
  }

  ctx.fillStyle = eyeColor;
  ctx.beginPath();
  ctx.arc(x + w * 0.4, y + h * 0.2, w * 0.06, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(x + w * 0.6, y + h * 0.2, w * 0.06, 0, Math.PI * 2);
  ctx.fill();

  // Pupils
  ctx.fillStyle = '#000';
  ctx.beginPath();
  ctx.arc(x + w * 0.4, y + h * 0.2, w * 0.03, 0, Math.PI * 2);
  ctx.fill();
  ctx.beginPath();
  ctx.arc(x + w * 0.6, y + h * 0.2, w * 0.03, 0, Math.PI * 2);
  ctx.fill();

  // Mouth - wider with phase
  var mouthW = w * (0.08 + phase * 0.04);
  ctx.fillStyle = '#000';
  ctx.beginPath();
  ctx.arc(x + w / 2, y + h * 0.28, mouthW, 0, Math.PI);
  ctx.fill();

  // Teeth
  ctx.fillStyle = '#FFF';
  for (var ti = 0; ti < 3; ti++) {
    var tx = x + w / 2 - mouthW + mouthW * 0.3 + ti * mouthW * 0.4;
    ctx.fillRect(tx - 2, y + h * 0.28 - 2, 4, 5);
  }

  // Arms
  var armYOff = (frame % 2 === 0) ? 0 : 3;
  ctx.fillStyle = '#FF3333';
  ctx.beginPath();
  ctx.moveTo(x + w * 0.18, y + h * 0.4);
  ctx.lineTo(x + w * 0.05, y + h * 0.55 + armYOff);
  ctx.lineTo(x + w * 0.1, y + h * 0.6 + armYOff);
  ctx.lineTo(x + w * 0.2, y + h * 0.5);
  ctx.fill();

  ctx.beginPath();
  ctx.moveTo(x + w * 0.82, y + h * 0.4);
  ctx.lineTo(x + w * 0.95, y + h * 0.55 - armYOff);
  ctx.lineTo(x + w * 0.9, y + h * 0.6 - armYOff);
  ctx.lineTo(x + w * 0.8, y + h * 0.5);
  ctx.fill();

  // Feet
  ctx.fillStyle = '#CC2222';
  ctx.fillRect(x + w * 0.2, y + h * 0.82, w * 0.25, h * 0.15);
  ctx.fillRect(x + w * 0.55, y + h * 0.82, w * 0.25, h * 0.15);

  ctx.restore();
}

// -- Coin Sprite --
function drawCoinSprite(ctx, x, y, size, frame) {
  ctx.save();
  var cx = x + size / 2;
  var cy = y + size / 2;

  // Spinning animation: width oscillates
  var spinCos = Math.cos(frame * 0.15);
  var scaleX = Math.abs(spinCos);
  var scaleXClip = Math.max(0.15, scaleX);

  ctx.fillStyle = '#FFD700';
  ctx.beginPath();
  ctx.ellipse(cx, cy, size * 0.4 * scaleXClip, size * 0.4, 0, 0, Math.PI * 2);
  ctx.fill();

  // Edge highlight
  ctx.strokeStyle = '#B8860B';
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.ellipse(cx, cy, size * 0.4 * scaleXClip, size * 0.4, 0, 0, Math.PI * 2);
  ctx.stroke();

  // Inner circle
  ctx.strokeStyle = 'rgba(184, 134, 11, 0.5)';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.ellipse(cx, cy, size * 0.28 * scaleXClip, size * 0.28, 0, 0, Math.PI * 2);
  ctx.stroke();

  // Dollar sign or center dot
  ctx.fillStyle = '#B8860B';
  ctx.beginPath();
  ctx.arc(cx, cy, size * 0.08, 0, Math.PI * 2);
  ctx.fill();

  // When flat (side-view), draw thin line
  if (scaleXClip < 0.3) {
    ctx.strokeStyle = '#B8860B';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(cx, y + 2);
    ctx.lineTo(cx, y + size - 2);
    ctx.stroke();
  }

  ctx.restore();
}

// -- Powerup Sprite --
function drawPowerupSprite(ctx, x, y, size, type, frame) {
  ctx.save();
  var cx = x + size / 2;
  var cy = y + size / 2;
  var bob = Math.sin(frame * 0.08) * 3;
  cy += bob;

  // Glow aura
  var glowColor;
  switch (type) {
    case 'speed': glowColor = 'rgba(68, 68, 255, 0.3)'; break;
    case 'invincible': glowColor = 'rgba(255, 0, 255, 0.3)'; break;
    case 'doubleJump': glowColor = 'rgba(255, 255, 255, 0.3)'; break;
    case 'extraLife': glowColor = 'rgba(255, 68, 68, 0.3)'; break;
    default: glowColor = 'rgba(255, 255, 255, 0.3)';
  }
  ctx.fillStyle = glowColor;
  ctx.beginPath();
  ctx.arc(cx, cy, size * 0.42, 0, Math.PI * 2);
  ctx.fill();

  // Background circle
  ctx.fillStyle = '#222';
  ctx.strokeStyle = '#FFF';
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.arc(cx, cy, size * 0.35, 0, Math.PI * 2);
  ctx.fill();
  ctx.stroke();

  switch (type) {
    case 'speed':
      // Lightning bolt
      ctx.fillStyle = '#4488FF';
      ctx.beginPath();
      ctx.moveTo(cx + size * 0.05, cy - size * 0.25);
      ctx.lineTo(cx - size * 0.08, cy - size * 0.03);
      ctx.lineTo(cx + size * 0.03, cy - size * 0.03);
      ctx.lineTo(cx - size * 0.12, cy + size * 0.25);
      ctx.lineTo(cx + size * 0.05, cy + size * 0.03);
      ctx.lineTo(cx - size * 0.05, cy + size * 0.03);
      ctx.lineTo(cx + size * 0.1, cy - size * 0.25);
      ctx.closePath();
      ctx.fill();
      break;

    case 'invincible':
      // Rainbow star
      var hues = [0, 60, 120, 180, 240, 300];
      var starPoints = 6;
      var outerR = size * 0.28;
      var innerR = size * 0.13;
      for (var s = 0; s < starPoints; s++) {
        ctx.fillStyle = 'hsl(' + ((frame * 5 + s * 60) % 360) + ', 100%, 50%)';
        ctx.beginPath();
        var a1 = (s / starPoints) * Math.PI * 2 - Math.PI / 2;
        var a2 = ((s + 0.5) / starPoints) * Math.PI * 2 - Math.PI / 2;
        var a3 = ((s + 1) / starPoints) * Math.PI * 2 - Math.PI / 2;
        ctx.moveTo(cx, cy);
        ctx.lineTo(cx + Math.cos(a1) * outerR, cy + Math.sin(a1) * outerR);
        ctx.lineTo(cx + Math.cos(a2) * innerR, cy + Math.sin(a2) * innerR);
        ctx.lineTo(cx + Math.cos(a3) * outerR, cy + Math.sin(a3) * outerR);
        ctx.closePath();
        ctx.fill();
      }
      break;

    case 'doubleJump':
      // Wing/feather shape
      ctx.fillStyle = '#FFF';
      ctx.beginPath();
      ctx.moveTo(cx - size * 0.05, cy + size * 0.2);
      ctx.quadraticCurveTo(cx - size * 0.25, cy + size * 0.1, cx - size * 0.28, cy);
      ctx.quadraticCurveTo(cx - size * 0.2, cy - size * 0.15, cx - size * 0.05, cy - size * 0.1);
      ctx.quadraticCurveTo(cx + size * 0.1, cy - size * 0.25, cx + size * 0.22, cy - size * 0.1);
      ctx.quadraticCurveTo(cx + size * 0.15, cy + size * 0.1, cx + size * 0.05, cy + size * 0.2);
      ctx.closePath();
      ctx.fill();
      // Feather lines
      ctx.strokeStyle = '#CCC';
      ctx.lineWidth = 0.5;
      for (var fl = 0; fl < 3; fl++) {
        ctx.beginPath();
        ctx.moveTo(cx - size * 0.05, cy + size * 0.1 + fl * 3);
        ctx.lineTo(cx + size * 0.12, cy - size * 0.1 + fl * 5);
        ctx.stroke();
      }
      break;

    case 'extraLife':
      // Heart
      ctx.fillStyle = '#FF4444';
      ctx.beginPath();
      ctx.moveTo(cx, cy + size * 0.2);
      ctx.bezierCurveTo(cx - size * 0.3, cy, cx - size * 0.3, cy - size * 0.25, cx, cy - size * 0.05);
      ctx.bezierCurveTo(cx + size * 0.3, cy - size * 0.25, cx + size * 0.3, cy, cx, cy + size * 0.2);
      ctx.fill();
      // +1 text
      ctx.fillStyle = '#FFF';
      ctx.font = (size * 0.4) + 'px monospace';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('+1', cx, cy + size * 0.18);
      break;
  }

  ctx.restore();
}

// -- Tile Drawing --
function drawTile(ctx, type, col, row, sx, sy) {
  var x = sx || 0;
  var y = sy || 0;

  if (x + TILE_SIZE < -TILE_SIZE || x > CANVAS_WIDTH + TILE_SIZE) return;
  if (y + TILE_SIZE < -TILE_SIZE || y > CANVAS_HEIGHT + TILE_SIZE) return;

  ctx.save();

  switch (type) {
    case TILE.DIRT:
      // Brown base
      ctx.fillStyle = '#8B5E3C';
      ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
      // Grid lines
      ctx.strokeStyle = '#6B3E1C';
      ctx.lineWidth = 0.5;
      ctx.strokeRect(x + 0.5, y + 0.5, TILE_SIZE - 1, TILE_SIZE - 1);
      ctx.beginPath();
      ctx.moveTo(x + TILE_SIZE / 2, y);
      ctx.lineTo(x + TILE_SIZE / 2, y + TILE_SIZE);
      ctx.moveTo(x, y + TILE_SIZE / 2);
      ctx.lineTo(x + TILE_SIZE, y + TILE_SIZE / 2);
      ctx.stroke();
      // Grass tuft on top if air above
      if (row > 0 && level && level.tiles[row] && level.tiles[row - 1] &&
          PASSABLE_SET.has(level.tiles[row - 1][col])) {
        ctx.fillStyle = '#4CAF50';
        for (var ti = 0; ti < 3; ti++) {
          var tx = x + 8 + ti * 10;
          ctx.fillRect(tx, y - 2, 3, 6 + (ti % 2) * 3);
        }
      }
      break;

    case TILE.STONE:
      ctx.fillStyle = '#808080';
      ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
      // Brick pattern mortar lines
      ctx.strokeStyle = '#606060';
      ctx.lineWidth = 1;
      var isOffsetRow = (row % 2 === 0);
      for (var br = 0; br < TILE_SIZE; br += 8) {
        ctx.beginPath();
        ctx.moveTo(x, y + br);
        ctx.lineTo(x + TILE_SIZE, y + br);
        ctx.stroke();
        if (br % 16 === 0) {
          for (var bc = (isOffsetRow ? 0 : 16); bc < TILE_SIZE; bc += 32) {
            ctx.beginPath();
            ctx.moveTo(x + bc, y + br);
            ctx.lineTo(x + bc, y + br + 8);
            ctx.stroke();
          }
        }
      }
      break;

    case TILE.CLOUD:
      // White fill
      ctx.fillStyle = '#F5F5FF';
      roundRect(ctx, x + 2, y + 2, TILE_SIZE - 4, TILE_SIZE - 4, 6);
      ctx.fill();
      // Faint blue shadow offset
      ctx.fillStyle = 'rgba(180, 200, 220, 0.3)';
      roundRect(ctx, x + 4, y + 4, TILE_SIZE - 4, TILE_SIZE - 4, 6);
      ctx.fill();
      // Main white on top
      ctx.fillStyle = '#F8F8FF';
      roundRect(ctx, x + 1, y + 1, TILE_SIZE - 4, TILE_SIZE - 4, 6);
      ctx.fill();
      break;

    case TILE.BRICK:
      // Dark red base
      ctx.fillStyle = '#8B0000';
      ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
      // Mortar lines
      ctx.strokeStyle = '#4A0000';
      ctx.lineWidth = 1;
      for (var mk = 0; mk < TILE_SIZE; mk += 8) {
        ctx.beginPath();
        ctx.moveTo(x, y + mk);
        ctx.lineTo(x + TILE_SIZE, y + mk);
        ctx.stroke();
      }
      var brickOffsetRow = (row % 2 === 0);
      for (var mb = 0; mb < TILE_SIZE; mb += 16) {
        var offCol = brickOffsetRow ? 0 : 16;
        ctx.beginPath();
        ctx.moveTo(x + offCol, y + mb);
        ctx.lineTo(x + offCol, y + mb + 8);
        ctx.stroke();
        if (offCol > 0) {
          ctx.beginPath();
          ctx.moveTo(x + offCol - 16, y + mb + 8);
          ctx.lineTo(x + offCol - 16 + 16, y + mb + 8);
          ctx.stroke();
        }
      }
      break;

    case TILE.PLATFORM:
      // Thin platform at bottom of tile
      var themeColor = '#8B5E3C'; // default dirt color
      if (level && level.theme === THEME.UNDERGROUND) themeColor = '#808080';
      else if (level && level.theme === THEME.SKY) themeColor = '#F5F5FF';
      else if (level && level.theme === THEME.CASTLE) themeColor = '#8B0000';
      ctx.fillStyle = themeColor;
      ctx.fillRect(x, y + TILE_SIZE - 8, TILE_SIZE, 8);
      // Top highlight
      ctx.fillStyle = 'rgba(255,255,255,0.3)';
      ctx.fillRect(x, y + TILE_SIZE - 8, TILE_SIZE, 2);
      break;

    case TILE.SPIKE:
      // Red triangles
      ctx.fillStyle = '#FF0000';
      ctx.beginPath();
      ctx.moveTo(x + 2, y + TILE_SIZE);
      ctx.lineTo(x + TILE_SIZE / 2, y + 4);
      ctx.lineTo(x + TILE_SIZE - 2, y + TILE_SIZE);
      ctx.fill();
      ctx.beginPath();
      ctx.moveTo(x + 10, y + TILE_SIZE);
      ctx.lineTo(x + TILE_SIZE / 2, y + 14);
      ctx.lineTo(x + TILE_SIZE - 10, y + TILE_SIZE);
      ctx.fill();
      // Outline
      ctx.strokeStyle = '#990000';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(x + 2, y + TILE_SIZE);
      ctx.lineTo(x + TILE_SIZE / 2, y + 4);
      ctx.lineTo(x + TILE_SIZE - 2, y + TILE_SIZE);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(x + 10, y + TILE_SIZE);
      ctx.lineTo(x + TILE_SIZE / 2, y + 14);
      ctx.lineTo(x + TILE_SIZE - 10, y + TILE_SIZE);
      ctx.stroke();
      break;

    case TILE.PIT:
      ctx.fillStyle = '#111';
      ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
      // Subtle dark-red dots
      ctx.fillStyle = 'rgba(139, 0, 0, 0.4)';
      for (var pd = 0; pd < 6; pd++) {
        var pdx = x + 4 + ((pd * 7 + 3) % (TILE_SIZE - 8));
        var pdy = y + TILE_SIZE - 6 - ((pd * 3) % 4);
        ctx.fillRect(pdx, pdy, 3, 3);
      }
      break;

    case TILE.CHECKPOINT_FLAG:
      // Draw ground under flag
      var flagColor = '#32CD32'; // default green
      if (level) {
        if (level.theme === THEME.UNDERGROUND) flagColor = '#4488FF';
        else if (level.theme === THEME.SKY) flagColor = '#FFD700';
        else if (level.theme === THEME.CASTLE) flagColor = '#FF4444';
      }
      // Check if activated
      var isActive = activatedCheckpoints && activatedCheckpoints.has(col + ',' + row);

      // Pole
      ctx.fillStyle = '#8B4513';
      ctx.fillRect(x + 5, y + 4, 3, TILE_SIZE - 4);
      // Flag
      ctx.fillStyle = isActive ? flagColor : '#888';
      ctx.beginPath();
      ctx.moveTo(x + 8, y + 6);
      ctx.lineTo(x + TILE_SIZE - 4, y + TILE_SIZE * 0.3);
      ctx.lineTo(x + 8, y + TILE_SIZE * 0.5);
      ctx.closePath();
      ctx.fill();
      // Flag outline
      ctx.strokeStyle = '#333';
      ctx.lineWidth = 0.8;
      ctx.stroke();
      // Pole top knob
      ctx.fillStyle = '#FFD700';
      ctx.beginPath();
      ctx.arc(x + 6.5, y + 6, 3, 0, Math.PI * 2);
      ctx.fill();
      break;

    case TILE.EXIT_FLAG:
      // Larger flag with glow
      var glow = 0.6 + Math.sin(globalFrame * 0.08) * 0.4;
      ctx.fillStyle = 'rgba(255, 215, 0, ' + (glow * 0.3) + ')';
      ctx.beginPath();
      ctx.arc(x + TILE_SIZE / 2, y + TILE_SIZE * 0.3, TILE_SIZE * 0.7, 0, Math.PI * 2);
      ctx.fill();

      // Pole
      ctx.fillStyle = '#8B4513';
      ctx.fillRect(x + 5, y + 4, 3, TILE_SIZE - 4);
      // Flag
      ctx.fillStyle = '#FFD700';
      ctx.beginPath();
      ctx.moveTo(x + 8, y + 6);
      ctx.lineTo(x + TILE_SIZE - 4, y + TILE_SIZE * 0.25);
      ctx.lineTo(x + 8, y + TILE_SIZE * 0.45);
      ctx.closePath();
      ctx.fill();
      ctx.strokeStyle = '#B8860B';
      ctx.lineWidth = 1;
      ctx.stroke();
      // Star on flag
      ctx.fillStyle = '#FFF';
      ctx.beginPath();
      ctx.arc(x + TILE_SIZE * 0.45, y + TILE_SIZE * 0.22, 3, 0, Math.PI * 2);
      ctx.fill();
      break;

    case TILE.DECO_GRASS:
      // Small green blade shapes
      ctx.fillStyle = '#32CD32';
      var seed = (col * 31 + row * 17) % 100;
      for (var gi = 0; gi < 3; gi++) {
        var gx = x + 6 + gi * 10;
        var gh = 5 + ((seed + gi * 13) % 6);
        ctx.fillRect(gx, y + TILE_SIZE - gh, 2, gh);
        // Blade tip
        ctx.fillRect(gx - 1, y + TILE_SIZE - gh, 4, 2);
      }
      break;

    case TILE.DECO_STALACTITE:
      // Gray triangle hanging from top
      ctx.fillStyle = '#777';
      ctx.beginPath();
      ctx.moveTo(x + TILE_SIZE * 0.25, y);
      ctx.lineTo(x + TILE_SIZE / 2, y + TILE_SIZE * 0.5);
      ctx.lineTo(x + TILE_SIZE * 0.75, y);
      ctx.fill();
      ctx.strokeStyle = '#555';
      ctx.lineWidth = 0.5;
      ctx.stroke();
      break;

    case TILE.DECO_STAR:
      // 4-point yellow star
      var starFlicker = 1 + Math.sin((globalFrame + col * 10) * 0.1) * 0.3;
      ctx.fillStyle = 'rgba(255, 215, 0, ' + (0.6 * starFlicker) + ')';
      var sx = x + TILE_SIZE / 2;
      var sy = y + TILE_SIZE / 2;
      var sr = 5 * starFlicker;
      ctx.beginPath();
      for (var sp = 0; sp < 8; sp++) {
        var ang = (sp * Math.PI) / 4 - Math.PI / 2;
        var rad = sp % 2 === 0 ? sr : sr * 0.35;
        if (sp === 0) ctx.moveTo(sx + Math.cos(ang) * rad, sy + Math.sin(ang) * rad);
        else ctx.lineTo(sx + Math.cos(ang) * rad, sy + Math.sin(ang) * rad);
      }
      ctx.closePath();
      ctx.fill();
      break;

    case TILE.DECO_TORCH:
      // Wall bracket and flame
      var torchFrame = Math.floor(globalFrame / 5) % 3;
      // Bracket
      ctx.fillStyle = '#8B4513';
      ctx.fillRect(x + TILE_SIZE * 0.4, y + TILE_SIZE * 0.4, TILE_SIZE * 0.5, 4);
      ctx.fillRect(x + TILE_SIZE * 0.3, y + TILE_SIZE * 0.2, 4, TILE_SIZE * 0.3);
      // Flame
      var flameH = [12, 16, 10][torchFrame];
      var flameW = [4, 6, 3][torchFrame];
      ctx.fillStyle = '#FF6600';
      ctx.beginPath();
      ctx.moveTo(x + TILE_SIZE * 0.5 - flameW, y + TILE_SIZE * 0.2);
      ctx.lineTo(x + TILE_SIZE * 0.5, y + TILE_SIZE * 0.2 - flameH);
      ctx.lineTo(x + TILE_SIZE * 0.5 + flameW, y + TILE_SIZE * 0.2);
      ctx.fill();
      // Inner yellow flame
      var flameH2 = flameH * 0.6;
      var flameW2 = flameW * 0.5;
      ctx.fillStyle = '#FFCC00';
      ctx.beginPath();
      ctx.moveTo(x + TILE_SIZE * 0.5 - flameW2, y + TILE_SIZE * 0.2);
      ctx.lineTo(x + TILE_SIZE * 0.5, y + TILE_SIZE * 0.2 - flameH2);
      ctx.lineTo(x + TILE_SIZE * 0.5 + flameW2, y + TILE_SIZE * 0.2);
      ctx.fill();
      // Glow
      ctx.fillStyle = 'rgba(255, 100, 0, 0.15)';
      ctx.beginPath();
      ctx.arc(x + TILE_SIZE * 0.5, y + TILE_SIZE * 0.15, TILE_SIZE * 0.4, 0, Math.PI * 2);
      ctx.fill();
      break;

    default:
      break;
  }

  ctx.restore();
}

// -- Parallax Background Drawing --
function drawParallaxLayer(ctx, layer, scrollOffset) {
  ctx.save();

  var offset = scrollOffset * layer.speed;
  var shape = layer.shape;
  var color = layer.color;

  switch (shape) {
    case 'hills':
      // Sine-wave curves as distant hills
      ctx.fillStyle = color || '#2D5A1E';
      ctx.beginPath();
      ctx.moveTo(0, CANVAS_HEIGHT);
      for (var hx = -20; hx < CANVAS_WIDTH + 40; hx += 4) {
        var hy = CANVAS_HEIGHT * 0.7 + Math.sin((hx + offset) * 0.015) * 40 + Math.sin((hx + offset) * 0.03) * 25;
        ctx.lineTo(hx, hy);
      }
      ctx.lineTo(CANVAS_WIDTH, CANVAS_HEIGHT);
      ctx.closePath();
      ctx.fill();

      // Lighter layer on top
      ctx.fillStyle = color ? color : '#3A7A28';
      ctx.globalAlpha = 0.5;
      ctx.beginPath();
      ctx.moveTo(0, CANVAS_HEIGHT);
      for (var hx2 = -20; hx2 < CANVAS_WIDTH + 40; hx2 += 4) {
        var hy2 = CANVAS_HEIGHT * 0.75 + Math.sin((hx2 + offset + 100) * 0.02) * 30 + Math.sin((hx2 + offset + 100) * 0.04) * 20;
        ctx.lineTo(hx2, hy2);
      }
      ctx.lineTo(CANVAS_WIDTH, CANVAS_HEIGHT);
      ctx.closePath();
      ctx.fill();
      break;

    case 'clouds':
      // Rounded rect cloud clusters
      ctx.fillStyle = color || 'rgba(255, 255, 255, 0.4)';
      var cloudCount = Math.floor(CANVAS_WIDTH / 100) + 2;
      for (var ci = 0; ci < cloudCount; ci++) {
        var cx = ((ci * 130 + offset * 0.7) % (CANVAS_WIDTH + 200)) - 100;
        var cy = 40 + (ci * 37) % 100;
        drawCloud(ctx, cx, cy, 30 + (ci % 3) * 10, color);
      }
      break;

    case 'stars':
      // Small white dots that twinkle
      var starCount = 60;
      for (var si = 0; si < starCount; si++) {
        var sxx = ((si * 137 + offset * 0.3) % (CANVAS_WIDTH + 100)) - 50;
        var syy = (si * 71) % (CANVAS_HEIGHT * 0.6);
        var twinkle = 0.4 + Math.sin((globalFrame + si * 17) * 0.05) * 0.4;
        ctx.fillStyle = 'rgba(255, 255, 220, ' + twinkle + ')';
        var sz = 1 + (si % 3);
        ctx.fillRect(sxx, syy, sz, sz);
      }
      break;

    case 'stalactites':
      // Triangles hanging from top
      ctx.fillStyle = color || 'rgba(60, 60, 60, 0.4)';
      var scount = Math.floor(CANVAS_WIDTH / 48) + 2;
      for (var st = 0; st < scount; st++) {
        var stx = ((st * 64 + offset * 0.5) % (CANVAS_WIDTH + 80)) - 40;
        var sth = 30 + (st % 3) * 25;
        var stw = 12 + (st % 4) * 4;
        ctx.beginPath();
        ctx.moveTo(stx - stw, 0);
        ctx.lineTo(stx, sth);
        ctx.lineTo(stx + stw, 0);
        ctx.fill();
      }
      break;

    case 'towers':
      // Tall rectangular structures for castle
      ctx.fillStyle = color || 'rgba(40, 0, 0, 0.5)';
      var tcount = Math.floor(CANVAS_WIDTH / 80) + 2;
      for (var tw = 0; tw < tcount; tw++) {
        var twx = ((tw * 120 + offset * 0.6) % (CANVAS_WIDTH + 160)) - 80;
        var twh = 80 + (tw % 3) * 50;
        ctx.fillRect(twx, CANVAS_HEIGHT - twh, 30, twh);
        // Battlements on top
        for (var bt = 0; bt < 3; bt++) {
          ctx.fillRect(twx + bt * 12, CANVAS_HEIGHT - twh - 10, 8, 10);
        }
      }
      break;
  }

  ctx.restore();
}

function drawCloud(ctx, cx, cy, size, color) {
  ctx.fillStyle = color || 'rgba(255, 255, 255, 0.4)';
  ctx.beginPath();
  ctx.arc(cx, cy, size * 0.5, 0, Math.PI * 2);
  ctx.arc(cx + size * 0.35, cy - size * 0.15, size * 0.4, 0, Math.PI * 2);
  ctx.arc(cx + size * 0.6, cy + size * 0.05, size * 0.35, 0, Math.PI * 2);
  ctx.arc(cx - size * 0.3, cy + size * 0.1, size * 0.35, 0, Math.PI * 2);
  ctx.fill();
}

// -- Particle Drawing --
function drawParticle(ctx, p, sx, sy) {
  ctx.save();
  var lifeRatio = p.life / p.maxLife;
  ctx.globalAlpha = lifeRatio;
  ctx.fillStyle = p.color;
  var px = sx !== undefined ? sx : p.x;
  var py = sy !== undefined ? sy : p.y;
  ctx.fillRect(px - p.size / 2, py - p.size / 2, p.size, p.size);
  ctx.restore();
}

// -- Utility: Rounded Rectangle --
function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r);
  ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r);
  ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y);
  ctx.closePath();
}


// ========== SECTION 6: LEVEL DATA ==========

// Level generation helper - creates empty tile grid
function createTileGrid(width, height) {
  var grid = [];
  for (var r = 0; r < height; r++) {
    grid.push([]);
    for (var c = 0; c < width; c++) {
      grid[r].push(TILE.AIR);
    }
  }
  return grid;
}

// Build level objects
function buildLevel0() {
  var w = 120;
  var h = 20;
  var tiles = createTileGrid(w, h);

  // Ground: rows 18-19, dirt
  for (var c = 0; c < w; c++) {
    tiles[18][c] = TILE.DIRT;
    tiles[19][c] = TILE.DIRT;
  }
  // Grass deco on top of ground (row 17)
  for (var c = 0; c < w; c++) {
    tiles[17][c] = TILE.DECO_GRASS;
  }

  // Pit gaps - remove ground and add PIT tiles
  var pits = [
    [24, 27], [54, 57], [84, 87]
  ];
  for (var pi = 0; pi < pits.length; pi++) {
    var pStart = pits[pi][0];
    var pEnd = pits[pi][1];
    for (var c = pStart; c <= pEnd; c++) {
      tiles[17][c] = TILE.AIR;
      tiles[18][c] = TILE.PIT;
      tiles[19][c] = TILE.PIT;
    }
  }

  // Platforms - scattered at various heights
  var platforms = [
    // [row, col, len, type]
    [12, 10, 3, TILE.DIRT], [10, 22, 4, TILE.DIRT],
    [12, 35, 5, TILE.DIRT], [10, 45, 4, TILE.DIRT],
    [12, 60, 5, TILE.DIRT], [8, 72, 4, TILE.DIRT],
    [12, 82, 5, TILE.DIRT], [10, 95, 4, TILE.DIRT],
    [12, 105, 4, TILE.DIRT],
    // Stepping stones over pits
    [15, 25, 1, TILE.DIRT], [14, 26, 1, TILE.DIRT],
    [15, 55, 1, TILE.DIRT], [14, 56, 1, TILE.DIRT],
    [15, 85, 1, TILE.DIRT], [14, 86, 1, TILE.DIRT],
  ];
  for (var pf = 0; pf < platforms.length; pf++) {
    var prow = platforms[pf][0];
    var pcol = platforms[pf][1];
    var plen = platforms[pf][2];
    var ptype = platforms[pf][3];
    for (var pc = 0; pc < plen; pc++) {
      tiles[prow][pcol + pc] = ptype;
      if (ptype === TILE.DIRT && prow > 0) {
        tiles[prow - 1][pcol + pc] = TILE.DECO_GRASS;
      }
    }
  }

  // Override some grass deco when walking space is needed
  for (var c = 0; c < w; c++) {
    if (tiles[16][c] !== TILE.AIR && tiles[17][c] === TILE.DECO_GRASS) {
      tiles[17][c] = TILE.AIR;
    }
  }

  return {
    id: 0,
    name: 'Green Fields',
    theme: THEME.GRASSLAND,
    width: w,
    height: h,
    bgColor1: '#5C94FC',
    bgColor2: '#87CEEB',
    bgGround: '#8B5E3C',
    tiles: tiles,
    playerSpawn: { col: 3, row: 17 },
    exit: { col: 116, row: 17 },
    enemies: [
      { type: 'slime', col: 10, row: 18, patrolRange: 3, direction: 1 },
      { type: 'slime', col: 20, row: 18, patrolRange: 2, direction: -1 },
      { type: 'slime', col: 38, row: 18, patrolRange: 3, direction: 1 },
      { type: 'slime', col: 50, row: 18, patrolRange: 2, direction: -1 },
      { type: 'slime', col: 65, row: 18, patrolRange: 3, direction: 1 },
      { type: 'slime', col: 78, row: 18, patrolRange: 2, direction: -1 },
      { type: 'slime', col: 90, row: 18, patrolRange: 3, direction: 1 },
      { type: 'slime', col: 100, row: 18, patrolRange: 2, direction: -1 },
      { type: 'bat', col: 30, row: 8, amplitude: 3, frequency: 0.025, direction: -1, speed: 2 },
      { type: 'bat', col: 42, row: 6, amplitude: 2, frequency: 0.03, direction: 1, speed: 2 },
      { type: 'bat', col: 58, row: 7, amplitude: 3, frequency: 0.022, direction: -1, speed: 2 },
      { type: 'bat', col: 75, row: 5, amplitude: 2, frequency: 0.028, direction: 1, speed: 2 },
      { type: 'bat', col: 95, row: 7, amplitude: 3, frequency: 0.025, direction: -1, speed: 2 },
      { type: 'bat', col: 108, row: 6, amplitude: 2, frequency: 0.03, direction: 1, speed: 2 },
    ],
    coins: [
      { col: 8, row: 16, value: 10 }, { col: 9, row: 16, value: 10 }, { col: 10, row: 16, value: 10 },
      { col: 15, row: 8, value: 10 }, { col: 16, row: 8, value: 10 },
      { col: 28, row: 16, value: 10 },
      { col: 36, row: 10, value: 10 }, { col: 37, row: 10, value: 10 },
      { col: 46, row: 8, value: 10 }, { col: 47, row: 8, value: 10 }, { col: 48, row: 8, value: 10 },
      { col: 62, row: 10, value: 10 }, { col: 63, row: 10, value: 10 },
      { col: 73, row: 6, value: 10 }, { col: 74, row: 6, value: 10 },
      { col: 90, row: 16, value: 10 },
      { col: 96, row: 8, value: 10 }, { col: 97, row: 8, value: 10 },
      { col: 106, row: 10, value: 10 }, { col: 107, row: 10, value: 10 },
      { col: 110, row: 16, value: 10 }, { col: 111, row: 16, value: 10 },
    ],
    powerups: [
      { col: 36, row: 11, type: 'speed' },
      { col: 62, row: 11, type: 'extraLife' },
      { col: 96, row: 9, type: 'doubleJump' },
    ],
    checkpoints: [
      { col: 55, row: 17 },
    ],
    parallax: {
      layers: [
        { color: 'rgba(34, 100, 34, 0.25)', shape: 'hills', speed: 0.3 },
        { color: 'rgba(255, 255, 255, 0.3)', shape: 'clouds', speed: 0.15 },
      ]
    }
  };
}

function buildLevel1() {
  var w = 100;
  var h = 20;
  var tiles = createTileGrid(w, h);

  // Stone ceiling: rows 0-1
  for (var c = 0; c < w; c++) {
    tiles[0][c] = TILE.STONE;
    tiles[1][c] = TILE.STONE;
  }
  // Stone floor: rows 18-19
  for (var c = 0; c < w; c++) {
    tiles[18][c] = TILE.STONE;
    tiles[19][c] = TILE.STONE;
  }

  // Stalactite decorations on ceiling
  for (var c = 0; c < w; c += 3) {
    tiles[2][c] = TILE.DECO_STALACTITE;
  }

  // Ceiling variation - open section at start and end
  for (var c = 0; c < 6; c++) {
    tiles[0][c] = TILE.AIR;
    tiles[1][c] = TILE.AIR;
    tiles[2][c] = TILE.AIR;
  }
  for (var c = 94; c < w; c++) {
    tiles[0][c] = TILE.AIR;
    tiles[1][c] = TILE.AIR;
    tiles[2][c] = TILE.AIR;
  }

  // Pit traps in floor
  var pits = [[22, 24], [48, 50], [72, 74]];
  for (var pi = 0; pi < pits.length; pi++) {
    var ps = pits[pi][0];
    var pe = pits[pi][1];
    for (var c = ps; c <= pe; c++) {
      tiles[18][c] = TILE.PIT;
      tiles[19][c] = TILE.PIT;
    }
  }

  // Narrow passage walls - columns of stone creating rooms
  // Section walls
  var walls = [
    [3, 18, 14], [3, 40, 14], [3, 60, 14], [3, 80, 14]
  ];
  for (var wi = 0; wi < walls.length; wi++) {
    var wRow = walls[wi][0];
    var wCol = walls[wi][1];
    var wLen = walls[wi][2];
    for (var wr = 0; wr < wLen; wr++) {
      tiles[wRow + wr][wCol] = TILE.STONE;
      tiles[wRow + wr][wCol + 1] = TILE.STONE;
    }
  }

  // Platform sections
  var platforms = [
    // [row, col, len, type]
    [7, 8, 3, TILE.STONE], [10, 12, 4, TILE.STONE],
    [14, 28, 4, TILE.STONE], [11, 34, 3, TILE.STONE],
    [14, 52, 4, TILE.STONE], [11, 65, 3, TILE.STONE],
    [14, 76, 4, TILE.STONE], [12, 85, 3, TILE.STONE],
    [14, 92, 3, TILE.STONE],
  ];
  for (var pf = 0; pf < platforms.length; pf++) {
    var pr = platforms[pf][0];
    var pc = platforms[pf][1];
    var pl = platforms[pf][2];
    var pt = platforms[pf][3];
    for (var pp = 0; pp < pl; pp++) {
      tiles[pr][pc + pp] = pt;
    }
  }

  // Spikes - ceiling and floor
  var spikes = [
    [3, 10], [3, 25], [3, 50], [3, 70],  // ceiling
    [17, 30], [17, 55], [17, 75],         // floor
  ];
  for (var spi = 0; spi < spikes.length; spi++) {
    tiles[spikes[spi][0]][spikes[spi][1]] = TILE.SPIKE;
  }

  return {
    id: 1,
    name: 'Dark Caverns',
    theme: THEME.UNDERGROUND,
    width: w,
    height: h,
    bgColor1: '#1a0a2e',
    bgColor2: '#2d1b4e',
    bgGround: '#808080',
    tiles: tiles,
    playerSpawn: { col: 3, row: 17 },
    exit: { col: 96, row: 17 },
    enemies: [
      { type: 'skeleton', col: 15, row: 18, patrolRange: 4, direction: 1, shootInterval: 150 },
      { type: 'skeleton', col: 30, row: 18, patrolRange: 3, direction: -1, shootInterval: 140 },
      { type: 'skeleton', col: 55, row: 18, patrolRange: 4, direction: 1, shootInterval: 130 },
      { type: 'skeleton', col: 65, row: 18, patrolRange: 3, direction: -1, shootInterval: 145 },
      { type: 'skeleton', col: 78, row: 18, patrolRange: 4, direction: 1, shootInterval: 135 },
      { type: 'skeleton', col: 88, row: 18, patrolRange: 3, direction: -1, shootInterval: 140 },
      { type: 'bat', col: 12, row: 6, amplitude: 2, frequency: 0.025, direction: -1, speed: 2 },
      { type: 'bat', col: 35, row: 5, amplitude: 2, frequency: 0.03, direction: 1, speed: 2 },
      { type: 'bat', col: 58, row: 6, amplitude: 2, frequency: 0.028, direction: -1, speed: 2 },
      { type: 'bat', col: 82, row: 5, amplitude: 2, frequency: 0.025, direction: 1, speed: 2 },
    ],
    coins: [
      { col: 8, row: 13, value: 10 }, { col: 9, row: 13, value: 10 },
      { col: 25, row: 16, value: 10 },
      { col: 35, row: 9, value: 10 }, { col: 36, row: 9, value: 10 },
      { col: 53, row: 12, value: 10 }, { col: 54, row: 12, value: 10 },
      { col: 66, row: 9, value: 10 },
      { col: 77, row: 12, value: 10 }, { col: 78, row: 12, value: 10 },
      { col: 86, row: 10, value: 10 },
      { col: 93, row: 12, value: 10 }, { col: 94, row: 12, value: 10 },
      // Gems in hard to reach spots
      { col: 49, row: 13, value: 50 },
      { col: 73, row: 13, value: 50 },
    ],
    powerups: [
      { col: 35, row: 10, type: 'invincible' },
      { col: 66, row: 10, type: 'extraLife' },
      { col: 86, row: 11, type: 'speed' },
    ],
    checkpoints: [
      { col: 50, row: 17 },
    ],
    parallax: {
      layers: [
        { color: 'rgba(30, 20, 40, 0.4)', shape: 'stalactites', speed: 0.2 },
        { color: 'rgba(60, 40, 60, 0.2)', shape: 'stalactites', speed: 0.1 },
      ]
    }
  };
}

function buildLevel2() {
  var w = 130;
  var h = 20;
  var tiles = createTileGrid(w, h);

  // PIT bottom rows
  for (var c = 0; c < w; c++) {
    tiles[18][c] = TILE.PIT;
    tiles[19][c] = TILE.PIT;
  }

  // Cloud platforms scattered at various heights
  var platforms = [
    // Starting area
    [16, 0, 10, TILE.CLOUD],
    [14, 5, 5, TILE.CLOUD],
    [16, 12, 7, TILE.CLOUD],
    // Mid section
    [12, 20, 5, TILE.CLOUD],
    [14, 26, 4, TILE.CLOUD],
    [10, 31, 6, TILE.CLOUD],
    [16, 36, 6, TILE.CLOUD],
    [13, 42, 5, TILE.CLOUD],
    [11, 48, 4, TILE.CLOUD],
    [15, 52, 7, TILE.CLOUD],
    [17, 58, 5, TILE.CLOUD],
    // Checkpoint area
    [13, 63, 8, TILE.CLOUD],
    [11, 69, 4, TILE.CLOUD],
    [15, 72, 6, TILE.CLOUD],
    // End section
    [13, 80, 5, TILE.CLOUD],
    [16, 84, 7, TILE.CLOUD],
    [10, 90, 6, TILE.CLOUD],
    [14, 96, 4, TILE.CLOUD],
    [16, 100, 6, TILE.CLOUD],
    [12, 106, 5, TILE.CLOUD],
    [16, 112, 8, TILE.CLOUD],
    [15, 120, 6, TILE.CLOUD],
    // High platforms
    [8, 15, 4, TILE.CLOUD],
    [7, 28, 3, TILE.CLOUD],
    [6, 45, 4, TILE.CLOUD],
    [8, 55, 3, TILE.CLOUD],
    [5, 75, 4, TILE.CLOUD],
    [7, 92, 4, TILE.CLOUD],
    [9, 108, 3, TILE.CLOUD],
  ];
  for (var pf = 0; pf < platforms.length; pf++) {
    var pr = platforms[pf][0];
    var pc = platforms[pf][1];
    var pl = platforms[pf][2];
    var pt = platforms[pf][3];
    for (var pp = 0; pp < pl; pp++) {
      tiles[pr][pc + pp] = pt;
    }
  }

  // Star decorations in empty sky
  for (var c = 0; c < w; c++) {
    for (var r = 0; r < h - 2; r++) {
      if (tiles[r][c] === TILE.AIR && (c + r * 7) % 13 === 0) {
        tiles[r][c] = TILE.DECO_STAR;
      }
    }
  }

  // Some platforms as one-way platforms (cloud platforms you can jump through)
  var oneWayPlatforms = [
    [16, 20, 3], [14, 35, 3], [16, 50, 3], [14, 70, 3], [16, 90, 3]
  ];
  for (var ow = 0; ow < oneWayPlatforms.length; ow++) {
    var owr = oneWayPlatforms[ow][0];
    var owc = oneWayPlatforms[ow][1];
    var owl = oneWayPlatforms[ow][2];
    for (var owp = 0; owp < owl; owp++) {
      tiles[owr][owc + owp] = TILE.PLATFORM;
    }
  }

  return {
    id: 2,
    name: 'Cloud Peaks',
    theme: THEME.SKY,
    width: w,
    height: h,
    bgColor1: '#4a90d9',
    bgColor2: '#b8d4f0',
    bgGround: '#b8d4f0',
    tiles: tiles,
    playerSpawn: { col: 3, row: 15 },
    exit: { col: 126, row: 15 },
    enemies: [
      { type: 'bat', col: 18, row: 8, amplitude: 3, frequency: 0.025, direction: 1, speed: 2.2 },
      { type: 'bat', col: 33, row: 6, amplitude: 2, frequency: 0.03, direction: -1, speed: 2.2 },
      { type: 'ghost', col: 25, row: 10, aggroRange: 8, speed: 1.5 },
      { type: 'bat', col: 50, row: 8, amplitude: 3, frequency: 0.022, direction: 1, speed: 2.2 },
      { type: 'ghost', col: 55, row: 10, aggroRange: 8, speed: 1.5 },
      { type: 'bat', col: 65, row: 6, amplitude: 2, frequency: 0.028, direction: -1, speed: 2.2 },
      { type: 'bat', col: 78, row: 8, amplitude: 3, frequency: 0.025, direction: 1, speed: 2.2 },
      { type: 'ghost', col: 70, row: 10, aggroRange: 8, speed: 1.5 },
      { type: 'bat', col: 95, row: 6, amplitude: 2, frequency: 0.03, direction: -1, speed: 2.2 },
      { type: 'ghost', col: 85, row: 10, aggroRange: 8, speed: 1.5 },
      { type: 'bat', col: 110, row: 8, amplitude: 3, frequency: 0.025, direction: 1, speed: 2.2 },
      { type: 'bat', col: 118, row: 6, amplitude: 2, frequency: 0.03, direction: -1, speed: 2.2 },
    ],
    coins: [
      { col: 13, row: 14, value: 10 }, { col: 14, row: 14, value: 10 },
      { col: 21, row: 10, value: 10 }, { col: 22, row: 10, value: 10 },
      { col: 32, row: 8, value: 10 }, { col: 33, row: 8, value: 10 },
      { col: 43, row: 11, value: 10 }, { col: 44, row: 11, value: 10 },
      { col: 53, row: 13, value: 10 }, { col: 54, row: 13, value: 10 },
      { col: 66, row: 11, value: 10 }, { col: 67, row: 11, value: 10 },
      { col: 76, row: 6, value: 10 },
      { col: 85, row: 14, value: 10 }, { col: 86, row: 14, value: 10 },
      { col: 93, row: 8, value: 10 }, { col: 94, row: 8, value: 10 },
      { col: 101, row: 14, value: 10 }, { col: 102, row: 14, value: 10 },
      { col: 113, row: 14, value: 10 }, { col: 114, row: 14, value: 10 },
      // Gems
      { col: 37, row: 13, value: 50 },
      { col: 59, row: 13, value: 100 },
      { col: 97, row: 11, value: 50 },
    ],
    powerups: [
      { col: 31, row: 9, type: 'doubleJump' },
      { col: 59, row: 14, type: 'invincible' },
      { col: 93, row: 7, type: 'extraLife' },
    ],
    checkpoints: [
      { col: 63, row: 12 },
    ],
    parallax: {
      layers: [
        { color: 'rgba(255, 255, 255, 0.25)', shape: 'clouds', speed: 0.12 },
        { color: 'rgba(255, 255, 255, 0.15)', shape: 'clouds', speed: 0.08 },
        { color: 'rgba(255, 250, 200, 0.3)', shape: 'stars', speed: 0.05 },
      ]
    }
  };
}

function buildLevel3() {
  var w = 110;
  var h = 20;
  var tiles = createTileGrid(w, h);

  // Brick ceiling: rows 0-1
  for (var c = 0; c < w; c++) {
    tiles[0][c] = TILE.BRICK;
    tiles[1][c] = TILE.BRICK;
  }
  // Brick floor: rows 18-19
  for (var c = 0; c < w; c++) {
    tiles[18][c] = TILE.BRICK;
    tiles[19][c] = TILE.BRICK;
  }

  // Open entry area (no ceiling for first few columns)
  for (var c = 0; c < 8; c++) {
    tiles[0][c] = TILE.AIR;
    tiles[1][c] = TILE.AIR;
  }

  // Torches on walls throughout
  var torchCols = [4, 12, 25, 38, 50, 62, 80, 95, 105];
  for (var tc = 0; tc < torchCols.length; tc++) {
    tiles[2][torchCols[tc]] = TILE.DECO_TORCH;
  }

  // Room dividers - vertical brick walls with doorways
  var rooms = [
    { col: 15, doorRow: 13 },
    { col: 30, doorRow: 12 },
    { col: 48, doorRow: 14 },
    { col: 65, doorRow: 13 },
    { col: 82, doorRow: 14 }, // before boss room
  ];

  for (var ri = 0; ri < rooms.length; ri++) {
    var rCol = rooms[ri].col;
    var dRow = rooms[ri].doorRow;
    for (var r = 3; r < 18; r++) {
      if (r < dRow || r > dRow + 1) {
        tiles[r][rCol] = TILE.BRICK;
        tiles[r][rCol + 1] = TILE.BRICK;
      }
    }
  }

  // Floor spikes in rooms
  var floorSpikes = [
    [17, 18], [17, 35], [17, 55], [17, 72],
  ];
  for (var fsi = 0; fsi < floorSpikes.length; fsi++) {
    tiles[floorSpikes[fsi][0]][floorSpikes[fsi][1]] = TILE.SPIKE;
  }

  // Platforms in rooms
  var platforms = [
    [14, 3, 4, TILE.BRICK], [10, 8, 3, TILE.BRICK],
    [12, 18, 4, TILE.BRICK], [8, 22, 3, TILE.BRICK],
    [14, 33, 4, TILE.BRICK], [10, 38, 3, TILE.BRICK],
    [13, 51, 4, TILE.BRICK], [8, 56, 3, TILE.BRICK],
    [14, 68, 4, TILE.BRICK], [12, 73, 3, TILE.BRICK],
    [14, 85, 6, TILE.BRICK], [10, 88, 4, TILE.BRICK],
  ];
  for (var pf = 0; pf < platforms.length; pf++) {
    var pr = platforms[pf][0];
    var pc = platforms[pf][1];
    var pl = platforms[pf][2];
    var pt = platforms[pf][3];
    for (var pp = 0; pp < pl; pp++) {
      tiles[pr][pc + pp] = pt;
    }
  }

  // Pit sections in floor
  var pits = [[17, 6], [17, 44], [17, 60]];
  for (var pi = 0; pi < pits.length; pi++) {
    var ps = pits[pi][0];
    var pe = pits[pi][1];
    tiles[ps][pe] = TILE.PIT;
    tiles[ps + 1][pe] = TILE.PIT;
  }

  // Boss room - open area with platforms (cols 83-105)
  for (var c = 83; c < 108; c++) {
    for (var r = 3; r < 18; r++) {
      if (tiles[r][c] !== TILE.BRICK || r >= 17) continue;
      tiles[r][c] = TILE.AIR;
    }
  }
  // Boss room floor
  for (var c = 83; c < 108; c++) {
    tiles[18][c] = TILE.BRICK;
    tiles[19][c] = TILE.BRICK;
  }
  // Boss room platforms
  tiles[14][87] = TILE.BRICK;
  tiles[14][88] = TILE.BRICK;
  tiles[10][92] = TILE.BRICK;
  tiles[10][93] = TILE.BRICK;
  tiles[14][97] = TILE.BRICK;
  tiles[14][98] = TILE.BRICK;
  tiles[14][99] = TILE.BRICK;

  // Exit flag - initially hidden (set to EXIT when boss dies)
  tiles[17][106] = TILE.BRICK; // placeholder - will be changed to EXIT_FLAG

  return {
    id: 3,
    name: 'Demon Castle',
    theme: THEME.CASTLE,
    width: w,
    height: h,
    bgColor1: '#1a0000',
    bgColor2: '#4a0000',
    bgGround: '#8B0000',
    tiles: tiles,
    playerSpawn: { col: 3, row: 17 },
    exit: { col: 106, row: 17 },
    enemies: [
      { type: 'skeleton', col: 10, row: 18, patrolRange: 3, direction: 1, shootInterval: 130 },
      { type: 'skeleton', col: 22, row: 18, patrolRange: 3, direction: -1, shootInterval: 140 },
      { type: 'ghost', col: 18, row: 10, aggroRange: 7, speed: 1.6 },
      { type: 'skeleton', col: 35, row: 18, patrolRange: 4, direction: 1, shootInterval: 125 },
      { type: 'ghost', col: 42, row: 8, aggroRange: 7, speed: 1.6 },
      { type: 'skeleton', col: 52, row: 18, patrolRange: 3, direction: -1, shootInterval: 135 },
      { type: 'skeleton', col: 70, row: 18, patrolRange: 4, direction: 1, shootInterval: 120 },
      { type: 'ghost', col: 68, row: 9, aggroRange: 7, speed: 1.6 },
      { type: 'ghost', col: 90, row: 8, aggroRange: 6, speed: 1.8 },
    ],
    coins: [
      { col: 6, row: 12, value: 10 }, { col: 7, row: 12, value: 10 },
      { col: 20, row: 12, value: 10 }, { col: 21, row: 12, value: 10 },
      { col: 36, row: 12, value: 10 }, { col: 37, row: 12, value: 10 },
      { col: 49, row: 11, value: 10 }, { col: 50, row: 11, value: 10 },
      { col: 66, row: 12, value: 10 }, { col: 67, row: 12, value: 10 },
      { col: 78, row: 10, value: 10 }, { col: 79, row: 10, value: 10 },
      { col: 88, row: 12, value: 10 }, { col: 89, row: 12, value: 10 },
      { col: 95, row: 13, value: 10 }, { col: 96, row: 13, value: 10 },
      // Gems in boss area
      { col: 91, row: 8, value: 100 },
      { col: 98, row: 9, value: 50 },
    ],
    powerups: [
      { col: 22, row: 11, type: 'extraLife' },
      { col: 56, row: 11, type: 'invincible' },
      { col: 85, row: 12, type: 'speed' },
    ],
    checkpoints: [
      { col: 48, row: 17 },
    ],
    boss: {
      type: 'boss',
      col: 94,
      row: 14,
      hp: 5,
      width: 64,
      height: 64,
      attacks: ['charge', 'fireball', 'stomp'],
      attackInterval: 90,
    },
    parallax: {
      layers: [
        { color: 'rgba(40, 0, 0, 0.4)', shape: 'towers', speed: 0.25 },
        { color: 'rgba(20, 0, 0, 0.3)', shape: 'towers', speed: 0.15 },
      ]
    }
  };
}

// Build the levels array
var levels = [
  buildLevel0(),
  buildLevel1(),
  buildLevel2(),
  buildLevel3(),
];
