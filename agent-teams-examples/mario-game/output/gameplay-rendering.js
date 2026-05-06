// ===== GAMEPLAY & RENDERING (Sections 10-17) =====

// ========== SECTION 10: PLAYER LOGIC ==========

function updatePlayer(dt) {
    if (!player.alive) {
        handleDeathSequence(dt);
        return;
    }
    var dtNorm = dt / 16.667;
    player.vy += GRAVITY * dtNorm;
    if (player.vy > MAX_FALL_SPEED) player.vy = MAX_FALL_SPEED;
    player.onGround = false;
    resolvePlayerTileCollision(player, dt);
    if (player.y > level.height * TILE_SIZE + 64) {
        killPlayer();
    }
    player.x = Math.max(0, Math.min(player.x, level.width * TILE_SIZE - player.width));
    player.y = Math.max(-64, player.y);
    if (player.onGround && player.vy >= 0) {
        player.state = "idle";
    } else if (player.vy < 0) {
        player.state = "jump";
    } else if (!player.onGround) {
        player.state = "fall";
    }
    if (Math.abs(player.vx) > 0.5 && player.onGround) {
        player.state = "walk";
    }
    if (player.invincibleTimer > 0) {
        player.invincibleTimer -= dtNorm;
        if (player.invincibleTimer < 0) player.invincibleTimer = 0;
    }
    if (player.deathTimer > 0) {
        player.deathTimer -= dtNorm;
        if (player.deathTimer < 0) player.deathTimer = 0;
    }
}

function movePlayer(dt) {
    if (!player.alive) return;
    var moving = false;
    if (typeof isPressed === 'function') {
        if (isPressed('left')) { player.vx = -player.speed; player.facing = -1; moving = true; }
        else if (isPressed('right')) { player.vx = player.speed; player.facing = 1; moving = true; }
    } else {
        if (keys['ArrowLeft'] || keys['KeyA']) { player.vx = -player.speed; player.facing = -1; moving = true; }
        else if (keys['ArrowRight'] || keys['KeyD']) { player.vx = player.speed; player.facing = 1; moving = true; }
    }
    if (!moving) {
        player.vx *= 0.8;
        if (Math.abs(player.vx) < 0.1) player.vx = 0;
    }
}

function jump() {
    if (!player.alive) return;
    if (player.onGround) {
        player.vy = JUMP_VELOCITY;
        player.onGround = false;
        player.state = "jump";
        player.canDoubleJump = player.powerups.doubleJump;
        player.hasDoubleJumped = false;
        if (typeof playSound === 'function') playSound('jump');
    } else if (player.powerups.doubleJump && player.canDoubleJump && !player.hasDoubleJumped) {
        player.vy = DOUBLE_JUMP_VEL;
        player.hasDoubleJumped = true;
        player.state = "jump";
        if (typeof playSound === 'function') playSound('jump');
        spawnParticles(player.x + player.width / 2, player.y + player.height, 6, '#FFFFFF');
    }
}

function stompBounce() {
    player.vy = STOMP_BOUNCE;
    player.onGround = false;
    player.state = "jump";
}

function hurtPlayer() {
    if (player.invincibleTimer > 0) return;
    if (player.powerups.invincible) return;
    player.lives--;
    player.invincibleTimer = INVINCIBILITY_FRAMES;
    if (typeof playSound === 'function') playSound('hurt');
    spawnParticles(player.x + player.width / 2, player.y + player.height / 2, 10, '#FF4444');
    if (player.lives <= 0) {
        killPlayer();
    }
}

function killPlayer() {
    player.alive = false;
    player.state = "dead";
    player.deathTimer = 60;
    player.vy = -6;
    player.vx = 0;
    if (typeof playSound === 'function') playSound('hurt');
    spawnParticles(player.x + player.width / 2, player.y + player.height / 2, 12, '#FFFFFF');
}

function respawnPlayer() {
    player.lives--;
    player.alive = true;
    player.state = "idle";
    player.vx = 0;
    player.vy = 0;
    player.invincibleTimer = 120;
    player.powerups.speed = false;
    player.powerups.invincible = false;
    player.powerups.doubleJump = false;
    player.powerupTimers.speed = 0;
    player.powerupTimers.invincible = 0;
    player.speed = PLAYER_SPEED;
    player.canDoubleJump = false;
    player.hasDoubleJumped = false;
    if (player.lastCheckpoint) {
        player.x = player.lastCheckpoint.col * TILE_SIZE;
        player.y = player.lastCheckpoint.row * TILE_SIZE - player.height;
    } else {
        player.x = level.playerSpawn.col * TILE_SIZE;
        player.y = level.playerSpawn.row * TILE_SIZE - player.height;
    }
    camera.x = player.x - CANVAS_WIDTH / 2;
    camera.y = player.y - CANVAS_HEIGHT / 2;
    updateCamera(0);
}

function updatePlayerAnimation(dt) {
    if (!player.alive) return;
    player.animTimer += dt / 16.667;
    var frameRate;
    var maxFrames;
    if (player.state === "walk") {
        frameRate = 8;
        maxFrames = 4;
    } else if (player.state === "jump") {
        frameRate = 20;
        maxFrames = 2;
    } else if (player.state === "fall") {
        frameRate = 20;
        maxFrames = 2;
    } else if (player.state === "dead") {
        frameRate = 30;
        maxFrames = 1;
    } else {
        frameRate = 15;
        maxFrames = 2;
    }
    if (player.animTimer >= frameRate) {
        player.animTimer = 0;
        player.animFrame = (player.animFrame + 1) % maxFrames;
    }
}

function updatePowerupTimers(dt) {
    var dtNorm = dt / 16.667;
    if (player.powerupTimers.speed > 0) {
        player.powerupTimers.speed -= dtNorm;
        if (player.powerupTimers.speed <= 0) {
            player.powerupTimers.speed = 0;
            player.powerups.speed = false;
            player.speed = PLAYER_SPEED;
        }
    }
    if (player.powerupTimers.invincible > 0) {
        player.powerupTimers.invincible -= dtNorm;
        if (player.powerupTimers.invincible <= 0) {
            player.powerupTimers.invincible = 0;
            player.powerups.invincible = false;
        }
    }
}

function activatePowerup(type) {
    if (type === "speed") {
        player.powerups.speed = true;
        player.powerupTimers.speed = POWERUP_DURATION;
        player.speed = PLAYER_SPEED * 2;
        if (typeof playSound === 'function') playSound('powerup');
    } else if (type === "invincible") {
        player.powerups.invincible = true;
        player.powerupTimers.invincible = POWERUP_DURATION;
        if (typeof playSound === 'function') playSound('powerup');
    } else if (type === "doubleJump") {
        player.powerups.doubleJump = true;
        if (typeof playSound === 'function') playSound('powerup');
    } else if (type === "extraLife") {
        player.lives = Math.min(player.lives + 1, MAX_LIVES);
        if (typeof playSound === 'function') playSound('powerup');
        spawnParticles(player.x + player.width / 2, player.y + player.height / 2, 15, '#FF4444');
    }
}

function collectCoin(value) {
    player.score += value;
    player.coins++;
    if (typeof playSound === 'function') playSound('coin');
}

// ========== SECTION 11: ENEMY LOGIC ==========

function initEnemies() {
    enemies = [];
    if (!level.enemies) return;
    var spawnDefs = level.enemies;
    for (var i = 0; i < spawnDefs.length; i++) {
        var def = spawnDefs[i];
        var enemy = {
            type: def.type,
            x: def.col * TILE_SIZE,
            y: def.row * TILE_SIZE - getEnemyHeight(def.type),
            width: getEnemyWidth(def.type),
            height: getEnemyHeight(def.type),
            vx: 0,
            vy: 0,
            alive: true,
            facing: def.direction || 1,
            animFrame: 0,
            animTimer: 0,
            spawnX: def.col * TILE_SIZE,
            patrolLeft: (def.col - (def.patrolRange || 3)) * TILE_SIZE,
            patrolRight: (def.col + (def.patrolRange || 3)) * TILE_SIZE,
            baseY: def.row * TILE_SIZE - getEnemyHeight(def.type),
            phase: Math.random() * Math.PI * 2,
            shootTimer: 0,
            shootInterval: def.shootInterval || 120,
            aggroRange: (def.aggroRange || 8) * TILE_SIZE,
            speed: getEnemySpeed(def.type, def.speed)
        };
        if (def.amplitude) enemy.amplitude = def.amplitude;
        if (def.frequency) enemy.frequency = def.frequency;
        enemies.push(enemy);
    }
}

function getEnemyWidth(type) {
    if (type === "slime") return 28;
    if (type === "bat") return 24;
    if (type === "skeleton") return 28;
    if (type === "ghost") return 28;
    return 28;
}

function getEnemyHeight(type) {
    if (type === "slime") return 24;
    if (type === "bat") return 20;
    if (type === "skeleton") return 32;
    if (type === "ghost") return 30;
    return 28;
}

function getEnemySpeed(type, customSpeed) {
    if (customSpeed !== undefined) return customSpeed;
    if (type === "slime") return 1.5;
    if (type === "bat") return 2.0;
    if (type === "skeleton") return 2.0;
    if (type === "ghost") return 1.5;
    return 1.5;
}

function updateEnemies(dt) {
    for (var i = 0; i < enemies.length; i++) {
        var enemy = enemies[i];
        if (!enemy.alive) continue;
        if (!enemyInView(enemy)) continue;
        if (enemy.type === "slime") updateSlime(enemy, dt);
        else if (enemy.type === "bat") updateBat(enemy, dt);
        else if (enemy.type === "skeleton") updateSkeleton(enemy, dt);
        else if (enemy.type === "ghost") updateGhost(enemy, dt);
        updateEnemyAnimation(enemy, dt);
    }
}

function updateSlime(enemy, rawDt) {
    var dt = rawDt / 16.667;
    enemy.vx = enemy.speed * enemy.facing;
    if (enemy.x < enemy.patrolLeft) {
        enemy.x = enemy.patrolLeft;
        enemy.facing = 1;
    }
    if (enemy.x + enemy.width > enemy.patrolRight) {
        enemy.x = enemy.patrolRight - enemy.width;
        enemy.facing = -1;
    }
    enemy.vy += GRAVITY * dt;
    resolveEnemyTileCollision(enemy, rawDt);
    if (enemy.y > level.height * TILE_SIZE + 64) {
        enemy.alive = false;
    }
}

function updateBat(enemy, rawDt) {
    var dt = rawDt / 16.667;
    enemy.phase += (enemy.frequency || 0.02) * dt;
    enemy.y = enemy.baseY + Math.sin(enemy.phase) * (enemy.amplitude || 4) * TILE_SIZE;
    enemy.x += enemy.speed * enemy.facing * dt;
    if (enemy.x < enemy.patrolLeft || enemy.x + enemy.width > enemy.patrolRight) {
        enemy.facing *= -1;
    }
}

function updateSkeleton(enemy, rawDt) {
    var dt = rawDt / 16.667;
    enemy.vx = enemy.speed * enemy.facing;
    if (enemy.x < enemy.patrolLeft) {
        enemy.x = enemy.patrolLeft;
        enemy.facing = 1;
    }
    if (enemy.x + enemy.width > enemy.patrolRight) {
        enemy.x = enemy.patrolRight - enemy.width;
        enemy.facing = -1;
    }
    enemy.vy += GRAVITY * dt;
    resolveEnemyTileCollision(enemy, rawDt);
    enemy.shootTimer += dt;
    if (enemy.shootTimer >= enemy.shootInterval) {
        enemy.shootTimer = 0;
        var boneX = enemy.x + (enemy.facing > 0 ? enemy.width : 0);
        var boneY = enemy.y + enemy.height / 2 - 4;
        spawnBone(boneX, boneY, enemy.facing);
    }
}

function updateGhost(enemy, rawDt) {
    var dt = rawDt / 16.667;
    enemy.phase += 0.02 * dt;
    enemy.y = enemy.baseY + Math.sin(enemy.phase) * 16;
    var dx = player.x - enemy.x;
    var dy = player.y - enemy.y;
    var dist = Math.sqrt(dx * dx + dy * dy);
    if (dist < enemy.aggroRange && dist > 0) {
        enemy.x += (dx / dist) * enemy.speed * dt;
        enemy.y += (dy / dist) * enemy.speed * 0.5 * dt;
        enemy.facing = dx > 0 ? 1 : -1;
    } else {
        enemy.x += enemy.speed * enemy.facing * dt;
        if (enemy.x < enemy.patrolLeft || enemy.x + enemy.width > enemy.patrolRight) {
            enemy.facing *= -1;
        }
    }
}

function killEnemy(enemy) {
    enemy.alive = false;
    if (enemy.type === "slime") player.score += 100;
    else if (enemy.type === "bat") player.score += 150;
    else if (enemy.type === "skeleton") player.score += 200;
    else if (enemy.type === "ghost") player.score += 250;
    spawnParticles(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2, 8, getEnemyDeathColor(enemy.type));
    if (typeof playSound === 'function') playSound('stomp');
}

function getEnemyDeathColor(type) {
    if (type === "slime") return '#44CC44';
    if (type === "bat") return '#8844CC';
    if (type === "skeleton") return '#CCCCCC';
    if (type === "ghost") return '#C8C8FF';
    return '#FFFFFF';
}

function enemyInView(enemy) {
    if (typeof isOnScreen === 'function') return isOnScreen(enemy);
    return true;
}

function updateEnemyAnimation(enemy, dt) {
    enemy.animTimer += dt / 16.667;
    var frameRate, maxFrames;
    if (enemy.type === "slime") { frameRate = 12; maxFrames = 2; }
    else if (enemy.type === "bat") { frameRate = 8; maxFrames = 4; }
    else if (enemy.type === "skeleton") { frameRate = 10; maxFrames = 4; }
    else if (enemy.type === "ghost") { frameRate = 15; maxFrames = 2; }
    else { frameRate = 12; maxFrames = 2; }
    if (enemy.animTimer >= frameRate) {
        enemy.animTimer -= frameRate;
        enemy.animFrame = (enemy.animFrame + 1) % maxFrames;
    }
}

// ========== SECTION 12: BOSS LOGIC ==========

function initBoss() {
    boss = null;
    if (currentLevel !== 3) return;
    if (!level.boss) return;
    var def = level.boss;
    boss = {
        type: "boss",
        x: def.col * TILE_SIZE,
        y: def.row * TILE_SIZE - (def.height || 64),
        width: def.width || 64,
        height: def.height || 64,
        vx: 0,
        vy: 0,
        hp: def.hp || 5,
        maxHp: def.hp || 5,
        phase: 1,
        invincibleTimer: 0,
        attackTimer: 0,
        currentAttack: "idle",
        attackState: "windup",
        attackTime: 0,
        facing: -1,
        animFrame: 0,
        animTimer: 0,
        alive: true,
        chargeDir: 0,
        fireballsFired: 0,
        stompPhase: 0,
        stompY: 0
    };
    if (typeof startBossMusic === 'function') startBossMusic();
}

function updateBoss(dt) {
    if (!boss || !boss.alive) return;
    var dtNorm = dt / 16.667;
    if (boss.invincibleTimer > 0) {
        boss.invincibleTimer -= dtNorm;
        if (boss.invincibleTimer < 0) boss.invincibleTimer = 0;
    }
    boss.animTimer += dtNorm;
    var frameRate = boss.phase === 3 ? 6 : (boss.phase === 2 ? 8 : 10);
    if (boss.animTimer >= frameRate) {
        boss.animTimer -= frameRate;
        boss.animFrame = (boss.animFrame + 1) % 4;
    }
    boss.facing = player.x > boss.x ? 1 : -1;
    if (boss.currentAttack === "idle") {
        boss.attackTimer -= dtNorm;
        if (boss.attackTimer <= 0) {
            boss.currentAttack = bossChooseAttack();
            boss.attackState = "windup";
            boss.attackTime = 0;
            boss.vx = 0;
            boss.vy = 0;
        }
    } else if (boss.currentAttack === "charge") {
        bossCharge(dtNorm);
    } else if (boss.currentAttack === "fireball") {
        bossFireball(dtNorm);
    } else if (boss.currentAttack === "stomp") {
        bossStomp(dtNorm);
    }
    if (boss.currentAttack !== "idle" && boss.attackState === "recovery") {
        boss.attackTime -= dtNorm;
        if (boss.attackTime <= 0) {
            boss.currentAttack = "idle";
            boss.attackState = "windup";
            boss.attackTimer = (level.boss.attackInterval || 90) + boss.phase * 10;
            boss.vx = 0;
            boss.vy = 0;
        }
    }
    boss.x = Math.max(0, Math.min(boss.x, level.width * TILE_SIZE - boss.width));
    boss.y = Math.min(boss.y, level.height * TILE_SIZE - boss.height);
}

function bossChooseAttack() {
    var attacks = level.boss.attacks || ["charge", "fireball", "stomp"];
    if (boss.phase === 3) {
        var r = Math.random();
        if (r < 0.4) return "charge";
        if (r < 0.75) return "fireball";
        return "stomp";
    }
    if (boss.phase === 2) {
        var r2 = Math.random();
        if (r2 < 0.35) return "charge";
        if (r2 < 0.7) return "fireball";
        return "stomp";
    }
    var r1 = Math.random();
    if (r1 < 0.4) return "charge";
    if (r1 < 0.7) return "fireball";
    return "stomp";
}

function bossCharge(dt) {
    boss.attackTime += dt;
    if (boss.attackState === "windup") {
        boss.vx = -1;
        if (boss.attackTime >= 30) {
            boss.attackState = "active";
            boss.attackTime = 0;
            boss.chargeDir = player.x > boss.x ? 1 : -1;
            boss.vx = boss.chargeDir * 8;
        }
    } else if (boss.attackState === "active") {
        boss.x += boss.vx * dt;
        if (boss.attackTime >= 45) {
            boss.attackState = "recovery";
            boss.attackTime = 20;
            boss.vx = boss.chargeDir * -2;
        }
    } else if (boss.attackState === "recovery") {
        boss.x += boss.vx * dt;
        if (Math.abs(boss.vx) < 0.5) boss.vx = 0;
        else boss.vx *= 0.9;
    }
}

function bossFireball(dt) {
    boss.attackTime += dt;
    if (boss.attackState === "windup") {
        if (boss.attackTime >= 25) {
            boss.attackState = "active";
            boss.attackTime = 0;
            boss.fireballsFired = 0;
        }
    } else if (boss.attackState === "active") {
        var fireInterval = 8;
        if (boss.attackTime >= boss.fireballsFired * fireInterval && boss.fireballsFired < 3) {
            var fromX = boss.x + boss.width / 2;
            var fromY = boss.y + boss.height / 2;
            var toX = player.x + player.width / 2 + (boss.fireballsFired - 1) * 30;
            var toY = player.y + player.height / 2;
            spawnFireball(fromX, fromY, toX, toY);
            boss.fireballsFired++;
        }
        if (boss.fireballsFired >= 3) {
            boss.attackState = "recovery";
            boss.attackTime = 30;
        }
    }
}

function bossStomp(dt) {
    boss.attackTime += dt;
    if (boss.attackState === "windup") {
        if (boss.attackTime >= 20) {
            boss.attackState = "active";
            boss.attackTime = 0;
            boss.vy = -12;
            boss.stompY = boss.y;
        }
    } else if (boss.attackState === "active") {
        boss.vy += GRAVITY * dt;
        boss.y += boss.vy * dt;
        if (boss.y >= boss.stompY && boss.vy > 0) {
            boss.y = boss.stompY;
            boss.vy = 0;
            boss.attackState = "recovery";
            boss.attackTime = 25;
            spawnParticles(boss.x + boss.width / 2, boss.y + boss.height, 20, '#FF4444');
            spawnParticles(boss.x + boss.width / 2 - 48, boss.y + boss.height, 12, '#FF4444');
            spawnParticles(boss.x + boss.width / 2 + 48, boss.y + boss.height, 12, '#FF4444');
            if (typeof playSound === 'function') playSound('stomp');
        }
    }
}

function damageBoss() {
    if (!boss || !boss.alive) return;
    if (boss.invincibleTimer > 0) return;
    boss.hp--;
    boss.invincibleTimer = 30;
    bossPhaseCheck();
    if (typeof playSound === 'function') playSound('bossHit');
    spawnParticles(boss.x + boss.width / 2, boss.y + boss.height / 2, 15, '#FFFF00');
    if (boss.hp <= 0) {
        boss.alive = false;
        if (typeof stopBossMusic === 'function') stopBossMusic();
        spawnParticles(boss.x, boss.y, 40, '#FF4444');
        spawnParticles(boss.x + boss.width, boss.y, 40, '#FF4444');
        if (typeof playSound === 'function') playSound('victory');
        player.score += 1000;
        if (level.exit) {
            level.tiles[level.exit.row][level.exit.col] = TILE.EXIT_FLAG;
        }
    }
}

function bossPhaseCheck() {
    if (!boss) return;
    if (boss.hp >= 4) boss.phase = 1;
    else if (boss.hp >= 2) boss.phase = 2;
    else boss.phase = 3;
}

function checkBossCollision() {
    if (!boss || !boss.alive) return;
    if (!player.alive) return;
    if (typeof rectsOverlap !== 'function') return;
    if (!rectsOverlap(player, boss)) return;
    var prevPlayerBottom = player.y + player.height - player.vy;
    var isStomp = player.vy > 0 && prevPlayerBottom <= boss.y + boss.height * 0.5;
    if (isStomp) {
        damageBoss();
        player.vy = STOMP_BOUNCE;
    } else if (boss.currentAttack !== "idle" && boss.attackState === "active") {
        if (!player.powerups.invincible && player.invincibleTimer <= 0) {
            hurtPlayer();
        }
    }
}

function updateProjectiles(dt) {
    var dtNorm = dt / 16.667;
    for (var i = projectiles.length - 1; i >= 0; i--) {
        var p = projectiles[i];
        if (!p.alive) continue;
        p.age += dtNorm;
        if (p.age >= p.lifetime) {
            p.alive = false;
            continue;
        }
        p.x += p.vx * dtNorm;
        p.y += p.vy * dtNorm;
        var tileCol = Math.floor(p.x / TILE_SIZE);
        var tileRow = Math.floor(p.y / TILE_SIZE);
        if (p.type === "bone") {
            if (tileRow >= 0 && tileRow < level.height && tileCol >= 0 && tileCol < level.width) {
                var tileType = level.tiles[tileRow][tileCol];
                if (SOLID_TILES.has(tileType)) {
                    p.alive = false;
                    spawnParticles(p.x, p.y, 4, '#CCCCCC');
                }
            }
        }
        if (p.x < 0 || p.x > level.width * TILE_SIZE || p.y < 0 || p.y > level.height * TILE_SIZE) {
            p.alive = false;
        }
    }
    projectiles = projectiles.filter(function(p) { return p.alive; });
}

function spawnFireball(fromX, fromY, toX, toY) {
    var dx = toX - fromX;
    var dy = toY - fromY;
    var dist = Math.sqrt(dx * dx + dy * dy);
    if (dist < 1) dist = 1;
    projectiles.push({
        x: fromX - 6,
        y: fromY - 6,
        vx: (dx / dist) * 4,
        vy: (dy / dist) * 4,
        width: 12,
        height: 12,
        damage: 1,
        color: '#FF6600',
        type: 'fireball',
        alive: true,
        lifetime: 120,
        age: 0
    });
    if (typeof playSound === 'function') playSound('fireball');
}

function spawnBone(x, y, direction) {
    projectiles.push({
        x: x - 4,
        y: y - 2,
        vx: direction * 3,
        vy: 0,
        width: 8,
        height: 4,
        damage: 1,
        color: '#EEEEEE',
        type: 'bone',
        alive: true,
        lifetime: 180,
        age: 0
    });
}

// ========== SECTION 13: COLLECTIBLES & POWERUPS ==========

function initCollectibles() {
    coins = [];
    powerupItems = [];
    if (level.coins) {
        for (var i = 0; i < level.coins.length; i++) {
            var c = level.coins[i];
            coins.push({
                x: c.col * TILE_SIZE + TILE_SIZE / 2 - 8,
                y: c.row * TILE_SIZE + TILE_SIZE / 2 - 8,
                width: 16,
                height: 16,
                value: c.value || 10,
                alive: true,
                animFrame: 0,
                animTimer: 0,
                bobOffset: Math.random() * Math.PI * 2
            });
        }
    }
    if (level.powerups) {
        for (var j = 0; j < level.powerups.length; j++) {
            var p = level.powerups[j];
            powerupItems.push({
                x: p.col * TILE_SIZE + TILE_SIZE / 2 - 12,
                y: p.row * TILE_SIZE + TILE_SIZE / 2 - 12,
                width: 24,
                height: 24,
                type: p.type,
                alive: true,
                animFrame: 0,
                animTimer: 0,
                bobOffset: Math.random() * Math.PI * 2
            });
        }
    }
}

function updateCollectibles(dt) {
    var dtNorm = dt / 16.667;
    for (var i = 0; i < coins.length; i++) {
        if (!coins[i].alive) continue;
        coins[i].animTimer += dtNorm;
        if (coins[i].animTimer >= 8) {
            coins[i].animTimer -= 8;
            coins[i].animFrame = (coins[i].animFrame + 1) % 4;
        }
        coins[i].y += Math.sin(globalFrame * 0.05 + coins[i].bobOffset) * 0.2;
    }
    for (var j = 0; j < powerupItems.length; j++) {
        if (!powerupItems[j].alive) continue;
        powerupItems[j].animTimer += dtNorm;
        if (powerupItems[j].animTimer >= 10) {
            powerupItems[j].animTimer -= 10;
            powerupItems[j].animFrame = (powerupItems[j].animFrame + 1) % 4;
        }
    }
}

// ========== SECTION 14: PARTICLES ==========

function spawnParticles(x, y, count, color) {
    for (var i = 0; i < count; i++) {
        if (particles.length >= 200) break;
        var angle = Math.random() * Math.PI * 2;
        var speed = 1 + Math.random() * 4;
        var life = 20 + Math.random() * 40;
        particles.push({
            x: x,
            y: y,
            vx: Math.cos(angle) * speed,
            vy: Math.sin(angle) * speed - 2,
            life: life,
            maxLife: life,
            color: color,
            size: 2 + Math.random() * 4,
            gravity: 0.05 + Math.random() * 0.1,
            screenSpace: false
        });
    }
}

function spawnConfettiParticles(count) {
    var colors = ['#FF3333', '#33FF33', '#3333FF', '#FFFF33', '#FF33FF', '#33FFFF', '#FFFFFF', '#FF9933'];
    for (var i = 0; i < count; i++) {
        if (particles.length >= 200) break;
        var color = colors[Math.floor(Math.random() * colors.length)];
        var life = 80 + Math.random() * 80;
        particles.push({
            x: Math.random() * CANVAS_WIDTH,
            y: -10 - Math.random() * 30,
            vx: (Math.random() - 0.5) * 3,
            vy: 1 + Math.random() * 2,
            life: life,
            maxLife: life,
            color: color,
            size: 3 + Math.random() * 5,
            gravity: 0.02 + Math.random() * 0.04,
            screenSpace: true
        });
    }
}

function updateParticles(dt) {
    var dtNorm = dt / 16.667;
    for (var i = particles.length - 1; i >= 0; i--) {
        var p = particles[i];
        p.life -= dtNorm;
        if (p.life <= 0) {
            particles.splice(i, 1);
            continue;
        }
        p.vy += p.gravity * dtNorm;
        p.y += p.vy * dtNorm;
        p.x += p.vx * dtNorm;
    }
}

function renderParticles(ctx) {
    for (var i = 0; i < particles.length; i++) {
        var p = particles[i];
        var alpha = Math.min(1, p.life / Math.max(1, p.maxLife));
        var sx, sy;
        if (p.screenSpace) {
            sx = p.x;
            sy = p.y;
        } else {
            sx = p.x - camera.x;
            sy = p.y - camera.y;
        }
        if (typeof drawParticle === 'function') {
            drawParticle(ctx, p, sx, sy);
        } else {
            ctx.globalAlpha = alpha;
            ctx.fillStyle = p.color;
            ctx.fillRect(sx - p.size / 2, sy - p.size / 2, p.size, p.size);
            ctx.globalAlpha = 1;
        }
    }
}

// ========== SECTION 15: RENDER PIPELINE ==========

function clearCanvas() {
    var bg1 = (level && level.bgColor1) ? level.bgColor1 : '#000000';
    var bg2 = (level && level.bgColor2) ? level.bgColor2 : '#333333';
    var grad = ctx.createLinearGradient(0, 0, 0, CANVAS_HEIGHT);
    grad.addColorStop(0, bg1);
    grad.addColorStop(1, bg2);
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
}

function renderParallaxBackground() {
    if (!level.parallax || !level.parallax.layers) return;
    var layers = level.parallax.layers;
    for (var i = 0; i < layers.length; i++) {
        var layer = layers[i];
        var scrollOffset = camera.x * (layer.speed || 0.5);
        if (typeof drawParallaxLayer === 'function') {
            drawParallaxLayer(ctx, layer, scrollOffset);
        } else {
            ctx.fillStyle = layer.color || '#000000';
            if (layer.shape === 'hills') {
                ctx.beginPath();
                ctx.moveTo(0, CANVAS_HEIGHT);
                for (var x = 0; x <= CANVAS_WIDTH; x += 4) {
                    var worldX = x + scrollOffset;
                    var hillY = CANVAS_HEIGHT - 40 - Math.sin(worldX * 0.02) * 30 - Math.sin(worldX * 0.05) * 15;
                    ctx.lineTo(x, hillY);
                }
                ctx.lineTo(CANVAS_WIDTH, CANVAS_HEIGHT);
                ctx.closePath();
                ctx.fill();
            } else if (layer.shape === 'clouds') {
                ctx.globalAlpha = 0.4;
                var cloudBase = -((scrollOffset * 0.3) % 400);
                for (var ci = 0; ci < 8; ci++) {
                    var cx = cloudBase + ci * 200 + (ci * 73 % 80);
                    ctx.beginPath();
                    ctx.ellipse(cx, 80 + (ci % 3) * 30, 60, 25, 0, 0, Math.PI * 2);
                    ctx.fill();
                }
                ctx.globalAlpha = 1;
            }
        }
    }
}

function renderTileMap() {
    if (!level || !level.tiles) return;
    var startCol = Math.floor(camera.x / TILE_SIZE) - 1;
    var endCol = Math.floor((camera.x + CANVAS_WIDTH) / TILE_SIZE) + 1;
    var startRow = Math.floor(camera.y / TILE_SIZE) - 1;
    var endRow = Math.floor((camera.y + CANVAS_HEIGHT) / TILE_SIZE) + 1;
    startCol = Math.max(0, startCol);
    endCol = Math.min(level.width - 1, endCol);
    startRow = Math.max(0, startRow);
    endRow = Math.min(level.height - 1, endRow);
    for (var row = startRow; row <= endRow; row++) {
        for (var col = startCol; col <= endCol; col++) {
            var tileType = level.tiles[row][col];
            if (tileType === TILE.AIR) continue;
            var worldX = col * TILE_SIZE;
            var worldY = row * TILE_SIZE;
            var sx = worldX - camera.x;
            var sy = worldY - camera.y;
            if (typeof drawTile === 'function') {
                drawTile(ctx, tileType, col, row, sx, sy);
            } else {
                renderTileFallback(ctx, tileType, sx, sy);
            }
        }
    }
}

function renderTileFallback(ctx, type, sx, sy) {
    if (type === TILE.DIRT) {
        ctx.fillStyle = '#8B5E3C';
        ctx.fillRect(sx, sy, TILE_SIZE, TILE_SIZE);
    } else if (type === TILE.STONE) {
        ctx.fillStyle = '#808080';
        ctx.fillRect(sx, sy, TILE_SIZE, TILE_SIZE);
    } else if (type === TILE.CLOUD) {
        ctx.fillStyle = '#F5F5FF';
        ctx.fillRect(sx, sy, TILE_SIZE, TILE_SIZE);
    } else if (type === TILE.BRICK) {
        ctx.fillStyle = '#8B0000';
        ctx.fillRect(sx, sy, TILE_SIZE, TILE_SIZE);
    } else if (type === TILE.PLATFORM) {
        ctx.fillStyle = '#8B5E3C';
        ctx.fillRect(sx, sy + TILE_SIZE - 8, TILE_SIZE, 8);
    } else if (type === TILE.SPIKE) {
        ctx.fillStyle = '#FF0000';
        ctx.beginPath();
        ctx.moveTo(sx, sy + TILE_SIZE);
        ctx.lineTo(sx + TILE_SIZE / 2, sy);
        ctx.lineTo(sx + TILE_SIZE, sy + TILE_SIZE);
        ctx.closePath();
        ctx.fill();
    } else if (type === TILE.CHECKPOINT_FLAG) {
        ctx.fillStyle = '#8B5E3C';
        ctx.fillRect(sx + 4, sy + 4, 3, 24);
        ctx.fillStyle = '#33CC33';
        ctx.fillRect(sx + 7, sy + 6, 16, 10);
    } else if (type === TILE.EXIT_FLAG) {
        ctx.fillStyle = '#8B5E3C';
        ctx.fillRect(sx + 4, sy + 4, 3, 24);
        ctx.fillStyle = '#FFD700';
        ctx.fillRect(sx + 7, sy + 6, 20, 14);
    } else if (type === TILE.PIT) {
        ctx.fillStyle = '#111111';
        ctx.fillRect(sx, sy, TILE_SIZE, TILE_SIZE);
    } else if (type === TILE.DECO_GRASS) {
        ctx.fillStyle = '#32CD32';
        for (var i = 0; i < 3; i++) {
            ctx.fillRect(sx + 6 + i * 10, sy + TILE_SIZE - 10, 2, 6 + Math.sin(i * 2) * 4);
        }
    }
}

function renderPlayer(ctx) {
    if (!player || !player.alive) return;
    var sx = player.x - camera.x;
    var sy = player.y - camera.y;
    var flashOn = player.invincibleTimer > 0 && Math.floor(player.invincibleTimer / 4) % 2 === 0;
    if (flashOn) {
        ctx.globalAlpha = 0.5;
    }
    if (typeof drawPlayerSprite === 'function') {
        drawPlayerSprite(ctx, sx, sy, player.width, player.height, player.facing, player.animFrame, player.state, player.powerups.invincible, flashOn);
    } else {
        drawPlayerFallback(ctx, sx, sy);
    }
    ctx.globalAlpha = 1;
    if (player.powerups.speed) {
        ctx.fillStyle = 'rgba(68, 68, 255, 0.3)';
        ctx.beginPath();
        ctx.arc(sx + player.width / 2, sy + player.height / 2, 20, 0, Math.PI * 2);
        ctx.fill();
    }
    if (player.powerups.invincible) {
        ctx.strokeStyle = 'rgba(255, 255, 0, 0.6)';
        ctx.lineWidth = 2;
        ctx.strokeRect(sx - 2, sy - 2, player.width + 4, player.height + 4);
        ctx.lineWidth = 1;
    }
}

function drawPlayerFallback(ctx, sx, sy) {
    ctx.fillStyle = '#3366FF';
    ctx.fillRect(sx, sy, player.width, player.height);
    ctx.fillStyle = '#FF3333';
    ctx.fillRect(sx, sy, player.width, 6);
    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(sx + 4, sy + 10, 6, 6);
    ctx.fillRect(sx + 18, sy + 10, 6, 6);
    ctx.fillStyle = '#000000';
    ctx.fillRect(sx + player.facing > 0 ? 6 : 20, sy + 12, 2, 2);
}

function renderEnemies(ctx) {
    for (var i = 0; i < enemies.length; i++) {
        var enemy = enemies[i];
        if (!enemy.alive) continue;
        if (!enemyInView(enemy)) continue;
        var sx = enemy.x - camera.x;
        var sy = enemy.y - camera.y;
        if (enemy.type === "slime" && typeof drawSlimeSprite === 'function') {
            drawSlimeSprite(ctx, sx, sy, enemy.width, enemy.height, enemy.animFrame);
        } else if (enemy.type === "bat" && typeof drawBatSprite === 'function') {
            drawBatSprite(ctx, sx, sy, enemy.width, enemy.height, enemy.animFrame);
        } else if (enemy.type === "skeleton" && typeof drawSkeletonSprite === 'function') {
            drawSkeletonSprite(ctx, sx, sy, enemy.width, enemy.height, enemy.animFrame);
        } else if (enemy.type === "ghost" && typeof drawGhostSprite === 'function') {
            var opacity = enemy.type === "ghost" ? (0.5 + Math.sin(globalFrame * 0.05) * 0.2) : 1;
            drawGhostSprite(ctx, sx, sy, enemy.width, enemy.height, enemy.animFrame, opacity);
        } else {
            drawEnemyFallback(ctx, enemy, sx, sy);
        }
    }
}

function drawEnemyFallback(ctx, enemy, sx, sy) {
    if (enemy.type === "slime") {
        ctx.fillStyle = '#44CC44';
        ctx.beginPath();
        ctx.ellipse(sx + enemy.width / 2, sy + enemy.height / 2, enemy.width / 2, enemy.height / 2, 0, 0, Math.PI * 2);
        ctx.fill();
    } else if (enemy.type === "bat") {
        ctx.fillStyle = '#8844CC';
        ctx.fillRect(sx + 4, sy + 4, enemy.width - 8, enemy.height - 8);
    } else if (enemy.type === "skeleton") {
        ctx.fillStyle = '#CCCCCC';
        ctx.fillRect(sx + 4, sy, enemy.width - 8, enemy.height);
    } else if (enemy.type === "ghost") {
        ctx.fillStyle = 'rgba(200, 200, 255, 0.6)';
        ctx.fillRect(sx, sy, enemy.width, enemy.height);
    }
}

function renderBoss(ctx) {
    if (!boss || !boss.alive) return;
    var sx = boss.x - camera.x;
    var sy = boss.y - camera.y;
    var flashOn = boss.invincibleTimer > 0 && Math.floor(boss.invincibleTimer / 3) % 2 === 0;
    if (typeof drawBossSprite === 'function') {
        drawBossSprite(ctx, sx, sy, boss.width, boss.height, boss.phase, boss.animFrame, flashOn);
    } else {
        drawBossFallback(ctx, sx, sy);
    }
    if (boss.hp > 0) {
        var barW = boss.width;
        var barH = 6;
        var barX = sx;
        var barY = sy - 12;
        ctx.fillStyle = '#333333';
        ctx.fillRect(barX, barY, barW, barH);
        var hpRatio = boss.hp / boss.maxHp;
        var hpColor = hpRatio > 0.5 ? '#33CC33' : (hpRatio > 0.25 ? '#CCCC33' : '#CC3333');
        ctx.fillStyle = hpColor;
        ctx.fillRect(barX + 1, barY + 1, (barW - 2) * hpRatio, barH - 2);
    }
}

function drawBossFallback(ctx, sx, sy) {
    ctx.fillStyle = boss.invincibleTimer > 0 ? '#FF8888' : '#FF4444';
    ctx.fillRect(sx + 4, sy + 8, boss.width - 8, boss.height - 16);
    ctx.fillRect(sx, sy + 8, boss.width, 16);
    ctx.fillRect(sx + 2, sy, 12, 12);
    ctx.fillRect(sx + boss.width - 14, sy, 12, 12);
    ctx.fillStyle = boss.phase >= 2 ? '#FFFF00' : '#000000';
    ctx.fillRect(sx + 16, sy + 16, 10, 10);
    ctx.fillRect(sx + boss.width - 26, sy + 16, 10, 10);
    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(sx + 20, sy + 40, boss.width - 40, 6);
}

function renderCollectibles(ctx) {
    for (var i = 0; i < coins.length; i++) {
        var c = coins[i];
        if (!c.alive) continue;
        var sx = c.x - camera.x;
        var sy = c.y - camera.y;
        if (typeof drawCoinSprite === 'function') {
            drawCoinSprite(ctx, sx, sy, c.width, c.animFrame);
        } else {
            drawCoinFallback(ctx, sx, sy, c);
        }
    }
    for (var j = 0; j < powerupItems.length; j++) {
        var p = powerupItems[j];
        if (!p.alive) continue;
        var psx = p.x - camera.x;
        var psy = p.y - camera.y;
        if (typeof drawPowerupSprite === 'function') {
            drawPowerupSprite(ctx, psx, psy, p.width, p.type, p.animFrame);
        } else {
            drawPowerupFallback(ctx, psx, psy, p);
        }
    }
}

function drawCoinFallback(ctx, sx, sy, c) {
    var scale = Math.abs(Math.cos(c.animFrame * Math.PI / 2));
    var halfW = c.width / 2 * scale;
    ctx.fillStyle = '#FFD700';
    ctx.beginPath();
    ctx.ellipse(sx + c.width / 2, sy + c.height / 2, halfW, c.height / 2, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = '#DAA520';
    ctx.lineWidth = 1;
    ctx.stroke();
}

function drawPowerupFallback(ctx, sx, sy, p) {
    if (p.type === "speed") {
        ctx.fillStyle = '#4488FF';
        ctx.fillRect(sx + 4, sy, 16, 24);
        ctx.fillStyle = '#FFFF00';
        ctx.beginPath();
        ctx.moveTo(sx + 12, sy + 2);
        ctx.lineTo(sx + 2, sy + 12);
        ctx.lineTo(sx + 12, sy + 10);
        ctx.lineTo(sx + 22, sy + 12);
        ctx.closePath();
        ctx.fill();
    } else if (p.type === "invincible") {
        ctx.fillStyle = '#FF44FF';
        drawStar(ctx, sx + 12, sy + 12, 5, 12, 5);
    } else if (p.type === "doubleJump") {
        ctx.fillStyle = '#FFFFFF';
        ctx.beginPath();
        ctx.ellipse(sx + 12, sy + 12, 10, 6, -0.3, 0, Math.PI * 2);
        ctx.fill();
    } else if (p.type === "extraLife") {
        ctx.fillStyle = '#FF3333';
        drawHeart(ctx, sx + 12, sy + 14, 10);
        ctx.fillStyle = '#FFFFFF';
        ctx.font = '8px monospace';
        ctx.textAlign = 'center';
        ctx.fillText('+1', sx + 12, sy + 16);
    }
}

function drawStar(ctx, cx, cy, spikes, outerR, innerR) {
    var step = Math.PI / spikes;
    ctx.beginPath();
    var rot = -Math.PI / 2;
    for (var i = 0; i < spikes * 2; i++) {
        var r = i % 2 === 0 ? outerR : innerR;
        var angle = rot + i * step;
        ctx.lineTo(cx + Math.cos(angle) * r, cy + Math.sin(angle) * r);
    }
    ctx.closePath();
    ctx.fill();
}

function drawHeart(ctx, x, y, size) {
    ctx.beginPath();
    ctx.moveTo(x, y + size / 3);
    ctx.bezierCurveTo(x, y - size / 2, x - size, y - size / 2, x - size, y + size / 3);
    ctx.bezierCurveTo(x - size, y + size, x, y + size, x, y + size);
    ctx.bezierCurveTo(x, y + size, x + size, y + size, x + size, y + size / 3);
    ctx.bezierCurveTo(x + size, y - size / 2, x, y - size / 2, x, y + size / 3);
    ctx.fill();
}

function renderProjectiles(ctx) {
    for (var i = 0; i < projectiles.length; i++) {
        var p = projectiles[i];
        if (!p.alive) continue;
        var sx = p.x - camera.x;
        var sy = p.y - camera.y;
        if (p.type === 'fireball') {
            ctx.fillStyle = p.color;
            ctx.beginPath();
            ctx.arc(sx + p.width / 2, sy + p.height / 2, p.width / 2, 0, Math.PI * 2);
            ctx.fill();
            ctx.fillStyle = '#FFFF00';
            ctx.beginPath();
            ctx.arc(sx + p.width / 2, sy + p.height / 2, p.width / 4, 0, Math.PI * 2);
            ctx.fill();
        } else if (p.type === 'bone') {
            ctx.fillStyle = p.color;
            ctx.fillRect(sx, sy, p.width, p.height);
            ctx.strokeStyle = '#999999';
            ctx.lineWidth = 1;
            ctx.strokeRect(sx, sy, p.width, p.height);
        }
    }
}

function renderHUD(ctx) {
    ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
    ctx.fillRect(0, 0, CANVAS_WIDTH, 40);
    ctx.font = '16px monospace';
    ctx.fillStyle = '#FFFFFF';
    ctx.textAlign = 'left';
    ctx.fillText('SCORE: ' + String(player.score).padStart(7, '0'), 10, 28);
    ctx.fillText('\u2299 ' + player.coins, 220, 28);
    ctx.textAlign = 'center';
    ctx.font = '18px monospace';
    if (levels && levels[currentLevel]) {
        ctx.fillText(levels[currentLevel].name.toUpperCase(), CANVAS_WIDTH / 2, 28);
    }
    ctx.textAlign = 'right';
    ctx.font = '20px monospace';
    var livesStr = '';
    for (var i = 0; i < MAX_LIVES; i++) {
        livesStr += i < player.lives ? '\u2665 ' : '\u2661 ';
    }
    ctx.fillText(livesStr.trim(), CANVAS_WIDTH - 10, 28);
    ctx.textAlign = 'left';
    var puX = 10;
    var puY = 54;
    if (player.powerups.speed) {
        ctx.fillStyle = '#4488FF';
        ctx.font = '13px monospace';
        ctx.fillText('SPEED ' + Math.ceil(player.powerupTimers.speed / 60) + 's', puX, puY);
        puX += 110;
    }
    if (player.powerups.invincible) {
        ctx.fillStyle = '#FF44FF';
        ctx.font = '13px monospace';
        ctx.fillText('INVINCIBLE ' + Math.ceil(player.powerupTimers.invincible / 60) + 's', puX, puY);
        puX += 130;
    }
    if (player.powerups.doubleJump) {
        ctx.fillStyle = '#FFFFFF';
        ctx.font = '13px monospace';
        ctx.fillText('DBL JUMP', puX, puY);
    }
    ctx.textAlign = 'left';
}

function renderTouchControls(ctx) {
    if (!isMobile) return;
    ctx.globalAlpha = 0.2;
    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(10, CANVAS_HEIGHT - 80, 64, 64);
    ctx.fillRect(84, CANVAS_HEIGHT - 80, 64, 64);
    ctx.fillStyle = '#333333';
    ctx.font = '24px monospace';
    ctx.fillText('\u25C0', 30, CANVAS_HEIGHT - 40);
    ctx.fillText('\u25B6', 104, CANVAS_HEIGHT - 40);
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(CANVAS_WIDTH - 42, CANVAS_HEIGHT - 42, 36, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = '#333333';
    ctx.font = '18px monospace';
    ctx.textAlign = 'center';
    ctx.fillText('JUMP', CANVAS_WIDTH - 42, CANVAS_HEIGHT - 36);
    ctx.globalAlpha = 1;
    ctx.textAlign = 'left';
}

// ========== SECTION 16: UI SCREENS ==========

var titleBlinkTimer = 0;
var titleAnimBalls = [];
for (var bi = 0; bi < 12; bi++) {
    titleAnimBalls.push({
        x: Math.random() * CANVAS_WIDTH,
        y: Math.random() * CANVAS_HEIGHT,
        vx: (Math.random() - 0.5) * 2,
        vy: (Math.random() - 0.5) * 2,
        size: 4 + Math.random() * 20,
        color: ['#3366FF', '#FF3333', '#33CC33', '#FFD700', '#8844CC'][Math.floor(Math.random() * 5)]
    });
}

function renderTitleScreen(ctx) {
    clearCanvas();
    for (var i = 0; i < titleAnimBalls.length; i++) {
        var b = titleAnimBalls[i];
        b.x += b.vx;
        b.y += b.vy;
        if (b.x < 0) b.x = CANVAS_WIDTH;
        if (b.x > CANVAS_WIDTH) b.x = 0;
        if (b.y < 0) b.y = CANVAS_HEIGHT;
        if (b.y > CANVAS_HEIGHT) b.y = 0;
        ctx.globalAlpha = 0.15;
        ctx.fillStyle = b.color;
        ctx.beginPath();
        ctx.arc(b.x, b.y, b.size, 0, Math.PI * 2);
        ctx.fill();
        ctx.globalAlpha = 1;
    }
    ctx.fillStyle = '#FFFFFF';
    ctx.textAlign = 'center';
    ctx.font = 'bold 48px monospace';
    ctx.strokeStyle = '#333333';
    ctx.lineWidth = 4;
    ctx.strokeText('PIXEL QUEST', CANVAS_WIDTH / 2, 140);
    ctx.fillText('PIXEL QUEST', CANVAS_WIDTH / 2, 140);
    ctx.font = '18px monospace';
    ctx.fillStyle = '#CCCCCC';
    ctx.fillText('A 4-Level Adventure', CANVAS_WIDTH / 2, 185);
    ctx.fillStyle = '#FFD700';
    ctx.font = '16px monospace';
    titleBlinkTimer++;
    if (Math.floor(titleBlinkTimer / 40) % 2 === 0) {
        ctx.fillText('Press ENTER or SPACE to Start', CANVAS_WIDTH / 2, 270);
    }
    ctx.fillStyle = '#AAAAAA';
    ctx.font = '14px monospace';
    ctx.fillText('Best Score: ' + String(bestScore).padStart(7, '0'), CANVAS_WIDTH / 2, 310);
    ctx.fillText('\u2190 \u2192 or A D to move  |  SPACE to jump', CANVAS_WIDTH / 2, 360);
    ctx.fillText('P to pause  |  R to restart', CANVAS_WIDTH / 2, 385);
}

function renderPauseScreen(ctx) {
    ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
    ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    ctx.fillStyle = '#FFFFFF';
    ctx.textAlign = 'center';
    ctx.font = 'bold 48px monospace';
    ctx.fillText('PAUSED', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 - 40);
    ctx.font = '18px monospace';
    ctx.fillStyle = '#CCCCCC';
    ctx.fillText('Press P to Resume', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 20);
    ctx.fillText('Press R to Restart', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 50);
}

function renderLevelCompleteScreen(ctx) {
    ctx.fillStyle = 'rgba(0, 0, 0, 0.85)';
    ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    ctx.fillStyle = '#FFD700';
    ctx.textAlign = 'center';
    ctx.font = 'bold 36px monospace';
    var levelName = levels && levels[currentLevel] ? levels[currentLevel].name.toUpperCase() : 'LEVEL';
    ctx.fillText(levelName + ' COMPLETE!', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 - 70);
    var bonus = player.lives * 100 + player.coins * 10;
    ctx.font = '20px monospace';
    ctx.fillText('Level Bonus: +' + bonus, CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 - 20);
    ctx.fillStyle = '#FFFFFF';
    ctx.fillText('Total Score: ' + String(player.score + bonus).padStart(7, '0'), CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 15);
    ctx.fillStyle = '#CCCCCC';
    ctx.font = '16px monospace';
    var blinkOn = Math.floor(globalFrame / 40) % 2 === 0;
    if (blinkOn) {
        ctx.fillText('Press ENTER or SPACE to continue', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 60);
    }
}

function renderGameOverScreen(ctx) {
    ctx.fillStyle = 'rgba(30, 0, 0, 0.9)';
    ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    ctx.textAlign = 'center';
    ctx.font = 'bold 56px monospace';
    ctx.fillStyle = '#FF3333';
    ctx.fillText('GAME OVER', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 - 50);
    ctx.font = '20px monospace';
    ctx.fillStyle = '#FFFFFF';
    ctx.fillText('Final Score: ' + String(player.score).padStart(7, '0'), CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 5);
    ctx.fillText('Best Score: ' + String(bestScore).padStart(7, '0'), CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 35);
    ctx.fillStyle = '#CCCCCC';
    ctx.font = '16px monospace';
    if (Math.floor(globalFrame / 40) % 2 === 0) {
        ctx.fillText('Press ENTER or SPACE to try again', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 80);
    }
}

function renderVictoryScreen(ctx) {
    ctx.fillStyle = 'rgba(0, 0, 20, 0.85)';
    ctx.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
    ctx.textAlign = 'center';
    ctx.font = 'bold 42px monospace';
    ctx.fillStyle = '#FFD700';
    ctx.fillText('\u2605  CONGRATULATIONS  \u2605', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 - 70);
    ctx.font = '22px monospace';
    ctx.fillText('You defeated the Demon!', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 - 30);
    ctx.font = '20px monospace';
    ctx.fillStyle = '#FFFFFF';
    ctx.fillText('Final Score: ' + String(player.score).padStart(7, '0'), CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 15);
    ctx.fillText('Best Score: ' + String(bestScore).padStart(7, '0'), CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 45);
    ctx.fillStyle = '#CCCCCC';
    ctx.font = '16px monospace';
    if (Math.floor(globalFrame / 40) % 2 === 0) {
        ctx.fillText('Press ENTER or SPACE to play again', CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 90);
    }
    if (globalFrame % 10 === 0) {
        spawnConfettiParticles(3);
    }
    if (typeof saveBestScore === 'function') saveBestScore(player.score);
    else if (player.score > bestScore) { bestScore = player.score; }
}

function drawTextBox(ctx, x, y, w, h, text, fontSize, color) {
    ctx.fillStyle = 'rgba(0, 0, 0, 0.8)';
    ctx.fillRect(x, y, w, h);
    ctx.strokeStyle = color || '#FFFFFF';
    ctx.lineWidth = 2;
    ctx.strokeRect(x, y, w, h);
    ctx.fillStyle = color || '#FFFFFF';
    ctx.font = (fontSize || 16) + 'px monospace';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(text, x + w / 2, y + h / 2);
    ctx.textBaseline = 'alphabetic';
}

// ========== SECTION 17: LEVEL TRANSITIONS ==========

function loadLevel(levelIndex) {
    currentLevel = levelIndex;
    level = levels[levelIndex];
    transitionCooldown = 30;
    player.x = level.playerSpawn.col * TILE_SIZE;
    player.y = level.playerSpawn.row * TILE_SIZE - player.height;
    player.vx = 0;
    player.vy = 0;
    player.alive = true;
    player.state = "idle";
    player.onGround = false;
    player.facing = 1;
    player.animFrame = 0;
    player.animTimer = 0;
    player.canDoubleJump = false;
    player.hasDoubleJumped = false;
    player.deathTimer = 0;
    player.invincibleTimer = 30;
    player.powerups.speed = false;
    player.powerups.invincible = false;
    player.powerups.doubleJump = false;
    player.powerupTimers.speed = 0;
    player.powerupTimers.invincible = 0;
    player.speed = PLAYER_SPEED;
    player.lastCheckpoint = null;
    activatedCheckpoints = new Set();
    enemies = [];
    coins = [];
    powerupItems = [];
    projectiles = [];
    particles = [];
    initEnemies();
    initCollectibles();
    initBoss();
    camera.x = player.x - CANVAS_WIDTH / 2;
    camera.y = player.y - CANVAS_HEIGHT / 2;
    if (typeof snapCamera === 'function') snapCamera();
    else updateCamera(0);
    if (currentLevel === 3 && boss) {
        if (typeof startBossMusic === 'function') startBossMusic();
    } else {
        if (typeof stopBossMusic === 'function') stopBossMusic();
    }
    gameState = STATE.PLAYING;
}

function nextLevel() {
    if (currentLevel < 3) {
        var bonus = player.lives * 100 + player.coins * 10;
        player.score += bonus;
        loadLevel(currentLevel + 1);
    }
}

function handleDeathSequence(dt) {
    if (!player.alive && player.deathTimer > 0) {
        player.vy += GRAVITY * (dt / 16.667);
        player.y += player.vy * (dt / 16.667);
        player.deathTimer -= dt / 16.667;
        if (player.deathTimer <= 0) {
            player.deathTimer = 0;
            if (player.lives > 0) {
                respawnPlayer();
            } else {
                gameState = STATE.GAME_OVER;
                if (typeof playSound === 'function') playSound('gameOver');
                if (typeof saveBestScore === 'function') saveBestScore(player.score);
                else if (player.score > bestScore) { bestScore = player.score; }
            }
        }
    }
}

function activateCheckpoint(col, row) {
    var key = col + ',' + row;
    if (activatedCheckpoints.has(key)) return;
    activatedCheckpoints.add(key);
    player.lastCheckpoint = { col: col, row: row };
    if (typeof playSound === 'function') playSound('powerup');
    spawnParticles(col * TILE_SIZE + TILE_SIZE / 2, row * TILE_SIZE + TILE_SIZE / 2, 10, '#33CC33');
}
