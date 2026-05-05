# STELLAR SURVIVOR — Performance Integration Spec

## Overview

`perf-system.js` provides a zero-GC performance layer for a Canvas 2D arcade shooter.  
All teammates include this file first, then access everything via `window.PERF.*`.

---

## 1. OBJECT POOLING → Used by: physics-engineer, rendering-engineer, game-designer

```js
// Create pools during game init (once):
const pools = {
  bullets:  new PERF.Pool(PERF.createBullet,  PERF.CONFIG.BULLET_POOL_SIZE),
  enemies:  new PERF.Pool(PERF.createEnemy,   PERF.CONFIG.ENEMY_POOL_SIZE),
  particles: new PERF.Pool(PERF.createParticle, PERF.CONFIG.PARTICLE_POOL_SIZE),
  powerUps: new PERF.Pool(PERF.createPowerUp, PERF.CONFIG.POWERUP_POOL_SIZE),
};

// Spawn a bullet:
const b = pools.bullets.get();
if (b) {
  b.x = player.x; b.y = player.y;
  b.vx = PERF.fastCos(angle) * 400;
  b.vy = PERF.fastSin(angle) * 400;
  b.life = 3000; // 3 seconds
  b.owner = 0;
}

// Update all active (auto-releases when life<=0):
pools.bullets.updateAll(dt);

// Render only active:
pools.particles.forEachActive(p => { /* draw p */ });
```

**CRITICAL RULE**: Never do `new`, `{}`, or `[]` in the update/render loop.  
Use pools exclusively. If you need a temporary object, use `PERF.vec2.get(x, y)`.

---

## 2. SPATIAL GRID → Used by: physics-engineer (collision system)

```js
const grid = new PERF.SpatialGrid(800, 600, 80); // 10x8 grid, 80px cells

// Each frame:
grid.clear();

// Insert all active player bullets and enemies into grid:
pools.bullets.forEachActive(b => { if (b.owner === 0) grid.insert(b); });
pools.enemies.forEachActive(e => grid.insert(e));

// Collision: player bullets vs enemies
PERF.clearQueryArray(PERF.QUERY_RESULT_ENEMIES);
pools.bullets.forEachActive(b => {
  if (b.owner !== 0) return; // skip enemy bullets
  grid.query(b.x, b.y, b.radius + 20, PERF.QUERY_RESULT_ENEMIES);
  for (let i = 0; i < PERF.QUERY_RESULT_ENEMIES.length; i++) {
    const e = PERF.QUERY_RESULT_ENEMIES[i];
    if (!e.active) continue;
    if (PERF.circleCollision(b.x, b.y, b.radius, e.x, e.y, e.radius)) {
      // HIT! damage enemy, release bullet
      e.hp -= b.damage;
      if (e.hp <= 0) { e.expired = true; /* spawn explosion particles */ }
      pools.bullets.release(b);
      break;
    }
  }
});

// Enemy bullets vs player: simple loop (no grid needed, 1 target)
pools.bullets.forEachActive(b => {
  if (b.owner !== 1) return;
  if (PERF.circleCollision(b.x, b.y, b.radius, player.x, player.y, player.radius)) {
    // HIT! damage player
    player.hp -= b.damage;
    pools.bullets.release(b);
  }
});

// Power-ups vs player: simple loop
pools.powerUps.forEachActive(p => {
  if (PERF.circleCollision(p.x, p.y, p.radius, player.x, player.y, player.radius)) {
    // APPLY power-up, release
    pools.powerUps.release(p);
  }
});
```

**Why this works**: Player bullets will vastly outnumber enemy projectiles (200 vs ~10).  
Checking player bullets only against enemies (not each other) saves ~99% of collision work.  
The spatial grid reduces enemy checks from O(n*m) to ~O(n).

---

## 3. GAME LOOP → Used by: game-designer (main orchestrator)

### Simple mode (recommended):
```js
function update(dt) {
  // dt is clamped to <=100ms
  pools.bullets.updateAll(dt);
  pools.enemies.updateAll(dt);
  pools.particles.updateAll(dt);
  pools.powerUps.updateAll(dt);
  // ... other updates
}

function render() {
  const ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, 800, 600);
  starfield.draw(ctx);              // blit cached background
  // render entities...
  PERF.drawPerfOverlay(ctx, pools); // debug overlay
}

// Start:
PERF.gameLoop.simple(performance.now(), update, render);
```

### Fixed timestep mode:
```js
// Physics at fixed 16.67ms, rendering interpolates
PERF.gameLoop.fixed(performance.now(), fixedUpdate, renderInterpolated);
```

---

## 4. RENDER OPTIMIZATION → Used by: rendering-engineer

### Off-screen culling:
```js
pools.enemies.forEachActive(e => {
  if (!PERF.isOnScreen(e)) return; // skip off-screen draws
  PERF.drawCircle(ctx, e.x, e.y, e.radius);
});
```

### Batched rendering (shadowBlur grouping):
```js
const batcher = new PERF.BatchedRenderContext(ctx);

// Render all enemies with glow/non-glow grouped:
batcher.submit(pools.enemies.raw, (ctx, e) => {
  PERF.drawCircle(ctx, e.x, e.y, e.radius);
});
// This draws all glow enemies first (expensive shadowBlur), 
// then all non-glow (cheap) — minimizing shadowBlur state changes.
```

### Starfield (pre-cached):
```js
const starfield = new PERF.StarfieldBackground(800, 600, 150);
// Each frame:
starfield.update(dt);    // updates only scrolled-off stars
starfield.draw(ctx);     // blit from offscreen cache
```

### Critical canvas optimizations:
- Use `ctx.clearRect(0, 0, W, H)` instead of `ctx.fillRect`
- Avoid `ctx.save()` / `ctx.restore()` in hot paths
- Use `|0` to truncate to integer pixel values
- Set `ctx.imageSmoothingEnabled = false` for crisp pixel art
- Use `globalCompositeOperation` sparingly (costly on some browsers)

---

## 5. MEMORY → Used by: ALL TEAMMATES

### Temp vectors:
```js
// Instead of: let dir = {x: dx, y: dy};
// Use:
let dir = PERF.vec2.get(dx, dy);
// ... use dir ...
// At end of frame (or immediately after):
// No explicit release needed — pool cycles; just call reset() at frame start:
PERF.vec2.reset();
```

### Trig (no Math.sin/cos in hot path):
```js
const angle = (elapsed / 500 * 360) % 360;
const sinVal = PERF.fastSin(angle);  // table lookup, 0 allocs
const cosVal = PERF.fastCos(angle);
```

### Query arrays (reuse, never re-allocate):
```js
PERF.QUERY_RESULT_ENEMIES.length = 0; // clear before each use
// or:
PERF.clearQueryArray(PERF.QUERY_RESULT_ENEMIES);
```

---

## 6. INPUT → Used by: all gameplay code

```js
// Movement (in update loop):
let dx = 0, dy = 0;
if (PERF.isKeyDown(37) || PERF.isKeyDown(65)) dx = -1; // Left/A
if (PERF.isKeyDown(39) || PERF.isKeyDown(68)) dx = 1;  // Right/D
if (PERF.isKeyDown(38) || PERF.isKeyDown(87)) dy = -1; // Up/W
if (PERF.isKeyDown(40) || PERF.isKeyDown(83)) dy = 1;  // Down/S

// Menu navigation (debounced — only fires once per press):
if (PERF.keyJustPressed(13))  selectMenuItem(); // Enter
if (PERF.keyJustPressed(27))  openPauseMenu();  // Escape

// Touch:
if (PERF.touchActive) {
  player.x += (PERF.touchX - player.x) * 0.1;
}

// Fire throttling (implemented per-entity, not at key-repeat level):
player.fireTimer -= dt;
if (PERF.isKeyDown(32) && player.fireTimer <= 0) {
  spawnBullet();
  player.fireTimer = player.fireInterval; // e.g., 150ms
}
```

---

## 7. MONITORING → Used by: game-designer, qa-engineer

Press `F` during gameplay to toggle the debug overlay showing:
- FPS
- Frame time (ms)
- Active bullet / enemy / particle / power-up counts

Automatically compiled out when `DEBUG = false`.

---

## 8. CAPACITY TARGETS

| Resource | Max Active | Pool Size |
|----------|-----------|-----------|
| Bullets  | 200       | 200       |
| Enemies  | 30        | 30        |
| Particles| 200       | 500       |
| PowerUps | 20        | 20        |

Particle emission is capped — `PERF.CONFIG.MAX_ACTIVE_PARTICLES` limits to 200 on-screen.  
If the particle pool has 200+ active, new emit requests silently drop.

---

## 9. INITIALIZATION SEQUENCE (recommended)

```js
// 1. Include perf-system.js
// 2. Call init
PERF.init(); // registers keyboard + touch listeners

// 3. Create pools
const pools = { ... };

// 4. Create spatial grid
const grid = new PERF.SpatialGrid(800, 600, PERF.CONFIG.SPATIAL_CELL_SIZE);

// 5. Create starfield
const starfield = new PERF.StarfieldBackground(800, 600, 150);

// 6. Start game loop
PERF.gameLoop.simple(performance.now(), update, render);
```
