# STELLAR SURVIVOR — UI Specification
## Canvas: 800×600, All rendering on Canvas (zero DOM except the canvas element)

================================================================================
SECTION 0: GLOBAL CONSTANTS & STYLES
================================================================================

CANVAS_WIDTH  = 800
CANVAS_HEIGHT = 600

// ===== FONT STACK =====
// Use @font-face to load Orbitron (Google Fonts) for titles/menus, fallback to monospace.
// Or embed via base64 in a single-file build.
FONT_TITLE    = "bold 48px 'Orbitron', 'Courier New', monospace"
FONT_SUBTITLE = "24px 'Orbitron', 'Courier New', monospace"
FONT_MENU     = "20px 'Orbitron', 'Courier New', monospace"
FONT_HUD      = "bold 14px 'Courier New', monospace"
FONT_HUD_SM   = "12px 'Courier New', monospace"
FONT_SCORE    = "bold 28px 'Courier New', monospace"
FONT_COMBO    = "bold 18px 'Courier New', monospace"
FONT_WARNING  = "bold 30px 'Courier New', monospace"

// ===== COLOR PALETTE =====
COLOR_NEON_CYAN     = "#00FFFF"
COLOR_NEON_MAGENTA  = "#FF00FF"
COLOR_NEON_GREEN    = "#00FF00"
COLOR_NEON_RED      = "#FF3333"
COLOR_NEON_YELLOW   = "#FFFF00"
COLOR_NEON_ORANGE   = "#FF8800"
COLOR_WHITE         = "#FFFFFF"
COLOR_LIGHT_GRAY    = "#AAAAAA"
COLOR_DARK_GRAY     = "#333333"

COLOR_BG_MENU       = "#0A0A1A"       // deep space blue-black
COLOR_OVERLAY       = "rgba(0, 0, 0, 0.7)"
COLOR_OVERLAY_LIGHT = "rgba(0, 0, 0, 0.5)"

COLOR_HEALTH_GREEN  = "#00FF00"
COLOR_HEALTH_YELLOW = "#FFFF00"
COLOR_HEALTH_RED    = "#FF3333"
COLOR_SHIELD        = "#3399FF"
COLOR_BOSS_HP       = "#FF0000"
COLOR_BOSS_HP_BG    = "#440000"
COLOR_COMBO         = "#FFAA00"

// ===== UI STATE MACHINE =====
UIScreen = {
  MAIN_MENU,
  HOW_TO_PLAY,
  HIGH_SCORES,
  PLAYING,          // in-game HUD visible
  PAUSED,
  LEVEL_TRANSITION,
  UPGRADE_SHOP,
  GAME_OVER,
  VICTORY
}

uiState = {
  currentScreen : UIScreen.MAIN_MENU,
  selectedMenuIndex : 0,        // 0=START, 1=HOW TO PLAY, 2=HIGH SCORES
  selectedShopIndex : 0,
  selectedPauseIndex : 0,
  selectedGameOverIndex : 0,
  transitionAlpha : 1.0,        // 0=transparent, 1=opaque for current screen
  transitionTarget : null,      // screen transitioning to
  transitionTimer : 0,
  scoreDisplayValue : 0,        // animated score counter
  comboScale : 1.0,             // for combo pop animation
  comboTimer : 0,
  healthBarWidth : 200,         // current rendered width (animated)
  healthTargetWidth : 200,      // target width based on HP%
  bossHPWidth : 0,
  bossHPTargetWidth : 0,
  levelTransitionTimer : 0,     // countdown for level complete screen
  shopPoints : 0,               // available upgrade points
  upgradeLevels : { engine:0, weapon:0, armor:0, shield:0 },
  showHighScore : false,        // "NEW HIGH SCORE!" flag
  starfield : [],               // array of {x, y, z, speed} for background
  celebrationParticles : [],    // for victory screen
  powerUpTimers : [],           // [{type, timeRemaining, totalTime}] for active power-up HUD
  previousCombo : 0,
  isTouchDevice : false,        // set on first touch event
  warningArrows : [],           // [{angle, distance}] for off-screen enemies
  timeSurvived : 0,             // for game over stats
}

// ===== STARFIELD (shared across menu screens) =====
function initStarfield() {
  for (i = 0; i < 200; i++) {
    uiState.starfield.push({
      x: Math.random() * 800,
      y: Math.random() * 600,
      z: Math.random() * 3 + 0.5,   // 0.5 - 3.5 (size proxy)
      speed: Math.random() * 0.5 + 0.1
    });
  }
}

function updateStarfield(dt) {
  for each star:
    star.y += star.speed * (star.z * 0.5);
    if (star.y > 600) { star.y = 0; star.x = Math.random() * 800; }
}

function drawStarfield(ctx) {
  for each star:
    alpha = 0.3 + (star.z / 3.5) * 0.7;
    radius = star.z * 0.6;
    ctx.fillStyle = `rgba(255,255,255,${alpha})`;
    ctx.beginPath();
    ctx.arc(star.x, star.y, radius, 0, Math.PI*2);
    ctx.fill();
}

function drawStarfieldAt(ctx, opacity) {
  ctx.save();
  ctx.globalAlpha = opacity;
  drawStarfield(ctx);
  ctx.restore();
}


================================================================================
SECTION 1: MAIN MENU SCREEN
================================================================================

// Layout (800×600):
//
//   ┌─────────────────────────────────────────────┐
//   │  ★  ★  ★  STARFIELD BG (animated)  ★  ★  ★ │
//   │                                             │
//   │     ╔══════════════════════════════╗        │  y=80
//   │     ║   STELLAR SURVIVOR          ║        │
//   │     ║   (neon cyan glow, pulsing) ║        │  y=130
//   │     ╚══════════════════════════════╝        │
//   │         ARCADE SPACE SHOOTER                │  y=155
//   │                                             │
//   │          ▶ START GAME                       │  y=250
//   │            HOW TO PLAY                      │  y=290
//   │            HIGH SCORES                      │  y=330
//   │                                             │
//   │   WASD/Arrows = Move | Space/Click = Fire   │  y=520
//   │   P = Pause | ↑↓/WS = Navigate             │  y=542
//   │                                             │
//   │         v1.0 — © 2026                       │  y=580
//   └─────────────────────────────────────────────┘

// TITLE ANIMATION:
titlePulse = Math.sin(performance.now() * 0.003) * 0.15 + 0.85;  // 0.7 - 1.0 range over ~2s
titleGlowRadius = 15 + Math.sin(performance.now() * 0.003) * 5;  // 10 - 20px glow

function drawMainMenu(ctx, dt) {
  updateStarfield(dt);
  drawStarfield(ctx);

  // === TITLE ===
  drawGlowText(ctx, "STELLAR SURVIVOR", 400, 105, FONT_TITLE, COLOR_NEON_CYAN, titleGlowRadius);
  drawGlowText(ctx, "STELLAR SURVIVOR", 400, 105, FONT_TITLE, COLOR_WHITE, 0);
  // Subtitle
  ctx.font = FONT_SUBTITLE;
  ctx.fillStyle = COLOR_NEON_MAGENTA;
  ctx.textAlign = "center";
  ctx.fillText("ARCADE SPACE SHOOTER", 400, 165);

  // === MENU OPTIONS ===
  const options = ["START GAME", "HOW TO PLAY", "HIGH SCORES"];
  const startY = 250;
  const spacing = 40;

  for (i = 0; i < options.length; i++) {
    const y = startY + i * spacing;
    const isSelected = (i === uiState.selectedMenuIndex);

    if (isSelected) {
      // Selection indicator: "▶ " prefix, neon glow, slight scale
      const pulse = Math.sin(performance.now() * 0.005) * 3;
      drawGlowText(ctx, "▶ " + options[i] + " ◀", 400, y, FONT_MENU, COLOR_NEON_YELLOW, 8 + pulse);
      ctx.font = FONT_MENU;
      ctx.fillStyle = COLOR_WHITE;
      ctx.fillText("▶ " + options[i] + " ◀", 400, y);
    } else {
      ctx.font = FONT_MENU;
      ctx.fillStyle = COLOR_LIGHT_GRAY;
      ctx.fillText(options[i], 400, y);
    }
  }

  // === CONTROLS ===
  ctx.font = FONT_HUD_SM;
  ctx.fillStyle = "#666666";
  ctx.fillText("WASD / Arrows = Move  |  Space / Click = Fire  |  P = Pause", 400, 520);
  ctx.fillText("↑↓ / WS = Navigate  |  Enter = Select", 400, 545);

  // === FOOTER ===
  ctx.fillText("v1.0  © 2026 Stellar Survivor Studio", 400, 580);
}

// MENU INPUT HANDLING:
function handleMenuInput(key, clickX, clickY) {
  const options = ["START GAME", "HOW TO PLAY", "HIGH SCORES"];
  const startY = 250;

  if (key === "ArrowDown" || key === "s" || key === "S") {
    uiState.selectedMenuIndex = (uiState.selectedMenuIndex + 1) % options.length;
  }
  if (key === "ArrowUp" || key === "w" || key === "W") {
    uiState.selectedMenuIndex = (uiState.selectedMenuIndex - 1 + options.length) % options.length;
  }
  if (key === "Enter" || key === " ") {
    selectMenuOption();
  }

  // Mouse click on options
  if (clickX && clickY) {
    for (i = 0; i < options.length; i++) {
      const y = startY + i * 40;
      if (clickY > y - 15 && clickY < y + 15) {
        uiState.selectedMenuIndex = i;
        selectMenuOption();
        break;
      }
    }
  }
}

function selectMenuOption() {
  switch (uiState.selectedMenuIndex) {
    case 0: transitionTo(UIScreen.PLAYING); break;
    case 1: transitionTo(UIScreen.HOW_TO_PLAY); break;
    case 2: transitionTo(UIScreen.HIGH_SCORES); break;
  }
}


================================================================================
SECTION 2: HOW TO PLAY SCREEN
================================================================================

// Layout:
//   y=30:  "HOW TO PLAY" (neon cyan, centered)
//   y=80:  "━━━ CONTROLS ━━━" (section header, left-aligned x=60)
//   y=100: Control list with icon-like prefixes
//   y=240: "━━━ ENEMIES ━━━"
//   y=360: "━━━ POWER-UPS ━━━"
//   y=540: "PRESS ENTER TO RETURN"
//
// CONTROLS LIST:
//   ←↑↓→ / WASD  —  Move ship
//   SPACE / CLICK  —  Fire lasers
//   P / ESC  —  Pause game
//   M  —  Mute / Unmute

function drawHowToPlay(ctx, dt) {
  updateStarfield(dt);
  drawStarfield(ctx);

  // Title
  drawGlowText(ctx, "HOW TO PLAY", 400, 45, FONT_TITLE, COLOR_NEON_CYAN, 12);

  ctx.font = FONT_MENU;
  ctx.textAlign = "left";

  // === CONTROLS ===
  ctx.fillStyle = COLOR_NEON_YELLOW;
  ctx.fillText("━━━ CONTROLS ━━━", 80, 90);
  ctx.font = FONT_HUD;
  const controls = [
    { key: "← ↑ ↓ → / WASD", desc: "Move your ship" },
    { key: "SPACE / LEFT CLICK", desc: "Fire lasers (hold for auto-fire)" },
    { key: "P / ESC", desc: "Pause the game" },
    { key: "M", desc: "Mute / Unmute sound" },
  ];
  for (i = 0; i < controls.length; i++) {
    ctx.fillStyle = COLOR_NEON_GREEN;
    ctx.fillText(controls[i].key, 80, 125 + i * 28);
    ctx.fillStyle = COLOR_LIGHT_GRAY;
    ctx.fillText("— " + controls[i].desc, 320, 125 + i * 28);
  }

  // === ENEMIES ===
  ctx.font = FONT_MENU;
  ctx.fillStyle = COLOR_NEON_YELLOW;
  ctx.fillText("━━━ ENEMIES ━━━", 80, 260);

  ctx.font = FONT_HUD;
  const enemies = [
    { name: "DRONE", color: "#FF4444", desc: "Basic enemy. Slow, low HP. 10 pts." },
    { name: "SCOUT", color: "#FF8800", desc: "Fast and erratic. Dodges fire. 25 pts." },
    { name: "TANK", color: "#CC0000", desc: "Heavy armor. Slow but tough. 50 pts." },
    { name: "BOSS", color: "#FF00FF", desc: "Level boss. Massive HP. Special attacks. 500+ pts." },
  ];
  for (i = 0; i < enemies.length; i++) {
    ctx.fillStyle = enemies[i].color;
    ctx.fillText("■ " + enemies[i].name, 80, 290 + i * 32);
    ctx.fillStyle = COLOR_LIGHT_GRAY;
    ctx.fillText("— " + enemies[i].desc, 200, 290 + i * 32);
  }

  // === POWER-UPS ===
  ctx.font = FONT_MENU;
  ctx.fillStyle = COLOR_NEON_YELLOW;
  ctx.fillText("━━━ POWER-UPS ━━━", 80, 440);

  ctx.font = FONT_HUD;
  const powerups = [
    { icon: "⚡", name: "RAPID FIRE", color: "#FFAA00", desc: "2× fire rate for 10 seconds" },
    { icon: "🛡", name: "SHIELD", color: "#3399FF", desc: "Absorbs 1 hit (stacks)" },
    { icon: "★", name: "SCORE BOOST", color: "#FFFF00", desc: "3× points for 8 seconds" },
    { icon: "❤", name: "REPAIR", color: "#FF3333", desc: "Restore 25 HP" },
  ];
  for (i = 0; i < powerups.length; i++) {
    ctx.fillStyle = powerups[i].color;
    ctx.fillText(powerups[i].icon + " " + powerups[i].name, 80, 470 + i * 32);
    ctx.fillStyle = COLOR_LIGHT_GRAY;
    ctx.fillText("— " + powerups[i].desc, 260, 470 + i * 32);
  }

  // === RETURN PROMPT ===
  ctx.font = FONT_MENU;
  ctx.textAlign = "center";
  const blink = Math.sin(performance.now() * 0.004) > 0;
  if (blink) {
    ctx.fillStyle = COLOR_NEON_CYAN;
    ctx.fillText("PRESS ENTER TO RETURN", 400, 560);
  }
}

function handleHowToPlayInput(key) {
  if (key === "Enter" || key === "Escape" || key === " ") {
    transitionTo(UIScreen.MAIN_MENU);
  }
}


================================================================================
SECTION 3: IN-GAME HUD
================================================================================

// Layout:
//   ┌──────────────────────────────────────────────────────────────┐
//   │ HP [████████████████░░░░░░░░] 80/100                        │ ← top-left (x=15,y=15)
//   │ SHIELD [████████] 2 hits                                    │ ← (x=15,y=40)
//   │                SCORE: 12,450                                │ ← top-center (x=400,y=15)
//   │                x4 COMBO!                                    │ ← (x=400,y=42)
//   │                         LEVEL 3 — WAVE 5                    │ ← top-right (x=785,y=15)
//   │  [warning indicators on screen edges for off-screen enemies]│
//   │                                                             │
//   │                              [BOSS HP ██████░░░░] 45%      │ ← (x=200,y=55, width=400)
//   │                                                             │
//   │  ⚡ 6.2s  [timer bar]     (bottom-right)                    │ ← active power-ups
//   │  🛡 4.1s  [timer bar]     (x=650,y=540)                    │
//   │                                                             │
//   │                        [virtual joystick]  [fire btn]      │ ← mobile only
//   └──────────────────────────────────────────────────────────────┘

// ===== HEALTH BAR =====
HEALTH_BAR_X = 15
HEALTH_BAR_Y = 15
HEALTH_BAR_W = 200
HEALTH_BAR_H = 18
HEALTH_BAR_RADIUS = 4

function getHealthColor(percent) {
  if (percent > 0.5) return lerpColor(COLOR_HEALTH_YELLOW, COLOR_HEALTH_GREEN, (percent - 0.5) * 2);
  else              return lerpColor(COLOR_HEALTH_RED, COLOR_HEALTH_YELLOW, percent * 2);
}
// lerpColor(a, b, t) — linear interpolate between two hex colors

function drawHealthBar(ctx, currentHP, maxHP) {
  const percent = currentHP / maxHP;
  // Animate width
  const targetWidth = HEALTH_BAR_W * percent;
  uiState.healthBarWidth += (targetWidth - uiState.healthBarWidth) * 0.1; // smooth lerp

  const x = HEALTH_BAR_X, y = HEALTH_BAR_Y;

  // Background
  ctx.fillStyle = "#222222";
  roundRect(ctx, x, y, HEALTH_BAR_W, HEALTH_BAR_H, HEALTH_BAR_RADIUS);
  ctx.fill();

  // Fill (gradient)
  const grad = ctx.createLinearGradient(x, 0, x + HEALTH_BAR_W, 0);
  grad.addColorStop(0, COLOR_HEALTH_RED);
  grad.addColorStop(0.5, COLOR_HEALTH_YELLOW);
  grad.addColorStop(1, COLOR_HEALTH_GREEN);
  ctx.fillStyle = grad;
  roundRect(ctx, x, y, uiState.healthBarWidth, HEALTH_BAR_H, HEALTH_BAR_RADIUS);
  ctx.fill();

  // Border
  ctx.strokeStyle = COLOR_WHITE;
  ctx.lineWidth = 1.5;
  roundRect(ctx, x, y, HEALTH_BAR_W, HEALTH_BAR_H, HEALTH_BAR_RADIUS);
  ctx.stroke();

  // Text (right-aligned inside bar area)
  ctx.font = FONT_HUD;
  ctx.fillStyle = COLOR_WHITE;
  ctx.textAlign = "right";
  ctx.fillText(`HP ${Math.ceil(currentHP)}/${maxHP}`, x + HEALTH_BAR_W - 6, y + 14);
  ctx.textAlign = "left"; // reset
}

// ===== SHIELD BAR =====
SHIELD_BAR_X = 15
SHIELD_BAR_Y = 40
SHIELD_BAR_W = 150
SHIELD_BAR_H = 12

function drawShieldBar(ctx, shieldHits, maxShields) {
  if (shieldHits <= 0) return; // hidden when no shield

  const x = SHIELD_BAR_X, y = SHIELD_BAR_Y;
  const segmentW = SHIELD_BAR_W / maxShields;

  // Background
  ctx.fillStyle = "#1A1A3A";
  roundRect(ctx, x, y, SHIELD_BAR_W, SHIELD_BAR_H, 3);
  ctx.fill();

  // Active shield segments
  ctx.fillStyle = COLOR_SHIELD;
  for (i = 0; i < shieldHits; i++) {
    roundRect(ctx, x + i * segmentW + 2, y + 2, segmentW - 4, SHIELD_BAR_H - 4, 2);
    ctx.fill();
  }

  // Label
  ctx.font = FONT_HUD_SM;
  ctx.fillStyle = COLOR_SHIELD;
  ctx.textAlign = "left";
  ctx.fillText(`SHIELD ${shieldHits}/${maxShields}`, x + SHIELD_BAR_W + 8, y + 10);
}

// ===== SCORE DISPLAY =====
SCORE_X = 400
SCORE_Y = 15

function drawScore(ctx, currentScore) {
  // Animated counter: smoothly count up from display value to actual value
  if (uiState.scoreDisplayValue < currentScore) {
    const diff = currentScore - uiState.scoreDisplayValue;
    uiState.scoreDisplayValue += Math.max(1, Math.floor(diff * 0.1));
    if (uiState.scoreDisplayValue > currentScore) uiState.scoreDisplayValue = currentScore;
  }

  ctx.textAlign = "center";
  ctx.font = FONT_SCORE;
  ctx.fillStyle = COLOR_NEON_CYAN;
  ctx.fillText(`SCORE: ${Math.floor(uiState.scoreDisplayValue).toLocaleString()}`, SCORE_X, SCORE_Y);
}

// ===== COMBO MULTIPLIER =====
COMBO_X = 400
COMBO_Y = 42

function drawCombo(ctx, comboCount) {
  if (comboCount < 2) return; // hidden below 2x

  // Animate scale on combo increase
  if (comboCount > uiState.previousCombo) {
    uiState.comboScale = 1.5; // pop up
    uiState.comboTimer = 300;  // ms for animation
  }
  if (uiState.comboTimer > 0) {
    uiState.comboScale += (1.0 - uiState.comboScale) * 0.1;
    uiState.comboTimer -= 16;
  }
  uiState.previousCombo = comboCount;

  ctx.save();
  ctx.translate(COMBO_X, COMBO_Y);
  ctx.scale(uiState.comboScale, uiState.comboScale);
  ctx.font = FONT_COMBO;
  ctx.textAlign = "center";

  // Glow
  ctx.shadowColor = COLOR_COMBO;
  ctx.shadowBlur = 10;
  ctx.fillStyle = COLOR_COMBO;
  ctx.fillText(`x${comboCount} COMBO!`, 0, 0);

  ctx.shadowBlur = 0;
  ctx.restore();
}

// ===== LEVEL / WAVE INDICATOR =====
LEVEL_X = 785
LEVEL_Y = 15

function drawLevelIndicator(ctx, level, wave) {
  ctx.font = FONT_HUD;
  ctx.fillStyle = COLOR_NEON_YELLOW;
  ctx.textAlign = "right";
  ctx.fillText(`LEVEL ${level} — WAVE ${wave}`, LEVEL_X, LEVEL_Y);
}

// ===== BOSS HP BAR =====
BOSS_HP_X = 200
BOSS_HP_Y = 58
BOSS_HP_W = 400
BOSS_HP_H = 16

function drawBossHP(ctx, bossCurrentHP, bossMaxHP, bossName) {
  if (bossMaxHP <= 0) return; // hidden when no boss

  const percent = bossCurrentHP / bossMaxHP;
  uiState.bossHPWidth += ((BOSS_HP_W * percent) - uiState.bossHPWidth) * 0.1;

  // Boss name label
  ctx.font = FONT_HUD_SM;
  ctx.fillStyle = COLOR_NEON_RED;
  ctx.textAlign = "center";
  ctx.fillText(bossName, 400, BOSS_HP_Y - 2);

  // Background
  ctx.fillStyle = COLOR_BOSS_HP_BG;
  roundRect(ctx, BOSS_HP_X, BOSS_HP_Y, BOSS_HP_W, BOSS_HP_H, 4);
  ctx.fill();

  // Fill
  ctx.fillStyle = COLOR_BOSS_HP;
  roundRect(ctx, BOSS_HP_X, BOSS_HP_Y, uiState.bossHPWidth, BOSS_HP_H, 4);
  ctx.fill();

  // Border
  ctx.strokeStyle = COLOR_NEON_RED;
  ctx.lineWidth = 2;
  roundRect(ctx, BOSS_HP_X, BOSS_HP_Y, BOSS_HP_W, BOSS_HP_H, 4);
  ctx.stroke();

  // Percentage text
  ctx.font = FONT_HUD;
  ctx.fillStyle = COLOR_WHITE;
  ctx.fillText(`${Math.round(percent * 100)}%`, 400, BOSS_HP_Y + 13);
}

// ===== ACTIVE POWER-UP INDICATORS =====
POWERUP_INDICATOR_X = 650
POWERUP_INDICATOR_Y = 538

function drawPowerUpIndicators(ctx, activePowerUps) {
  // activePowerUps: [{type: "rapidfire", timeRemaining: 6.2, totalTime: 10}, ...]
  ctx.textAlign = "left";
  const x = POWERUP_INDICATOR_X;
  let y = POWERUP_INDICATOR_Y;

  const POWERUP_ICONS = {
    "rapidfire": { icon: "⚡ RAPID FIRE", color: "#FFAA00" },
    "shield":    { icon: "🛡 SHIELD",     color: "#3399FF" },
    "scoreboost":{ icon: "★ SCORE x3",   color: "#FFFF00" },
  };

  for (const pu of activePowerUps) {
    const info = POWERUP_ICONS[pu.type];
    if (!info) continue;

    // Icon + name
    ctx.font = FONT_HUD_SM;
    ctx.fillStyle = info.color;
    ctx.fillText(info.icon, x, y);

    // Timer bar
    const barW = 120;
    const barH = 6;
    const barX = x;
    const barY = y + 4;
    const progress = pu.timeRemaining / pu.totalTime;

    ctx.fillStyle = "#222222";
    ctx.fillRect(barX, barY, barW, barH);
    ctx.fillStyle = info.color;
    ctx.fillRect(barX, barY, barW * progress, barH);

    ctx.fillText(`${pu.timeRemaining.toFixed(1)}s`, barX + barW + 8, y + 5);

    y -= 30; // stack upward
  }
}

// ===== OFF-SCREEN ENEMY WARNING ARROWS =====
function drawWarningArrows(ctx, offScreenEnemies) {
  // offScreenEnemies: [{angle: radians from center, distance: normalized 0-1}]
  if (offScreenEnemies.length === 0) return;

  const cx = 400, cy = 300;

  for (const enemy of offScreenEnemies) {
    // Position arrow on screen edge
    const edgeX = cx + Math.cos(enemy.angle) * 380; // 380 to keep slightly inside
    const edgeY = cy + Math.sin(enemy.angle) * 280;

    // Clamp to a safe margin (20px from edge)
    const arrowX = Math.max(20, Math.min(780, edgeX));
    const arrowY = Math.max(20, Math.min(580, edgeY));

    // Pulsate based on distance (closer = faster pulse)
    const pulse = Math.sin(performance.now() * (10 - enemy.distance * 5) * 0.001) * 0.4 + 0.6;

    ctx.save();
    ctx.translate(arrowX, arrowY);
    ctx.rotate(enemy.angle);

    ctx.fillStyle = `rgba(255, 50, 50, ${pulse})`;
    ctx.beginPath();
    // Triangle arrow pointing toward center
    ctx.moveTo(12, 0);
    ctx.lineTo(-6, -8);
    ctx.lineTo(-6, 8);
    ctx.closePath();
    ctx.fill();

    ctx.restore();
  }
}

// ===== MOBILE TOUCH CONTROLS (only when touch detected) =====
JOYSTICK_BASE_X = 110
JOYSTICK_BASE_Y = 440
JOYSTICK_BASE_R = 75   // 150px diameter
JOYSTICK_THUMB_R = 30

FIRE_BTN_X = 680
FIRE_BTN_Y = 440
FIRE_BTN_R = 40       // 80px diameter

function drawMobileControls(ctx) {
  if (!uiState.isTouchDevice) return;

  ctx.globalAlpha = 0.3;

  // Joystick base
  ctx.strokeStyle = COLOR_WHITE;
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.arc(JOYSTICK_BASE_X, JOYSTICK_BASE_Y, JOYSTICK_BASE_R, 0, Math.PI*2);
  ctx.stroke();

  // Joystick thumb at current drag position (or center if idle)
  const thumbX = mobileControls.joystickDX * JOYSTICK_BASE_R + JOYSTICK_BASE_X;
  const thumbY = mobileControls.joystickDY * JOYSTICK_BASE_R + JOYSTICK_BASE_Y;
  ctx.fillStyle = COLOR_WHITE;
  ctx.beginPath();
  ctx.arc(thumbX, thumbY, JOYSTICK_THUMB_R, 0, Math.PI*2);
  ctx.fill();

  // Fire button
  ctx.beginPath();
  ctx.arc(FIRE_BTN_X, FIRE_BTN_Y, FIRE_BTN_R, 0, Math.PI*2);
  ctx.strokeStyle = COLOR_NEON_RED;
  ctx.lineWidth = 3;
  ctx.stroke();
  ctx.fillStyle = "rgba(255, 50, 50, 0.2)";
  ctx.fill();

  ctx.font = FONT_HUD;
  ctx.fillStyle = COLOR_NEON_RED;
  ctx.textAlign = "center";
  ctx.fillText("FIRE", FIRE_BTN_X, FIRE_BTN_Y + 6);

  ctx.globalAlpha = 1.0;
}

// Mobile input state
mobileControls = {
  joystickActive: false,
  joystickTouchId: null,
  joystickDX: 0,  // -1 to 1
  joystickDY: 0,
  fireActive: false,
  fireTouchId: null,
};

function handleTouchStart(e) {
  uiState.isTouchDevice = true;
  for each touch in e.changedTouches:
    if (isInsideCircle(touch, JOYSTICK_BASE_X, JOYSTICK_BASE_Y, JOYSTICK_BASE_R * 1.5)) {
      mobileControls.joystickActive = true;
      mobileControls.joystickTouchId = touch.identifier;
      updateJoystick(touch);
    }
    else if (isInsideCircle(touch, FIRE_BTN_X, FIRE_BTN_Y, FIRE_BTN_R * 1.5)) {
      mobileControls.fireActive = true;
      mobileControls.fireTouchId = touch.identifier;
    }
}

function handleTouchMove(e) {
  for each touch in e.changedTouches:
    if (touch.identifier === mobileControls.joystickTouchId) {
      updateJoystick(touch);
    }
}

function handleTouchEnd(e) {
  for each touch in e.changedTouches:
    if (touch.identifier === mobileControls.joystickTouchId) {
      mobileControls.joystickActive = false;
      mobileControls.joystickDX = 0;
      mobileControls.joystickDY = 0;
    }
    if (touch.identifier === mobileControls.fireTouchId) {
      mobileControls.fireActive = false;
    }
}

function updateJoystick(touch) {
  const dx = touch.clientX - canvasRect.left - JOYSTICK_BASE_X;
  const dy = touch.clientY - canvasRect.top - JOYSTICK_BASE_Y;
  const dist = Math.sqrt(dx*dx + dy*dy);
  const maxDist = JOYSTICK_BASE_R;
  if (dist > maxDist) {
    mobileControls.joystickDX = dx / dist;
    mobileControls.joystickDY = dy / dist;
  } else {
    mobileControls.joystickDX = dx / maxDist;
    mobileControls.joystickDY = dy / maxDist;
  }
}


================================================================================
SECTION 4: PAUSE MENU
================================================================================

// Semi-transparent dark overlay over the frozen game frame, then menu on top.

function drawPauseMenu(ctx, gameFrameSnapshot) {
  // Option A: Use frozen game frame as background
  // ctx.drawImage(gameFrameSnapshot, 0, 0);
  // Option B: Dark overlay only (simpler, no snapshot needed)
  ctx.fillStyle = COLOR_OVERLAY;
  ctx.fillRect(0, 0, 800, 600);

  // Title
  drawGlowText(ctx, "PAUSED", 400, 180, FONT_TITLE, COLOR_NEON_CYAN, 12);
  ctx.font = FONT_TITLE;
  ctx.textAlign = "center";
  ctx.fillStyle = COLOR_WHITE;
  ctx.fillText("PAUSED", 400, 180);

  // Menu options
  const options = ["RESUME", "RESTART LEVEL", "QUIT TO MENU"];
  const startY = 290;
  const spacing = 45;

  for (i = 0; i < options.length; i++) {
    const y = startY + i * spacing;
    const isSelected = (i === uiState.selectedPauseIndex);

    if (isSelected) {
      ctx.fillStyle = COLOR_NEON_YELLOW;
      ctx.font = FONT_MENU;
      ctx.fillText("▶ " + options[i] + " ◀", 400, y);
    } else {
      ctx.fillStyle = COLOR_LIGHT_GRAY;
      ctx.font = FONT_MENU;
      ctx.fillText(options[i], 400, y);
    }
  }
}

function handlePauseInput(key) {
  if (key === "ArrowDown" || key === "s" || key === "S") {
    uiState.selectedPauseIndex = (uiState.selectedPauseIndex + 1) % 3;
  }
  if (key === "ArrowUp" || key === "w" || key === "W") {
    uiState.selectedPauseIndex = (uiState.selectedPauseIndex - 1 + 3) % 3;
  }
  if (key === "p" || key === "P" || key === "Escape") {
    // Resume
    uiState.currentScreen = UIScreen.PLAYING;
  }
  if (key === "Enter" || key === " ") {
    switch (uiState.selectedPauseIndex) {
      case 0: uiState.currentScreen = UIScreen.PLAYING; break;
      case 1: restartLevel(); break;
      case 2: transitionTo(UIScreen.MAIN_MENU); break;
    }
  }
}


================================================================================
SECTION 5: LEVEL TRANSITION SCREEN
================================================================================

// After boss defeated, 3-second celebration before upgrade shop:
//   0.0-0.5s: Screen freeze + fade overlay
//   0.5-2.5s: "LEVEL X COMPLETE!" appears with scale-up animation
//   0.5-2.5s: Score summary fades in below
//   2.5-3.0s: Fade out
//   3.0s:   → Transition to UPGRADE_SHOP screen

function drawLevelTransition(ctx, dt) {
  const { level, score, enemiesKilled, accuracy, bossDefeated } = levelResult;
  const elapsed = uiState.levelTransitionTimer;

  // Dark overlay
  const overlayAlpha = Math.min(1, elapsed / 500);
  ctx.fillStyle = `rgba(0, 0, 10, ${overlayAlpha})`;
  ctx.fillRect(0, 0, 800, 600);

  if (elapsed < 3000) {
    // Title animation (scale up from 0 to 1 over 500ms)
    let titleScale = Math.min(1, elapsed / 500);
    titleScale = easeOutBack(titleScale); // overshoot easing for punch

    ctx.save();
    ctx.translate(400, 150);
    ctx.scale(titleScale, titleScale);
    ctx.font = "bold 40px 'Orbitron', monospace";
    ctx.fillStyle = COLOR_NEON_YELLOW;
    ctx.textAlign = "center";
    ctx.shadowColor = COLOR_NEON_YELLOW;
    ctx.shadowBlur = 20;
    ctx.fillText(`LEVEL ${level} COMPLETE!`, 0, 0);
    ctx.shadowBlur = 0;
    ctx.restore();

    // Stats (fade in after 1s)
    if (elapsed > 800) {
      const statAlpha = Math.min(1, (elapsed - 800) / 500);
      ctx.globalAlpha = statAlpha;
      ctx.font = FONT_MENU;
      ctx.textAlign = "center";
      ctx.fillStyle = COLOR_WHITE;
      ctx.fillText(`SCORE: ${score.toLocaleString()}`, 400, 260);
      ctx.font = FONT_HUD;
      ctx.fillStyle = COLOR_LIGHT_GRAY;
      ctx.fillText(`Enemies Killed: ${enemiesKilled}  |  Accuracy: ${accuracy}%  |  Boss Defeated: ${bossDefeated ? "YES" : "NO"}`, 400, 300);

      // Upgrade points earned
      const points = calculateUpgradePoints(level, score, accuracy);
      ctx.font = FONT_MENU;
      ctx.fillStyle = COLOR_NEON_GREEN;
      ctx.fillText(`UPGRADE POINTS EARNED: ${points}`, 400, 350);
      ctx.globalAlpha = 1;
    }
  }
}

function updateLevelTransition(dt) {
  uiState.levelTransitionTimer += dt * 1000; // dt in seconds
  if (uiState.levelTransitionTimer >= 3000) {
    transitionTo(UIScreen.UPGRADE_SHOP);
    uiState.levelTransitionTimer = 0;
    uiState.shopPoints = calculateUpgradePoints(levelResult.level, levelResult.score, levelResult.accuracy);
  }
}

function calculateUpgradePoints(level, score, accuracy) {
  // 1 base + 1 bonus for high accuracy + 1 bonus for high score
  let points = 1;
  if (accuracy >= 70) points++;
  if (score >= level * 2000) points++;
  return points; // returns 1-3
}


================================================================================
SECTION 6: UPGRADE SHOP
================================================================================

// Layout:
//   y=40 :  "UPGRADE SHOP" title
//   y=70 :  "Points Available: X" (neon green)
//   y=110:  Shop item list (4 items)
//   y=450:  "CURRENT STATS" section
//   y=550:  "PRESS SPACE TO CONTINUE"

SHOP_ITEMS = [
  {
    name: "ENGINE UPGRADE",
    desc: "+10% movement speed",
    cost: 1,
    maxLevel: 3,
    statKey: "engine",
    icon: "⟐"
  },
  {
    name: "WEAPON UPGRADE",
    desc: "+10% fire rate",
    cost: 1,
    maxLevel: 3,
    statKey: "weapon",
    icon: "✧"
  },
  {
    name: "ARMOR UPGRADE",
    desc: "+15 max HP",
    cost: 1,
    maxLevel: 2,
    statKey: "armor",
    icon: "⬡"
  },
  {
    name: "SHIELD CAPACITY",
    desc: "+1 shield hit absorbed",
    cost: 2,
    maxLevel: 2,
    statKey: "shield",
    icon: "◈"
  }
];

function drawUpgradeShop(ctx, dt) {
  updateStarfield(dt);
  drawStarfieldAt(ctx, 0.4);

  // Title
  drawGlowText(ctx, "UPGRADE SHOP", 400, 45, FONT_TITLE, COLOR_NEON_CYAN, 10);
  ctx.font = FONT_TITLE;
  ctx.textAlign = "center";
  ctx.fillStyle = COLOR_WHITE;
  ctx.fillText("UPGRADE SHOP", 400, 45);

  // Points display
  ctx.font = FONT_MENU;
  ctx.fillStyle = COLOR_NEON_GREEN;
  ctx.fillText(`POINTS AVAILABLE: ${uiState.shopPoints}`, 400, 80);

  // Shop items
  const startY = 120;
  const spacing = 60;

  for (i = 0; i < SHOP_ITEMS.length; i++) {
    const item = SHOP_ITEMS[i];
    const y = startY + i * spacing;
    const isSelected = (i === uiState.selectedShopIndex);
    const currentLevel = uiState.upgradeLevels[item.statKey];
    const isMaxed = currentLevel >= item.maxLevel;
    const canAfford = uiState.shopPoints >= item.cost && !isMaxed;

    // Selection highlight background
    if (isSelected) {
      ctx.fillStyle = "rgba(0, 255, 255, 0.08)";
      roundRect(ctx, 100, y - 22, 600, 50, 8);
      ctx.fill();
    }

    // Icon
    ctx.font = "24px sans-serif";
    ctx.textAlign = "left";
    ctx.fillStyle = isSelected ? COLOR_NEON_CYAN : COLOR_LIGHT_GRAY;
    ctx.fillText(item.icon, 120, y + 8);

    // Name + description
    ctx.font = FONT_MENU;
    ctx.fillStyle = isMaxed ? "#666666" : (isSelected ? COLOR_NEON_YELLOW : COLOR_WHITE);
    ctx.fillText(item.name, 160, y + 5);
    ctx.font = FONT_HUD_SM;
    ctx.fillStyle = isMaxed ? "#444444" : COLOR_LIGHT_GRAY;
    ctx.fillText(item.desc, 160, y + 22);

    // Level indicator (right side)
    ctx.font = FONT_HUD;
    ctx.textAlign = "right";
    let levelText = `LVL ${currentLevel}/${item.maxLevel}`;
    if (isMaxed) levelText = "MAX";
    ctx.fillStyle = isMaxed ? "#666666" : COLOR_WHITE;
    ctx.fillText(levelText, 500, y + 8);

    // Cost / Buy status
    ctx.font = FONT_HUD;
    if (isMaxed) {
      ctx.fillStyle = "#666666";
      ctx.fillText("MAXED", 670, y + 8);
    } else if (canAfford) {
      ctx.fillStyle = COLOR_NEON_GREEN;
      ctx.fillText(`${item.cost} PT`, 670, y + 8);
    } else {
      ctx.fillStyle = COLOR_NEON_RED;
      ctx.fillText(`${item.cost} PT`, 670, y + 8);
    }
    ctx.textAlign = "left";
  }

  // === CURRENT STATS (bottom section) ===
  ctx.font = FONT_MENU;
  ctx.textAlign = "center";
  ctx.fillStyle = COLOR_NEON_YELLOW;
  ctx.fillText("━━━ CURRENT STATS ━━━", 400, 390);

  const stats = getPlayerStats();
  ctx.font = FONT_HUD;
  const statLines = [
    { label: "SPEED",       current: `${(stats.baseSpeed).toFixed(1)}`, upgraded: stats.upgraded ? ` → ${(stats.upgradedSpeed).toFixed(1)}` : "" },
    { label: "FIRE RATE",   current: `${(stats.fireRate * 100).toFixed(0)}%`, upgraded: stats.upgraded ? "" : "" },
    { label: "MAX HP",      current: `${stats.maxHP}`, upgraded: stats.upgraded ? ` → ${stats.upgradedMaxHP}` : "" },
    { label: "SHIELDS",     current: `${stats.shieldHits}`, upgraded: stats.upgraded ? ` → ${stats.upgradedShields}` : "" },
  ];

  ctx.textAlign = "center";
  for (i = 0; i < statLines.length; i++) {
    const x = 150 + i * 180;
    ctx.fillStyle = COLOR_LIGHT_GRAY;
    ctx.fillText(statLines[i].label, x, 425);
    ctx.fillStyle = COLOR_WHITE;
    ctx.fillText(statLines[i].current + statLines[i].upgraded, x, 448);
  }

  // === CONTINUE PROMPT ===
  const blink = Math.sin(performance.now() * 0.004) > 0;
  if (blink) {
    ctx.fillStyle = COLOR_NEON_CYAN;
    ctx.fillText("PRESS SPACE TO CONTINUE", 400, 555);
  }
}

function handleShopInput(key) {
  if (key === "ArrowDown" || key === "s" || key === "S") {
    uiState.selectedShopIndex = (uiState.selectedShopIndex + 1) % SHOP_ITEMS.length;
  }
  if (key === "ArrowUp" || key === "w" || key === "W") {
    uiState.selectedShopIndex = (uiState.selectedShopIndex - 1 + SHOP_ITEMS.length) % SHOP_ITEMS.length;
  }
  if (key === "Enter") {
    buyUpgrade(uiState.selectedShopIndex);
  }
  if (key === " ") {
    // Continue to next level
    startNextLevel();
    uiState.currentScreen = UIScreen.PLAYING;
  }
}

function buyUpgrade(index) {
  const item = SHOP_ITEMS[index];
  const currentLevel = uiState.upgradeLevels[item.statKey];
  if (currentLevel >= item.maxLevel || uiState.shopPoints < item.cost) return;

  uiState.upgradeLevels[item.statKey]++;
  uiState.shopPoints -= item.cost;
  applyUpgrade(item.statKey, uiState.upgradeLevels[item.statKey]);
}


================================================================================
SECTION 7: GAME OVER SCREEN
================================================================================

// Layout:
//   Dark red-tinted background
//   y=100: "GAME OVER" (large text, fade in from 0 alpha over 1s)
//   y=150: "NEW HIGH SCORE!" (if applicable, golden, pulsing)
//   y=210: "FINAL SCORE: 12,450"
//   y=280: Stats section: enemies killed, accuracy, levels, time
//   y=450: "PRESS ENTER TO RESTART"  or  menu options

function drawGameOver(ctx, dt, gameOverTime) {
  // Red-tinted dark background
  ctx.fillStyle = "#1A0000";
  ctx.fillRect(0, 0, 800, 600);

  // Optional: slow drifting particles
  drawDeathParticles(ctx, dt);

  const elapsed = gameOverTime;
  const fadeIn = Math.min(1, elapsed / 1500);

  ctx.globalAlpha = fadeIn;
  ctx.textAlign = "center";

  // "GAME OVER" title
  drawGlowText(ctx, "GAME OVER", 400, 110, "bold 52px 'Orbitron', monospace", COLOR_NEON_RED, 14);
  ctx.font = "bold 52px 'Orbitron', monospace";
  ctx.fillStyle = COLOR_NEON_RED;
  ctx.fillText("GAME OVER", 400, 110);

  // NEW HIGH SCORE
  if (uiState.showHighScore) {
    const pulse = Math.sin(performance.now() * 0.005) * 5;
    ctx.font = FONT_MENU;
    ctx.fillStyle = COLOR_NEON_YELLOW;
    ctx.shadowColor = COLOR_NEON_YELLOW;
    ctx.shadowBlur = 10 + pulse;
    ctx.fillText("★ NEW HIGH SCORE! ★", 400, 160);
    ctx.shadowBlur = 0;
  }

  // Final score
  ctx.font = FONT_SCORE;
  ctx.fillStyle = COLOR_WHITE;
  ctx.fillText(`FINAL SCORE: ${finalScore.toLocaleString()}`, 400, 220);

  // Stats grid (2×2)
  ctx.font = FONT_HUD;
  ctx.fillStyle = COLOR_LIGHT_GRAY;
  const stats = [
    { label: "ENEMIES KILLED", value: gameStats.enemiesKilled },
    { label: "ACCURACY",       value: `${gameStats.accuracy}%` },
    { label: "LEVELS COMPLETED", value: gameStats.levelsCompleted },
    { label: "TIME SURVIVED",  value: formatTime(gameStats.timeSurvived) },
  ];
  for (i = 0; i < stats.length; i++) {
    const x = 250 + (i % 2) * 300;
    const y = 280 + Math.floor(i / 2) * 50;
    ctx.fillStyle = COLOR_LIGHT_GRAY;
    ctx.fillText(stats[i].label, x, y);
    ctx.fillStyle = COLOR_WHITE;
    ctx.font = FONT_MENU;
    ctx.fillText(stats[i].value, x, y + 28);
    ctx.font = FONT_HUD;
  }

  // Options
  const options = ["RESTART", "MAIN MENU"];
  const startY = 440;
  for (i = 0; i < options.length; i++) {
    const y = startY + i * 45;
    const isSelected = (i === uiState.selectedGameOverIndex);
    ctx.font = FONT_MENU;
    if (isSelected) {
      ctx.fillStyle = COLOR_NEON_YELLOW;
      ctx.fillText("▶ " + options[i] + " ◀", 400, y);
    } else {
      ctx.fillStyle = COLOR_LIGHT_GRAY;
      ctx.fillText(options[i], 400, y);
    }
  }

  ctx.globalAlpha = 1;
}

function handleGameOverInput(key) {
  if (key === "ArrowDown" || key === "s") uiState.selectedGameOverIndex = 1;
  if (key === "ArrowUp" || key === "w") uiState.selectedGameOverIndex = 0;
  if (key === "Enter" || key === " ") {
    switch (uiState.selectedGameOverIndex) {
      case 0: restartGame(); break;  // Resets and goes to PLAYING
      case 1: transitionTo(UIScreen.MAIN_MENU); break;
    }
  }
}

function formatTime(seconds) {
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}:${s.toString().padStart(2, '0')}`;
}


================================================================================
SECTION 8: VICTORY SCREEN
================================================================================

// Layout:
//   Celebration particle effects (gold, white, cyan sparkles)
//   y=100:  "VICTORY!" (neon gold, scaling pulse)
//   y=160:  "YOU SAVED THE GALAXY!"
//   y=230:  Final score
//   y=300:  Stats grid (same as game over)
//   y=480:  [PLAY AGAIN] [MAIN MENU]

// Celebration particles:
celebrationParticles: [{x, y, vx, vy, life, color, size}]

function initCelebrationParticles() {
  uiState.celebrationParticles = [];
  const colors = ["#FFD700", "#FFAA00", "#00FFFF", "#FF00FF", "#FFFFFF", "#FF4444"];
  for (i = 0; i < 100; i++) {
    uiState.celebrationParticles.push({
      x: Math.random() * 800,
      y: 600 + Math.random() * 100,  // start below screen
      vx: (Math.random() - 0.5) * 2,
      vy: -Math.random() * 4 - 1,
      life: 2 + Math.random() * 3,
      maxLife: 3,
      color: colors[Math.floor(Math.random() * colors.length)],
      size: 1 + Math.random() * 3
    });
  }
}

function updateCelebrationParticles(dt) {
  for each p:
    p.x += p.vx;
    p.y += p.vy;
    p.life -= dt;
    if (p.life <= 0) {
      p.x = Math.random() * 800;
      p.y = 600;
      p.vy = -Math.random() * 4 - 1;
      p.life = p.maxLife;
    }
}

function drawVictory(ctx, dt, victoryTime) {
  updateCelebrationParticles(dt);
  const elapsed = victoryTime;

  // Deep space background with celebratory tint
  ctx.fillStyle = "#050510";
  ctx.fillRect(0, 0, 800, 600);

  // Particles
  for each p in uiState.celebrationParticles:
    const alpha = Math.min(1, p.life / p.maxLife * 2);
    ctx.fillStyle = p.color;
    ctx.globalAlpha = alpha;
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.size, 0, Math.PI*2);
    ctx.fill();
  ctx.globalAlpha = 1;

  const fadeIn = Math.min(1, elapsed / 1500);

  ctx.globalAlpha = fadeIn;
  ctx.textAlign = "center";

  // VICTORY title
  const victoryPulse = Math.sin(performance.now() * 0.003) * 0.1 + 0.9;
  ctx.save();
  ctx.translate(400, 110);
  ctx.scale(victoryPulse, victoryPulse);
  drawGlowText(ctx, "VICTORY!", 0, 0, "bold 56px 'Orbitron', monospace", "#FFD700", 20);
  ctx.font = "bold 56px 'Orbitron', monospace";
  ctx.fillStyle = "#FFD700";
  ctx.fillText("VICTORY!", 0, 0);
  ctx.restore();

  // Subtitle
  ctx.font = FONT_SUBTITLE;
  ctx.fillStyle = COLOR_NEON_CYAN;
  ctx.fillText("YOU SAVED THE GALAXY!", 400, 180);

  // Final score
  ctx.font = FONT_SCORE;
  ctx.fillStyle = COLOR_WHITE;
  ctx.fillText(`FINAL SCORE: ${finalScore.toLocaleString()}`, 400, 240);

  // Stats (same layout as game over)
  ctx.font = FONT_HUD;
  const stats = [
    { label: "ENEMIES KILLED", value: gameStats.enemiesKilled },
    { label: "ACCURACY",       value: `${gameStats.accuracy}%` },
    { label: "LEVELS COMPLETED", value: gameStats.levelsCompleted },
    { label: "TIME SURVIVED",  value: formatTime(gameStats.timeSurvived) },
  ];
  for (i = 0; i < stats.length; i++) {
    const x = 250 + (i % 2) * 300;
    const y = 300 + Math.floor(i / 2) * 50;
    ctx.fillStyle = COLOR_LIGHT_GRAY;
    ctx.fillText(stats[i].label, x, y);
    ctx.fillStyle = COLOR_WHITE;
    ctx.font = FONT_MENU;
    ctx.fillText(stats[i].value, x, y + 28);
    ctx.font = FONT_HUD;
  }

  // Options
  const options = ["PLAY AGAIN", "MAIN MENU"];
  const startY = 460;
  for (i = 0; i < options.length; i++) {
    const y = startY + i * 45;
    const isSelected = (i === uiState.selectedGameOverIndex); // reuse index
    ctx.font = FONT_MENU;
    if (isSelected) {
      ctx.fillStyle = COLOR_NEON_YELLOW;
      ctx.fillText("▶ " + options[i] + " ◀", 400, y);
    } else {
      ctx.fillStyle = COLOR_LIGHT_GRAY;
      ctx.fillText(options[i], 400, y);
    }
  }

  ctx.globalAlpha = 1;
}


================================================================================
SECTION 9: TRANSITIONS & ANIMATIONS
================================================================================

// SCREEN TRANSITION SYSTEM:
TRANSITION_DURATION = 300; // ms for fade

function transitionTo(targetScreen) {
  uiState.transitionTarget = targetScreen;
  uiState.transitionTimer = 0;
  // Current screen renders at fading-out alpha
  // Target screen renders at fading-in alpha
}

function updateScreenTransition(dt) {
  if (uiState.transitionTarget === null) return;

  uiState.transitionTimer += dt * 1000;

  if (uiState.transitionTimer >= TRANSITION_DURATION) {
    uiState.currentScreen = uiState.transitionTarget;
    uiState.transitionTarget = null;
    uiState.transitionAlpha = 1.0;

    // On-screen-entry hooks
    if (uiState.currentScreen === UIScreen.PLAYING && !gameRunning) {
      startOrResumeGame();
    }
    if (uiState.currentScreen === UIScreen.VICTORY) {
      initCelebrationParticles();
    }
  }
}

function getTransitionAlpha() {
  if (uiState.transitionTarget === null) return { current: 1, incoming: 0 };
  const t = uiState.transitionTimer / TRANSITION_DURATION; // 0..1
  return {
    current: 1 - t,  // outgoing screen fades out
    incoming: t      // incoming screen fades in
  };
}

// EASING FUNCTION (for scale animations, score counting)
function easeOutBack(t) {
  const c1 = 1.70158;
  const c3 = c1 + 1;
  return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
}

function easeOutCubic(t) {
  return 1 - Math.pow(1 - t, 3);
}

// HEALTH BAR ANIMATION:
// Uses lerp in drawHealthBar: uiState.healthBarWidth += (target - current) * 0.1
// This gives smooth asymptotic approach, ~16px jump per frame at 60fps

// SCORE COUNTING:
// In drawScore: diff = actual - display; display += max(1, floor(diff * 0.1))
// At 60fps, this counts up ~10% of remaining difference per frame
// After ~30 frames (0.5s), 95% complete; full convergence in ~1s

// COMBO POP ANIMATION:
// On combo increase: comboScale = 1.5, comboTimer = 300ms
// Each frame: comboScale += (1.0 - comboScale) * 0.1 (spring-back)
// Result: scale pops to 1.5x, then settles back to 1.0x over ~200ms


================================================================================
SECTION 10: HIGH SCORE SYSTEM
================================================================================

// Storage key: "stellar_survivor_highscores"
// Format: JSON array of {name: "PLAYER", score: 12450, level: 5, date: "2026-05-05"}

HIGH_SCORE_KEY = "stellar_survivor_highscores"
MAX_HIGH_SCORES = 5

function loadHighScores() {
  try {
    const data = localStorage.getItem(HIGH_SCORE_KEY);
    return data ? JSON.parse(data) : [];
  } catch {
    return [];
  }
}

function saveHighScore(score, level, date) {
  const scores = loadHighScores();
  scores.push({ name: "PLAYER", score, level, date: date || new Date().toISOString().slice(0, 10) });
  scores.sort((a, b) => b.score - a.score);
  scores.splice(MAX_HIGH_SCORES);
  localStorage.setItem(HIGH_SCORE_KEY, JSON.stringify(scores));
  return scores;
}

function isNewHighScore(score) {
  const scores = loadHighScores();
  if (scores.length < MAX_HIGH_SCORES) return true;
  return score > scores[scores.length - 1].score;
}

// HIGH SCORES SCREEN:
function drawHighScores(ctx, dt) {
  updateStarfield(dt);
  drawStarfieldAt(ctx, 0.5);

  // Title
  drawGlowText(ctx, "HIGH SCORES", 400, 45, FONT_TITLE, COLOR_NEON_CYAN, 12);
  ctx.font = FONT_TITLE;
  ctx.textAlign = "center";
  ctx.fillStyle = COLOR_WHITE;
  ctx.fillText("HIGH SCORES", 400, 45);

  const scores = loadHighScores();

  if (scores.length === 0) {
    ctx.font = FONT_MENU;
    ctx.fillStyle = COLOR_LIGHT_GRAY;
    ctx.fillText("NO SCORES YET — GO PLAY!", 400, 300);
  } else {
    // Column headers
    ctx.font = FONT_HUD;
    ctx.fillStyle = COLOR_NEON_YELLOW;
    ctx.textAlign = "left";
    ctx.fillText("RANK", 150, 110);
    ctx.fillText("SCORE", 250, 110);
    ctx.fillText("LEVEL", 450, 110);
    ctx.fillText("DATE", 600, 110);

    // Divider
    ctx.strokeStyle = COLOR_DARK_GRAY;
    ctx.beginPath();
    ctx.moveTo(100, 120); ctx.lineTo(700, 120);
    ctx.stroke();

    // Score entries
    for (i = 0; i < scores.length; i++) {
      const y = 150 + i * 50;
      const rankColor = i === 0 ? "#FFD700" : (i === 1 ? "#C0C0C0" : (i === 2 ? "#CD7F32" : COLOR_LIGHT_GRAY));

      ctx.font = FONT_MENU;
      ctx.fillStyle = rankColor;
      ctx.fillText(`#${i + 1}`, 150, y);

      ctx.fillStyle = COLOR_WHITE;
      ctx.fillText(scores[i].score.toLocaleString(), 250, y);

      ctx.font = FONT_HUD;
      ctx.fillText(`Lv.${scores[i].level}`, 450, y);
      ctx.fillText(scores[i].date, 600, y);

      // Highlight row background for new entry (last added)
      if (scores[i].score === uiState.lastSavedScore) {
        ctx.fillStyle = "rgba(255, 255, 0, 0.05)";
        ctx.fillRect(100, y - 18, 620, 40);
      }
    }
  }

  // Return prompt
  const blink = Math.sin(performance.now() * 0.004) > 0;
  if (blink) {
    ctx.font = FONT_MENU;
    ctx.fillStyle = COLOR_NEON_CYAN;
    ctx.textAlign = "center";
    ctx.fillText("PRESS ENTER TO RETURN", 400, 560);
  }
}

function handleHighScoresInput(key) {
  if (key === "Enter" || key === "Escape" || key === " ") {
    transitionTo(UIScreen.MAIN_MENU);
  }
}


================================================================================
SECTION 11: UTILITY FUNCTIONS
================================================================================

// === GLOW TEXT (shadow-based glow) ===
function drawGlowText(ctx, text, x, y, font, color, glowRadius) {
  ctx.save();
  ctx.font = font;
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.shadowColor = color;
  ctx.shadowBlur = glowRadius;
  ctx.fillStyle = color;
  ctx.fillText(text, x, y);
  ctx.restore();
}

// === ROUNDED RECTANGLE ===
function roundRect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.arcTo(x + w, y, x + w, y + r, r);
  ctx.lineTo(x + w, y + h - r);
  ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
  ctx.lineTo(x + r, y + h);
  ctx.arcTo(x, y + h, x, y + h - r, r);
  ctx.lineTo(x, y + r);
  ctx.arcTo(x, y, x + r, y, r);
  ctx.closePath();
}

// === COLOR INTERPOLATION ===
function lerpColor(a, b, t) {
  // a and b are hex colors like "#FF0000"
  const ar = parseInt(a.slice(1,3), 16), ag = parseInt(a.slice(3,5), 16), ab = parseInt(a.slice(5,7), 16);
  const br = parseInt(b.slice(1,3), 16), bg = parseInt(b.slice(3,5), 16), bb = parseInt(b.slice(5,7), 16);
  const r = Math.round(ar + (br - ar) * t);
  const g = Math.round(ag + (bg - ag) * t);
  const b_ = Math.round(ab + (bb - ab) * t);
  return `rgb(${r},${g},${b_})`;
}

// === TOUCH DETECTION (for mobile controls) ===
function isInsideCircle(touch, cx, cy, r) {
  const dx = touch.clientX - canvasRect.left - cx;
  const dy = touch.clientY - canvasRect.top - cy;
  return (dx * dx + dy * dy) <= (r * r);
}

// === COLLECT UI INPUT (called from main game loop) ===
function handleUIInput(key, mouseX, mouseY) {
  switch (uiState.currentScreen) {
    case UIScreen.MAIN_MENU:     handleMenuInput(key, mouseX, mouseY); break;
    case UIScreen.HOW_TO_PLAY:   handleHowToPlayInput(key); break;
    case UIScreen.HIGH_SCORES:   handleHighScoresInput(key); break;
    case UIScreen.PAUSED:        handlePauseInput(key); break;
    case UIScreen.UPGRADE_SHOP:  handleShopInput(key); break;
    case UIScreen.GAME_OVER:     handleGameOverInput(key); break;
    case UIScreen.VICTORY:       {
      // Same as game over input handling (options: PLAY AGAIN, MAIN MENU)
      if (key === "ArrowDown" || key === "s") uiState.selectedGameOverIndex = 1;
      if (key === "ArrowUp" || key === "w") uiState.selectedGameOverIndex = 0;
      if (key === "Enter" || key === " ") {
        if (uiState.selectedGameOverIndex === 0) restartGame();
        else transitionTo(UIScreen.MAIN_MENU);
      }
      break;
    }
  }
}


================================================================================
SECTION 12: MAIN UI RENDER DISPATCH
================================================================================

function renderUI(ctx, dt) {
  switch (uiState.currentScreen) {
    case UIScreen.MAIN_MENU:
      drawMainMenu(ctx, dt);
      break;
    case UIScreen.HOW_TO_PLAY:
      drawHowToPlay(ctx, dt);
      break;
    case UIScreen.HIGH_SCORES:
      drawHighScores(ctx, dt);
      break;
    case UIScreen.PLAYING:
      // Game renders itself, HUD drawn on top
      drawHealthBar(ctx, playerHP, playerMaxHP);
      drawShieldBar(ctx, playerShieldHits, playerMaxShields);
      drawScore(ctx, gameScore);
      drawCombo(ctx, comboMultiplier);
      drawLevelIndicator(ctx, currentLevel, currentWave);
      drawBossHP(ctx, bossHP, bossMaxHP, bossName);
      drawPowerUpIndicators(ctx, activePowerUps);
      drawWarningArrows(ctx, offScreenEnemies);
      drawMobileControls(ctx);
      break;
    case UIScreen.PAUSED:
      drawPauseMenu(ctx);
      break;
    case UIScreen.LEVEL_TRANSITION:
      drawLevelTransition(ctx, dt);
      break;
    case UIScreen.UPGRADE_SHOP:
      drawUpgradeShop(ctx, dt);
      break;
    case UIScreen.GAME_OVER:
      drawGameOver(ctx, dt, gameOverElapsed);
      break;
    case UIScreen.VICTORY:
      drawVictory(ctx, dt, victoryElapsed);
      break;
  }

  // Draw transition overlay if transitioning
  if (uiState.transitionTarget !== null) {
    // Fade overlay approach: draw a black rect at the alpha of the transition
    const alpha = Math.abs(uiState.transitionTimer / TRANSITION_DURATION - 0.5) * 2;
    // Actually simpler: overlay with current screen's outgoing alpha
    const tx = getTransitionAlpha();
    // For simplicity, use a solid fade overlay
    ctx.fillStyle = `rgba(0, 0, 0, ${tx.current * 0.5})`;
    ctx.fillRect(0, 0, 800, 600);
  }
}


================================================================================
APPENDIX A: COORDINATE QUICK REFERENCE (800×600)
================================================================================

MAIN MENU:
  Title:          (400, 105)
  Subtitle:       (400, 165)
  Menu items:     (400, 250/290/330)  spacing 40
  Controls text:  (400, 520/545)
  Footer:         (400, 580)

HOW TO PLAY:
  Title:          (400, 45)
  Controls sec:   (80, 90)  header; items at y=125+28*i
  Enemies sec:    (80, 260) header; items at y=290+32*i
  Power-ups sec:  (80, 440) header; items at y=470+32*i
  Return prompt:  (400, 560)

IN-GAME HUD:
  Health bar:     (15, 15)  w=200 h=18
  Shield bar:     (15, 40)  w=150 h=12
  Score:          (400, 15)
  Combo:          (400, 42)
  Level/Wave:     (785, 15)  right-aligned
  Boss HP bar:    (200, 58)  w=400 h=16
  Power-up ind:   (650, 538) stacking upward
  Warning arrows: at screen edge per enemy angle
  Joystick base:  (110, 440) r=75
  Fire button:    (680, 440) r=40

PAUSE:
  Title:          (400, 180)
  Options:        (400, 290/335/380) spacing 45

LEVEL TRANSITION:
  Title:          (400, 150)
  Score:          (400, 260)
  Stats:          (400, 300)
  Points:         (400, 350)

UPGRADE SHOP:
  Title:          (400, 45)
  Points:         (400, 80)
  Items:          y=120+60*i, name at (160, y+5), cost at (670, y+8)
  Stats header:   (400, 390)
  Stat cols:      x=150/330/510/690, values at y=425/448
  Continue:       (400, 555)

GAME OVER / VICTORY:
  Title:          (400, 110)
  Subtitle:       (400, 160/180)
  Score:          (400, 220/240)
  Stats grid:     x=250/550, y=280/330 (or 300/350)
  Options:        (400, 440/485) or (460/505)

HIGH SCORES:
  Title:          (400, 45)
  Column labels:  x=150(RANK) 250(SCORE) 450(LEVEL) 600(DATE) at y=110
  Divider:        (100,120) to (700,120)
  Entries:        y=150+50*i, fields at same x as labels
  Return prompt:  (400, 560)


APPENDIX B: EVENT INTEGRATION GUIDE
================================================================================

// In main.js / game loop:

// INPUT HANDLING:
document.addEventListener('keydown', (e) => {
  if (uiState.currentScreen !== UIScreen.PLAYING) {
    handleUIInput(e.key);
    e.preventDefault();
    return;
  }
  // Gameplay keys (WASD, Space, P) handled by game input system
  if (e.key === 'p' || e.key === 'P') {
    uiState.currentScreen = UIScreen.PAUSED;
    uiState.selectedPauseIndex = 0;
  }
});

canvas.addEventListener('mousedown', (e) => {
  const rect = canvas.getBoundingClientRect();
  const mx = (e.clientX - rect.left) * (800 / rect.width);
  const my = (e.clientY - rect.top) * (600 / rect.height);
  handleUIInput(null, mx, my);
});

canvas.addEventListener('touchstart', handleTouchStart);
canvas.addEventListener('touchmove', handleTouchMove);
canvas.addEventListener('touchend', handleTouchEnd);
canvas.addEventListener('touchcancel', handleTouchEnd);

// GAME LOOP RENDER ORDER:
function gameLoop(timestamp) {
  const dt = (timestamp - lastTimestamp) / 1000; // seconds
  lastTimestamp = timestamp;

  update(dt);
  ctx.clearRect(0, 0, 800, 600);

  if (uiState.currentScreen === UIScreen.PLAYING) {
    renderGame(ctx, dt);        // game world, entities, effects
  }
  renderUI(ctx, dt);            // HUD on top of game, or full-screen menus

  updateScreenTransition(dt);   // handle ongoing transitions

  requestAnimationFrame(gameLoop);
}


APPENDIX C: FONT LOADING STRATEGY
================================================================================

// Option 1: Google Fonts Web Loader (simplest for single-file)
// Add to HTML: <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">

// Option 2: Base64 embed (for truly offline single-file)
// Download Orbitron .woff2, base64 encode it, and inject via @font-face style tag:

/*
const fontCSS = `
@font-face {
  font-family: 'Orbitron';
  src: url(data:font/woff2;base64,${BASE64_FONT_DATA}) format('woff2');
  font-weight: 400;
  font-style: normal;
}
@font-face {
  font-family: 'Orbitron';
  src: url(data:font/woff2;base64,${BASE64_FONT_DATA_BOLD}) format('woff2');
  font-weight: 700;
  font-style: normal;
}
`;
const style = document.createElement('style');
style.textContent = fontCSS;
document.head.appendChild(style);
*/

// Option 3: Fallback to monospace (always works, decent for arcade feel)
// All FONT_* constants include 'Courier New', monospace as fallback


APPENDIX D: POWER-UP TIMER TRACKING
================================================================================

// Used by the HUD power-up indicators. The game engine should update this array.
// The HUD reads from this shared state.

activePowerUps = []; // Array of {type: string, timeRemaining: float (seconds), totalTime: float}

// In game update loop:
function updatePowerUpTimers(dt) {
  for (i = activePowerUps.length - 1; i >= 0; i--) {
    activePowerUps[i].timeRemaining -= dt;
    if (activePowerUps[i].timeRemaining <= 0) {
      activePowerUps.splice(i, 1);
    }
  }
}

// When a power-up is collected:
function addPowerUp(type, duration) {
  // If same type exists, refresh duration instead of stacking
  const existing = activePowerUps.find(p => p.type === type);
  if (existing) {
    existing.timeRemaining = duration;
    existing.totalTime = duration;
  } else {
    activePowerUps.push({ type, timeRemaining: duration, totalTime: duration });
  }
}
