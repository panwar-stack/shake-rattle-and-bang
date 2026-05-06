# Pixel Quest — 4-Level Browser Platformer
## Complete Technical Architecture Specification

---

## 1. FILE STRUCTURE (Single HTML File)

The entire game lives in one `index.html` file, organized in 18 numbered sections separated by clear HTML comments:

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>Pixel Quest</title>
  <style>/* CSS: black bg, centered canvas, overflow hidden, touch-action none */</style>
</head>
<body>
  <canvas id="game"></canvas>
  <script>
  // ========== SECTION 1: CONSTANTS & CONFIG ==========
  // ========== SECTION 2: CANVAS SETUP ==========
  // ========== SECTION 3: INPUT HANDLING ==========
  // ========== SECTION 4: AUDIO SYSTEM ==========
  // ========== SECTION 5: SPRITE DRAWING (ASSETS) ==========
  // ========== SECTION 6: LEVEL DATA ==========
  // ========== SECTION 7: GAME STATE & PLAYER STATE ==========
  // ========== SECTION 8: CAMERA SYSTEM ==========
  // ========== SECTION 9: COLLISION SYSTEM ==========
  // ========== SECTION 10: PLAYER LOGIC ==========
  // ========== SECTION 11: ENEMY LOGIC ==========
  // ========== SECTION 12: BOSS LOGIC ==========
  // ========== SECTION 13: COLLECTIBLES & POWERUPS ==========
  // ========== SECTION 14: PARTICLES ==========
  // ========== SECTION 15: RENDER PIPELINE ==========
  // ========== SECTION 16: UI SCREENS ==========
  // ========== SECTION 17: LEVEL TRANSITIONS ==========
  // ========== SECTION 18: GAME LOOP & MAIN ==========
  </script>
</body>
</html>
```

### CSS Responsibilities
- `body`: black background (`#000`), `margin: 0`, `overflow: hidden`, `display: flex`, `align-items: center`, `justify-content: center`, `height: 100vh`.
- `canvas`: `display: block`, `image-rendering: pixelated`, max 100vw/100vh with aspect-ratio preserved via JS `canvas.style.width`/`height`.
- `touch-action: none` on canvas to prevent browser gestures.

---

## 2. GAME STATE MACHINE

### State Enum

```js
const STATE = { TITLE: 0, PLAYING: 1, PAUSED: 2, LEVEL_COMPLETE: 3, GAME_OVER: 4, VICTORY: 5 };
let gameState = STATE.TITLE;
let currentLevel = 0;
```

### State Transition Table

```
                    +---------+
          +-------->|  TITLE  |<---------------+
          |         +----+----+                |
          |              | Enter/Space/Tap     |
          |              v                     |
          |         +---------+                |
          |    +--->| PLAYING |<--+            |
          |    |    +--+--+---+   |            |
          |    |       |  |       |            |
          |    | P key |  | death + lives>0    |
          |    |       |  | (respawn)          |
          |    |    +--+  v                    |
          |    |    v     (back to PLAYING)    |
          |    | +------+                      |
          |    | |PAUSED|                      |
          |    | +--+---+                      |
          |    |    | P key -> PLAYING         |
          |    |    | R key -> TITLE           |
          |    |                               |
          |    | exit (levels 0-2)             |
          |    v                               |
          | +---------------+                  |
          | |LEVEL_COMPLETE |                  |
          | +-------+-------+                  |
          |         | Enter/Space/Tap          |
          |         v                          |
          |  PLAYING (next level)              |
          |                                    |
          | exit (level 3 = final)             |
          |    v                               |
          | +---------+                       |
          | | VICTORY |--Enter/Tap--> TITLE   |
          | +---------+                       |
          |                                    |
          | death + lives==0                   |
          |    v                               |
          | +-----------+                     |
          +-| GAME_OVER |--Enter/Tap--> TITLE |
            +-----------+                     |

  R key from any PLAYING state -> TITLE (restart)
```

### Transition Rules (code-level)

| From           | To              | Condition                                           | Action                      |
|----------------|-----------------|-----------------------------------------------------|-----------------------------|
| TITLE          | PLAYING         | Enter / Space / Tap                                 | resetGame(), loadLevel(0)   |
| PLAYING        | PAUSED          | KeyP or Escape pressed                              | -                           |
| PLAYING        | LEVEL_COMPLETE  | Player collides with exit tile AND currentLevel < 3 | stopMusic(), playLevelCompleteSound() |
| PLAYING        | VICTORY         | Player collides with exit tile AND currentLevel == 3| stopMusic(), playVictorySound() |
| PLAYING        | GAME_OVER       | player.lives == 0 after hurt                         | playGameOverSound()         |
| PLAYING        | PLAYING         | player.lives > 0 after hurt -> respawn              | respawnPlayer()             |
| PAUSED         | PLAYING         | KeyP or Escape pressed                              | -                           |
| PAUSED         | TITLE           | KeyR pressed                                        | resetGame()                 |
| LEVEL_COMPLETE | PLAYING         | Enter / Space / Tap                                 | loadLevel(currentLevel + 1) |
| GAME_OVER      | TITLE           | Enter / Space / Tap                                 | resetGame()                 |
| VICTORY        | TITLE           | Enter / Space / Tap                                 | resetGame()                 |

### Additional global flag
- `let transitionCooldown = 0` — set to 30 frames after state transition to prevent accidental double-trigger.

---

## 3. DATA STRUCTURES

### 3.1 Constants

```js
const TILE_SIZE       = 32;
const CANVAS_WIDTH    = 960;
const CANVAS_HEIGHT   = 640;
const GRAVITY         = 0.65;
const MAX_FALL_SPEED  = 14;
const PLAYER_SPEED    = 4;
const JUMP_VELOCITY   = -10;
const INVINCIBILITY_FRAMES = 90;   // frames after taking damage
const POWERUP_DURATION     = 600;   // frames (10 sec at 60fps)
const DOUBLE_JUMP_VEL      = -9;
const MAX_LIVES            = 3;
const STOMP_BOUNCE         = -7;    // vertical velocity after stomping enemy

// Tile encoding numbers
const TILE = {
  AIR:               0,   // passable empty space
  DIRT:              1,   // solid block, grassland
  STONE:             2,   // solid block, underground
  CLOUD:             3,   // solid block, sky
  BRICK:             4,   // solid block, castle
  PLATFORM:          5,   // one-way platform (solid only when falling onto)
  SPIKE:             6,   // hazard - damages player
  CHECKPOINT_FLAG:   7,   // visual marker for checkpoint
  EXIT_FLAG:         8,   // goal / level exit
  PIT:               9,   // instant death zone
  DECO_GRASS:        10,  // passable decoration (grassland)
  DECO_STALACTITE:   11,  // passable decoration (underground)
  DECO_STAR:         12,  // passable decoration (sky)
  DECO_TORCH:        13,  // passable decoration (castle)
};

// Tile collision sets
const SOLID_TILES     = new Set([1, 2, 3, 4]);
const HAZARD_TILES    = new Set([6, 9]);
const PLATFORM_SET    = new Set([5]);
const PASSABLE_SET    = new Set([0, 10, 11, 12, 13]);
const TRIGGER_TILES   = new Set([7, 8]); // checkpoint & exit
const THEME = { GRASSLAND: 1, UNDERGROUND: 2, SKY: 3, CASTLE: 4 };
```

### 3.2 Level Data Format

Each level is a plain object. All 4 levels are stored in a `levels` array `[level0, level1, level2, level3]`.

```js
{
  id: Number,          // 0-3
  name: String,        // e.g. "Green Fields"
  theme: Number,       // THEME.GRASSLAND / UNDERGROUND / SKY / CASTLE
  width: Number,       // columns of tiles
  height: Number,      // rows of tiles (always 20)
  bgColor1: String,    // top gradient color (CSS hex, e.g. "#5C94FC")
  bgColor2: String,    // bottom gradient color
  bgGround: String,    // color for side "fill" below level if needed

  // CORE: 2D tile grid — tiles[row][col], row 0 = top, row = height-1 = bottom
  tiles: Array[height][width] of Number,

  // Entity definitions (world positions stored as tile column/row, converted to pixels on load)
  playerSpawn: { col: Number, row: Number },
  exit:        { col: Number, row: Number },

  enemies:     Array of EnemyDef,
  coins:       Array of { col, row, value },
  powerups:    Array of { col, row, type },
  checkpoints: Array of { col, row },

  // Parallax background layers (rendered behind tiles)
  parallax: {
    layers: [
      { color: String, shape: String, speed: Number },
      ...
    ]
  }
}
```

#### Level Dimensions Table

| Level | ID | Name           | Width | Theme       | bgColor1   | bgColor2   |
|-------|----|----------------|-------|-------------|------------|------------|
| 1     | 0  | Green Fields   | 120   | grassland   | #5C94FC    | #87CEEB    |
| 2     | 1  | Dark Caverns   | 100   | underground | #1a0a2e    | #2d1b4e    |
| 3     | 2  | Cloud Peaks    | 130   | sky         | #4a90d9    | #b8d4f0    |
| 4     | 3  | Demon Castle   | 110   | castle      | #1a0000    | #4a0000    |

#### Tile Visual Rendering Rules (how `drawTile(ctx, type)` behaves)

| Tile Type | Visual                                               |
|-----------|------------------------------------------------------|
| DIRT (1)  | Brown (#8B5E3C) rect, darker (#6B3E1C) grid lines, green (#4CAF50) tuft on top edge if tile above is AIR |
| STONE (2) | Gray (#808080) rect, darker gray (#606060) mortar lines in brick pattern |
| CLOUD (3) | White (#F5F5FF) fill, roundedRect(2,2,28,28,6), faint blue shadow offset |
| BRICK (4) | Dark red (#8B0000) rect, thin dark (#4A0000) horizontal/vertical mortar lines every 8px |
| PLATFORM (5) | Thin 32x8 rect at tile bottom, same color as theme solid tile |
| SPIKE (6) | Red (#FF0000) triangles: two isosceles triangles (base 16px at bottom, tip at top of tile) |
| PIT (9)   | Near-black (#111), subtle dark-red dots at bottom |
| CHECKPOINT_FLAG (7) | Brown pole (3px wide, 28px tall), colored flag (green for grassland, blue for sky, etc.) |
| EXIT_FLAG (8) | Same pole as checkpoint but larger flag, pulsing glow animation |
| DECO_GRASS (10) | Small green (#32CD32) blade shapes (2px wide, 6-10px tall, 3 per tile, random heights) |
| DECO_STALACTITE (11) | Gray (#777) triangle hanging from tile top, 8px wide, 10px tall |
| DECO_STAR (12) | Yellow (#FFD700) 4-point star, 6px radius |
| DECO_TORCH (13) | Brown bracket on wall + animated orange/red flame (3 frames) |

#### Enemy Definition (spawn data stored in level, runtime state added on init)

```js
// Spawn definition (in level data)
enemies: [
  {
    type: "slime",           // "slime" | "bat" | "skeleton" | "ghost"
    col: 30,                 // tile column
    row: 17,                 // tile row (enemy stands on this tile — body above)
    patrolRange: 3,          // tiles it walks in each direction from spawn
    direction: 1,            // initial facing: 1 = right, -1 = left
  },
  {
    type: "bat",
    col: 42,
    row: 10,
    amplitude: 4,            // vertical sine amplitude in tiles
    frequency: 0.02,         // sine wave frequency
    direction: -1,
    speed: 2,
  },
  {
    type: "skeleton",
    col: 55,
    row: 17,
    patrolRange: 4,
    direction: -1,
    shootInterval: 120,      // frames between bone throws
  },
  {
    type: "ghost",
    col: 70,
    row: 12,
    aggroRange: 8,           // tiles — if player within this many tiles, ghost chases
    speed: 1.5,
  },
]

// Runtime enemy state (created in loadLevel from spawn defs)
{
  type: String,              // "slime" | "bat" | "skeleton" | "ghost" | "boss"
  x: Number, y: Number,      // world pixel position
  width: Number, height: Number,
  vx: Number, vy: Number,
  alive: Boolean,
  facing: Number,            // 1 or -1
  animFrame: Number,         // current animation frame (0..n)
  animTimer: Number,         // accumulator for frame timing

  // Patrol-specific
  spawnX: Number,            // original X position
  patrolLeft: Number,        // left boundary in pixels
  patrolRight: Number,       // right boundary in pixels

  // Bat-specific
  baseY: Number,             // vertical center for sine wave
  phase: Number,             // current sine phase offset

  // Skeleton-specific
  shootTimer: Number,        // cooldown for bone throw
  shootInterval: Number,

  // Ghost-specific
  aggroRange: Number,        // chase activation distance in pixels
}
```

#### Boss Definition

```js
// In level 3 (castle) only:
boss: {
  type: "boss",
  col: 100,
  row: 13,
  hp: 5,                     // total hit points
  width: 64, height: 64,
  attacks: ["charge", "fireball", "stomp"],
  attackInterval: 90,        // frames between attacks
}

// Runtime boss state
{
  x: Number, y: Number,
  width: 64, height: 64,
  vx: Number, vy: Number,
  hp: Number,                // starts at 5, decreases on stomp or power-up hit
  maxHp: 5,
  phase: Number,             // 1, 2, or 3 (derived: phase 1 at hp 5-4, phase 2 at 3-2, phase 3 at 1)
  invincibleTimer: Number,   // brief invincibility after being hit
  attackTimer: Number,
  currentAttack: String,     // "charge" | "fireball" | "stomp" | "idle"
  attackState: String,       // "windup" | "active" | "recovery"
  attackTime: Number,        // timer for current attack phase
  facing: Number,
  animFrame: Number,
  animTimer: Number,
  alive: Boolean,
}
```

### 3.3 Player Runtime State

```js
let player = {
  // World position (pixels)
  x: 0, y: 0,

  // Velocity (pixels per frame)
  vx: 0, vy: 0,

  // Hitbox dimensions
  width: 28,
  height: 32,

  // Movement parameters
  speed: PLAYER_SPEED,      // 4 normally, 8 with speed powerup
  jumpForce: JUMP_VELOCITY, // -10
  gravity: GRAVITY,         // 0.65

  // State flags
  onGround: false,
  facing: 1,                // 1 = right, -1 = left
  alive: true,
  state: "idle",            // "idle" | "walk" | "jump" | "fall" | "dead"

  // Lives & Score
  lives: 3,
  score: 0,
  coins: 0,                 // coin count (can also just use score for coin tracking)

  // Powerups (active flags)
  powerups: {
    speed: false,           // doubles player.speed
    invincible: false,      // no damage from enemies/spikes
    doubleJump: false,      // can jump once in mid-air
  },

  // Powerup timers (frames remaining)
  powerupTimers: {
    speed: 0,
    invincible: 0,
  },

  // Air-jump state
  canDoubleJump: false,     // set true when doubleJump powerup active and player goes airborne
  hasDoubleJumped: false,   // set true after using double jump in current airtime

  // Invincibility after taking damage (flashing effect)
  invincibleTimer: 0,

  // Animation
  animFrame: 0,
  animTimer: 0,

  // Checkpoint data
  lastCheckpoint: null,     // { col, row, level } — null if no checkpoint reached

  // Death animation
  deathTimer: 0,            // countdown before respawn/game over
};
```

### 3.4 Enemy Type Reference Table

| Type     | W   | H   | Speed | Stompable | Behavior            | Points | Special                   |
|----------|-----|-----|-------|-----------|---------------------|--------|---------------------------|
| slime    | 28  | 24  | 1.5   | YES       | patrol left-right   | 100    | none                      |
| bat      | 24  | 20  | 2.0   | YES       | sine wave           | 150    | flies, ignores platforms  |
| skeleton | 28  | 32  | 2.0   | YES       | patrol + shoot      | 200    | throws bone projectile    |
| ghost    | 28  | 30  | 1.5   | NO        | chase when aggro    | 250    | passes through walls      |
| boss     | 64  | 64  | 2.5   | NO (only hp attacks) | boss phases     | 1000   | charge, fireball, stomp   |

### 3.5 Powerup Types

| Type        | Effect                                   | Duration (frames) | Visual                          | Sound          |
|-------------|------------------------------------------|--------------------|---------------------------------|----------------|
| "speed"     | player.speed *= 2, trail particles       | 600 (10 sec)       | blue glow aura, speed lines     | rising arp     |
| "invincible"| player.invincible = true, flashing player| 480 (8 sec)        | rainbow cycle tint              | ascending scale|
| "doubleJump"| player.doubleJump = true (permanent)     | until level end    | wing particles on double jump   | double beep    |
| "extraLife" | player.lives += 1 (instant)              | instant            | heart icon + particle burst     | 1-up chime     |

### 3.6 Collectible Types

| Type      | Value | Visual                                  | Collection Sound |
|-----------|-------|-----------------------------------------|------------------|
| coin_10   | 10    | Yellow circle, 16px diameter, spin anim | short beep       |
| gem_50    | 50    | Red diamond shape, 20px, glow anim      | double beep      |
| gem_100   | 100   | Blue diamond, bigger, sparkle           | triple beep      |

### 3.7 Projectile State

```js
// Runtime array, cleared on level load
let projectiles = [];
// Each projectile:
{
  x: Number, y: Number,
  vx: Number, vy: Number,
  width: Number, height: Number,
  damage: Number,           // damage to player (usually 1)
  color: String,            // for rendering
  type: String,             // "bone" | "fireball"
  alive: Boolean,
  lifetime: Number,         // max frames before auto-despawn
  age: Number,
}
```

### 3.8 Particle State

```js
let particles = [];
// Each particle:
{
  x: Number, y: Number,
  vx: Number, vy: Number,
  life: Number,             // remaining frames
  maxLife: Number,          // for opacity fade
  color: String,
  size: Number,
  gravity: Number,
}
```

---

## 4. GAME LOOP DESIGN

### 4.1 Main Loop Structure

```js
let lastTime = 0;
let globalFrame = 0;

function gameLoop(timestamp) {
  const rawDt = timestamp - lastTime;
  const dt = Math.min(rawDt, 33.33);  // cap at ~33ms to avoid spiral of death
  lastTime = timestamp;
  globalFrame++;

  update(dt);
  render();

  requestAnimationFrame(gameLoop);
}
```

### 4.2 Update Order (during PLAYING state)

```
update(dt):
  1. handleInput()                          -- process key/touch state into player.vx / jump trigger
  2. updatePlayer(dt)                       -- apply gravity, velocity, tile collision resolution
  3. updatePlayerAnimation(dt)              -- advance animation frame timer
  4. updateCamera(dt)                       -- smooth follow player, clamp to level bounds
  5. updateEnemies(dt)                      -- AI, movement, collision for each enemy
  6. updateBoss(dt)                         -- boss AI (if level 3)
  7. updateProjectiles(dt)                  -- move projectiles, resolve collisions
  8. updatePlayerProjectileCollisions()     -- projectile hits player?
  9. updateCollectibles(dt)                 -- coin/gem animation only, no physics
  10. updatePowerupTimers(dt)               -- decrement timers, deactivate expired powerups
  11. checkPlayerEnemyCollisions()          -- stomp or hurt
  12. checkPlayerCollectibleCollisions()    -- pick up coins/powerups
  13. checkPlayerHazardCollisions()         -- spikes, pits
  14. checkPlayerExitCollision()            -- reached goal?
  15. updateParticles(dt)                   -- particle physics and lifetime
  16. updateAudio(dt)                       -- boss music loop, etc.
  17. checkDeathRespawn()                   -- handle post-death timer
```

### 4.3 Render Order (during PLAYING state)

```
render():
  1. clearCanvas()                          -- fillRect entire canvas with level bgColor1
  2. renderParallaxBackground()             -- hills/clouds/stars layers
  3. renderTileMap()                        -- visible tiles only (camera culling)
  4. renderCollectibles()                   -- coins/gems
  5. renderPowerups()                       -- floating powerup items
  6. renderEnemies()                        -- enemies in view
  7. renderBoss()                           -- if alive and level 3
  8. renderProjectiles()                    -- bones, fireballs
  9. renderPlayer()                         -- player sprite (with flash if invincible)
  10. renderParticles()                     -- on top of everything
  11. renderHUD()                           -- score, lives, coins, level name, powerup icons
  12. renderTouchControls()                 -- semi-transparent button overlays (mobile only)
```

### 4.4 Design Principle: Fixed Timestep Emulation

The game uses a variable delta time capped at 33.33ms (~30fps minimum, 60fps typical). All physics use `dt` scaling:
- `player.vy += GRAVITY * dt` — where dt is normalized to 1.0 at 60fps (i.e. `dt_norm = dt / 16.667`)
- This ensures consistent game feel across refresh rates.

---

## 5. COLLISION SYSTEM DESIGN

### 5.1 AABB (Axis-Aligned Bounding Box)

Base function:

```js
function rectsOverlap(a, b) {
  return (
    a.x < b.x + b.width &&
    a.x + a.width > b.x &&
    a.y < b.y + b.height &&
    a.y + a.height > b.y
  );
}
```

### 5.2 Tile-Based Collisions

All tile collision uses a "get nearby tiles" approach — no iterating the entire map.

```js
function getTouchingTiles(entity) {
  const tiles = [];
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
```

### 5.3 Player-Tile Resolution Algorithm

Split into X-axis first, then Y-axis (prevents corner tunneling):

```
resolvePlayerTileCollision(player, dt):

  // --- PHASE 1: HORIZONTAL ---
  player.x += player.vx * dt_norm;

  for each touching tile:
    if tile is solid:
      if moving right (vx > 0): push player left  -> player.x = tile.col * TILE_SIZE - player.width
      if moving left  (vx < 0): push player right -> player.x = (tile.col + 1) * TILE_SIZE
      player.vx = 0;

    if tile is SPIKE: hurtPlayer();

  // --- PHASE 2: VERTICAL ---
  player.y += player.vy * dt_norm;

  for each touching tile:
    if tile is solid:
      if moving down (vy > 0):
        // snap to top of tile
        player.y = tile.row * TILE_SIZE - player.height;
        player.vy = 0;
        player.onGround = true;
        player.canDoubleJump = player.powerups.doubleJump;
        player.hasDoubleJumped = false;

      if moving up (vy < 0):
        // snap to bottom of tile
        player.y = (tile.row + 1) * TILE_SIZE;
        player.vy = 0;

    if tile is PLATFORM (5):
      // ONLY collide when falling onto it from above
      if vy > 0:
        // Check: was player's feet above the platform top in the previous frame?
        prevBottom = player.y - player.vy * dt_norm + player.height;
        platformTop = tile.row * TILE_SIZE;
        if prevBottom <= platformTop + 2:  // small tolerance
          player.y = platformTop - player.height;
          player.vy = 0;
          player.onGround = true;
          player.canDoubleJump = player.powerups.doubleJump;
          player.hasDoubleJumped = false;

    if tile is SPIKE: hurtPlayer();

  // --- FALL OFF BOTTOM OF LEVEL ---
  if player.y > level.height * TILE_SIZE + 64:
    killPlayer();  // instant death, no respawn at checkpoint (or yes?)

  // --- CLAMP TO LEVEL BOUNDS ---
  player.x = Math.max(0, Math.min(player.x, level.width * TILE_SIZE - player.width));
```

### 5.4 Enemy-Tile Collision

Simpler than player — only horizontal resolution for patrolling enemies, vertical gravity + ground check:

```
resolveEnemyTileCollision(enemy, dt):
  enemy.x += enemy.vx * dt_norm;
  for solid tiles touching: push out horizontally, reverse vx (turn around)

  enemy.y += enemy.vy * dt_norm;
  for solid tiles touching from below: snap to top, vy = 0
  enemy.y += enemy.vy * dt_norm;  slight re-check

  // Ghost special case: ghost ignores ALL tile collisions (passes through walls)
```

### 5.5 Player-Enemy Collision (Stomp vs Hurt)

```
checkPlayerEnemyCollision(player, enemies):
  for each alive enemy:
    if rectsOverlap(player, enemy):

      // Determine if this is a stomp:
      // Player is falling (vy > 0) AND player's feet were above enemy's midpoint
      isStomp = player.vy > 0 &&
                (player.y + player.height - player.vy * dt_norm) <= enemy.y + enemy.height * 0.5;

      if isStomp && enemy is stompable:
        // STOMP!
        player.vy = STOMP_BOUNCE;     // bounce up
        killEnemy(enemy);
        player.score += enemyPoints;
        spawnParticles(enemy.x + enemy.width/2, enemy.y + enemy.height/2, 8, enemyColor);
        playStompSound();

      else if player.invincible OR player.powerups.invincible:
        // Nothing happens

      else if player.invincibleTimer > 0:
        // Nothing happens (post-damage invincibility)

      else:
        // HURT!
        hurtPlayer();
```

### 5.6 Hazard Collision

```
checkPlayerHazardCollision(player, level):
  for tile in getTouchingTiles(player):
    if tile.type in HAZARD_TILES (SPIKE or PIT):
      if !player.powerups.invincible:
        hurtPlayer();
```

### 5.7 Collectible Collision

```
checkPlayerCollectibleCollisions(player, coins[], powerups[]):
  for each coin in levelCoins:
    if coin.alive && rectsOverlap(player, coin):
      coin.alive = false;
      player.score += coin.value;
      player.coins++;
      playCoinSound();

  for each pu in levelPowerups:
    if pu.alive && rectsOverlap(player, pu):
      pu.alive = false;
      activatePowerup(pu.type);
      playPowerUpSound();
```

### 5.8 Exit Collision

```
checkPlayerExitCollision(player, exitTile):
  exitRect = { x: exit.col * TILE_SIZE, y: exit.row * TILE_SIZE, w: TILE_SIZE, h: TILE_SIZE };
  if rectsOverlap(player, exitRect):
    if transitionCooldown <= 0:
      transitionCooldown = 60;
      if currentLevel < 3:
        gameState = LEVEL_COMPLETE;
        playLevelCompleteSound();
      else:
        gameState = VICTORY;
        playVictorySound();
```

---

## 6. CAMERA SYSTEM DESIGN

```js
let camera = {
  x: 0, y: 0,
  width: CANVAS_WIDTH,
  height: CANVAS_HEIGHT,
  targetX: 0, targetY: 0,
  lerpSpeed: 0.08,   // 0 = no follow, 1 = instant snap. 0.08 = smooth
};

function updateCamera(dt) {
  // Center on player
  camera.targetX = player.x + player.width / 2 - camera.width / 2;
  camera.targetY = player.y + player.height / 2 - camera.height / 2;

  // Smooth interpolation (lerp)
  camera.x += (camera.targetX - camera.x) * camera.lerpSpeed;
  camera.y += (camera.targetY - camera.y) * camera.lerpSpeed;

  // Clamp to level boundaries (no showing outside the map)
  const maxX = level.width * TILE_SIZE - camera.width;
  const maxY = level.height * TILE_SIZE - camera.height;
  camera.x = Math.max(0, Math.min(camera.x, maxX));
  camera.y = Math.max(0, Math.min(camera.y, maxY));

  // If level is narrower than screen, center it
  if (maxX < 0) camera.x = maxX / 2;
  if (maxY < 0) camera.y = maxY / 2;
}

// Convert world coordinates to screen coordinates
function worldToScreen(worldX, worldY) {
  return {
    x: Math.round(worldX - camera.x),
    y: Math.round(worldY - camera.y),
  };
}

// Check if an entity's bounding box is visible
function isOnScreen(entity) {
  return (
    entity.x + entity.width  > camera.x &&
    entity.x                 < camera.x + camera.width &&
    entity.y + entity.height > camera.y &&
    entity.y                 < camera.y + camera.height
  );
}
```

### Camera Boundary Behavior
- **Horizontal**: Camera.x clamped between 0 and `level.width * TILE_SIZE - CANVAS_WIDTH`.
- **Vertical**: Camera.y clamped between 0 and `level.height * TILE_SIZE - CANVAS_HEIGHT`.
- If the level is narrower or shorter than the canvas, camera centers the level horizontally or vertically (camera.x/y goes negative).
- The lerp creates a slight "catch-up" feel — player can briefly get ahead of camera center, making speed feel faster.

---

## 7. ASSET GENERATION APPROACH

All visual and audio assets are created **programmatically** — no external files.

### 7.1 Sprite Drawing (Canvas 2D)

Every entity has a dedicated drawing function that uses `ctx.fillRect`, `ctx.fillStyle`, `ctx.beginPath`, etc. Sprites are built from simple shapes:

**Player Sprite** (`drawPlayer(ctx, x, y, w, h, facing, frame, state)`):
- Body: Blue (#3366FF) rounded rect, 28x32.
- Eyes: Two white (#FFF) 6x6 squares with black 2x2 pupils, offset based on facing.
- Hat: Red (#FF3333) rect on top, 24x6.
- Walk animation: Legs alternate — two 6x8 rects that offset up/down each frame.
- Jump frame: Legs tucked (shorter leg rects).
- Dead frame: Body rotated/flipped (or just a grey X-shape).
- Invincible: Color cycles through hue rotation (hsl-based fill).

**Slime** (`drawSlime(ctx, x, y, w, h, frame)`):
- Green (#44CC44) ellipse/rounded rect, wider at bottom.
- Two white eyes at top half.
- Squish animation: height shrinks, width expands each frame (2-frame loop).

**Bat** (`drawBat(ctx, x, y, w, h, frame)`):
- Purple (#8844CC) body — small ellipse.
- Wings: two triangles that flap up/down on alternating frames (4-frame loop).
- Two red eyes.

**Skeleton** (`drawSkeleton(ctx, x, y, w, h, frame)`):
- Light gray (#CCC) body — thin stick-like rects.
- Skull: white circle with black eye holes.
- Walk cycle: bone segments alternate (4 frames).

**Ghost** (`drawGhost(ctx, x, y, w, h, frame)`):
- Translucent white/blue (`rgba(200, 200, 255, 0.7)`).
- Rounded top, wavy bottom edge.
- Two dark eye holes.
- Fade in/out opacity oscillation (2 frames).

**Boss** (`drawBoss(ctx, x, y, w, h, phase, frame)`):
- Large red (#FF4444) creature.
- Phase 1 (hp 5-4): Two horns, big grin, two arms.
- Phase 2 (hp 3-2): Horns grow, eyes glow yellow, mouth opens wider (enraged).
- Phase 3 (hp 1): Cracks on body, flashing red, faster animation.
- Each phase has 4 animation frames.

**Coin** (`drawCoin(ctx, x, y, frame)`):
- Yellow (#FFD700) circle, 14px radius.
- Spinning animation: width scales from 14 to 2 to 14 (cos-based), simulating 3D rotation.
- Horizontal line drawn at midpoint when flat.

**Powerup** (`drawPowerup(ctx, x, y, type, frame)`):
- Floating up-down sine bob.
- Speed: Blue lightning bolt shape inside a circle.
- Invincible: Rainbow star shape.
- Double Jump: White wing/feather shape.
- Extra Life: Red heart shape with "+1" text.

**Parallax Background Layers** (`drawParallaxLayer(ctx, layer, cameraX)`):
- `shape: "hills"`: Sine-wave curves filled with layer.color, drawn across the full level width, scrolling at `layer.speed * camera.x`.
- `shape: "clouds"`: Rounded rect clusters, semi-transparent.
- `shape: "stars"`: Tiny white dots with twinkle (size oscillation).
- `shape: "stalactites"`: Triangles hanging from top of screen.

### 7.2 Audio Generation (Web Audio API)

All sounds generated at init time using oscillators and stored as reusable AudioBuffer objects.

```js
let audioCtx;
let soundBuffers = {};  // { jump: AudioBuffer, coin: AudioBuffer, ... }
let bossMusicNode = null;

function initAudio() {
  audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  soundBuffers.jump    = createToneBuffer(audioCtx, [[200, 600]], 0.1, 'sine');
  soundBuffers.coin    = createToneBuffer(audioCtx, [[523,0.05], [659,0.05]], 0.1, 'square');
  soundBuffers.stomp   = createToneBuffer(audioCtx, [[80, 0.12]], 0.12, 'square');
  soundBuffers.hurt    = createNoiseBuffer(audioCtx, 0.15);
  soundBuffers.powerup = createToneBuffer(audioCtx, [[523,0.08],[659,0.08],[784,0.08],[1047,0.15]], 0.4, 'sine');
  soundBuffers.levelComplete = createToneBuffer(audioCtx, [[523,0.1],[659,0.1],[784,0.1],[1047,0.3]], 0.6, 'triangle');
  soundBuffers.gameOver = createToneBuffer(audioCtx, [[400,0.2],[300,0.2],[200,0.5]], 0.9, 'sawtooth');
  soundBuffers.victory  = createToneBuffer(audioCtx, [[523,0.15],[659,0.15],[784,0.15],[1047,0.15],[1318,0.4]], 1.0, 'sine');
  soundBuffers.fireball = createNoiseBuffer(audioCtx, 0.2);
  soundBuffers.bossHit  = createToneBuffer(audioCtx, [[100,0.15],[60,0.2]], 0.35, 'sawtooth');
}

function playSound(name) {
  if (!audioCtx || !soundBuffers[name]) return;
  const source = audioCtx.createBufferSource();
  source.buffer = soundBuffers[name];
  source.connect(audioCtx.destination);
  source.start(0);
}

function createToneBuffer(ctx, segments, totalDuration, waveType) {
  // segments = [[frequency, durationSeconds], ...]
  // Generates concatenated sine/square/etc. waves
  const sampleRate = ctx.sampleRate;
  const length = Math.floor(sampleRate * totalDuration);
  const buffer = ctx.createBuffer(1, length, sampleRate);
  const data = buffer.getChannelData(0);
  let pos = 0;
  for (const [freq, dur] of segments) {
    const segLen = Math.floor(sampleRate * dur);
    for (let i = 0; i < segLen && pos < length; i++, pos++) {
      const t = i / sampleRate;
      let sample = 0;
      switch (waveType) {
        case 'sine':     sample = Math.sin(2 * Math.PI * freq * t); break;
        case 'square':   sample = Math.sin(2 * Math.PI * freq * t) > 0 ? 0.5 : -0.5; break;
        case 'triangle': sample = 2 * Math.abs(2 * (t * freq - Math.floor(t * freq + 0.5))) - 0.5; break;
        case 'sawtooth': sample = 2 * (t * freq - Math.floor(t * freq)) - 1; break;
      }
      // Apply envelope (fade in/out)
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
```

### 7.3 Boss Music

A simple looped bass pattern using a low-frequency oscillator connected to gain:

```js
function startBossMusic() {
  if (!audioCtx) return;
  stopBossMusic();
  bossMusicNode = audioCtx.createOscillator();
  const gainNode = audioCtx.createGain();
  gainNode.gain.value = 0.1;
  bossMusicNode.type = 'sawtooth';
  bossMusicNode.frequency.value = 110;  // A2
  // Modulate frequency for simple melody
  // Schedule frequency changes
  bossMusicNode.connect(gainNode);
  gainNode.connect(audioCtx.destination);
  bossMusicNode.start();
}

function stopBossMusic() {
  if (bossMusicNode) {
    bossMusicNode.stop();
    bossMusicNode.disconnect();
    bossMusicNode = null;
  }
}
```

---

## 8. UI SYSTEM DESIGN

All UI is drawn on the main canvas using `ctx.fillText`, `ctx.fillRect`, `ctx.strokeRect`. No DOM elements for UI (except the canvas itself).

### 8.1 HUD (rendered when PLAYING)

Positioned at top of screen, semi-transparent background bar:

```
+-----------------------------------------------------------+
| SCORE: 0012345     COINS: 42     GREEN FIELDS     X3 ♥♥♥  |
| [speed icon if active]                                     |
+-----------------------------------------------------------+
```

- **Top bar**: Black rect with alpha 0.5, 40px tall, full width.
- **Left**: `SCORE: <score>` in white, monospace font.
- **Left-mid**: Coin icon (small yellow circle) + count.
- **Center**: Level name in larger white text.
- **Right**: Heart icons for lives. Greyed out hearts for lost lives.
- **Below bar**: Small powerup icons if active (speed=blue bolt, invincible=rainbow star, doubleJump=white wing).

Drawing code:
```js
function renderHUD() {
  const ctx = mainCtx;
  // Background bar
  ctx.fillStyle = 'rgba(0,0,0,0.5)';
  ctx.fillRect(0, 0, CANVAS_WIDTH, 40);

  ctx.font = '16px monospace';
  ctx.fillStyle = '#FFF';
  ctx.textAlign = 'left';
  ctx.fillText('SCORE: ' + String(player.score).padStart(7, '0'), 10, 28);

  // Coin count
  ctx.fillText('⦿ ' + player.coins, 220, 28);

  // Level name
  ctx.textAlign = 'center';
  ctx.font = '18px monospace';
  ctx.fillText(levels[currentLevel].name.toUpperCase(), CANVAS_WIDTH / 2, 28);

  // Lives
  ctx.textAlign = 'right';
  ctx.font = '20px monospace';
  let livesStr = '';
  for (let i = 0; i < MAX_LIVES; i++) {
    livesStr += i < player.lives ? '♥ ' : '♡ ';
  }
  ctx.fillText(livesStr.trim(), CANVAS_WIDTH - 10, 28);

  // Powerup indicator row
  let puX = 10;
  let puY = 52;
  if (player.powerups.speed) {
    ctx.fillStyle = '#44F';
    ctx.fillText('⚡ SPEED', puX, puY);
    puX += 80;
  }
  if (player.powerups.invincible) {
    ctx.fillStyle = '#F0F';
    ctx.fillText('★ INVINCIBLE', puX, puY);
    puX += 120;
  }
  if (player.powerups.doubleJump) {
    ctx.fillStyle = '#FFF';
    ctx.fillText('✈ DBL JUMP', puX, puY);
  }
}
```

### 8.2 Title Screen

```
┌─────────────────────────────────────────────┐
│                                             │
│           ╔═══════════════════╗             │
│           ║   PIXEL QUEST     ║             │
│           ╚═══════════════════╝             │
│                                             │
│          A 4-Level Adventure                │
│                                             │
│        Press ENTER or SPACE                 │
│            to Start                         │
│                                             │
│        Best Score: 0000000                  │
│                                             │
│    ← → or A D to move  |  SPACE to jump    │
│    P to pause  |  R to restart              │
│                                             │
└─────────────────────────────────────────────┘
```

Rendering:
- Center-aligned text.
- Title: 48px bold monospace, white with dark outline.
- Subtitle, high score, controls: 18px monospace.
- Press enter: blinking (toggled every 40 frames).
- Animated background: slowly moving colored rectangles (retro feel).

### 8.3 Pause Overlay

```
┌─────────────────────────────────────────────┐
│                                             │
│              P A U S E D                    │
│                                             │
│        Press P to Resume                    │
│        Press R to Restart                   │
│                                             │
└─────────────────────────────────────────────┘
```

- Dark semi-transparent overlay (`rgba(0,0,0,0.7)`) over the frozen game render.
- Large centered "PAUSED" text.
- Resume/Restart instructions.

### 8.4 Level Complete Overlay

```
┌─────────────────────────────────────────────┐
│                                             │
│         LEVEL 1 COMPLETE!                   │
│                                             │
│         Score: +500 bonus                   │
│                                             │
│       Press ENTER to continue               │
│                                             │
└─────────────────────────────────────────────┘
```

- Dark overlay with green/gold text.
- Bonus score calculated: `(remainingLives * 100) + (coins * 10)`.
- Show total score accumulating.

### 8.5 Game Over Screen

```
┌─────────────────────────────────────────────┐
│                                             │
│            G A M E   O V E R               │
│                                             │
│         Final Score: 0012345                │
│                                             │
│       Press ENTER to try again              │
│                                             │
└─────────────────────────────────────────────┘
```

- Dark red/black overlay.
- Large red "GAME OVER" text.
- Compare with best score, save to localStorage if higher.

### 8.6 Victory Screen

```
┌─────────────────────────────────────────────┐
│                                             │
│       ★  C O N G R A T U L A T I O N S  ★  │
│                                             │
│          You defeated the Demon!            │
│                                             │
│         Final Score: 0099999                │
│         Best Score:  0100000                │
│                                             │
│       Press ENTER to play again             │
│                                             │
└─────────────────────────────────────────────┘
```

- Golden/white text.
- Particle celebration effect (colorful particles spawning across screen).
- Confetti-like falling particles.

### 8.7 Touch Control Overlay (Mobile Only)

Detected via `'ontouchstart' in window`. If true, render semi-transparent controls:

```
+-----------------------------------------------------------+
|                                                           |
|                                                   [  ^  ] |
|  [  <  ]                                     [ JUMP ]    |
|                                                           |
+-----------------------------------------------------------+
```

- Left side: Left/Right arrow buttons (64x64 squares, 20% opaque).
- Right side: Jump button (72x72 circle, 20% opaque).
- Touch handling: track active touches, map to key state.
- Touch zones defined as rectangles, checked on touchstart/touchmove/touchend.

---

## 9. LEVEL TRANSITION MECHANICS

### 9.1 Level Load Flow

```
loadLevel(levelIndex):
  1. Set currentLevel = levelIndex
  2. Copy level data reference: level = levels[levelIndex]
  3. Set transitionCooldown = 30  (prevent immediate exit trigger)
  4. Initialize player position from level.playerSpawn:
     player.x = playerSpawn.col * TILE_SIZE
     player.y = playerSpawn.row * TILE_SIZE
  5. Reset player velocity, set alive = true
  6. Keep player.lives, player.score, player.coins (carry over between levels)
  7. Reset player powerups and timers (powerups do NOT carry between levels)
  8. player.lastCheckpoint = null
  9. Build runtime enemies array from level.enemies spawn definitions
  10. Build runtime coins array from level.coins (each with alive=true, anim state)
  11. Build runtime powerups array from level.powerups (each with alive=true, anim state)
  12. Clear projectiles array
  13. Clear particles array
  14. Reset camera position (instant snap, no lerp on level start)
  15. If level is boss level (index 3): startBossMusic()
  16. gameState = STATE.PLAYING
```

### 9.2 Player Death Flow

```
killPlayer():
  player.alive = false;
  player.state = "dead";
  player.deathTimer = 60;  // frames of death animation
  player.vy = -6;          // small death bounce
  playHurtSound();
  spawnParticles(player.x + player.width/2, player.y + player.height/2, 12, '#FFF');

  // Timer counts down in update, then:
  //   if player.lives > 0: respawnPlayer()
  //   else: gameState = STATE.GAME_OVER

respawnPlayer():
  player.lives--;
  player.alive = true;
  player.state = "idle";
  player.invincibleTimer = 120;  // brief invincibility on respawn
  player.powerups = { speed: false, invincible: false, doubleJump: false };
  player.powerupTimers = { speed: 0, invincible: 0 };

  if player.lastCheckpoint:
    player.x = player.lastCheckpoint.col * TILE_SIZE;
    player.y = player.lastCheckpoint.row * TILE_SIZE;
  else:
    player.x = level.playerSpawn.col * TILE_SIZE;
    player.y = level.playerSpawn.row * TILE_SIZE;

  player.vx = 0; player.vy = 0;
  camera.x = player.x - CANVAS_WIDTH/2;  // snap camera
  camera.y = player.y - CANVAS_HEIGHT/2;
```

### 9.3 Checkpoint Activation

```
// Called when player overlaps a checkpoint tile or checkpoint entity zone
activateCheckpoint(col, row):
  // Prevent re-activating the same checkpoint
  const key = col + ',' + row;
  if (activatedCheckpoints.has(key)) return;
  activatedCheckpoints.add(key);

  player.lastCheckpoint = { col, row };
  playCheckpointSound();  // a short positive chime
  // Visual: checkpoint flag changes color to show it's activated
```

The `activatedCheckpoints` set is cleared on `loadLevel()`.

### 9.4 Screen Transitions

Between levels, add a simple fade effect:

```
// In render loop, if gameState === LEVEL_COMPLETE
// Draw a black rect over the screen with increasing alpha:
// alpha = Math.min(1, (framesSinceComplete - 30) / 30);
// This creates a 0.5-second fade to black before the next level loads.
```

Use a transition phase variable:
```
let transitionPhase = 'none'; // 'none' | 'fadeOut' | 'fadeIn'
let transitionTimer = 0;
```

---

## 10. DETAILED FUNCTION SIGNATURES

### SECTION 1: CONSTANTS & CONFIG
```
No functions — only constant declarations and config objects.
```

### SECTION 2: CANVAS SETUP
```js
function initCanvas()                                          // Set up canvas element, size it, get 2d context
function resizeCanvas()                                        // Handle window resize, maintain aspect ratio
```

### SECTION 3: INPUT HANDLING
```js
function setupInput()                                          // Add keydown, keyup, touch listeners
function handleKeyDown(e: KeyboardEvent)                       // Set keys[e.code] = true, handle special keys (P, R)
function handleKeyUp(e: KeyboardEvent)                         // Set keys[e.code] = false
function handleTouchStart(e: TouchEvent)                        // Map touch zones to virtual key presses
function handleTouchMove(e: TouchEvent)                         // Update touch zones
function handleTouchEnd(e: TouchEvent)                          // Release virtual keys
function isPressed(action: String): Boolean                    // Check if a game action is active (from keys or touch)
function processInput()                                        // Convert key/touch state into player commands
```

### SECTION 4: AUDIO SYSTEM
```js
function initAudio()                                           // Create AudioContext, generate all sound buffers
function playSound(name: String)                               // Play a pre-generated sound buffer
function createToneBuffer(ctx, segments, duration, wave): AudioBuffer  // Generate tone buffer from segments
function createNoiseBuffer(ctx, duration): AudioBuffer         // Generate white noise buffer
function startBossMusic()                                      // Start looping boss music oscillator
function stopBossMusic()                                       // Stop boss music oscillator
```

### SECTION 5: SPRITE DRAWING (ASSETS)
```js
function drawPlayerSprite(ctx, x, y, w, h, facing, frame, state, invincible, flashOn)
function drawSlimeSprite(ctx, x, y, w, h, frame)
function drawBatSprite(ctx, x, y, w, h, frame)
function drawSkeletonSprite(ctx, x, y, w, h, frame)
function drawGhostSprite(ctx, x, y, w, h, frame, opacity)
function drawBossSprite(ctx, x, y, w, h, phase, frame, flashOn)
function drawCoinSprite(ctx, x, y, size, frame)
function drawPowerupSprite(ctx, x, y, size, type, frame)
function drawTile(ctx, type, col, row, worldX, worldY)
function drawParallaxLayer(ctx, layer, scrollOffset)
function drawParticle(ctx, p: Particle)
```

### SECTION 6: LEVEL DATA
```
No functions — data declarations only.
```

### SECTION 7: GAME STATE & PLAYER STATE
```js
function initPlayer()                                          // Reset player to default state
function resetGame()                                           // Full reset: score=0, lives=3, loadLevel(0)
function loadBestScore(): Number                               // Read from localStorage
function saveBestScore(score: Number)                          // Write to localStorage
```

### SECTION 8: CAMERA SYSTEM
```js
function updateCamera(dt: Number)                              // Lerp follow player, clamp to bounds
function snapCamera()                                          // Instant snap camera to player
function isOnScreen(entity: {x,y,w,h}): Boolean               // Bounding box visibility test
function worldToScreen(wx: Number, wy: Number): {x,y}          // World coords -> screen coords
```

### SECTION 9: COLLISION SYSTEM
```js
function rectsOverlap(a:{x,y,w,h}, b:{x,y,w,h}): Boolean      // AABB overlap test
function getTouchingTiles(entity:{x,y,w,h}): Array             // Get all tiles overlapping entity
function resolvePlayerTileCollision(player, dt: Number)        // X-then-Y tile collision resolution
function resolveEnemyTileCollision(enemy, dt: Number)          // Enemy tile collision (with ghost exception)
function checkPlayerEnemyCollisions()                          // Iterate enemies, stomp or hurt
function checkPlayerCollectibleCollisions()                    // Coin/powerup pickup detection
function checkPlayerHazardCollisions()                         // Spike/pit detection
function checkPlayerExitCollision()                            // Goal detection
function checkCheckpointCollision()                            // Checkpoint activation
function checkPlayerProjectileCollisions()                     // Projectile hitting player
```

### SECTION 10: PLAYER LOGIC
```js
function updatePlayer(dt: Number)                              // Full per-frame player update
function movePlayer(dt: Number)                                // Apply input-based horizontal movement
function jump()                                                // Initiate jump or double jump
function stompBounce()                                         // Bounce after stomping enemy
function hurtPlayer()                                          // Take damage, decrement lives, invincibility
function killPlayer()                                          // Death sequence: set dead state, death timer
function respawnPlayer()                                       // Respawn at checkpoint with invincibility
function updatePlayerAnimation(dt: Number)                     // Advance animation frame based on state
function updatePowerupTimers(dt: Number)                       // Decrement timers, deactivate expired ones
function activatePowerup(type: String)                         // Activate a collected powerup
function collectCoin(value: Number)                            // Add coin value to score and count
```

### SECTION 11: ENEMY LOGIC
```js
function initEnemies()                                         // Build runtime enemy array from level defs
function updateEnemies(dt: Number)                             // Update all alive enemies
function updateSlime(enemy, dt: Number)                        // Slime AI: patrol, turn at edges/walls
function updateBat(enemy, dt: Number)                          // Bat AI: sine wave movement
function updateSkeleton(enemy, dt: Number)                     // Skeleton AI: patrol + shoot bones
function updateGhost(enemy, dt: Number)                        // Ghost AI: chase when player in range
function killEnemy(enemy)                                      // Mark enemy dead, particles, score, sound
function enemyInView(enemy): Boolean                           // Camera culling check
function updateEnemyAnimation(enemy, dt: Number)               // Advance enemy animation frame
```

### SECTION 12: BOSS LOGIC
```js
function initBoss()                                            // Create boss runtime state from level def
function updateBoss(dt: Number)                                // Full boss AI update
function bossChooseAttack(): String                            // Pick next attack based on phase
function bossCharge(dt: Number)                                // Phase: windup -> dash across screen
function bossFireball(dt: Number)                              // Phase: shoot fireballs toward player
function bossStomp(dt: Number)                                 // Phase: jump and slam, ground shockwave
function damageBoss()                                          // Reduce boss HP, check phase transitions
function bossPhaseCheck()                                      // Update phase based on HP thresholds
function updateProjectiles(dt: Number)                         // Move all projectiles, check lifetime
function spawnFireball(fromX, fromY, toX, toY)                 // Spawn a fireball projectile
function spawnBone(x, y, direction)                            // Spawn a bone projectile
function checkBossStompCollision()                             // Can player stomp boss head? (no — hp system)
```

### SECTION 13: COLLECTIBLES & POWERUPS
```js
function initCollectibles()                                    // Build runtime coin/powerup arrays
function updateCollectibles(dt: Number)                        // Animation only (bob, spin)
```

### SECTION 14: PARTICLES
```js
function spawnParticles(x: Number, y: Number, count: Number, color: String)
function spawnConfettiParticles(count: Number)                 // For victory screen
function updateParticles(dt: Number)                           // Physics + lifetime
function renderParticles(ctx)                                  // Draw all alive particles
```

### SECTION 15: RENDER PIPELINE
```js
function clearCanvas()                                         // Fill with bg color
function renderParallaxBackground()                            // Draw parallax layers
function renderTileMap()                                       // Draw visible tiles only
function renderPlayer(ctx)                                     // Draw player sprite
function renderEnemies(ctx)                                    // Draw all visible enemies
function renderBoss(ctx)                                       // Draw boss
function renderCollectibles(ctx)                               // Draw coins & powerups
function renderProjectiles(ctx)                                // Draw all projectiles
function renderHUD(ctx)                                        // Draw HUD overlay
function renderTouchControls(ctx)                              // Draw mobile touch buttons
```

### SECTION 16: UI SCREENS
```js
function renderTitleScreen(ctx)                                // Title screen render + blinking text
function renderPauseScreen(ctx)                                // Pause overlay
function renderLevelCompleteScreen(ctx)                        // Level complete overlay + score
function renderGameOverScreen(ctx)                             // Game over overlay
function renderVictoryScreen(ctx)                              // Victory screen + confetti
function renderFadeTransition(alpha: Number)                   // Black fade overlay for transitions
function drawTextBox(ctx, x, y, w, h, text, fontSize, color)  // Utility for centered text in box
```

### SECTION 17: LEVEL TRANSITIONS
```js
function loadLevel(levelIndex: Number)                         // Full level load sequence
function nextLevel()                                           // loadLevel(currentLevel + 1)
function handleDeathSequence(dt: Number)                       // Countdown timer -> respawn or game over
function activateCheckpoint(col: Number, row: Number)          // Register checkpoint
```

### SECTION 18: GAME LOOP & MAIN
```js
function init()                                                // Entry point: initCanvas, setupInput, initAudio, resetGame, start loop
function gameLoop(timestamp: Number)                           // RAF callback -> update() + render()
function update(dt: Number)                                    // Router: delegate to state-specific update
function render()                                              // Router: delegate to state-specific render
window.addEventListener('load', init);                         // Kick off everything
```

---

## 11. ADDITIONAL DESIGN NOTES

### 11.1 Global Mutable State Map

The following globals exist (all declared at top of script):

```js
let canvas, ctx;                    // canvas element and 2d context
let gameState;                      // current STATE enum value
let currentLevel;                   // index into levels array
let level;                          // reference to current level object
let player;                         // player state object
let camera;                         // camera state object
let enemies = [];                   // runtime enemy objects
let boss = null;                    // runtime boss object (null if no boss)
let coins = [];                     // runtime coin objects
let powerupItems = [];             // runtime powerup objects
let projectiles = [];              // bone, fireball, etc.
let particles = [];                // visual effects
let keys = {};                      // pressed key map: keys['ArrowRight'] = true/false
let touches = {};                   // active touch map: touches['left'] = true/false
let activatedCheckpoints = new Set(); // string keys "col,row"
let transitionCooldown = 0;        // frame counter
let audioCtx;                       // Web Audio context
let soundBuffers = {};             // pre-generated audio buffers
let bossMusicNode = null;          // active boss music oscillator
let lastTime = 0;                  // last frame timestamp
let globalFrame = 0;               // total frame counter
let bestScore = 0;                 // from localStorage
let isMobile = false;              // touch device detection
```

### 11.2 Performance Optimization Principles

1. **Camera culling**: Only render tiles, enemies, collectibles within camera viewport (plus 1 tile margin).
2. **Tile iteration**: Only check tiles in entity's 9-tile neighborhood for collisions (`getTouchingTiles` limits to bounding box coverage).
3. **Dead entity skipping**: Skip update logic for dead enemies/collectibles.
4. **Fixed particle cap**: Maximum 200 particles alive at once.
5. **Image rendering**: All drawing is `fillRect` and `fillText` — no `drawImage` (no external assets to load).
6. **Frame rate cap**: Physics dt capped at 33.33ms to prevent tunneling during lag spikes.

### 11.3 Responsive Layout Strategy

- Canvas intrinsic size is 960x640 (a clean 3:2 ratio).
- On resize: calculate the largest size that fits both viewport width and height while maintaining 3:2 ratio.
- Set `canvas.style.width` and `canvas.style.height` (CSS pixels) — the canvas resolution stays 960x640.
- `image-rendering: pixelated` for crisp scaling.
- On mobile: touch controls appear; on desktop: keyboard only.

### 11.4 localStorage

```js
const LS_BEST_SCORE = 'pixelquest_best';

function loadBestScore() {
  const stored = localStorage.getItem(LS_BEST_SCORE);
  bestScore = stored ? parseInt(stored, 10) : 0;
  return bestScore;
}

function saveBestScore(score) {
  if (score > bestScore) {
    bestScore = score;
    localStorage.setItem(LS_BEST_SCORE, String(score));
  }
}
```

### 11.5 Level Design Guidelines (for level data author)

- **Grassland (level 0)**: Ground at row 18. Platforms at rows 12-16. Some gaps over pits (row 19 = PIT). Coins in arcs. Slimes on ground, bats in open areas.
- **Underground (level 1)**: Ceiling at row 1 (mostly stone). Floor at row 18. Narrow passages (height 3-4 tiles). Skeletons patrolling. Spikes on floor/ceiling. Darker atmosphere.
- **Sky (level 2)**: No ground floor — all platforms (cloud blocks). PIT tile below lowest platform. Bats and ghosts. Wind-like parallax. Checkpoint platforms.
- **Castle (level 3)**: Brick everywhere. Torches on walls. Skeletons and ghosts. Final room is a large open space with the boss at col 100. Exit flag appears only after boss defeated.

### 11.6 Boss Defeat Flow

```
// Boss hit logic (only from stomping head, or when player is invincible):
function damageBoss():
  if boss.invincibleTimer > 0: return  // brief cooldown between hits
  boss.hp--;
  boss.invincibleTimer = 30;
  boss.phase = bossPhaseFromHP(boss.hp);  // 5→phase1, 3→phase2, 1→phase3
  playBossHitSound();
  spawnParticles(boss.x + boss.width/2, boss.y + boss.height/2, 15, '#FF0');

  if boss.hp <= 0:
    boss.alive = false;
    stopBossMusic();
    spawnParticles(boss.x, boss.y, 40, '#FF4444');  // big explosion
    playVictorySound();
    player.score += 1000;
    // Reveal exit flag (or make it accessible)
    level.tiles[exit.row][exit.col] = TILE.EXIT_FLAG;
```

---

## 12. SUMMARY

This specification defines:
- **18 code sections** in a single HTML file
- **6 game states** with clear transitions
- **14 tile types** with numeric encoding and visual rules
- **4 enemy types + boss** with full AI behaviors
- **4 powerup types** with timed/persistent effects
- **AABB collision** with X-then-Y resolution
- **Lerp-based camera** with boundary clamping
- **Programmatic sprites** (Canvas 2D primitives)
- **Programmatic sounds** (Web Audio oscillators/noise)
- **6 UI screens** with consistent design
- **Full function signatures** across 18 systems

Implementation agents should follow this spec section-by-section, using the function signatures as their contract. All data structures are JavaScript plain objects and arrays — no classes or prototypal inheritance.
