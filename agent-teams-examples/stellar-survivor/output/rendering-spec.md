

### 4.2.1 Enemy Render Dispatch + Special Entities

```js
function renderEnemy(ctx, enemy, time) {
  switch (enemy.type) {
    case 'drone':     renderEnemy_Drone(ctx, enemy, time); break;
    case 'weaver':    renderEnemy_Weaver(ctx, enemy, time); break;
    case 'tank':      renderEnemy_Tank(ctx, enemy, time); break;
    case 'sniper':    renderEnemy_Sniper(ctx, enemy, time); break;
    case 'splitter':  renderEnemy_Splitter(ctx, enemy, time); break;
    case 'mineLayer': renderEnemy_MineLayer(ctx, enemy, time); break;
    case 'shielder':  renderEnemy_Shielder(ctx, enemy, time); break;
    case 'splitterFragment': renderSplitterFragment(ctx, enemy, time); break;
    case 'mine':      renderMine(ctx, enemy, time); break;
    case 'homingMissile': renderHomingMissile(ctx, enemy, time); break;
  }
}

// --- Splitter Fragment (on death, 3 fragments size 10×10, HP 1, #FFAA00) ---
function renderSplitterFragment(ctx, fragment, time) {
  ctx.save();
  ctx.translate(fragment.x, fragment.y);
  ctx.rotate(time * 10);

  ctx.beginPath();
  ctx.arc(0, 0, 5, 0, Math.PI * 2);
  ctx.fillStyle = '#FFAA00';
  ctx.fill();
  ctx.strokeStyle = '#FFDD44';
  ctx.lineWidth = 1;
  ctx.stroke();

  ctx.restore();
}

// --- Mine (dropped by Mine Layer, 14×14, HP 2, #44DD44, timed fuse 8s) ---
function renderMine(ctx, mine, time) {
  ctx.save();
  ctx.translate(mine.x, mine.y);

  // Flash white rapidly in last 1.5s before detonation (10Hz warning)
  const isWarning = mine.fuseTimer > 0 && mine.fuseTimer <= 1.5;
  const warningFlash = isWarning && Math.sin(time * 20 * Math.PI) > 0;

  // Outer pulse
  const pulse = 1 + Math.sin(time * 4) * 0.1;
  ctx.beginPath();
  ctx.arc(0, 0, 8 * pulse, 0, Math.PI * 2);
  ctx.fillStyle = warningFlash ? '#FFFFFF' : '#44DD44';
  ctx.fill();
  ctx.strokeStyle = warningFlash ? '#FFFFFF' : '#88FF88';
  ctx.lineWidth = 1.5;
  ctx.setLineDash(warningFlash ? [2, 1] : []);
  ctx.stroke();
  ctx.setLineDash([]);

  // Center dot
  ctx.beginPath();
  ctx.arc(0, 0, 2, 0, Math.PI * 2);
  ctx.fillStyle = '#88FF88';
  ctx.fill();

  ctx.restore();
}

// --- Homing Missile (boss missiles, 14×8, #CC2222, destructible) ---
function renderHomingMissile(ctx, missile, time) {
  ctx.save();
  ctx.translate(missile.x, missile.y);
  ctx.rotate(missile.angle);
  ctx.globalCompositeOperation = 'lighter';

  // Trail
  ctx.fillStyle = '#CC2222';
  ctx.fillRect(-3, 6, 6, 10);

  // Body
  const bodyGrad = ctx.createLinearGradient(0, -7, 0, 7);
  bodyGrad.addColorStop(0, '#FF4444');
  bodyGrad.addColorStop(0.5, '#CC2222');
  bodyGrad.addColorStop(1, '#660000');
  ctx.fillStyle = bodyGrad;
  ctx.fillRect(-4, -7, 8, 14);

  // Fins
  ctx.fillStyle = '#882222';
  ctx.fillRect(-7, 0, 3, 4);
  ctx.fillRect(4, 0, 3, 4);

  ctx.restore();
}
```