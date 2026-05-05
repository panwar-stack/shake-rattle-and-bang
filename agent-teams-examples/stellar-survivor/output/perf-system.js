/**
 * STELLAR SURVIVOR — PERFORMANCE OPTIMIZATION SYSTEM
 * ===================================================
 * Target: 60fps stable on Canvas 2D (800x600, scaled to window)
 * Minimum: 30fps on low-end devices
 * All code is zero-GC in the hot path — no allocations during gameplay.
 *
 * Usage: Include this file before game logic. All pools, grid, timing,
 * monitoring, and helpers will be available globally under window.PERF.
 */

(function () {
  'use strict';

  // ==========================================================================
  //  CONFIGURATION
  // ==========================================================================

  const DEBUG = true; // Set false for production; compiles out debug overlays

  const CONFIG = {
    CANVAS_WIDTH: 800,
    CANVAS_HEIGHT: 600,

    BULLET_POOL_SIZE: 200,
    ENEMY_POOL_SIZE: 30,
    PARTICLE_POOL_SIZE: 500,
    POWERUP_POOL_SIZE: 20,

    MAX_ACTIVE_PARTICLES: 200, // Hard cap during emit
    SPATIAL_CELL_SIZE: 80, // 800/80 = 10 cols x 600/80 ≈ 7.5 → 8 rows

    MAX_DELTA_TIME: 100, // Cap dt at 100ms to prevent spiral-of-death
    FIXED_TIMESTEP: 1000 / 60, // ~16.67ms for fixed-update mode

    TRIG_TABLE_SIZE: 360,
  };

  // ==========================================================================
  //  SECTION 1: OBJECT POOLING
  // ==========================================================================

  /**
   * Generic object pool.
   * - Pre-instantiates `size` objects via `createFunc()`.
   * - Each object MUST have an `active` boolean property.
   * - get() returns first inactive object (O(n) but n is small and stable).
   * - release(obj) deactivates.
   * - forEachActive / forEachActiveSlice iterate only live objects.
   */
  class Pool {
    constructor(createFunc, size) {
      this._items = new Array(size);
      this._size = size;
      for (let i = 0; i < size; i++) {
        const obj = createFunc();
        obj.active = false;
        obj._poolIndex = i; // For O(1) release
        this._items[i] = obj;
      }
      this._freeList = []; // Stack of free indices for O(1) get when available
    }

    /** Acquire an inactive object. Returns null if pool is exhausted. */
    get() {
      if (this._freeList.length > 0) {
        const idx = this._freeList.pop();
        this._items[idx].active = true;
        return this._items[idx];
      }
      // Fallback: linear scan (only hit when freeList isn't populated yet)
      for (let i = 0; i < this._size; i++) {
        if (!this._items[i].active) {
          this._items[i].active = true;
          return this._items[i];
        }
      }
      // Pool exhausted — this is acceptable for particles (just dont emit)
      return null;
    }

    /** Mark an object as available for reuse. O(1). */
    release(obj) {
      if (obj.active) {
        obj.active = false;
        this._freeList.push(obj._poolIndex);
      }
    }

    /** Iterate over all active objects. */
    forEachActive(fn) {
      for (let i = 0; i < this._size; i++) {
        const obj = this._items[i];
        if (obj.active) fn(obj, i);
      }
    }

    /**
     * Iterate over active objects, collecting results into a pre-allocated
     * output array. Returns the output array for chaining.
     */
    forEachActiveCollect(fn, out) {
      for (let i = 0; i < this._size; i++) {
        const obj = this._items[i];
        if (obj.active) fn(obj, i, out);
      }
      return out;
    }

    /**
     * Update all active objects with dt, auto-releasing those whose `life` <= 0
     * or who have an `expired` flag set.
     */
    updateAll(dt) {
      for (let i = 0; i < this._size; i++) {
        const obj = this._items[i];
        if (!obj.active) continue;
        if (obj.update) obj.update(dt);
        if ((obj.life !== undefined && obj.life <= 0) || obj.expired) {
          this.release(obj);
        }
      }
    }

    /** Number of currently active objects. */
    activeCount() {
      let c = 0;
      for (let i = 0; i < this._size; i++) {
        if (this._items[i].active) c++;
      }
      return c;
    }

    /** Direct access to underlying array (for spatial grid insertion, etc.) */
    get raw() {
      return this._items;
    }

    get capacity() {
      return this._size;
    }
  }

  // ==========================================================================
  //  SECTION 2: PRE-ALLOCATED ENTITY FACTORIES
  // ==========================================================================

  /**
   * Factory functions for each pool type.
   * These are called only once per object at init time — zero GC in-game.
   * Each returns a plain object with shared shape to maximize hidden-class
   * optimization in V8/SpiderMonkey.
   */

  function createBullet() {
    return {
      active: false,
      _poolIndex: 0,
      x: 0,
      y: 0,
      vx: 0,
      vy: 0,
      speed: 0,
      radius: 3,
      damage: 1,
      life: 0, // remaining lifetime in ms; <=0 triggers auto-release
      color: '#ff0',
      owner: 0, // 0 = player, 1 = enemy
      update: null, // Assigned by game logic
    };
  }

  function createEnemy() {
    return {
      active: false,
      _poolIndex: 0,
      x: 0,
      y: 0,
      vx: 0,
      vy: 0,
      radius: 16,
      hp: 3,
      maxHp: 3,
      speed: 0,
      life: Infinity,
      color: '#f44',
      type: 0,
      scoreValue: 100,
      fireTimer: 0,
      fireInterval: 2000,
      expired: false,
      update: null,
    };
  }

  function createParticle() {
    return {
      active: false,
      _poolIndex: 0,
      x: 0,
      y: 0,
      vx: 0,
      vy: 0,
      radius: 2,
      life: 0,
      maxLife: 0,
      color: '#fff',
      alpha: 1,
      sizeStart: 2,
      sizeEnd: 0,
      decayType: 0, // 0 = linear, 1 = easeOut
      update: null,
    };
  }

  function createPowerUp() {
    return {
      active: false,
      _poolIndex: 0,
      x: 0,
      y: 0,
      vy: 40, // drift downward
      radius: 12,
      life: 15000, // 15s on screen
      type: 0, // 0=shield, 1=rapidFire, 2=spread, 3=health
      color: '#0ff',
      pulse: 0,
      update: null,
    };
  }

  // ==========================================================================
  //  SECTION 3: SPATIAL GRID FOR COLLISION OPTIMIZATION
  // ==========================================================================

  /**
   * Bucket-based spatial hash.
   * 800x600 world with ~80px cells → 10 x 8 grid = 80 cells.
   * Only player bullets check enemies (not vice versa).
   * Enemy bullets only check player.
   * Power-ups only check player.
   * This avoids O(n²) all-pairs collision checks.
   */
  class SpatialGrid {
    constructor(worldWidth, worldHeight, cellSize) {
      this._cellSize = cellSize;
      this._cols = Math.ceil(worldWidth / cellSize);
      this._rows = Math.ceil(worldHeight / cellSize);
      this._cellCount = this._cols * this._rows;
      this._cells = new Array(this._cellCount);
      for (let i = 0; i < this._cellCount; i++) {
        this._cells[i] = [];
      }
    }

    /** Clear all cell buckets. Call at start of each frame. */
    clear() {
      for (let i = 0; i < this._cellCount; i++) {
        this._cells[i].length = 0;
      }
    }

    /**
     * Insert an entity into all cells its bounding circle overlaps.
     * Entity must have: x, y, radius
     */
    insert(entity) {
      const cs = this._cellSize;
      const cols = this._cols;
      const rows = this._rows;

      const minCol = Math.max(0, ((entity.x - entity.radius) / cs) | 0);
      const maxCol = Math.min(cols - 1, ((entity.x + entity.radius) / cs) | 0);
      const minRow = Math.max(0, ((entity.y - entity.radius) / cs) | 0);
      const maxRow = Math.min(rows - 1, ((entity.y + entity.radius) / cs) | 0);

      for (let r = minRow; r <= maxRow; r++) {
        const rowOffset = r * cols;
        for (let c = minCol; c <= maxCol; c++) {
          this._cells[rowOffset + c].push(entity);
        }
      }
    }

    /**
     * Query all entities in cells that overlap the given bounding circle.
     * Results are appended to the provided `out` array (pre-allocated!).
     * Returns out for chaining.
     */
    query(x, y, radius, out) {
      const cs = this._cellSize;
      const cols = this._cols;
      const rows = this._rows;

      const minCol = Math.max(0, ((x - radius) / cs) | 0);
      const maxCol = Math.min(cols - 1, ((x + radius) / cs) | 0);
      const minRow = Math.max(0, ((y - radius) / cs) | 0);
      const maxRow = Math.min(rows - 1, ((y + radius) / cs) | 0);

      for (let r = minRow; r <= maxRow; r++) {
        const rowOffset = r * cols;
        for (let c = minCol; c <= maxCol; c++) {
          const cell = this._cells[rowOffset + c];
          for (let i = 0; i < cell.length; i++) {
            out.push(cell[i]);
          }
        }
      }
      return out;
    }

    get cellSize() {
      return this._cellSize;
    }
    get cols() {
      return this._cols;
    }
    get rows() {
      return this._rows;
    }
  }

  // ==========================================================================
  //  SECTION 4: FRAME TIMING & GAME LOOP
  // ==========================================================================

  const gameLoop = {
    lastTime: 0,
    accumulator: 0,
    frameCount: 0,
    fpsTimer: 0,
    currentFPS: 60,
    frameTimeMS: 16,

    /** Simple single-update loop (recommended for arcade games). */
    simple(timestamp, updateFn, renderFn) {
      requestAnimationFrame((t) => gameLoop.simple(t, updateFn, renderFn));

      let dt = timestamp - gameLoop.lastTime;
      gameLoop.lastTime = timestamp;
      if (dt > CONFIG.MAX_DELTA_TIME) dt = CONFIG.MAX_DELTA_TIME;

      updateFn(dt);
      renderFn();

      // FPS tracking
      gameLoop.frameCount++;
      gameLoop.fpsTimer += dt;
      if (gameLoop.fpsTimer >= 1000) {
        gameLoop.currentFPS = gameLoop.frameCount;
        gameLoop.frameTimeMS = (gameLoop.fpsTimer / gameLoop.frameCount).toFixed(2);
        gameLoop.frameCount = 0;
        gameLoop.fpsTimer -= 1000;
      }
    },

    /**
     * Fixed-timestep accumulator loop.
     * Physics updates at fixed intervals; rendering interpolates.
     */
    fixed(timestamp, fixedUpdateFn, renderFn) {
      requestAnimationFrame((t) => gameLoop.fixed(t, fixedUpdateFn, renderFn));

      let dt = timestamp - gameLoop.lastTime;
      gameLoop.lastTime = timestamp;
      if (dt > CONFIG.MAX_DELTA_TIME) dt = CONFIG.MAX_DELTA_TIME;

      const step = CONFIG.FIXED_TIMESTEP;
      gameLoop.accumulator += dt;

      while (gameLoop.accumulator >= step) {
        fixedUpdateFn(step);
        gameLoop.accumulator -= step;
      }

      const alpha = gameLoop.accumulator / step;
      renderFn(alpha);

      // FPS tracking
      gameLoop.frameCount++;
      gameLoop.fpsTimer += dt;
      if (gameLoop.fpsTimer >= 1000) {
        gameLoop.currentFPS = gameLoop.frameCount;
        gameLoop.frameTimeMS = (gameLoop.fpsTimer / gameLoop.frameCount).toFixed(2);
        gameLoop.frameCount = 0;
        gameLoop.fpsTimer -= 1000;
      }
    },
  };

  // ==========================================================================
  //  SECTION 5: TRIGONOMETRY LOOKUP TABLES (ZERO GC)
  // ==========================================================================

  const SIN_TABLE = new Float32Array(CONFIG.TRIG_TABLE_SIZE);
  const COS_TABLE = new Float32Array(CONFIG.TRIG_TABLE_SIZE);

  (function initTrigTables() {
    for (let i = 0; i < CONFIG.TRIG_TABLE_SIZE; i++) {
      const angle = (i / CONFIG.TRIG_TABLE_SIZE) * Math.PI * 2;
      SIN_TABLE[i] = Math.sin(angle);
      COS_TABLE[i] = Math.cos(angle);
    }
  })();

  /** Fast sin from degrees (0-359). Input is clamped to valid range. */
  function fastSin(deg) {
    return SIN_TABLE[((deg % 360 + 360) % 360) | 0];
  }

  /** Fast cos from degrees (0-359). Input is clamped to valid range. */
  function fastCos(deg) {
    return COS_TABLE[((deg % 360 + 360) % 360) | 0];
  }

  /** Fast sin/cos from radians using pre-computed degree table. */
  function fastSinCos(rad, out) {
    const deg = ((rad * (180 / Math.PI)) % 360 + 360) % 360;
    const idx = deg | 0;
    // Linear interpolation between table entries
    const frac = deg - idx;
    const next = (idx + 1) % CONFIG.TRIG_TABLE_SIZE;
    out[0] = SIN_TABLE[idx] + frac * (SIN_TABLE[next] - SIN_TABLE[idx]);
    out[1] = COS_TABLE[idx] + frac * (COS_TABLE[next] - COS_TABLE[idx]);
  }

  // ==========================================================================
  //  SECTION 6: TEMPORARY VECTOR POOL (ZERO GC)
  // ==========================================================================

  /**
   * Never create {x,y} literals in the game loop. Reuse from this pool.
   * Acquire with vec2.get() and release with vec2.release(v).
   * Always release before next frame — pool is per-frame.
   */
  const VEC2_POOL_SIZE = 32;
  const vec2 = {
    _pool: new Array(VEC2_POOL_SIZE),
    _nextIdx: 0,
    _init() {
      for (let i = 0; i < VEC2_POOL_SIZE; i++) {
        this._pool[i] = { x: 0, y: 0 };
      }
    },
    get(x, y) {
      const v = this._pool[this._nextIdx];
      this._nextIdx = (this._nextIdx + 1) % VEC2_POOL_SIZE;
      v.x = x || 0;
      v.y = y || 0;
      return v;
    },
    /** Reset the allocator for a new frame. */
    reset() {
      this._nextIdx = 0;
    },
  };
  vec2._init();

  // ==========================================================================
  //  SECTION 7: PRE-ALLOCATED COLLISION RESULT ARRAYS
  // ==========================================================================

  /**
   * Pre-allocate arrays used for spatial grid queries.
   * Reused every frame — never allocate new arrays.
   * Sized generously for worst-case scenarios.
   */
  const QUERY_RESULT_ENEMIES = new Array(CONFIG.ENEMY_POOL_SIZE);
  const QUERY_RESULT_BULLETS = new Array(CONFIG.BULLET_POOL_SIZE);
  const QUERY_RESULT_MISC = new Array(64);

  function clearQueryArray(arr) {
    arr.length = 0;
  }

  // ==========================================================================
  //  SECTION 8: FPS / PERFORMANCE MONITOR
  // ==========================================================================

  /**
   * Toggle with 'F' key (only when DEBUG=true).
   * Renders in top-left corner: FPS, frame time, active entity counts.
   */
  let showPerfOverlay = false;

  function togglePerfOverlay() {
    showPerfOverlay = !showPerfOverlay;
  }

  /**
   * Draw the performance overlay onto the canvas.
   * Call at the very end of your render function.
   */
  function drawPerfOverlay(ctx, pools) {
    if (!DEBUG || !showPerfOverlay) return;
    const x = 8,
      y = 16;
    const lineH = 16;
    ctx.save();
    ctx.font = '12px monospace';
    ctx.fillStyle = '#0f0';
    ctx.shadowColor = '#000';
    ctx.shadowBlur = 2;
    ctx.textBaseline = 'top';

    let ly = y;
    ctx.fillText('FPS: ' + gameLoop.currentFPS, x, ly);
    ly += lineH;
    ctx.fillText('Frame: ' + gameLoop.frameTimeMS + 'ms', x, ly);
    ly += lineH;

    if (pools && pools.bullets) {
      ctx.fillText('Bullets: ' + pools.bullets.activeCount() + '/' + CONFIG.BULLET_POOL_SIZE, x, ly);
      ly += lineH;
    }
    if (pools && pools.enemies) {
      ctx.fillText('Enemies: ' + pools.enemies.activeCount() + '/' + CONFIG.ENEMY_POOL_SIZE, x, ly);
      ly += lineH;
    }
    if (pools && pools.particles) {
      ctx.fillText('Particles: ' + pools.particles.activeCount() + '/' + CONFIG.PARTICLE_POOL_SIZE, x, ly);
      ly += lineH;
    }
    if (pools && pools.powerUps) {
      ctx.fillText('PowerUps: ' + pools.powerUps.activeCount() + '/' + CONFIG.POWERUP_POOL_SIZE, x, ly);
      ly += lineH;
    }

    ctx.restore();
  }

  // ==========================================================================
  //  SECTION 9: CANVAS STATE BATCHING CONTEXT WRAPPER
  // ==========================================================================

  /**
   * BatchedRenderContext — minimizes canvas state changes.
   * Groups draws by color/shadowBlur to avoid redundant ctx assignments.
   * Usage: brc = new BatchedRenderContext(ctx); brc.submit(batchFn);
   */
  class BatchedRenderContext {
    constructor(ctx) {
      this._ctx = ctx;
      this._shadowBlurOn = false;
      this._currentColor = '';
      this._currentAlpha = 1;
      this._pendingType = null; // 'glow' | 'normal'
    }

    /** Begin a batch of draws sharing the same color and glow state. */
    beginBatch(color, alpha, useShadowBlur) {
      const ctx = this._ctx;
      if (this._currentColor !== color || this._currentAlpha !== alpha) {
        ctx.fillStyle = color;
        ctx.strokeStyle = color;
        ctx.globalAlpha = alpha;
        this._currentColor = color;
        this._currentAlpha = alpha;
      }
      if (useShadowBlur !== this._shadowBlurOn) {
        if (useShadowBlur) {
          ctx.shadowBlur = 10;
          ctx.shadowColor = color;
        } else {
          ctx.shadowBlur = 0;
          ctx.shadowColor = 'transparent';
        }
        this._shadowBlurOn = useShadowBlur;
      }
    }

    /**
     * Submit all entity renders through this method.
     * It batches all glow draws together first, then all non-glow draws.
     * This is the single biggest render optimization:
     *   shadowBlur is EXTREMELY expensive — group all glow draws together.
     */
    submit(entities, drawFn) {
      // Pass 1: all glow draws (expensive shadowBlur)
      this.beginBatch('', 1, true);
      for (let i = 0; i < entities.length; i++) {
        const e = entities[i];
        if (!e.active) continue;
        if (e.glow) {
          this.beginBatch(e.glowColor || e.color, e.alpha || 1, true);
          drawFn(this._ctx, e);
        }
      }

      // Pass 2: all non-glow draws
      this.beginBatch('', 1, false);
      for (let i = 0; i < entities.length; i++) {
        const e = entities[i];
        if (!e.active) continue;
        if (!e.glow) {
          this.beginBatch(e.color, e.alpha || 1, false);
          drawFn(this._ctx, e);
        }
      }

      // Reset shadowBlur
      if (this._shadowBlurOn) {
        this._ctx.shadowBlur = 0;
        this._ctx.shadowColor = 'transparent';
        this._shadowBlurOn = false;
      }
    }
  }

  // ==========================================================================
  //  SECTION 10: STARFIELD BACKGROUND (LAYERED, CACHED)
  // ==========================================================================

  /**
   * Starfield using offscreen canvas cache.
   * Stars are rendered once to an offscreen canvas; only scrolled-off
   * stars are redrawn onto the cache per frame (dirty-rect principle).
   * The main canvas copies from the offscreen cache with drawImage.
   */
  class StarfieldBackground {
    constructor(width, height, starCount) {
      this._width = width;
      this._height = height;
      this._starCount = starCount;

      // Offscreen canvas cache
      this._cache = document.createElement('canvas');
      this._cache.width = width;
      this._cache.height = height;
      this._cacheCtx = this._cache.getContext('2d');

      // Star data (pre-allocated)
      this._stars = new Array(starCount);
      for (let i = 0; i < starCount; i++) {
        this._stars[i] = {
          x: Math.random() * width,
          y: Math.random() * height,
          speed: 10 + Math.random() * 40, // px/s downward
          brightness: 0.3 + Math.random() * 0.7,
        };
      }

      // Pre-render onto cache
      this._renderCache();
    }

    _renderCache() {
      const ctx = this._cacheCtx;
      ctx.fillStyle = '#000';
      ctx.fillRect(0, 0, this._width, this._height);
      for (let i = 0; i < this._starCount; i++) {
        const s = this._stars[i];
        const alpha = s.brightness;
        ctx.fillStyle = 'rgba(255,255,255,' + alpha + ')';
        ctx.fillRect(s.x | 0, s.y | 0, 1, 1);
      }
    }

    /**
     * Update and redraw only the stars that scrolled off-screen.
     * The offscreen cache handles persistence.
     */
    update(dt) {
      const ctx = this._cacheCtx;
      const dtSec = dt / 1000;

      for (let i = 0; i < this._starCount; i++) {
        const s = this._stars[i];
        const oldY = s.y;
        s.y += s.speed * dtSec;
        if (s.y > this._height) {
          s.y -= this._height;
          s.x = Math.random() * this._width;
          // Clear old position, draw new
          ctx.fillStyle = '#000';
          ctx.fillRect(s.x | 0, oldY | 0, 1, 1);
          const alpha = s.brightness;
          ctx.fillStyle = 'rgba(255,255,255,' + alpha + ')';
          ctx.fillRect(s.x | 0, s.y | 0, 1, 1);
        } else {
          const iy = s.y | 0;
          if (iy !== (oldY | 0)) {
            // Moved to a new pixel row — redraw
            ctx.fillStyle = '#000';
            ctx.fillRect(s.x | 0, oldY | 0, 1, 1);
            const alpha = s.brightness;
            ctx.fillStyle = 'rgba(255,255,255,' + alpha + ')';
            ctx.fillRect(s.x | 0, iy, 1, 1);
          }
        }
      }
    }

    /** Blit cached starfield to the main canvas. */
    draw(mainCtx) {
      mainCtx.drawImage(this._cache, 0, 0);
    }
  }

  // ==========================================================================
  //  SECTION 11: COLLISION HELPERS (ZERO GC)
  // ==========================================================================

  /**
   * Circle-circle collision test. Pure function, no allocations.
   */
  function circleCollision(ax, ay, ar, bx, by, br) {
    const dx = bx - ax;
    const dy = by - ay;
    const distSq = dx * dx + dy * dy;
    const radSum = ar + br;
    return distSq < radSum * radSum;
  }

  /**
   * Point-in-circle test.
   */
  function pointInCircle(px, py, cx, cy, cr) {
    const dx = cx - px;
    const dy = cy - py;
    return dx * dx + dy * dy < cr * cr;
  }

  // ==========================================================================
  //  SECTION 12: RENDER UTILITY HELPERS
  // ==========================================================================

  /**
   * Off-screen culling: return true if entity is visible in viewport.
   */
  function isOnScreen(entity, margin) {
    const m = margin || entity.radius || 0;
    return (
      entity.x + m > 0 &&
      entity.x - m < CONFIG.CANVAS_WIDTH &&
      entity.y + m > 0 &&
      entity.y - m < CONFIG.CANVAS_HEIGHT
    );
  }

  /**
   * Draw a circle efficiently. No save/restore, minimal state changes.
   */
  function drawCircle(ctx, x, y, radius) {
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fill();
  }

  // ==========================================================================
  //  SECTION 13: INPUT HANDLING (KEY STATE MAP)
  // ==========================================================================

  /**
   * Keyboard state map. Boolean array indexed by keyCode.
   * Uses keydown/keyup to track current pressed state.
   * No per-frame event processing — just read keysDown[code].
   */
  const keysDown = new Array(256);
  for (let i = 0; i < 256; i++) keysDown[i] = false;

  let keyJustPressedMap = new Array(256);
  for (let i = 0; i < 256; i++) keyJustPressedMap[i] = false;

  function onKeyDown(e) {
    if (e.keyCode < 256) {
      if (!keysDown[e.keyCode]) {
        keyJustPressedMap[e.keyCode] = true;
      }
      keysDown[e.keyCode] = true;
    }
    // Toggle perf overlay
    if (e.keyCode === 70) {
      // 'F' key
      togglePerfOverlay();
    }
    // Prevent default for game keys (arrows, space)
    if ([32, 37, 38, 39, 40].indexOf(e.keyCode) !== -1) {
      e.preventDefault();
    }
  }

  function onKeyUp(e) {
    if (e.keyCode < 256) {
      keysDown[e.keyCode] = false;
      keyJustPressedMap[e.keyCode] = false;
    }
  }

  /**
   * Check if key was just pressed this frame (consuming the press).
   * Good for menu navigation to avoid key-repeat issues.
   */
  function keyJustPressed(code) {
    if (keyJustPressedMap[code]) {
      keyJustPressedMap[code] = false;
      return true;
    }
    return false;
  }

  function isKeyDown(code) {
    return keysDown[code];
  }

  // ==========================================================================
  //  SECTION 14: TOUCH INPUT (PASSIVE LISTENERS)
  // ==========================================================================

  let touchActive = false;
  let touchX = 0;
  let touchY = 0;

  function onTouchStart(e) {
    touchActive = true;
    const t = e.touches[0];
    touchX = t.clientX;
    touchY = t.clientY;
    e.preventDefault();
  }

  function onTouchMove(e) {
    const t = e.touches[0];
    touchX = t.clientX;
    touchY = t.clientY;
  }

  function onTouchEnd() {
    touchActive = false;
  }

  // ==========================================================================
  //  SECTION 15: INITIALIZATION (CALL ONCE)
  // ==========================================================================

  function init() {
    // Keyboard
    window.addEventListener('keydown', onKeyDown);
    window.addEventListener('keyup', onKeyUp);

    // Touch (passive: false to allow preventDefault)
    window.addEventListener('touchstart', onTouchStart, { passive: false });
    window.addEventListener('touchmove', onTouchMove, { passive: false });
    window.addEventListener('touchend', onTouchEnd, { passive: false });
    window.addEventListener('touchcancel', onTouchEnd, { passive: false });
  }

  // ==========================================================================
  //  SECTION 16: EXPORT TO GLOBAL SCOPE
  // ==========================================================================

  window.PERF = {
    CONFIG,
    DEBUG,

    // Pools
    Pool,
    createBullet,
    createEnemy,
    createParticle,
    createPowerUp,

    // Spatial
    SpatialGrid,

    // Timing
    gameLoop,

    // Trig
    fastSin,
    fastCos,
    fastSinCos,

    // Vectors
    vec2,

    // Query arrays (pre-allocated)
    QUERY_RESULT_ENEMIES,
    QUERY_RESULT_BULLETS,
    QUERY_RESULT_MISC,
    clearQueryArray,

    // Collision
    circleCollision,
    pointInCircle,

    // Render helpers
    isOnScreen,
    drawCircle,
    BatchedRenderContext,
    StarfieldBackground,

    // Input
    keysDown,
    isKeyDown,
    keyJustPressed,
    touchActive,
    touchX,
    touchY,

    // Perf monitor
    showPerfOverlay,
    togglePerfOverlay,
    drawPerfOverlay,

    // Init
    init,
  };
})();
