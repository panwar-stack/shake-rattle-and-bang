// ===== CORE ENGINE (Sections 1, 2, 3, 7, 8, 9, 18) =====

// ========== SECTION 1: CONSTANTS & CONFIG ==========

const TILE_SIZE       = 32;
const CANVAS_WIDTH    = 960;
const CANVAS_HEIGHT   = 640;
const GRAVITY         = 0.65;
const MAX_FALL_SPEED  = 14;
const PLAYER_SPEED    = 4;
const JUMP_VELOCITY   = -10;
const INVINCIBILITY_FRAMES = 90;
const POWERUP_DURATION     = 600;
const DOUBLE_JUMP_VEL      = -9;
const MAX_LIVES            = 3;
const STOMP_BOUNCE         = -7;

const TILE = {
  AIR:               0,
  DIRT:              1,
  STONE:             2,
  CLOUD:             3,
  BRICK:             4,
  PLATFORM:          5,
  SPIKE:             6,
  CHECKPOINT_FLAG:   7,
  EXIT_FLAG:         8,
  PIT:               9,
  DECO_GRASS:        10,
  DECO_STALACTITE:   11,
  DECO_STAR:         12,
  DECO_TORCH:        13,
};

const SOLID_TILES     = new Set([TILE.DIRT, TILE.STONE, TILE.CLOUD, TILE.BRICK]);
const HAZARD_TILES    = new Set([TILE.SPIKE, TILE.PIT]);
const PLATFORM_SET    = new Set([TILE.PLATFORM]);
const PASSABLE_SET    = new Set([TILE.AIR, TILE.DECO_GRASS, TILE.DECO_STALACTITE, TILE.DECO_STAR, TILE.DECO_TORCH]);
const TRIGGER_TILES   = new Set([TILE.CHECKPOINT_FLAG, TILE.EXIT_FLAG]);

const STATE = { TITLE: 0, PLAYING: 1, PAUSED: 2, LEVEL_COMPLETE: 3, GAME_OVER: 4, VICTORY: 5 };
const THEME = { GRASSLAND: 1, UNDERGROUND: 2, SKY: 3, CASTLE: 4 };

// ========== GLOBAL MUTABLE STATE (Section 11.1) ==========

let canvas, ctx;
let gameState       = STATE.TITLE;
let currentLevel    = 0;
let level           = null;

let player = {
  x: 0, y: 0,
  vx: 0, vy: 0,
  width: 28,
  height: 32,
  speed: PLAYER_SPEED,
  jumpForce: JUMP_VELOCITY,
  gravity: GRAVITY,
  onGround: false,
  facing: 1,
  alive: true,
  state: "idle",
  lives: MAX_LIVES,
  score: 0,
  coins: 0,
  powerups: {
    speed: false,
    invincible: false,
    doubleJump: false,
  },
  powerupTimers: {
    speed: 0,
    invincible: 0,
  },
  canDoubleJump: false,
  hasDoubleJumped: false,
  invincibleTimer: 0,
  animFrame: 0,
  animTimer: 0,
  lastCheckpoint: null,
  deathTimer: 0,
};

let camera = {
  x: 0, y: 0,
  width: CANVAS_WIDTH,
  height: CANVAS_HEIGHT,
  targetX: 0, targetY: 0,
  lerpSpeed: 0.08,
};

let enemies           = [];
let boss              = null;
let coins             = [];
let powerupItems      = [];
let projectiles       = [];
let particles         = [];
let keys              = {};
let touches           = {};
let activatedCheckpoints = new Set();
let transitionCooldown = 0;
let audioCtx          = null;
let soundBuffers      = {};
let bossMusicNode     = null;
let lastTime          = 0;
let globalFrame       = 0;
let bestScore         = 0;
let isMobile          = false;
let jumpWasPressed    = false;

const LS_BEST_SCORE = 'pixelquest_best';

// ========== SECTION 2: CANVAS SETUP ==========

function initCanvas() {
  canvas = document.getElementById('game');
  if (!canvas) {
    canvas = document.createElement('canvas');
    canvas.id = 'game';
    document.body.appendChild(canvas);
  }
  canvas.width = CANVAS_WIDTH;
  canvas.height = CANVAS_HEIGHT;
  canvas.style.imageRendering = 'pixelated';
  canvas.style.touchAction = 'none';
  ctx = canvas.getContext('2d');
  ctx.imageSmoothingEnabled = false;
  resizeCanvas();
}

function resizeCanvas() {
  const maxW = window.innerWidth;
  const maxH = window.innerHeight;
  const ratio = CANVAS_WIDTH / CANVAS_HEIGHT;
  let displayW, displayH;
  if (maxW / maxH > ratio) {
    displayH = maxH;
    displayW = maxH * ratio;
  } else {
    displayW = maxW;
    displayH = maxW / ratio;
  }
  canvas.style.width  = Math.floor(displayW) + 'px';
  canvas.style.height = Math.floor(displayH) + 'px';
}

// ========== SECTION 3: INPUT HANDLING ==========

function setupInput() {
  isMobile = 'ontouchstart' in window;

  window.addEventListener('keydown', handleKeyDown);
  window.addEventListener('keyup', handleKeyUp);

  if (isMobile) {
    canvas.addEventListener('touchstart', handleTouchStart, { passive: false });
    canvas.addEventListener('touchmove', handleTouchMove, { passive: false });
    canvas.addEventListener('touchend', handleTouchEnd);
    canvas.addEventListener('touchcancel', handleTouchEnd);
  }

  window.addEventListener('resize', resizeCanvas);
}

function handleKeyDown(e) {
  keys[e.code] = true;
  if (e.code === 'Space' || e.code === 'ArrowUp' || e.code === 'ArrowDown') {
    e.preventDefault();
  }
}

function handleKeyUp(e) {
  keys[e.code] = false;
}

function getTouchZones() {
  const scaleX = CANVAS_WIDTH / (parseFloat(canvas.style.width) || CANVAS_WIDTH);
  const scaleY = CANVAS_HEIGHT / (parseFloat(canvas.style.height) || CANVAS_HEIGHT);
  return {
    left:  { x: 10,               y: CANVAS_HEIGHT - 150, w: 80, h: 80, scaleX, scaleY },
    right: { x: 110,              y: CANVAS_HEIGHT - 150, w: 80, h: 80, scaleX, scaleY },
    jump:  { x: CANVAS_WIDTH - 150, y: CANVAS_HEIGHT - 170, w: 120, h: 120, scaleX, scaleY },
  };
}

function moveEventToCanvas(e) {
  const rect = canvas.getBoundingClientRect();
  const touch = e.touches[0] || e.changedTouches[0];
  if (!touch) return null;
  return {
    x: (touch.clientX - rect.left) * (CANVAS_WIDTH / rect.width),
    y: (touch.clientY - rect.top) * (CANVAS_HEIGHT / rect.height),
  };
}

function isPointInZone(px, py, zone) {
  return px >= zone.x && px <= zone.x + zone.w && py >= zone.y && py <= zone.y + zone.h;
}

function handleTouchStart(e) {
  e.preventDefault();
  const point = moveEventToCanvas(e);
  if (!point) return;
  const zones = getTouchZones();
  if (isPointInZone(point.x, point.y, zones.left))  { touches.left = true; touches.right = false; }
  if (isPointInZone(point.x, point.y, zones.right)) { touches.right = true; touches.left = false; }
  if (isPointInZone(point.x, point.y, zones.jump))  { touches.jump = true; }
}

function handleTouchMove(e) {
  e.preventDefault();
  const point = moveEventToCanvas(e);
  if (!point) return;
  const zones = getTouchZones();
  touches.left = false;
  touches.right = false;
  touches.jump = false;
  if (isPointInZone(point.x, point.y, zones.left))  touches.left = true;
  if (isPointInZone(point.x, point.y, zones.right)) touches.right = true;
  if (isPointInZone(point.x, point.y, zones.jump))  touches.jump = true;
}

function handleTouchEnd(e) {
  e.preventDefault();
  touches.left = false;
  touches.right = false;
  touches.jump = false;
}

function isPressed(action) {
  switch (action) {
    case 'left':  return keys['ArrowLeft'] || keys['KeyA'] || touches.left;
    case 'right': return keys['ArrowRight'] || keys['KeyD'] || touches.right;
    case 'jump':  return keys['Space'] || keys['ArrowUp'] || keys['KeyW'] || touches.jump;
    default:      return false;
  }
}

function processInput() {
  if (!player.alive) { player.vx = 0; return; }

  player.vx = 0;
  if (isPressed('left'))  player.vx = -player.speed;
  if (isPressed('right')) player.vx = player.speed;

  const jumpNow = isPressed('jump');
  if (jumpNow && !jumpWasPressed) {
    if (player.onGround) {
      player.vy = player.jumpForce;
      player.onGround = false;
      if (typeof playSound === 'function') playSound('jump');
    } else if (player.canDoubleJump && !player.hasDoubleJumped) {
      player.vy = DOUBLE_JUMP_VEL;
      player.hasDoubleJumped = true;
      if (typeof playSound === 'function') playSound('jump');
    }
  }
  jumpWasPressed = jumpNow;
}

function handleInput() {
  if (transitionCooldown > 0) {
    transitionCooldown--;
  }

  const enterOrSpace = keys['Enter'] || keys['Space'];
  const tapCheck = enterOrSpace || (isMobile && Object.keys(touches).length > 0);

  switch (gameState) {
    case STATE.TITLE:
      if (tapCheck && transitionCooldown <= 0) {
        player.score = 0;
        player.lives = MAX_LIVES;
        player.coins = 0;
        loadLevel(0);
        transitionCooldown = 30;
      }
      break;

    case STATE.PLAYING:
      if ((keys['KeyP'] || keys['Escape']) && transitionCooldown <= 0) {
        gameState = STATE.PAUSED;
        transitionCooldown = 30;
        keys['KeyP'] = false;
        keys['Escape'] = false;
      }
      if (keys['KeyR']) {
        player.score = 0;
        player.lives = MAX_LIVES;
        gameState = STATE.TITLE;
        transitionCooldown = 30;
        keys['KeyR'] = false;
      }
      break;

    case STATE.PAUSED:
      if ((keys['KeyP'] || keys['Escape']) && transitionCooldown <= 0) {
        gameState = STATE.PLAYING;
        transitionCooldown = 30;
        keys['KeyP'] = false;
        keys['Escape'] = false;
      }
      if (keys['KeyR']) {
        player.score = 0;
        player.lives = MAX_LIVES;
        gameState = STATE.TITLE;
        transitionCooldown = 30;
        keys['KeyR'] = false;
      }
      break;

    case STATE.LEVEL_COMPLETE:
      if (tapCheck && transitionCooldown <= 0) {
        loadLevel(currentLevel + 1);
        transitionCooldown = 30;
      }
      break;

    case STATE.GAME_OVER:
      if (tapCheck && transitionCooldown <= 0) {
        player.score = 0;
        player.lives = MAX_LIVES;
        player.coins = 0;
        gameState = STATE.TITLE;
        transitionCooldown = 30;
      }
      break;

    case STATE.VICTORY:
      if (tapCheck && transitionCooldown <= 0) {
        player.score = 0;
        player.lives = MAX_LIVES;
        player.coins = 0;
        gameState = STATE.TITLE;
        transitionCooldown = 30;
      }
      break;
  }
}

function renderTouchControls(ctx) {
  if (!isMobile) return;
  const zones = getTouchZones();

  ctx.save();
  ctx.globalAlpha = 0.2;

  ctx.fillStyle = '#FFF';
  ctx.fillRect(zones.left.x, zones.left.y, zones.left.w, zones.left.h);
  ctx.fillRect(zones.right.x, zones.right.y, zones.right.w, zones.right.h);

  ctx.beginPath();
  ctx.arc(zones.jump.x + zones.jump.w / 2, zones.jump.y + zones.jump.h / 2, zones.jump.w / 2, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();

  ctx.save();
  ctx.globalAlpha = 0.5;
  ctx.fillStyle = '#000';
  ctx.font = '28px monospace';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('<', zones.left.x + zones.left.w / 2, zones.left.y + zones.left.h / 2);
  ctx.fillText('>', zones.right.x + zones.right.w / 2, zones.right.y + zones.right.h / 2);
  ctx.fillText('JUMP', zones.jump.x + zones.jump.w / 2, zones.jump.y + zones.jump.h / 2);
  ctx.restore();
}

// ========== SECTION 7: GAME STATE & PLAYER STATE ==========

function initPlayer() {
  player.x = 0;
  player.y = 0;
  player.vx = 0;
  player.vy = 0;
  player.width = 28;
  player.height = 32;
  player.speed = PLAYER_SPEED;
  player.jumpForce = JUMP_VELOCITY;
  player.gravity = GRAVITY;
  player.onGround = false;
  player.facing = 1;
  player.alive = true;
  player.state = "idle";
  player.lives = MAX_LIVES;
  player.score = 0;
  player.coins = 0;
  player.powerups = { speed: false, invincible: false, doubleJump: false };
  player.powerupTimers = { speed: 0, invincible: 0 };
  player.canDoubleJump = false;
  player.hasDoubleJumped = false;
  player.invincibleTimer = 0;
  player.animFrame = 0;
  player.animTimer = 0;
  player.lastCheckpoint = null;
  player.deathTimer = 0;
}

function resetGame() {
  player.score = 0;
  player.lives = MAX_LIVES;
  player.coins = 0;
  gameState = STATE.TITLE;
}

function loadBestScore() {
  try {
    const stored = localStorage.getItem(LS_BEST_SCORE);
    bestScore = stored ? parseInt(stored, 10) : 0;
  } catch (e) {
    bestScore = 0;
  }
  return bestScore;
}

function saveBestScore(score) {
  if (score > bestScore) {
    bestScore = score;
    try {
      localStorage.setItem(LS_BEST_SCORE, String(score));
    } catch (e) {}
  }
}

// ========== SECTION 8: CAMERA SYSTEM ==========

function updateCamera(dt) {
  if (!level) return;

  camera.targetX = player.x + player.width / 2 - camera.width / 2;
  camera.targetY = player.y + player.height / 2 - camera.height / 2;

  camera.x += (camera.targetX - camera.x) * camera.lerpSpeed;
  camera.y += (camera.targetY - camera.y) * camera.lerpSpeed;

  const maxX = level.width * TILE_SIZE - camera.width;
  const maxY = level.height * TILE_SIZE - camera.height;

  if (maxX < 0) camera.x = maxX / 2;
  else camera.x = Math.max(0, Math.min(camera.x, maxX));

  if (maxY < 0) camera.y = maxY / 2;
  else camera.y = Math.max(0, Math.min(camera.y, maxY));
}

function snapCamera() {
  if (!level) return;

  camera.x = player.x + player.width / 2 - camera.width / 2;
  camera.y = player.y + player.height / 2 - camera.height / 2;

  const maxX = level.width * TILE_SIZE - camera.width;
  const maxY = level.height * TILE_SIZE - camera.height;

  camera.x = Math.max(0, Math.min(camera.x, maxX));
  camera.y = Math.max(0, Math.min(camera.y, maxY));

  if (maxX < 0) camera.x = maxX / 2;
  if (maxY < 0) camera.y = maxY / 2;

  camera.targetX = camera.x;
  camera.targetY = camera.y;
}

function isOnScreen(entity) {
  return (
    entity.x + entity.width > camera.x &&
    entity.x < camera.x + camera.width &&
    entity.y + entity.height > camera.y &&
    entity.y < camera.y + camera.height
  );
}

function worldToScreen(worldX, worldY) {
  return {
    x: Math.round(worldX - camera.x),
    y: Math.round(worldY - camera.y),
  };
}

// ========== SECTION 9: COLLISION SYSTEM ==========

function rectsOverlap(a, b) {
  return (
    a.x < b.x + b.width &&
    a.x + a.width > b.x &&
    a.y < b.y + b.height &&
    a.y + a.height > b.y
  );
}

function getTouchingTiles(entity) {
  const tiles = [];
  if (!level) return tiles;

  const startCol = Math.floor(entity.x / TILE_SIZE);
  const endCol   = Math.floor((entity.x + entity.width - 0.01) / TILE_SIZE);
  const startRow = Math.floor(entity.y / TILE_SIZE);
  const endRow   = Math.floor((entity.y + entity.height - 0.01) / TILE_SIZE);

  for (let row = startRow; row <= endRow; row++) {
    for (let col = startCol; col <= endCol; col++) {
      if (row >= 0 && row < level.height && col >= 0 && col < level.width) {
        const tileType = level.tiles[row][col];
        tiles.push({ col, row, type: tileType });
      }
    }
  }
  return tiles;
}

function resolvePlayerTileCollision(player, dt) {
  if (!level) return;
  const dtNorm = dt / 16.667;

  // --- PHASE 1: HORIZONTAL ---
  player.x += player.vx * dtNorm;

  const hTiles = getTouchingTiles(player);
  for (const tile of hTiles) {
    if (SOLID_TILES.has(tile.type)) {
      if (player.vx > 0) {
        player.x = tile.col * TILE_SIZE - player.width;
      } else if (player.vx < 0) {
        player.x = (tile.col + 1) * TILE_SIZE;
      }
      player.vx = 0;
    }
  }

  // --- PHASE 2: VERTICAL ---
  const prevBottom = player.y + player.height;
  player.y += player.vy * dtNorm;

  const vTiles = getTouchingTiles(player);
  player.onGround = false;

  for (const tile of vTiles) {
    if (SOLID_TILES.has(tile.type)) {
      if (player.vy > 0) {
        player.y = tile.row * TILE_SIZE - player.height;
        player.vy = 0;
        player.onGround = true;
        player.canDoubleJump = player.powerups.doubleJump;
        player.hasDoubleJumped = false;
      } else if (player.vy < 0) {
        player.y = (tile.row + 1) * TILE_SIZE;
        player.vy = 0;
      }
    }

    if (PLATFORM_SET.has(tile.type)) {
      if (player.vy >= 0 && prevBottom <= tile.row * TILE_SIZE + 2) {
        player.y = tile.row * TILE_SIZE - player.height;
        player.vy = 0;
        player.onGround = true;
        player.canDoubleJump = player.powerups.doubleJump;
        player.hasDoubleJumped = false;
      }
    }
  }

  // Fall off bottom of level
  if (player.y > level.height * TILE_SIZE + 64) {
    killPlayer();
  }

  // Clamp to level bounds
  player.x = Math.max(0, Math.min(player.x, level.width * TILE_SIZE - player.width));
}

function resolveEnemyTileCollision(enemy, dt) {
  if (!level) return;

  if (enemy.type === 'ghost') return;

  const dtNorm = dt / 16.667;

  // Horizontal
  enemy.x += enemy.vx * dtNorm;
  const hTiles = getTouchingTiles(enemy);
  for (const tile of hTiles) {
    if (SOLID_TILES.has(tile.type)) {
      if (enemy.vx > 0) {
        enemy.x = tile.col * TILE_SIZE - enemy.width;
      } else if (enemy.vx < 0) {
        enemy.x = (tile.col + 1) * TILE_SIZE;
      }
      enemy.vx = -enemy.vx;
    }
  }

  // Vertical
  enemy.y += enemy.vy * dtNorm;
  const vTiles = getTouchingTiles(enemy);
  for (const tile of vTiles) {
    if (SOLID_TILES.has(tile.type)) {
      if (enemy.vy > 0) {
        enemy.y = tile.row * TILE_SIZE - enemy.height;
        enemy.vy = 0;
      } else if (enemy.vy < 0) {
        enemy.y = (tile.row + 1) * TILE_SIZE;
        enemy.vy = 0;
      }
    }
  }

  // Fall off level
  if (enemy.y > level.height * TILE_SIZE + 64) {
    enemy.alive = false;
  }
}

function checkPlayerEnemyCollisions() {
  if (!player.alive) return;

  const playerPrevBottom = player.y + player.height - player.vy;

  for (const enemy of enemies) {
    if (!enemy.alive) continue;

    if (rectsOverlap(player, enemy)) {
      const isStomp = player.vy > 0 &&
        playerPrevBottom <= enemy.y + enemy.height * 0.5;

      if (enemy.type === 'ghost') {
        if (player.powerups.invincible || player.invincibleTimer > 0) {
          // nothing
        } else {
          hurtPlayer();
        }
        continue;
      }

      if (isStomp) {
        player.vy = STOMP_BOUNCE;
        if (typeof killEnemy === 'function') killEnemy(enemy);
        if (typeof spawnParticles === 'function') {
          spawnParticles(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2, 8, '#FFF');
        }
        if (typeof playSound === 'function') playSound('stomp');
      } else if (player.powerups.invincible || player.invincibleTimer > 0) {
        // nothing
      } else {
        hurtPlayer();
      }
    }
  }

  // Separate boss collision check
  if (boss && boss.alive && rectsOverlap(player, boss)) {
    const isStomp = player.vy > 0 &&
      playerPrevBottom <= boss.y + boss.height * 0.5;

    if (isStomp) {
      if (typeof damageBoss === 'function') damageBoss();
      player.vy = STOMP_BOUNCE;
    } else if (!player.powerups.invincible && player.invincibleTimer <= 0) {
      hurtPlayer();
    }
  }
}

function checkPlayerCollectibleCollisions() {
  if (!player.alive) return;

  for (const coin of coins) {
    if (!coin.alive) continue;
    if (rectsOverlap(player, coin)) {
      coin.alive = false;
      player.score += coin.value;
      player.coins++;
      if (typeof playSound === 'function') playSound('coin');
    }
  }

  for (const pu of powerupItems) {
    if (!pu.alive) continue;
    if (rectsOverlap(player, pu)) {
      pu.alive = false;
      activatePowerup(pu.type);
      if (typeof playSound === 'function') playSound('powerup');
    }
  }
}

function checkPlayerHazardCollisions() {
  if (!player.alive) return;
  if (player.powerups.invincible || player.invincibleTimer > 0) return;

  const touching = getTouchingTiles(player);
  for (const tile of touching) {
    if (HAZARD_TILES.has(tile.type)) {
      hurtPlayer();
      return;
    }
  }
}

function checkPlayerExitCollision() {
  if (!player.alive || !level) return;
  if (transitionCooldown > 0) return;
  if (!level.exit) return;

  const exitRect = {
    x: level.exit.col * TILE_SIZE,
    y: level.exit.row * TILE_SIZE,
    width: TILE_SIZE,
    height: TILE_SIZE,
  };

  if (rectsOverlap(player, exitRect)) {
    transitionCooldown = 60;
    if (currentLevel < 3) {
      gameState = STATE.LEVEL_COMPLETE;
      if (typeof playSound === 'function') playSound('levelComplete');
    } else {
      gameState = STATE.VICTORY;
      saveBestScore(player.score);
      if (typeof playSound === 'function') playSound('victory');
    }
  }
}

function checkCheckpointCollision() {
  if (!player.alive || !level) return;

  const touching = getTouchingTiles(player);
  for (const tile of touching) {
    if (tile.type === TILE.CHECKPOINT_FLAG) {
      const key = tile.col + ',' + tile.row;
      if (!activatedCheckpoints.has(key)) {
        activatedCheckpoints.add(key);
        player.lastCheckpoint = { col: tile.col, row: tile.row };
        if (typeof playSound === 'function') playSound('powerup');
      }
    }
  }
}

function checkPlayerProjectileCollisions() {
  if (!player.alive) return;
  if (player.powerups.invincible || player.invincibleTimer > 0) return;

  for (const proj of projectiles) {
    if (!proj.alive) continue;
    if (rectsOverlap(player, proj)) {
      proj.alive = false;
      hurtPlayer();
      return;
    }
  }
}

// ========== PLAYER STATE FUNCTIONS (referenced by collision system) ==========

function hurtPlayer() {
  if (player.invincibleTimer > 0 || player.powerups.invincible) return;
  if (!player.alive) return;

  player.lives--;
  if (player.lives <= 0) {
    killPlayer();
  } else {
    player.invincibleTimer = INVINCIBILITY_FRAMES;
    if (typeof playSound === 'function') playSound('hurt');
  }
}

function killPlayer() {
  if (!player.alive) return;
  player.alive = false;
  player.state = "dead";
  player.deathTimer = 60;
  player.vy = -6;
  if (typeof playSound === 'function') playSound('hurt');
  if (typeof spawnParticles === 'function') {
    spawnParticles(player.x + player.width / 2, player.y + player.height / 2, 12, '#FFF');
  }
}

function respawnPlayer() {
  player.lives--;
  player.alive = true;
  player.state = "idle";
  player.invincibleTimer = 120;
  player.powerups = { speed: false, invincible: false, doubleJump: false };
  player.powerupTimers = { speed: 0, invincible: 0 };
  player.canDoubleJump = false;
  player.hasDoubleJumped = false;

  if (player.lastCheckpoint) {
    player.x = player.lastCheckpoint.col * TILE_SIZE;
    player.y = player.lastCheckpoint.row * TILE_SIZE;
  } else if (level && level.playerSpawn) {
    player.x = level.playerSpawn.col * TILE_SIZE;
    player.y = level.playerSpawn.row * TILE_SIZE;
  } else {
    player.x = 2 * TILE_SIZE;
    player.y = 0;
  }

  player.vx = 0;
  player.vy = 0;

  if (level) {
    camera.x = player.x - CANVAS_WIDTH / 2;
    camera.y = player.y - CANVAS_HEIGHT / 2;
    const maxX = level.width * TILE_SIZE - CANVAS_WIDTH;
    const maxY = level.height * TILE_SIZE - CANVAS_HEIGHT;
    camera.x = Math.max(0, Math.min(camera.x, maxX));
    camera.y = Math.max(0, Math.min(camera.y, maxY));
    camera.targetX = camera.x;
    camera.targetY = camera.y;
  }
}

function activatePowerup(type) {
  switch (type) {
    case 'speed':
      player.powerups.speed = true;
      player.powerupTimers.speed = POWERUP_DURATION;
      player.speed = PLAYER_SPEED * 2;
      break;
    case 'invincible':
      player.powerups.invincible = true;
      player.powerupTimers.invincible = 480;
      break;
    case 'doubleJump':
      player.powerups.doubleJump = true;
      if (!player.onGround) {
        player.canDoubleJump = true;
        player.hasDoubleJumped = false;
      }
      break;
    case 'extraLife':
      if (player.lives < MAX_LIVES) {
        player.lives++;
      }
      break;
  }
}

function updatePowerupTimers(dt) {
  if (player.powerups.speed) {
    player.powerupTimers.speed--;
    if (player.powerupTimers.speed <= 0) {
      player.powerups.speed = false;
      player.powerupTimers.speed = 0;
      player.speed = PLAYER_SPEED;
    }
  }

  if (player.powerups.invincible) {
    player.powerupTimers.invincible--;
    if (player.powerupTimers.invincible <= 0) {
      player.powerups.invincible = false;
      player.powerupTimers.invincible = 0;
    }
  }

  if (player.invincibleTimer > 0) {
    player.invincibleTimer--;
    if (player.invincibleTimer < 0) player.invincibleTimer = 0;
  }
}

function checkDeathRespawn() {
  if (player.alive) return;

  player.deathTimer--;
  if (player.deathTimer <= 0) {
    if (player.lives > 0) {
      respawnPlayer();
    } else {
      saveBestScore(player.score);
      gameState = STATE.GAME_OVER;
      if (typeof playSound === 'function') playSound('gameOver');
    }
  }
}

// ========== LEVEL LOADING ==========

function loadLevel(levelIndex) {
  currentLevel = levelIndex;
  level = levels[currentLevel];
  transitionCooldown = 30;

  if (!level) return;

  // Reset player from spawn
  if (level.playerSpawn) {
    player.x = level.playerSpawn.col * TILE_SIZE;
    player.y = level.playerSpawn.row * TILE_SIZE;
  } else {
    player.x = 2 * TILE_SIZE;
    player.y = 0;
  }
  player.vx = 0;
  player.vy = 0;
  player.alive = true;
  player.state = "idle";
  player.facing = 1;
  player.powerups = { speed: false, invincible: false, doubleJump: false };
  player.powerupTimers = { speed: 0, invincible: 0 };
  player.canDoubleJump = false;
  player.hasDoubleJumped = false;
  player.invincibleTimer = 0;
  player.animFrame = 0;
  player.animTimer = 0;
  player.lastCheckpoint = null;
  player.deathTimer = 0;
  player.speed = PLAYER_SPEED;

  // Build runtime entities from level data
  enemies = [];
  if (level.enemies) {
    if (typeof initEnemies === 'function') {
      initEnemies();
    } else {
      for (const def of level.enemies) {
        const enemy = {
          type: def.type,
          x: def.col * TILE_SIZE,
          y: def.row * TILE_SIZE,
          width: 28, height: 24,
          vx: 0, vy: 0,
          alive: true,
          facing: def.direction || 1,
          animFrame: 0, animTimer: 0,
          spawnX: def.col * TILE_SIZE,
          patrolLeft: (def.col - (def.patrolRange || 2)) * TILE_SIZE,
          patrolRight: (def.col + (def.patrolRange || 2)) * TILE_SIZE,
          baseY: def.row * TILE_SIZE,
          phase: 0,
          shootTimer: 0,
          shootInterval: def.shootInterval || 120,
          aggroRange: (def.aggroRange || 8) * TILE_SIZE,
          speed: def.speed || 1.5,
          amplitude: def.amplitude || 2,
          frequency: def.frequency || 0.02,
        };
        // Set correct dimensions per type
        switch (def.type) {
          case 'slime':    enemy.width = 28; enemy.height = 24; break;
          case 'bat':      enemy.width = 24; enemy.height = 20; enemy.y -= enemy.height; break;
          case 'skeleton': enemy.width = 28; enemy.height = 32; break;
          case 'ghost':    enemy.width = 28; enemy.height = 30; enemy.y -= enemy.height; break;
        }
        enemies.push(enemy);
      }
    }
  }

  coins = [];
  if (level.coins) {
    if (typeof initCollectibles === 'function') {
      initCollectibles();
    } else {
      for (const def of level.coins) {
        coins.push({
          x: def.col * TILE_SIZE + 8,
          y: def.row * TILE_SIZE + 8,
          width: 16, height: 16,
          value: def.value || 10,
          alive: true,
          animFrame: 0,
          animTimer: 0,
        });
      }
    }
  }

  powerupItems = [];
  if (level.powerups) {
    for (const def of level.powerups) {
      powerupItems.push({
        x: def.col * TILE_SIZE + 4,
        y: def.row * TILE_SIZE + 4,
        width: 24, height: 24,
        type: def.type,
        alive: true,
        animFrame: 0,
        animTimer: 0,
        bobOffset: Math.random() * Math.PI * 2,
      });
    }
  }

  projectiles = [];
  particles = [];
  activatedCheckpoints = new Set();

  // Init boss for level 3
  boss = null;
  if (currentLevel === 3 && level.boss) {
    if (typeof initBoss === 'function') {
      initBoss();
    } else {
      boss = {
        type: 'boss',
        x: level.boss.col * TILE_SIZE,
        y: level.boss.row * TILE_SIZE,
        width: level.boss.width || 64,
        height: level.boss.height || 64,
        vx: 0, vy: 0,
        hp: level.boss.hp || 5,
        maxHp: level.boss.hp || 5,
        phase: 1,
        invincibleTimer: 0,
        attackTimer: 0,
        attackInterval: level.boss.attackInterval || 90,
        currentAttack: 'idle',
        attackState: 'recovery',
        attackTime: 0,
        facing: -1,
        animFrame: 0,
        animTimer: 0,
        alive: true,
        attacks: level.boss.attacks || ['charge', 'fireball', 'stomp'],
      };
    }
  }

  if (currentLevel === 3 && boss) {
    if (typeof startBossMusic === 'function') startBossMusic();
  } else {
    if (typeof stopBossMusic === 'function') stopBossMusic();
  }

  snapCamera();
  gameState = STATE.PLAYING;
}

// ========== SECTION 18: GAME LOOP & MAIN ==========

function init() {
  initCanvas();
  setupInput();
  loadBestScore();
  resetGame();
  if (typeof initAudio === 'function') initAudio();
  lastTime = performance.now();
  requestAnimationFrame(gameLoop);
}

function gameLoop(timestamp) {
  const rawDt = timestamp - lastTime;
  const dt = Math.min(rawDt, 33.33);
  lastTime = timestamp;
  globalFrame++;

  update(dt);
  render();

  requestAnimationFrame(gameLoop);
}

function update(dt) {
  handleInput();

  if (gameState === STATE.PLAYING) {
    processInput();

    if (typeof updatePlayer === 'function') updatePlayer(dt);
    if (typeof updatePlayerAnimation === 'function') updatePlayerAnimation(dt);
    updateCamera(dt);
    if (typeof updateEnemies === 'function') updateEnemies(dt);
    if (typeof updateBoss === 'function') updateBoss(dt);
    if (typeof checkBossCollision === 'function') checkBossCollision();
    if (typeof updateProjectiles === 'function') updateProjectiles(dt);
    checkPlayerProjectileCollisions();
    if (typeof updateCollectibles === 'function') updateCollectibles(dt);
    updatePowerupTimers(dt);
    checkPlayerEnemyCollisions();
    checkPlayerCollectibleCollisions();
    checkPlayerHazardCollisions();
    checkPlayerExitCollision();
    checkCheckpointCollision();
    if (typeof updateParticles === 'function') updateParticles(dt);
    if (typeof updateAudio === 'function') updateAudio(dt);
    checkDeathRespawn();
  }
}

function render() {
  switch (gameState) {
    case STATE.TITLE:
      clearCanvas('#111');
      if (typeof renderTitleScreen === 'function') renderTitleScreen(ctx);
      break;

    case STATE.PLAYING:
      clearCanvas(level ? level.bgColor1 : '#000');
      if (typeof renderParallaxBackground === 'function') renderParallaxBackground(ctx);
      if (typeof renderTileMap === 'function') renderTileMap(ctx);
      if (typeof renderCollectibles === 'function') renderCollectibles(ctx);
      if (typeof renderEnemies === 'function') renderEnemies(ctx);
      if (typeof renderBoss === 'function') renderBoss(ctx);
      if (typeof renderProjectiles === 'function') renderProjectiles(ctx);
      if (typeof renderPlayer === 'function') renderPlayer(ctx);
      if (typeof renderParticles === 'function') renderParticles(ctx);
      if (typeof renderHUD === 'function') renderHUD(ctx, player, currentLevel);
      renderTouchControls(ctx);
      break;

    case STATE.PAUSED:
      clearCanvas(level ? level.bgColor1 : '#000');
      if (typeof renderParallaxBackground === 'function') renderParallaxBackground(ctx);
      if (typeof renderTileMap === 'function') renderTileMap(ctx);
      if (typeof renderCollectibles === 'function') renderCollectibles(ctx);
      if (typeof renderEnemies === 'function') renderEnemies(ctx);
      if (typeof renderBoss === 'function') renderBoss(ctx);
      if (typeof renderProjectiles === 'function') renderProjectiles(ctx);
      if (typeof renderPlayer === 'function') renderPlayer(ctx);
      if (typeof renderParticles === 'function') renderParticles(ctx);
      if (typeof renderHUD === 'function') renderHUD(ctx, player, currentLevel);
      renderTouchControls(ctx);
      if (typeof renderPauseScreen === 'function') renderPauseScreen(ctx);
      break;

    case STATE.LEVEL_COMPLETE:
      clearCanvas(level ? level.bgColor1 : '#000');
      if (typeof renderParallaxBackground === 'function') renderParallaxBackground(ctx);
      if (typeof renderTileMap === 'function') renderTileMap(ctx);
      if (typeof renderCollectibles === 'function') renderCollectibles(ctx);
      if (typeof renderEnemies === 'function') renderEnemies(ctx);
      if (typeof renderBoss === 'function') renderBoss(ctx);
      if (typeof renderProjectiles === 'function') renderProjectiles(ctx);
      if (typeof renderPlayer === 'function') renderPlayer(ctx);
      if (typeof renderParticles === 'function') renderParticles(ctx);
      if (typeof renderHUD === 'function') renderHUD(ctx, player, currentLevel);
      if (typeof renderLevelCompleteScreen === 'function') renderLevelCompleteScreen(ctx);
      break;

    case STATE.GAME_OVER:
      clearCanvas('#100');
      if (typeof renderGameOverScreen === 'function') renderGameOverScreen(ctx);
      break;

    case STATE.VICTORY:
      clearCanvas('#111');
      if (typeof renderVictoryScreen === 'function') renderVictoryScreen(ctx);
      break;

    default:
      clearCanvas('#000');
      break;
  }
}

function clearCanvas(color) {
  ctx.fillStyle = color || '#000';
  ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
}

window.addEventListener('load', init);
