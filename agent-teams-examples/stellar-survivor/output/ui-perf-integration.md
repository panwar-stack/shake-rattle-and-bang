# UI ↔ Perf System Integration Notes
## How the UI layer uses window.PERF capabilities

================================================================================
1. STARFIELD (Menu Backgrounds)
================================================================================

The PERF system provides a pre-cached, zero-alloc starfield:
  const starfield = new PERF.StarfieldBackground(800, 600, 150);

REPLACE my custom initStarfield() / updateStarfield() / drawStarfield() with:

  // In game init:
  uiState.perfStarfield = new PERF.StarfieldBackground(800, 600, 150);

  // Each frame (in menu screens):
  uiState.perfStarfield.update(dt_ms * 0.001);  // PERF uses seconds... verify
  uiState.perfStarfield.draw(ctx, 0.5);          // opacity parameter if available

If StarfieldBackground doesn't accept an opacity param, wrap in:
  ctx.save();
  ctx.globalAlpha = 0.5;
  uiState.perfStarfield.draw(ctx);
  ctx.restore();

NOTE: The PERF starfield scrolls vertically (default behavior). This matches
my spec's starfield direction (stars move downward). The 150 parameter is the
star count — matches my spec's 200 stars closely enough.


================================================================================
2. KEYBOARD INPUT (Menu Navigation)
================================================================================

PERF provides debounced key-press detection — critical for menu navigation
to avoid key-repeat issues:

  // Instead of raw keydown handler, use:
  if (PERF.keyJustPressed(38) || PERF.keyJustPressed(87)) // Up / W
    navigateUp();
  if (PERF.keyJustPressed(40) || PERF.keyJustPressed(83)) // Down / S
    navigateDown();
  if (PERF.keyJustPressed(13))  // Enter
    selectCurrentOption();
  if (PERF.keyJustPressed(27) || PERF.keyJustPressed(80)) // Esc / P
    togglePause();

CODE MAP (from perf-integration-spec.md):
  Up Arrow    = code 38
  Down Arrow  = code 40
  Left Arrow  = code 37
  Right Arrow = code 39
  W = 87, A = 65, S = 83, D = 68
  Space = 32
  Enter = 13
  Escape = 27
  P = 80
  M = 77

For in-game movement (held keys, not debounced):
  if (PERF.isKeyDown(37) || PERF.isKeyDown(65)) dx = -1; // Left/A
  if (PERF.isKeyDown(39) || PERF.isKeyDown(68)) dx = 1;  // Right/D
  if (PERF.isKeyDown(38) || PERF.isKeyDown(87)) dy = -1; // Up/W
  if (PERF.isKeyDown(40) || PERF.isKeyDown(83)) dy = 1;  // Down/S

Fire (held):
  if (PERF.isKeyDown(32) && player.fireTimer <= 0) { ... }

IMPORTANT: The UI input handling in ui-spec.md Section 12 uses raw key names
("ArrowUp", "W", etc.). When integrating with PERF, use the keycode-based
PERF.keyJustPressed() / PERF.isKeyDown() instead. DO NOT add a separate
keydown listener — PERF.init() already registers the listeners.


================================================================================
3. TOUCH INPUT (Mobile Controls)
================================================================================

PERF provides:
  PERF.touchActive  — boolean, true when screen is touched
  PERF.touchX       — latest touch X coordinate
  PERF.touchY       — latest touch Y coordinate

LIMITATION: These are single-touch only (track the first/recent touch only).

My mobile control spec (Section 3) requires MULTI-TOUCH support for:
  - Virtual joystick (left thumb)
  - Fire button (right thumb)
  Simultaneously.

RESOLUTION: The UI layer should add its own touch event listeners on the canvas
for multi-touch support, AS WELL AS using PERF.touchActive/touchX/touchY for
single-touch convenience. Register via:

  canvas.addEventListener('touchstart', handleTouchStart, {passive: false});
  canvas.addEventListener('touchmove', handleTouchMove, {passive: false});
  canvas.addEventListener('touchend', handleTouchEnd);
  canvas.addEventListener('touchcancel', handleTouchEnd);

The {passive: false} is REQUIRED because we need preventDefault() to stop
scrolling/zooming during gameplay touch.

PERF.init() also registers touch listeners. Verify there's no conflict.
If PERF.init() uses passive: true, no conflict — both work. If PERF uses
preventDefault(), coordinate on which layer handles it.

FALLBACK: If multi-touch is too complex, use single-touch auto-fire mode:
  - Touch anywhere left half of screen → move ship toward touch point
  - Touch anywhere on screen → auto-fire enabled
  This is simpler and works well on mobile (many arcade shooters do this).


================================================================================
4. CELEBRATION / DEATH PARTICLES
================================================================================

My spec includes particle effects for:
  - Victory screen (gold/cyan sparkle celebration)
  - Game over screen (red drifting particles, optional)

Use PERF's particle pool for these:

  // During game init:
  uiParticlePool = new PERF.Pool(PERF.createParticle, PERF.CONFIG.PARTICLE_POOL_SIZE);

  // For victory celebration:
  for (i = 0; i < 50; i++) {
    const p = uiParticlePool.get();
    if (!p) break;
    p.x = Math.random() * 800;
    p.y = 600 + Math.random() * 100;
    p.vx = (Math.random() - 0.5) * 2;
    p.vy = -Math.random() * 4 - 1;
    p.life = 2 + Math.random() * 3;
    p.color = colors[Math.floor(Math.random() * colors.length)];
    p.size = 1 + Math.random() * 3;
  }

  // In render:
  uiParticlePool.forEachActive(p => {
    ctx.fillStyle = p.color;
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.size, 0, Math.PI*2);
    ctx.fill();
  });

NOTE: Verify that PERF.createParticle creates objects with properties:
  { x, y, vx, vy, life, active, color, size }
If the default factory doesn't include color/size, you may need to extend
or use a custom pool. For now, assume the existing pool works and we add
custom properties at spawn time (JS allows this even on created objects).


================================================================================
5. UI RENDER PERFORMANCE RULES
================================================================================

Following PERF rules for the UI rendering path:

  1. NO allocations in renderUI() — all text format strings are static
  2. Avoid ctx.save()/ctx.restore() in HUD hot path (use manual state reset)
  3. Use ctx.globalAlpha changes sparingly (group all alpha-draws)
  4. ctx.textAlign changes: batch all "center" draws, then all "left", then all "right"
  5. Glow text (shadowBlur): PERF.BatchedRenderContext should group these
     → All menu glow titles drawn together, then all non-glow text
  6. Rounded rects: cache the path if used repeatedly at same position

For menu screens (not hot path, 0-60fps matters less):
  - Minor allocations for menu text arrays is acceptable
  - ctx.save()/ctx.restore() is acceptable in menu rendering
  - Starfield is pre-cached by PERF, so menu BG is cheap

For in-game HUD (hot path, every frame):
  - Health bar: gradient recreation each frame is acceptable (small cost)
  - Score text: string formatting with toLocaleString() — could be cached
  - Warning arrows: array iteration is fine (max ~10 off-screen enemies)


================================================================================
6. INITIALIZATION INTEGRATION
================================================================================

Single-file integration order:

  <!-- 1. Performance system -->
  <script src="perf-system.js"></script>

  <!-- 2. UI system (this spec's implementation) -->
  <script src="ui-system.js"></script>

  <!-- 3. Game systems -->
  <script src="game.js"></script>

  In main init:
    PERF.init();                         // keyboard + touch listeners
    uiInit();                            // sets up starfield, menu state
    ... game init, pools, grid ...
    PERF.gameLoop.simple(timestamp, update, render);


================================================================================
7. OPEN QUESTIONS FOR LEAD / TEAM
================================================================================

  Q1: Does PERF.StarfieldBackground support opacity parameter in draw()?
      If not, we wrap with ctx.globalAlpha.

  Q2: Should the UI use PERF.BatchedRenderContext for glow text batching?
      If yes, the rendering engineer should handle batcher coordination.

  Q3: Multi-touch vs single-touch for mobile — which approach?
      Recommend: single-touch auto-fire with touch-to-move for MVP.
      Multi-touch joystick + fire button can be added later.

  Q4: What font loading strategy? (Google Fonts link vs base64 vs fallback)
      Recommend: Orbitron via Google Fonts with Courier New fallback.
