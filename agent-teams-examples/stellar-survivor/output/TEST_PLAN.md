# STELLAR SURVIVOR — QA Test Plan & Verification Checklist

**Document Version:** 1.0  
**Author:** QA Lead  
**Game:** Stellar Survivor (HTML5 Arcade Space Shooter)  

---

## Priority Legend

| Code | Meaning |
|------|---------|
| **P0** | Critical — must pass before release; game is broken if this fails |
| **P1** | High — severe user impact; must pass for playability |
| **P2** | Medium — noticeable issue; should be fixed |
| **P3** | Low — cosmetic or edge-case polish |

---

## 1. FUNCTIONAL TESTING

### 1.1 Game Initialization

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F01 | Open `index.html` in browser | Canvas element created with correct dimensions; no console errors | P0 |
| F02 | Game loop starts automatically | `requestAnimationFrame` fires; background renders (stars/parallax visible) | P0 |
| F03 | Asset loading completes | All sprites, audio files load; no missing-texture fallbacks or silent audio | P0 |
| F04 | Loading screen displays progress | Progress bar/text updates as assets load; transitions to main menu on completion | P1 |
| F05 | Canvas fails gracefully on unsupported browsers | Fallback message shown if `canvas` or `getContext('2d')` unavailable | P2 |

### 1.2 Main Menu

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F06 | Menu renders after load | Title "STELLAR SURVIVOR" visible; all menu buttons displayed | P0 |
| F07 | "START" button — click / Enter | Transitions to level 1 gameplay; player ship appears, enemies begin spawning | P0 |
| F08 | "HOW TO PLAY" button — click | Instructions overlay shown; lists controls, power-ups, objectives | P1 |
| F09 | "HOW TO PLAY" — dismiss | Escape or click-back dismisses overlay; returns to menu (no state corruption) | P1 |
| F10 | "HIGH SCORES" button — click | High score table displayed; loads from localStorage; sorted descending | P1 |
| F11 | "HIGH SCORES" — empty state | "No scores yet" message when localStorage is empty | P2 |
| F12 | Menu keyboard navigation | Arrow keys + Enter cycle and select menu items | P2 |
| F13 | Menu music plays on load | Background menu music audible; loops seamlessly | P1 |

### 1.3 Player Movement

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F14 | W key moves ship up | Ship translates upward at defined speed | P0 |
| F15 | A key moves ship left | Ship translates left at defined speed | P0 |
| F16 | S key moves ship down | Ship translates downward at defined speed | P0 |
| F17 | D key moves ship right | Ship translates right at defined speed | P0 |
| F18 | Arrow Up moves ship up | Same as W key (dual binding) | P0 |
| F19 | Arrow Left moves ship left | Same as A key | P0 |
| F20 | Arrow Down moves ship down | Same as S key | P0 |
| F21 | Arrow Right moves ship right | Same as D key | P0 |
| F22 | Diagonal movement (W+A, W+D, S+A, S+D) | Ship moves diagonally; speed normalized (no √2 faster) | P1 |
| F23 | Ship stops at left boundary | Ship.x clamped ≥ 0 (or half-ship-width from edge) | P0 |
| F24 | Ship stops at right boundary | Ship.x clamped ≤ canvas.width | P0 |
| F25 | Ship stops at top boundary | Ship.y clamped ≥ 0 | P0 |
| F26 | Ship stops at bottom boundary | Ship.y clamped ≤ canvas.height | P0 |
| F27 | Touch drag moves ship (mobile) | Touch-drag translates ship position; follows finger | P1 |
| F28 | Touch controls — dead zone | Small finger movements within dead zone don't jitter ship | P2 |

### 1.4 Shooting

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F29 | Space bar fires bullet | One bullet emitted per press (if within fire rate) | P0 |
| F30 | Mouse click fires bullet | Same as Space bar | P0 |
| F31 | Holding Space fires continuously | Bullets fire at defined fire-rate interval (e.g., every 200ms) | P0 |
| F32 | Fire rate is respected | Rapid tapping cannot exceed fire rate; no bullet burst exploit | P0 |
| F33 | Bullets travel upward (or toward cursor if aiming system) | Bullets move at defined speed in correct direction | P0 |
| F34 | Bullets removed when off-screen | Bullets beyond canvas bounds are recycled to pool | P1 |
| F35 | Bullet pool exhaustion | Firing continuously for 30 sec never produces missing/glitched bullets | P0 |
| F36 | Bullet visual and audio feedback | Bullet sprite renders; firing sound plays per bullet (or per burst) | P2 |

### 1.5 Enemy Spawning

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F37 | Wave 1 enemies appear | Correct enemy type and count per design spec | P0 |
| F38 | Enemies enter with animation | Enemies have entry/fly-in animation; not teleporting to position | P2 |
| F39 | Subsequent waves spawn after delay | Timer/counter for next wave; enemies don't all spawn at once | P0 |
| F40 | All enemy types appear across levels | Each enemy type (grunt, tank, sniper, etc.) spawns in appropriate waves | P1 |
| F41 | Enemy spawn positions are within game area | No enemies spawn off-screen or overlapping player | P0 |
| F42 | Spawn rejected when pool exhausted | Console/log message; game continues without crash; no invisible enemies | P1 |
| F43 | Boss appears at level end | Boss entry sequence plays; boss health bar appears | P0 |
| F44 | Minion spawns during boss fight | Boss periodically spawns smaller enemies | P2 |

### 1.6 Enemy AI

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F45 | Grunt type — moves straight down | Basic enemy descends vertically; fires occasionally | P0 |
| F46 | Tank type — moves slow, high HP | Slower movement; takes multiple hits to destroy | P0 |
| F47 | Sniper type — aims at player | Movement pattern tracks/leads player position | P1 |
| F48 | Evader type — dodges bullets | Reacts to incoming player bullets with lateral movement | P2 |
| F49 | Boss movement pattern | Boss follows designed movement pattern; not static | P1 |
| F50 | Boss phase transitions | After HP threshold, boss switches attack pattern; visual change clear | P0 |
| F51 | Enemy fire intervals respected | Each enemy type fires at its own rate; no bullet spam from single enemy | P1 |

### 1.7 Collision Detection

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F52 | Player bullet hits enemy | Enemy takes damage; bullet removed; hit effect/VFX plays | P0 |
| F53 | Enemy destroyed at 0 HP | Enemy death animation plays; score increments; removed from game | P0 |
| F54 | Enemy bullet hits player | Player takes damage; bullet removed | P0 |
| F55 | Player bullet hits enemy bullet (if implemented) | Bullets cancel each other; both removed | P3 |
| F56 | Player collides with power-up | Power-up applied; power-up sprite removed from field | P0 |
| F57 | Player collides with enemy (contact damage) | Player takes damage OR enemy destroyed (depending on design); invincibility triggers | P0 |
| F58 | Hitbox accuracy | Collision feels fair; no invisible walls around sprites or hits from empty space | P1 |
| F59 | No collision during invincibility frames | Player flashes; takes zero damage from any source during i-frames | P0 |

### 1.8 Health System

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F60 | Player starts with 3 HP (or design spec) | Health display shows full; 3 hearts/segments visible | P0 |
| F61 | Taking damage reduces HP by 1 | Health decrements; visual feedback (screen shake, red flash) | P0 |
| F62 | Invincibility frames after damage | Player flashes for ~1-2 seconds; cannot take damage | P0 |
| F63 | Health reaches 0 → death | Death animation plays; game over triggered | P0 |
| F64 | Health cannot go negative | Health clamped at 0; display never shows negative | P2 |
| F65 | Health pickup restores 1 HP | Health increments by 1; capped at max HP | P0 |
| F66 | Health pickup at full HP | Pickup consumed but no effect; not wasted (or refunds depending on design) | P2 |
| F67 | Health HUD updates instantly on change | No visible delay between damage and HUD update | P1 |

### 1.9 Power-ups

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F68 | "Rapid Fire" power-up | Fire rate increased; timer visible; expires correctly | P1 |
| F69 | "Spread Shot" power-up | Multiple bullets fired in fan; timer visible; expires correctly | P1 |
| F70 | "Shield" power-up | Visual shield around player; absorbs 1 hit; persists until hit or timer | P1 |
| F71 | "Speed Boost" power-up | Player movement speed increased; timer visible; expires correctly | P1 |
| F72 | "Score Multiplier" power-up | Score ×2 for duration; timer visible; expires correctly | P1 |
| F73 | Power-up timer countdown | Timer bar/text visibly decrements each second | P1 |
| F74 | Power-up expiration | Effect removed at timer=0; no residual effects; visual feedback of expiry | P0 |
| F75 | Multiple power-ups active simultaneously | All effects stack correctly; independent timers; no conflicts | P1 |
| F76 | Same power-up picked up while active | Timer resets/extends; does not stack infinitely | P1 |
| F77 | Power-up spawn probability | Drop rate feels fair (~15-25% from enemies); adjustable | P2 |

### 1.10 Level Progression

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F78 | Waves complete → all enemies defeated | Wave counter increments; next wave spawns after brief pause | P0 |
| F79 | All waves in level spawn | Level 1 has correct number of waves; no missing/stuck waves | P0 |
| F80 | Boss spawns after final wave | Boss entry animation; boss health bar appears; suspense music changes | P0 |
| F81 | Boss defeated → level complete | Victory jingle; transition to next level or upgrade shop | P0 |
| F82 | Level 1→2 transition | All entities cleared; new background; new enemy types; difficulty increase | P0 |
| F83 | Level 2→3 transition | Same as above; further difficulty increase | P0 |
| F84 | Level 3→4 transition | Same as above | P0 |
| F85 | Level 4→5 transition | Same as above | P0 |
| F86 | Level 5 boss defeated → victory | Victory screen shown; credits roll; final score displayed | P0 |
| F87 | Level transition — no entity carry-over | No bullets/enemies/power-ups from previous level persist | P0 |

### 1.11 Upgrade Shop (if implemented)

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F88 | Shop appears between levels | Upgrade menu with available purchases; score/currency visible | P1 |
| F89 | Purchase upgrade with score/currency | Score deducted; upgrade applied (e.g., +1 HP, faster speed) | P1 |
| F90 | Insufficient currency | Purchase rejected; visual feedback; no upgrade applied | P1 |
| F91 | "Continue" exits shop | Resumes gameplay at next level; upgrades persist for session | P1 |

### 1.12 Pause System

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F92 | P key pauses game | Game freezes; pause overlay appears; "PAUSED" text visible | P0 |
| F93 | All game logic stops during pause | No movement, shooting, spawning, or timers advance while paused | P0 |
| F94 | "Resume" option unpauses | Game continues from paused state; no lost entities/time-skips | P0 |
| F95 | "Quit to Menu" returns to main menu | Game state destroyed; main menu loads cleanly | P0 |
| F96 | Pause menu has audio toggle | Mute/unmute works from pause menu | P2 |
| F97 | Gameplay timer pauses | Total game time frozen during pause | P2 |

### 1.13 Game Over

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F98 | Death triggers game over screen | "GAME OVER" displayed; death animation completes first | P0 |
| F99 | Final score displayed | Score value correct (all kills, combos, bonuses included) | P0 |
| F100 | High score check | If score > previous high score, "NEW HIGH SCORE!" message | P0 |
| F101 | High score saved to localStorage | Score persists after page refresh; appears in high scores list | P0 |
| F102 | "Restart" returns to level 1 | Fresh game state; score reset to 0; level 1 starts | P0 |
| F103 | "Quit to Menu" returns to main menu | Clean transition; no residual state | P0 |
| F104 | Game over music/sound plays | Appropriate sfx/music for game over | P2 |

### 1.14 Victory

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| F105 | Level 5 boss defeated → victory screen | "VICTORY!" or "YOU WIN!" displayed | P0 |
| F106 | Victory shows final score and stats | Score, time, enemies killed, accuracy displayed | P1 |
| F107 | "Play Again" starts new game | Fresh state; score reset | P0 |
| F108 | Victory music plays | Triumphant SFX/music audible | P2 |

---

## 2. EDGE CASES

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| E01 | Enemy pool exhaustion (all active) | `spawnEnemy()` returns null or logs warning; no crash; no invisible enemies | P1 |
| E02 | Player dies during boss fight | Boss HP resets; level restarts from wave 1 of that level; no carry-over damage | P0 |
| E03 | Power-up picked up during level transition | Power-ups cleared with all entities on transition; no lingering effects | P1 |
| E04 | Multiple power-ups active simultaneously (all types) | All apply independently; visual stack clear; no game logic conflicts | P1 |
| E05 | Rapid pause/unpause (spam P key) | No crash; no state corruption; game resumes at correct frame | P0 |
| E06 | Browser tab loses focus → returns | `deltaTime` capped (≤50ms); game resumes at correct speed; no huge time-skip | P0 |
| E07 | Browser back/forward navigation | Game state cleanly destroyed or saved; no memory leaks; no dangling RAF | P2 |
| E08 | Window resize during gameplay | Canvas scales correctly; game world coordinates unaffected; HUD repositions | P1 |
| E09 | Extremely fast clicking (auto-clicker test) | Fire rate respected; no bullet queue overflow; no crash | P0 |
| E10 | Score overflow (value > 9,999,999) | Display handles large integer; no text clipping; counter wraps or formats (e.g., 10M) | P3 |
| E11 | Zero enemies killed → score 0 | Game over score is 0; high score list doesn't crash with zero | P2 |
| E12 | Player at border when wave spawns | Enemies don't spawn inside player; safe-spawn distance enforced | P1 |
| E13 | Bullet fired exactly at screen edge | Bullet appears and travels correctly; not clipped/glitched | P3 |
| E14 | All keys held simultaneously (W+A+S+D+Space) | No key ghosting issues; ship may stop (no net movement) or prioritize; no crash | P2 |
| E15 | localStorage is full or disabled | Game still works; high scores not saved; no crash (silent fail) | P1 |
| E16 | localStorage contains corrupted data | Game defaults to empty high scores; no parse errors crash the game | P1 |
| E17 | Canvas is manually removed from DOM | Game loop stops; no infinite errors in console | P2 |
| E18 | Multiple game instances (two tabs) | Each runs independently; no shared state conflict via localStorage writes | P2 |
| E19 | Player spends 10+ minutes on one level | No memory accumulation; object pools stable; performance unchanged | P2 |
| E20 | Boss defeat frame-perfect timing (killed on player death frame) | Only one outcome (game over or victory); no double-trigger; no stuck state | P1 |

---

## 3. PERFORMANCE TESTING

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| P01 | 60fps sustained with 200 player bullets active | `requestAnimationFrame` fires ~16.6ms per frame; no frame drops | P0 |
| P02 | 60fps sustained with 30 enemies + 200 bullets + 200 particles | Frame budget ≤ 16ms; Canvas clear + draw in budget | P0 |
| P03 | No memory leaks over 10-minute play session | Chrome DevTools heap snapshot: no upward trend; GC eventually reclaims; JS heap stable | P1 |
| P04 | Object pool exhaustion under normal conditions | Pools never exhaust during normal gameplay; max entities tuned correctly | P1 |
| P05 | Canvas clear and redraw within 16ms budget | Profiler shows draw time < 8ms (leaving 8ms for logic); no composite jank | P0 |
| P06 | No frame drops during boss fights | Boss bullet patterns (30+ projectiles) don't drop below 60fps on desktop | P0 |
| P07 | Mobile: 30fps minimum | iPhone/Android Chrome maintains ≥ 30fps with simplified particles | P1 |
| P08 | First contentful paint < 1s | Loading screen visible within 1 second of page load | P2 |
| P09 | Time to interactive < 3s | START button functional within 3 seconds on fast connection | P2 |
| P10 | Off-screen bullet cleanup | Bullets off-screen are recycled within 2 frames; no leaking entities | P1 |
| P11 | Particle system prunes excess | Particle count capped (e.g., 300 max); oldest particles recycled first | P2 |
| P12 | Garbage collection pauses undetectable | No visible stutter from GC during gameplay (use object pools, avoid `new` in hot paths) | P1 |
| P13 | Idle CPU usage | When paused or in menu, CPU usage drops significantly (no spinning loops) | P2 |

---

## 4. BROWSER COMPATIBILITY

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| B01 | Chrome (latest, macOS) | All features functional; 60fps; Web Audio works; fullscreen optional | P0 |
| B02 | Chrome (latest, Windows) | Same as macOS | P0 |
| B03 | Firefox (latest, macOS) | All features functional; AudioContext differences handled; Canvas renders identically | P0 |
| B04 | Firefox (latest, Windows) | Same as macOS | P0 |
| B05 | Safari (latest, macOS) | AudioContext needs user gesture to resume (handled); Canvas identical; no WebGL issues | P1 |
| B06 | Safari (iOS, latest) | Touch controls work; no double-tap zoom; audio unmutes on first touch | P0 |
| B07 | Edge (latest, Windows) | Same as Chrome (Chromium-based); all features | P1 |
| B08 | Chrome (Android, latest) | Touch controls responsive; 30fps+; no scroll interference | P1 |
| B09 | AudioContext — Safari restrictions | Audio starts muted; unmuted on first user interaction (START click) | P1 |
| B10 | Canvas rendering consistency | Screenshots compared across browsers; colors, shapes identical within ±1px tolerance | P2 |
| B11 | `requestAnimationFrame` behavior | No browser uses >60fps refresh as default multiplier; deltaTime normalized | P1 |
| B12 | Keyboard event handling differences | `event.key` cross-browser compatible; `event.code` used where possible | P1 |

---

## 5. GAME BALANCE TESTING

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| G01 | Level 1 — beatable by novice (2-3 tries) | Tester with no prior knowledge completes level 1 within 3 attempts | P0 |
| G02 | Level 2 — requires some skill | Noticeable difficulty increase; more enemies, faster bullets; but beatable | P1 |
| G03 | Level 3 — requires power-up usage | Without power-ups, very difficult; with power-ups, achievable | P1 |
| G04 | Level 4 — pattern recognition needed | Enemy patterns require learning; boss has complex phases; fair but hard | P1 |
| G05 | Level 5 — expert level, beatable | Max difficulty; requires mastery of all mechanics; beatable by skilled player | P1 |
| G06 | Power-up drop rate feels rewarding | ~1 drop per 3-5 enemies killed; not constant but not too rare | P1 |
| G07 | Power-ups are not overpowered | Fully powered-up player doesn't trivialize boss fights; still engaging | P1 |
| G08 | Boss fights feel epic but fair | Boss has telegraphed attacks; no undodgable bullet patterns; satisfying length | P0 |
| G09 | Upgrade shop provides meaningful progression | Purchased upgrades noticeably improve survivability; player feels rewarded | P1 |
| G10 | Score system encourages replay | Combos, kill streaks, accuracy bonus; high score chasing feels worthwhile | P1 |
| G11 | Enemy bullet speed increases per level | Level 1: slow; Level 3: moderate; Level 5: fast but dodgable | P2 |
| G12 | Player death feels fair | No instant-death scenarios without telegraphing; player sees what killed them | P0 |
| G13 | HP economy balanced across levels | Health pickups appear enough to sustain but not make it trivial; tension maintained | P1 |
| G14 | Score-to-currency ratio for shop | Earn enough in one level to buy at least one meaningful upgrade | P2 |

---

## 6. REGRESSION CHECKLIST

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| R01 | Restart from Game Over | Fresh state: score=0, HP=max, Level=1, no power-ups; enemies from wave 1 | P0 |
| R02 | Restart from Pause Menu | Fresh state: same as R01 | P0 |
| R03 | Quit to Menu → Start New Game | Fresh state: same as R01 | P0 |
| R04 | Play Again from Victory | Fresh state: same as R01 | P0 |
| R05 | High score persists across games | Previous high score visible in HIGH SCORES after new game and page refresh | P0 |
| R06 | Upgrades reset on new game | Purchased upgrades not carried over; shop resets to base state | P0 |
| R07 | Multiple game-over cycles | Play 5 full games end-to-end; no memory leaks; scores accumulate correctly | P1 |
| R08 | localStorage high scores survive browser restart | Close browser, reopen; high scores still present | P1 |
| R09 | Page refresh during gameplay | Game restarts from menu on refresh; no broken state from mid-game refresh | P1 |
| R10 | Settings (audio volume, mute) persist | If implementing settings persistence via localStorage; restored on reload | P3 |

---

## 7. RESPONSIVE BEHAVIOR

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| RB01 | 1920×1080 desktop | Game centered horizontally and vertically; correct aspect ratio; no black bars or letterboxing issues | P0 |
| RB02 | 1366×768 laptop | Game fills available viewport; HUD elements readable; buttons appropriately sized | P1 |
| RB03 | 768×1024 tablet (portrait) | Game scales to fit; touch controls visible and sized for fingers; UI readable | P2 |
| RB04 | 375×812 mobile (iPhone X) | Game playable with touch controls; HUD scaled but legible; no elements cut off | P1 |
| RB05 | Window resize — gradual | Canvas redraws smoothly; no flicker; game world coordinates unchanged | P1 |
| RB06 | Window resize — snap (maximize/restore) | Handles instant resize; no delay or visual corruption | P2 |
| RB07 | Aspect ratio maintained | Game world aspect ratio locked; extra space filled with decorative border or background | P1 |
| RB08 | Fullscreen API (if implemented) | Toggle fullscreen works; game scales correctly; exit fullscreen restores window size | P3 |
| RB09 | Device pixel ratio (Retina/HiDPI) | Canvas renders at native resolution; text and sprites crisp; no blurry rendering | P2 |
| RB10 | Zoom level 100-200% | Game scales but remains playable; no layout breakage | P3 |

---

## 8. ACCESSIBILITY BASICS

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| A01 | Color contrast on HUD text | WCAG AA minimum (4.5:1 for normal text, 3:1 for large text) | P2 |
| A02 | Color contrast on menu buttons | All button text readable against background | P2 |
| A03 | Color-blind accessibility (enemy bullets vs player bullets) | Bullets distinguishable by shape, not just color (e.g., different patterns) | P3 |
| A04 | Text readable at all screen sizes | Minimum 12px effective font size on smallest supported screen | P1 |
| A05 | Controls communicated clearly | HOW TO PLAY lists all controls; visual on-screen hints for touch controls | P1 |
| A06 | Audio mute toggle accessible | Mute button visible on menu, pause screen, and during gameplay; keyboard shortcut (M key) | P1 |
| A07 | No epilepsy triggers | No rapid flashing (>3Hz); no strobing effects; particle effects subdued | P2 |
| A08 | Keyboard-only navigation in menus | Full menu navigation possible without mouse (Arrow keys + Enter/Escape) | P2 |
| A09 | Focus indicators visible | Tab/focus outlines visible on interactive elements | P3 |
| A10 | Screen reader basics (if applicable) | Canvas elements have `aria-label`; game state changes announced (stretch goal) | P3 |

---

## 9. SPECIFIC BUG TESTS

| ID | Test | Expected Result | Priority |
|----|------|-----------------|----------|
| S01 | **Player bullet pool exhaustion** — spam fire for 30 seconds | No bullets disappear mid-flight; pool recycles oldest bullets; visual continuity maintained | P0 |
| S02 | **Enemy collision during invincibility** — get hit by enemy while flashing | Zero damage taken; no HP reduction; invincibility visual persists | P0 |
| S03 | **Boss phase transitions** — damage boss to phase thresholds | Phase change smooth; attack pattern switches; visual/audio cue; no sprite flicker | P0 |
| S04 | **Level transition entity cleanup** | After boss dies, wait for transition: ALL bullets, enemies, power-ups, particles cleared | P0 |
| S05 | **Audio context resume** — start game, notice no sound, click START (first interaction) | Sound begins playing after first user gesture; no "AudioContext not allowed" errors | P1 |
| S06 | **localStorage high score persistence** — get high score, refresh page, open HIGH SCORES | Score still displayed; loaded correctly on page load | P0 |
| S07 | **Canvas resize distortion** — resize browser window during gameplay | No stretching/distortion; aspect ratio maintained; game world coordinates unaffected | P1 |
| S08 | **Double-tap zoom prevention (mobile)** — double-tap on game canvas | Browser does not zoom; `touch-action: none` or `event.preventDefault()` active | P1 |
| S09 | **Touch scroll prevention (mobile)** — swipe on game canvas | Page does not scroll; game registers touch movement as ship control | P1 |
| S10 | **Negative deltaTime** — caused by system clock adjustment or tab backgrounding | `deltaTime` clamped to [0, 50ms]; no reverse movement; no NaN positions | P0 |
| S11 | **Canvas context loss** — simulate WebGL context loss (if WebGL used) | Game recovers or shows error; no infinite loop or blank screen | P3 |
| S12 | **Very large score display** — set score to 999,999,999 programmatically | Display fits HUD area; number formatted or scaled; no overflow into other HUD elements | P2 |
| S13 | **Concurrent power-up consumption** — pick up 3 power-ups in rapid succession | All 3 apply; timers start independently; icons all displayed; no overwrite | P1 |
| S14 | **Game loop timing anomaly** — artificially inject 500ms frame | Game catches up gracefully; no physics explosion; player/enemies don't teleport wildly | P1 |
| S15 | **Empty bullet pool on level start** — all bullets used then level transitions | Pool reset/reinitialized for new level; no stale bullets from previous level | P1 |
| S16 | **localStorage corrupted value** — manually set malformed JSON in localStorage key | Game handles gracefully; resets to default high scores; no parse error crash | P1 |
| S17 | **Very fast boss kill** — using debug/cheat to one-shot boss | Victory triggers correctly; no skipped phases crash; transition works | P2 |
| S18 | **Simultaneous keyboard + mouse fire** — hold Space and click rapidly | Only one bullet stream (fire rate respected); no double-fire exploit | P1 |

---

## 10. TEST EXECUTION SUMMARY

### Pass Criteria

| Stage | Criteria |
|-------|----------|
| **Alpha** | All P0 tests pass; no known crash bugs |
| **Beta** | All P0 + P1 tests pass; ≤ 3 known P2 issues |
| **Release** | All P0 + P1 + P2 tests pass; no known P3 regressions from previous version |

### Test Environment Setup

1. **Desktop browsers:** Chrome, Firefox, Safari, Edge — all latest stable versions
2. **Mobile browsers:** Chrome Android (Pixel or equivalent), Safari iOS (iPhone 12 or newer)
3. **Tools:** Chrome DevTools (Performance tab, Memory tab, Lighthouse), BrowserStack or similar for cross-browser
4. **Hardware:** Mid-range laptop (8GB RAM, integrated GPU) as baseline performance target

### Automation Recommendations (Future)

- Unit tests for: object pool logic, collision math, score calculation, level progression state machine
- Integration tests for: game loop timing, entity lifecycle, wave spawning system
- E2E smoke test: auto-play script that simulates inputs and verifies game doesn't crash for 5 minutes

---

*End of Test Plan*
