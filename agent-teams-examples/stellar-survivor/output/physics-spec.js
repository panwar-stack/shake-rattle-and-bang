/**
 * ============================================================
 *  STELLAR SURVIVOR — Physics & Gameplay Mechanics Specification
 * ============================================================
 *
 *  This is the AUTHORITATIVE reference for all physics, collision,
 *  damage, movement, power-up, and game balance systems.
 *  All other engineers (rendering, input, game logic) should
 *  reference constants and formulas from this module.
 *
 *  Coordinate System:
 *    Origin: top-left (0,0)
 *    X+ → right, Y+ → down
 *    World: 800 × 600 px
 *    Play area: 800 × 600 (camera fixed, no scrolling)
 *
 *  Units: pixels, seconds, pixels/second
 */

// ============================================================
//  SECTION 1: WORLD & CAMERA CONSTANTS
// ============================================================
export const WORLD = {
  WIDTH: 800,
  HEIGHT: 600,
  MARGIN: 16,                // ship boundary margin (clamp inside this)
  GRAVITY: 0,                // no gravity (top-down space)
  EPSILON: 0.001,            // floating-point tolerance
};

export const CAMERA = {
  FIXED: true,               // no scrolling camera
  SCREEN_SHAKE_DECAY: 0.85,   // intensity multiplier per frame
  SCREEN_SHAKE_THRESHOLD: 0.3,// stop shake when below this
};

// ============================================================
//  SECTION 2: PLAYER MOVEMENT
// ============================================================
export const PLAYER = {
  // --- Ship properties ---
  COLLISION_RADIUS: 15,          // px (circle center at ship origin)
  MAX_HP: 100,
  INVINCIBILITY_DURATION: 1.5,   // seconds after hit

  // --- Movement ---
  BASE_SPEED: 300,               // px/s max speed
  ACCELERATION: 1800,            // px/s² (how fast speed ramps up)
  DECELERATION: 1200,            // px/s² (friction when no input)
  SPEED_BOOST_MULTIPLIER: 1.5,   // ×1.5 with speed power-up

  // --- Mouse follow ---
  MOUSE_LERP_FACTOR: 0.12,       // lerp per frame for smooth follow

  // --- Visual ---
  INVINCIBILITY_FLASH_INTERVAL: 0.1, // seconds between flash on/off
};

/**
 * Player Movement Pseudo-Code (Keyboard):
 *
 *   function updatePlayer(dt):
 *     // Read input axes (-1, 0, +1 for each axis)
 *     let ix = (keyRight ? 1 : 0) - (keyLeft ? 1 : 0)
 *     let iy = (keyDown ? 1 : 0) - (keyUp ? 1 : 0)
 *
 *     // Normalize diagonal movement
 *     let len = Math.sqrt(ix*ix + iy*iy)
 *     if (len > 0) { ix /= len; iy /= len; }
 *
 *     // Determine target speed
 *     let currentSpeed = PLAYER.BASE_SPEED * (hasSpeedBoost ? PLAYER.SPEED_BOOST_MULTIPLIER : 1)
 *     let targetVx = ix * currentSpeed
 *     let targetVy = iy * currentSpeed
 *
 *     // Apply acceleration or deceleration
 *     if (len > 0) {
 *       // Accelerating toward target
 *       let accel = PLAYER.ACCELERATION * dt
 *       // Clamp acceleration to not overshoot
 *       let dvx = targetVx - player.vx
 *       let dvy = targetVy - player.vy
 *       let dMag = Math.sqrt(dvx*dvx + dvy*dvy)
 *       if (dMag <= accel) {
 *         player.vx = targetVx; player.vy = targetVy
 *       } else {
 *         player.vx += (dvx / dMag) * accel
 *         player.vy += (dvy / dMag) * accel
 *       }
 *     } else {
 *       // Deceleration (friction) when no input
 *       let decel = PLAYER.DECELERATION * dt
 *       let speed = Math.sqrt(player.vx*player.vx + player.vy*player.vy)
 *       if (speed <= decel) {
 *         player.vx = 0; player.vy = 0
 *       } else {
 *         player.vx -= (player.vx / speed) * decel
 *         player.vy -= (player.vy / speed) * decel
 *       }
 *     }
 *
 *     // Integrate position
 *     player.x += player.vx * dt
 *     player.y += player.vy * dt
 *
 *     // Clamp to world bounds (+ margin)
 *     player.x = clamp(player.x, MARGIN + COLLISION_RADIUS, WORLD.WIDTH  - MARGIN - COLLISION_RADIUS)
 *     player.y = clamp(player.y, MARGIN + COLLISION_RADIUS, WORLD.HEIGHT - MARGIN - COLLISION_RADIUS)
 */

/**
 * Mouse Follow Pseudo-Code:
 *
 *   let dx = mouseWorldX - player.x
 *   let dy = mouseWorldY - player.y
 *   let dist = Math.sqrt(dx*dx + dy*dy)
 *
 *   if (dist > 2) {  // dead zone
 *     let maxStep = PLAYER.BASE_SPEED * dt
 *     let step = Math.min(dist * PLAYER.MOUSE_LERP_FACTOR, maxStep)
 *     player.x += (dx / dist) * step
 *     player.y += (dy / dist) * step
 *   }
 *
 *   // Then clamp to bounds (same as keyboard)
 */

/**
 * Virtual Joystick (Touch) Pseudo-Code:
 *
 *   // On touchstart: record baseX, baseY (center of joystick zone)
 *   // On touchmove:  compute dx = touchX - baseX, dy = touchY - baseY
 *   //                cap radius at MAX_JOYSTICK_RADIUS (e.g. 60px)
 *   //                normalize: ix = clamp(dx/MAX_JOYSTICK_RADIUS, -1, 1)
 *   //                            iy = clamp(dy/MAX_JOYSTICK_RADIUS, -1, 1)
 *   //                feed ix, iy into same movement code as keyboard
 *   // On touchend:   ix = 0, iy = 0
 *   //
 *   // Auto-fire: toggle button, when ON → fire every FIRE_INTERVAL seconds
 */

// ============================================================
//  SECTION 3: COLLISION DETECTION SYSTEM
// ============================================================
export const COLLISION = {
  // Layer masks for collision filtering
  LAYER_PLAYER_BULLET:  0x01,  // player projectiles
  LAYER_ENEMY_BULLET:   0x02,  // enemy projectiles
  LAYER_PLAYER:         0x04,  // player ship
  LAYER_ENEMY:          0x08,  // enemy ships
  LAYER_POWERUP:        0x10,  // power-up orbs
  LAYER_BOSS:           0x20,  // boss entities (larger hitbox)

  // --- Collision pairs (check matrix) ---
  // Player bullets  vs Enemies+Boss  → damage enemy
  // Enemy bullets   vs Player         → damage player
  // Player          vs Power-ups      → collect power-up
  // Player          vs Enemies+Boss   → contact damage to player
  // Player bullets  vs Enemy bullets  → (optional: cancel out)

  // --- Radii ---
  PLAYER_RADIUS: 15,
  BULLET_PLAYER_RADIUS: 4,
  BULLET_ENEMY_RADIUS: 6,
  POWERUP_PICKUP_RADIUS: 20,

  // --- Enemy radii by type (see enemy table) ---

  // --- Spatial Grid (bucket) optimization ---
  GRID_CELL_SIZE: 64,   // px — cell must be > largest entity diameter (40*2=80 → use 64)

  // Hit flash frame count
  HIT_FLASH_FRAMES: 4,
};

/**
 * Circle-Circle Collision:
 *
 *   function circlesOverlap(ax, ay, ar, bx, by, br):
 *     let dx = ax - bx
 *     let dy = ay - by
 *     let distSq = dx*dx + dy*dy
 *     let radiiSum = ar + br
 *     return distSq <= radiiSum * radiiSum
 */

/**
 * COLLISION RESPONSE pseudocode (called each frame):
 *
 *   // === PASS 1: Player bullets → Enemies ===
 *   for each alive playerBullet in spatialGrid.query(enemyLayer):
 *     for each alive enemy in nearbyBuckets(enemyGroup):
 *       if circlesOverlap(bullet.x, bullet.y, 4, enemy.x, enemy.y, enemy.radius):
 *         enemy.takeDamage(bullet.damage)
 *         bullet.kill()
 *         if (enemy.isDead):
 *           spawnPowerUp(enemy.x, enemy.y)
 *           spawnParticles(enemy.x, enemy.y, 'explosion')
 *           score += enemy.scoreValue
 *         break  // bullet can only hit one enemy
 *
 *   // === PASS 2: Enemy bullets → Player ===
 *   for each alive enemyBullet:
 *     if player.isInvincible: continue
 *     if circlesOverlap(bullet.x, bullet.y, 6, player.x, player.y, 15):
 *       player.takeDamage(bullet.damage)
 *       bullet.kill()
 *       triggerScreenShake(2, 0.3)
 *
 *   // === PASS 3: Player → Power-ups ===
 *   for each alive powerUp:
 *     if circlesOverlap(player.x, player.y, 15, powerUp.x, powerUp.y, 20):
 *       powerUp.apply(player)
 *       powerUp.kill()
 *       playSound('powerup_pickup')
 *
 *   // === PASS 4: Player → Enemies (contact damage) ===
 *   for each alive enemy:
 *     if player.isInvincible: continue
 *     if circlesOverlap(player.x, player.y, 15, enemy.x, enemy.y, enemy.radius):
 *       player.takeDamage(enemy.contactDamage)
 *       // Knockback for player
 *       let angle = Math.atan2(player.y - enemy.y, player.x - enemy.x)
 *       player.vx += Math.cos(angle) * 200  // bounce velocity
 *       player.vy += Math.sin(angle) * 200
 *       triggerScreenShake(5, 0.5)
 */

// ============================================================
//  SECTION 4: SPATIAL GRID (optimized collision)
// ============================================================
/**
 * SpatialGrid is a bucket-based broad-phase that reduces
 * O(n²) checks to O(n) by only testing entities in the
 * same or adjacent cells.
 *
 * Implementation (pseudo-code):
 *
 *   class SpatialGrid:
 *     constructor(cellSize, worldWidth, worldHeight):
 *       this.cellSize = cellSize
 *       this.cols = Math.ceil(worldWidth / cellSize)
 *       this.rows = Math.ceil(worldHeight / cellSize)
 *       this.cells = new Array(this.cols * this.rows)
 *       for (let i = 0; i < cells.length; i++) this.cells[i] = []
 *
 *     clear():
 *       for each cell in this.cells: cell.length = 0
 *
 *     insert(entity):
 *       // Entity must have: x, y, radius
 *       let minCol = Math.floor((entity.x - entity.radius) / cellSize)
 *       let maxCol = Math.floor((entity.x + entity.radius) / cellSize)
 *       let minRow = Math.floor((entity.y - entity.radius) / cellSize)
 *       let maxRow = Math.floor((entity.y + entity.radius) / cellSize)
 *       // Clamp to grid bounds
 *       minCol = Math.max(0, minCol)
 *       maxCol = Math.min(cols - 1, maxCol)
 *       minRow = Math.max(0, minRow)
 *       maxRow = Math.min(rows - 1, maxRow)
 *       for col from minCol to maxCol:
 *         for row from minRow to maxRow:
 *           this.cells[row * this.cols + col].push(entity)
 *
 *     query(x, y, radius):
 *       // Return array of entities in cells overlapping the query circle
 *       let result = []
 *       let minCol = Math.max(0, Math.floor((x - radius) / cellSize))
 *       let maxCol = Math.min(cols - 1, Math.floor((x + radius) / cellSize))
 *       let minRow = Math.max(0, Math.floor((y - radius) / cellSize))
 *       let maxRow = Math.min(rows - 1, Math.floor((y + radius) / cellSize))
 *       for col from minCol to maxCol:
 *         for row from minRow to maxRow:
 *           let idx = row * this.cols + col
 *           for each entity in this.cells[idx]:
 *             if (entity not already in result):
 *               result.push(entity)
 *       return result
 *
 *   // Per-frame usage:
 *   grid.clear()                        // reset all cells
 *   for each alive enemy:    grid.insert(enemy)     // only insert what bullets can hit
 *   for each alive enemyBullet: grid.insert(eBullet)  // only insert what player needs
 *   for each alive powerUp: grid.insert(powerUp)
 *   // Then run collision passes using grid.query()
 */

// ============================================================
//  SECTION 5: PROJECTILE SYSTEM
// ============================================================
export const BULLET = {
  PLAYER_SPEED: 500,        // px/s
  PLAYER_RADIUS: 4,
  PLAYER_FIRE_INTERVAL: 0.15, // seconds between shots (base)
  PLAYER_MAX_ON_SCREEN: 3,   // max player bullets alive at once
  PLAYER_LIFETIME: 2.0,      // seconds before despawn
  PLAYER_OFFSCREEN_MARGIN: 100, // despawn when this far outside world

  ENEMY_SPEED_MIN: 200,
  ENEMY_SPEED_MAX: 400,
  ENEMY_RADIUS: 6,
  ENEMY_LIFETIME: 3.0,       // enemy bullets live longer
  ENEMY_OFFSCREEN_MARGIN: 100,

  // Rapid-fire modifier
  RAPID_FIRE_INTERVAL_MULTIPLIER: 0.5, // fire rate halved = twice as fast

  // Pool sizes
  PLAYER_BULLET_POOL_SIZE: 30,
  ENEMY_BULLET_POOL_SIZE: 100,
};

/**
 * Boss Bullet Patterns:
 *
 * 1. RADIAL BURST (circle spread):
 *    spawnBulletRing(centerX, centerY, bulletCount, speed, angleOffset=0):
 *      for i in 0..bulletCount-1:
 *        let angle = angleOffset + (2*PI / bulletCount) * i
 *        let vx = Math.cos(angle) * speed
 *        let vy = Math.sin(angle) * speed
 *        spawnEnemyBullet(centerX, centerY, vx, vy)
 *
 * 2. AIMED BURST:
 *    spawnAimedBurst(centerX, centerY, bulletCount, spreadAngle, speed):
 *      let baseAngle = Math.atan2(player.y - centerY, player.x - centerX)
 *      let halfSpread = spreadAngle / 2
 *      for i in 0..bulletCount-1:
 *        let t = (i / (bulletCount - 1)) - 0.5  // -0.5 to 0.5
 *        let angle = baseAngle + t * spreadAngle
 *        let vx = Math.cos(angle) * speed
 *        let vy = Math.sin(angle) * speed
 *        spawnEnemyBullet(centerX, centerY, vx, vy)
 *
 * 3. SPIRAL PATTERN:
 *    // Called each frame while boss is in spiral phase
 *    updateSpiral(boss, dt):
 *      boss.spiralTimer += dt
 *      if (boss.spiralTimer >= boss.spiralInterval):
 *        boss.spiralTimer -= boss.spiralInterval
 *        boss.spiralAngle += boss.spiralAngleStep
 *        let vx = Math.cos(boss.spiralAngle) * 250
 *        let vy = Math.sin(boss.spiralAngle) * 250
 *        spawnEnemyBullet(boss.x, boss.y, vx, vy)
 *        // Dual spiral (optional): spawn opposite direction
 *        spawnEnemyBullet(boss.x, boss.y, -vx, -vy)
 */

// ============================================================
//  SECTION 6: BULLET-OBJECT POOLING
// ============================================================
/**
 * Object Pool pattern for bullets, enemies, particles:
 *
 *   class ObjectPool:
 *     constructor(createFn, maxSize):
 *       this.items = []         // all objects (pre-allocated)
 *       this.createFn = createFn
 *       for let i = 0; i < maxSize; i++:
 *         let obj = createFn()
 *         obj.alive = false
 *         this.items.push(obj)
 *
 *     // Get a dead object, or recycle the oldest alive one
 *     acquire():
 *       // First, try to find a dead one
 *       for each item in this.items:
 *         if (!item.alive):
 *           item.alive = true
 *           return item
 *       // If all alive, recycle oldest (FIFO — for safety, kill oldest bullet)
 *       let oldest = this.items[this.oldestIndex]
 *       oldest.kill()  // call kill before reuse
 *       oldest.alive = true
 *       this.oldestIndex = (this.oldestIndex + 1) % this.items.length
 *       return oldest
 *
 *     // Return all alive items (for iteration)
 *     getAlive():
 *       return this.items.filter(item => item.alive)
 *
 *     // Also: maintain an `aliveCount` for quick iteration without filter
 *
 *   BULLET OBJECT STRUCTURE:
 *     {
 *       x: 0, y: 0,
 *       vx: 0, vy: 0,
 *       speed: 500,
 *       radius: 4,
 *       damage: 1,
 *       alive: false,
 *       lifetime: 2.0,          // decremented each frame; kill at 0
 *       timeAlive: 0,           // incremented each frame
 *       owner: 'player',        // 'player' or 'enemy'
 *       spriteIndex: 0,         // for rendering
 *
 *       init(x, y, vx, vy, configOverride={}):
 *         this.x = x; this.y = y
 *         this.vx = vx; this.vy = vy
 *         this.alive = true
 *         this.timeAlive = 0
 *         // Apply overrides (damage, speed, etc.)
 *
 *       update(dt):
 *         if (!this.alive) return
 *         this.timeAlive += dt
 *         this.x += this.vx * dt
 *         this.y += this.vy * dt
 *         // Despawn check
 *         if (this.timeAlive > this.lifetime) this.kill()
 *         if (this.x < -BULLET_OFFSCREEN || this.x > WORLD.WIDTH + BULLET_OFFSCREEN ||
 *             this.y < -BULLET_OFFSCREEN || this.y > WORLD.HEIGHT + BULLET_OFFSCREEN) this.kill()
 *
 *       kill():
 *         this.alive = false
 *         // If this is a player bullet: decrement onScreenCount
 *   }

 *   POOL USAGE IN GAME LOOP:
 *     // Spawn player bullet
 *     if (playerCanFire && playerBulletsOnScreen < BULLET.PLAYER_MAX_ON_SCREEN):
 *       let bullet = playerBulletPool.acquire()
 *       let interval = hasRapidFire ? BULLET.PLAYER_FIRE_INTERVAL * BULLET.RAPID_FIRE_INTERVAL_MULTIPLIER : BULLET.PLAYER_FIRE_INTERVAL
 *       bullet.init(player.x, player.y - 10, 0, -BULLET.PLAYER_SPEED, { damage: 1, lifetime: BULLET.PLAYER_LIFETIME })
 *       player.fireCooldown = interval
 *       playerBulletsOnScreen++
 *
 *     // Update all bullets
 *     for each bullet in playerBulletPool.getAlive():    bullet.update(dt)
 *     for each bullet in enemyBulletPool.getAlive():     bullet.update(dt)
 *
 *     // Enemy bullet pool (used by spawn function)
 *     spawnEnemyBullet(x, y, vx, vy, config={}):
 *       let bullet = enemyBulletPool.acquire()
 *       bullet.init(x, y, vx, vy, config)
 */
export const POOL_SIZES = {
  PLAYER_BULLETS: 30,
  ENEMY_BULLETS: 100,
  POWERUPS: 20,
  PARTICLES: 200,
  ENEMIES: 50,
};

// ============================================================
//  SECTION 7: POWER-UP MECHANICS
// ============================================================
export const POWERUP = {
  // --- Drop rates ---
  BASE_DROP_CHANCE: 0.10,          // 10% from normal enemies
  ELITE_DROP_CHANCE: 0.15,         // 15% from elite enemies
  NUKE_DROP_CHANCE: 0.03,          // 3% nuke/super
  BOSS_GUARANTEED: true,           // Boss always drops 1 power-up

  // --- Visual / movement ---
  FLOAT_AMPLITUDE: 5,              // px vertical sine oscillation
  FLOAT_FREQUENCY: 3.0,            // rad/s
  DRIFT_SPEED_X: 15,               // px/s horizontal drift (picks random direction)
  PICKUP_RADIUS: 20,
  FALL_SPEED: 60,                  // px/s when no drift (slow vertical fall)
  LIFETIME: 15.0,                  // seconds before despawn (blinking last 3s)

  // --- Types & weights (for random selection) ---
  TYPES: {
    SHIELD:            { weight: 20, duration: 12, label: 'Shield' },
    RAPID_FIRE:        { weight: 20, duration: 8,  label: 'Rapid Fire' },
    SPEED_BOOST:       { weight: 20, duration: 10, label: 'Speed Boost' },
    HEAL:              { weight: 20, duration: 0,  label: 'Heal' },          // instant
    SCORE_MULTIPLIER:  { weight: 15, duration: 10, label: '2x Score' },
    NUKE:              { weight: 5,  duration: 0,  label: 'Nuke' },          // instant
  },

  // --- Shield specifics ---
  SHIELD_ABSORB_HITS: 3,
};

/**
 * Power-Up Update Pseudo-Code:
 *
 *   updatePowerUp(pu, dt):
 *     pu.timeAlive += dt
 *     // Float animation
 *     pu.y += Math.sin(pu.timeAlive * POWERUP.FLOAT_FREQUENCY) * POWERUP.FLOAT_AMPLITUDE * dt * 3
 *     pu.x += pu.driftDir * POWERUP.DRIFT_SPEED_X * dt  // driftDir is -1 or +1
 *     pu.y += POWERUP.FALL_SPEED * dt                    // slow fall
 *
 *     // Clamp to world (bounce off edges — switch drift direction)
 *     if (pu.x < COLLISION_RADIUS || pu.x > WORLD.WIDTH - COLLISION_RADIUS):
 *       pu.driftDir *= -1
 *     if (pu.y > WORLD.HEIGHT + 50):  // fell off bottom
 *       pu.kill()
 *
 *     // Blinking before despawn
 *     if (pu.lifetime - pu.timeAlive <= 3):
 *       pu.blinking = true
 *     if (pu.timeAlive >= pu.lifetime):
 *       pu.kill()
 */

/**
 * Power-Up Application:
 *
 *   applyPowerUp(player, type):
 *     switch(type):
 *       case 'SHIELD':
 *         player.shieldHits = POWERUP.SHIELD_ABSORB_HITS
 *         player.shieldTimer = POWERUP.TYPES.SHIELD.duration
 *       case 'RAPID_FIRE':
 *         player.rapidFire = true
 *         player.rapidFireTimer = POWERUP.TYPES.RAPID_FIRE.duration
 *       case 'SPEED_BOOST':
 *         player.speedBoost = true
 *         player.speedBoostTimer = POWERUP.TYPES.SPEED_BOOST.duration
 *       case 'HEAL':
 *         player.hp = Math.min(player.hp + 30, PLAYER.MAX_HP)
 *       case 'SCORE_MULTIPLIER':
 *         player.scoreMultiplier = true
 *         player.scoreMultiplierTimer = POWERUP.TYPES.SCORE_MULTIPLIER.duration
 *       case 'NUKE':
 *         // Kill all enemies on screen
 *         for each enemy: enemy.takeDamage(9999)
 *         // Kill all enemy bullets
 *         for each bullet: bullet.kill()
 *         spawnScreenFlash()  // bright flash effect
 *         triggerScreenShake(10, 0.6)
 *
 *   // Timer tickdown (called in player.update):
 *   if (player.shieldTimer > 0):
 *     player.shieldTimer -= dt
 *     if (player.shieldTimer <= 0): player.shieldHits = 0
 *   // Same pattern for rapidFireTimer, speedBoostTimer, scoreMultiplierTimer
 */

// ============================================================
//  SECTION 8: HEALTH & DAMAGE SYSTEM
// ============================================================
export const DAMAGE = {
  ENEMY_CONTACT_MIN: 15,
  ENEMY_CONTACT_MAX: 25,
  ENEMY_BULLET_MIN: 10,
  ENEMY_BULLET_MAX: 20,
  BOSS_CONTACT: 30,

  // Knockback on player-enemy contact
  KNOCKBACK_SPEED: 200,    // px/s impulse
};

/**
 * Player Damage Handling:
 *
 *   player.takeDamage(amount):
 *     if (this.invincible) return
 *     if (this.shieldHits > 0):
 *       this.shieldHits--
 *       // Shield absorbs the hit, play shield effect
 *       return
 *     this.hp -= amount
 *     this.invincible = true
 *     this.invincibleTimer = PLAYER.INVINCIBILITY_DURATION
 *     if (this.hp <= 0):
 *       this.hp = 0
 *       this.onDeath()
 *
 *   player.update(dt):
 *     if (this.invincible):
 *       this.invincibleTimer -= dt
 *       if (this.invincibleTimer <= 0):
 *         this.invincible = false
 *       // Flash toggle
 *       this.flashTimer += dt
 *       if (this.flashTimer >= INVINCIBILITY_FLASH_INTERVAL):
 *         this.flashTimer -= INVINCIBILITY_FLASH_INTERVAL
 *         this.flashVisible = !this.flashVisible
 *
 *   Enemy Damage Handling:
 *     enemy.takeDamage(amount):
 *       this.hp -= amount
 *       this.flashFrames = COLLISION.HIT_FLASH_FRAMES  // white flash for N frames
 *       if (this.hp <= 0):
 *         this.alive = false
 *         spawnDeathEffect(this.x, this.y)
 */

// ============================================================
//  SECTION 9: ENEMY STATS & GAME BALANCE TABLES
// ============================================================

/**
 * ENEMY TYPES — Complete Stat Table
 *
 *  Type          HP    Speed  Radius  Damage  Score   Drop%   BulletSpeed   FireRate   Pattern
 *  ───────────── ────  ─────  ──────  ──────  ─────   ─────   ────────────  ────────   ─────────────
 *  Drone         1     120    12      15(c)   50      10%     -             -          straight line
 *  Fighter       3     100    14      18(c)   100     10%     -             -          zigzag or dive
 *  Scout         2     180    12      12(c)   75      10%     -             -          weave + flee
 *  Turret        5     0      16      20(b)   150     12%     250           1.2s       aimed single shot
 *  Shielder      8     40     18      25(c)   200     15%     -             -          orbits player
 *  Swarmling     1     200    10      10(c)   25      5%      -             -          kamikaze rush
 *  Spliter       6     80     14      18(b)   250     12%     300           0.8s       aimed burst(3)
 *  Asteroid      10    60     40      20(c)   0       0%      -             -          linear drift (no attack)
 *  Boss          100   30     36      30(c)   2000    100%    350           0.5s       phases: burst/aimed/spiral
 *
 *  (c) = contact damage, (b) = bullet damage, contact damage defaults to max(bullet dmg, contact dmg)
 */

export const ENEMIES = {
  DRONE: {
    name: 'Drone',
    hp: 1, speed: 120, radius: 12,
    contactDamage: 15, bulletDamage: 0,
    score: 50, dropChance: 0.10,
    bulletSpeed: 0, fireRate: 0, burstCount: 0,
    pattern: 'straight',   // flies straight down, slight horizontal oscillation
  },
  FIGHTER: {
    name: 'Fighter',
    hp: 3, speed: 100, radius: 14,
    contactDamage: 18, bulletDamage: 0,
    score: 100, dropChance: 0.10,
    bulletSpeed: 0, fireRate: 0, burstCount: 0,
    pattern: 'zigzag',     // sinusoidal horizontal movement while descending
  },
  SCOUT: {
    name: 'Scout',
    hp: 2, speed: 180, radius: 12,
    contactDamage: 12, bulletDamage: 0,
    score: 75, dropChance: 0.10,
    bulletSpeed: 0, fireRate: 0, burstCount: 0,
    pattern: 'weave',      // fast, erratic, changes direction
  },
  TURRET: {
    name: 'Turret',
    hp: 5, speed: 0, radius: 16,
    contactDamage: 0, bulletDamage: 20,
    score: 150, dropChance: 0.12,
    bulletSpeed: 250, fireRate: 1.2, burstCount: 1,
    pattern: 'aimed',      // stationary, aims at player
  },
  SHIELDER: {
    name: 'Shielder',
    hp: 8, speed: 40, radius: 18,
    contactDamage: 25, bulletDamage: 0,
    score: 200, dropChance: 0.15,
    bulletSpeed: 0, fireRate: 0, burstCount: 0,
    pattern: 'orbit',      // tries to stay at a fixed distance from player
  },
  SWARMLING: {
    name: 'Swarmling',
    hp: 1, speed: 200, radius: 10,
    contactDamage: 10, bulletDamage: 0,
    score: 25, dropChance: 0.05,
    bulletSpeed: 0, fireRate: 0, burstCount: 0,
    pattern: 'kamikaze',   // accelerates toward player, dies on contact
  },
  SPLITTER: {
    name: 'Spliter',
    hp: 6, speed: 80, radius: 14,
    contactDamage: 0, bulletDamage: 18,
    score: 250, dropChance: 0.12,
    bulletSpeed: 300, fireRate: 0.8, burstCount: 3,
    pattern: 'aimed_burst', // fires 3 aimed bullets, then pauses
  },
  ASTEROID: {
    name: 'Asteroid',
    hp: 10, speed: 60, radius: 40,
    contactDamage: 20, bulletDamage: 0,
    score: 0, dropChance: 0,
    bulletSpeed: 0, fireRate: 0, burstCount: 0,
    pattern: 'drift',      // drifts across screen, no attack, just obstacle
  },
  BOSS: {
    name: 'Boss',
    hp: 100, speed: 30, radius: 36,
    contactDamage: 30, bulletDamage: 20,
    score: 2000, dropChance: 1.0,
    bulletSpeed: 350, fireRate: 0.5, burstCount: 12,
    pattern: 'phased',     // cycles through burst → aimed → spiral → rest
  },
};

// ============================================================
//  SECTION 10: DIFFICULTY SCALING
// ============================================================

/**
 * Per-level multipliers applied to enemy stats.
 * Level transitions occur after clearing all enemies in current wave.
 */
export const DIFFICULTY = {
  LEVELS: [1, 2, 3, 4, 5],
  MULTIPLIERS: [1.0, 1.3, 1.6, 2.0, 2.5],

  /**
   * Scaled stats for enemy at given level:
   *   scaledHP         = baseHP   * mult
   *   scaledSpeed      = baseSpeed * sqrt(mult)     // speed scales slower
   *   scaledBulletCount = baseBurstCount * mult      // more bullets in bursts (ceil)
   *   scaledSpawnRate  = baseSpawnRate / mult        // lower interval = more enemies
   *   scaledScore      = baseScore * mult
   */
};

/**
 * getLevelMultiplier(levelIndex):
 *   return DIFFICULTY.MULTIPLIERS[levelIndex]
 *
 * scaleEnemy(enemyTemplate, level):
 *   let m = DIFFICULTY.MULTIPLIERS[level]
 *   return {
 *     ...enemyTemplate,
 *     hp:       Math.round(enemyTemplate.hp * m),
 *     speed:    Math.round(enemyTemplate.speed * Math.sqrt(m)),
 *     burstCount: Math.max(enemyTemplate.burstCount, Math.ceil(enemyTemplate.burstCount * m)),
 *     score:    Math.round(enemyTemplate.score * m),
 *   }
 */

// ============================================================
//  SECTION 11: SCREEN SHAKE
// ============================================================
export const SCREEN_SHAKE = {
  DECAY: 0.85,                // multiply intensity by this each frame
  MIN_THRESHOLD: 0.3,         // stop shaking below this
};

/**
 * Screen shake state:
 *   let shakeIntensity = 0
 *   let shakeDuration  = 0
 *
 *   trigger(intensity, duration):
 *     shakeIntensity = Math.max(shakeIntensity, intensity)
 *     shakeDuration = Math.max(shakeDuration, duration)
 *
 *   update(dt):
 *     if (shakeIntensity <= SCREEN_SHAKE.MIN_THRESHOLD):
 *       shakeIntensity = 0
 *       offsetX = 0; offsetY = 0
 *       return
 *     shakeIntensity *= SCREEN_SHAKE.DECAY
 *     offsetX = (Math.random() * 2 - 1) * shakeIntensity
 *     offsetY = (Math.random() * 2 - 1) * shakeIntensity
 *
 *   // Renderer applies offsetX, offsetY as translation to all draw calls
 *
 *   // Named triggers:
 *   SHAKE_HIT:    { intensity: 3,   duration: 0.15 }  // player hit
 *   SHAKE_EXPLODE:{ intensity: 6,   duration: 0.25 }  // enemy explosion
 *   SHAKE_BOSS:   { intensity: 10,  duration: 0.5  }  // boss attack
 *   SHAKE_NUKE:   { intensity: 15,  duration: 0.6  }  // nuke screen clear
 */

// ============================================================
//  SECTION 12: PARTICLE SYSTEM (pooled)
// ============================================================
export const PARTICLES = {
  POOL_SIZE: 200,
  TYPES: {
    EXPLOSION:     { count: 12, speed: 150, lifetime: 0.5,  colors: ['#ff6600','#ffcc00','#ff3300'], size: 3 },
    SPARK:         { count: 5,  speed: 100, lifetime: 0.3,  colors: ['#ffff00','#ffffff'], size: 2 },
    SHIELD_HIT:    { count: 8,  speed: 80,  lifetime: 0.4,  colors: ['#00ffff','#0088ff'], size: 2 },
    NUKE_FLASH:    { count: 40, speed: 300, lifetime: 0.8,  colors: ['#ffffff','#ffffcc'], size: 5 },
    THRUST:        { count: 2,  speed: 40,  lifetime: 0.2,  colors: ['#ff4400','#ff8800'], size: 1 },
  },
};

/**
 * Particle object:
 *   {
 *     x, y, vx, vy,
 *     life, maxLife,
 *     size, color,
 *     alive: false,
 *     update(dt): x += vx * dt; y += vy * dt; life -= dt; alive = life > 0
 *   }
 *
 * spawnParticles(x, y, type):
 *   let config = PARTICLES.TYPES[type]
 *   for i in 0..config.count:
 *     let p = particlePool.acquire()
 *     let angle = Math.random() * 2 * PI
 *     let speed = config.speed * (0.5 + Math.random() * 0.5)
 *     p.x = x; p.y = y
 *     p.vx = Math.cos(angle) * speed
 *     p.vy = Math.sin(angle) * speed
 *     p.life = config.lifetime; p.maxLife = p.life
 *     p.size = config.size * (0.5 + Math.random())
 *     p.color = config.colors[Math.floor(Math.random() * config.colors.length)]
 *     p.alive = true
 */

// ============================================================
//  SECTION 13: GAME STATE DEFINITIONS
// ============================================================
export const GAME_STATES = {
  MENU:        'menu',
  PLAYING:     'playing',
  PAUSED:      'paused',
  LEVEL_COMPLETE: 'level_complete',
  GAME_OVER:   'game_over',
};

/**
 * Main Game State Object (conceptual):
 *
 *   gameState = {
 *     state: 'menu',
 *     level: 0,
 *     score: 0,
 *     highScore: 0,  // persisted to localStorage
 *     lives: 3,      // if using lives system; otherwise single-life arcade
 *     time: 0,       // elapsed game time
 *   }
 */

// ============================================================
//  SECTION 14: WAVE / SPAWN SYSTEM PARAMETERS
// ============================================================
export const SPAWN = {
  // Spawn area: top of screen (Y < 0, offscreen, drift down)
  SPAWN_Y_MIN: -40,
  SPAWN_Y_MAX: -20,
  SPAWN_X_MIN: 40,
  SPAWN_X_MAX: WORLD.WIDTH - 40,

  // Spawn timing
  BASE_INTERVAL: 1.5,   // seconds between spawns (level 1)
  MIN_INTERVAL: 0.4,    // fastest possible

  // Wave structure
  ENEMIES_PER_WAVE_BASE: 15,
  ENEMIES_PER_WAVE_INCREMENT: 5,
  WAVE_TRANSITION_DELAY: 3.0,  // seconds between waves
  BOSS_EVERY_N_WAVES: 5,       // boss every 5th wave

  // Enemy type weights by level (progressively harder enemies)
  // Level → [Drone, Fighter, Scout, Turret, Shielder, Swarmling, Splitter, Asteroid]
  WEIGHTS: [
    [50, 25, 15, 5,  0,  5,  0,  0],   // Level 1
    [35, 25, 15, 10, 5,  5,  5,  0],   // Level 2
    [20, 20, 15, 15, 10, 10, 5,  5],   // Level 3
    [10, 15, 10, 20, 15, 10, 10, 10],  // Level 4
    [5,  10, 5,  20, 20, 15, 15, 10],  // Level 5
  ],
};

// ============================================================
//  SECTION 15: UTILITY FUNCTIONS
// ============================================================

/**
 * Clamp value between min and max
 */
export function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

/**
 * Circle-circle overlap test (fast, no sqrt until needed)
 */
export function circlesOverlap(x1, y1, r1, x2, y2, r2) {
  const dx = x1 - x2;
  const dy = y1 - y2;
  const rSum = r1 + r2;
  return dx * dx + dy * dy <= rSum * rSum;
}

/**
 * Normalize a 2D vector in-place, returns length
 */
export function normalize(vx, vy) {
  const len = Math.sqrt(vx * vx + vy * vy);
  if (len < WORLD.EPSILON) return { x: 0, y: 0, length: 0 };
  return { x: vx / len, y: vy / len, length: len };
}

/**
 * Random float between min and max
 */
export function randRange(min, max) {
  return min + Math.random() * (max - min);
}

/**
 * Random integer between min and max (inclusive)
 */
export function randInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * Weighted random selection from array of [value, weight] pairs
 */
export function weightedRandom(items) {
  // items = [[value, weight], ...]
  const totalWeight = items.reduce((sum, [, w]) => sum + w, 0);
  let r = Math.random() * totalWeight;
  for (const [value, weight] of items) {
    r -= weight;
    if (r <= 0) return value;
  }
  return items[items.length - 1][0];
}

/**
 * Lerp between a and b by factor t
 */
export function lerp(a, b, t) {
  return a + (b - a) * t;
}

// ============================================================
//  SECTION 16: FRAME-INDEPENDENT TIMESTEP
// ============================================================
/**
 * Fixed timestep game loop (recommended for deterministic physics):
 *
 *   const FIXED_DT = 1/60                    // 16.67ms
 *   const MAX_FRAME_DT = 1/15                // cap at ~66ms to avoid spiral of death
 *   let accumulator = 0
 *
 *   function gameLoop(timestamp):
 *     requestAnimationFrame(gameLoop)
 *     let frameDt = Math.min((timestamp - lastTime) / 1000, MAX_FRAME_DT)
 *     lastTime = timestamp
 *     accumulator += frameDt
 *
 *     while (accumulator >= FIXED_DT):
 *       update(FIXED_DT)     // physics, collision, game logic at fixed step
 *       accumulator -= FIXED_DT
 *
 *     render(accumulator / FIXED_DT)  // interpolation alpha for smooth rendering
 *
 *   This gives deterministic physics at target 60fps while allowing
 *   the renderer to interpolate for smooth visual on any refresh rate.
 */

// ============================================================
//  EXPORT SUMMARY
// ============================================================
// For convenience, re-export everything under a single namespace:
export const PHYSICS_SPEC = {
  WORLD,
  CAMERA,
  PLAYER,
  COLLISION,
  BULLET,
  DAMAGE,
  ENEMIES,
  DIFFICULTY,
  POWERUP,
  PARTICLES,
  SCREEN_SHAKE,
  POOL_SIZES,
  SPAWN,
  GAME_STATES,
};

export default PHYSICS_SPEC;
