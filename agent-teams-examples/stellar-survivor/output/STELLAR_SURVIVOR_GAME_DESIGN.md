# STELLAR SURVIVOR — Complete Game Design Specification

## GAME OVERVIEW
A top-down arcade space shooter built as a single HTML5 file using Canvas. Player ship at bottom of screen, enemies descend from top. 5 levels, each ending with a boss. Shop between levels. Local high-score persistence.

---

## 1. ENEMY TYPES

### 1.1 STANDARD ENEMIES (7 types)

#### Drone (Basic Scout)
| Property | Value |
|---|---|
| HP | 1 |
| Speed | 120 px/s |
| Size (W×H) | 20×20 px |
| Hitbox | 16×16 px |
| Color | #FF4444 (red) |
| Point Value | 10 |
| Bullet | Single straight-down shot, speed 200 px/s, fires every 2.0s |
| Movement | Straight descent from top; sine-wave horizontal offset (±30px amplitude, 1.5 Hz) |
| Spawn Waves | All waves, all levels; primary filler enemy |

#### Weaver (Zig-Zag Rusher)
| Property | Value |
|---|---|
| HP | 2 |
| Speed | 180 px/s |
| Size | 18×18 px |
| Hitbox | 14×14 px |
| Color | #FF8800 (orange) |
| Point Value | 25 |
| Bullet | None (contact damage only) |
| Movement | Zig-zag pattern: horizontal amplitude 100px, frequency 3 Hz; descends while zigzagging |
| Spawn Waves | Wave 2+ in all levels |

#### Tank (Heavy Bruiser)
| Property | Value |
|---|---|
| HP | 8 |
| Speed | 60 px/s |
| Size | 36×36 px |
| Hitbox | 32×32 px |
| Color | #8844AA (purple) |
| Point Value | 75 |
| Bullet | Triple spread shot (angles: 0°, -25°, +25°), bullet speed 250 px/s, fires every 1.5s |
| Movement | Descends to y=200, stops, fires 2 volleys, then resumes descent after 3s |
| Spawn Waves | Wave 3+ in all levels |

#### Sniper (Precision Marksman)
| Property | Value |
|---|---|
| HP | 3 |
| Speed | 100 px/s |
| Size | 22×22 px |
| Hitbox | 18×18 px |
| Color | #44AAFF (blue) |
| Point Value | 50 |
| Bullet | Single aimed shot directly at player position; bullet speed 400 px/s; fires every 1.8s |
| Movement | Stays in top 30% of screen; slowly tracks player X coordinate (speed 80 px/s); bobs vertically ±20px |
| Spawn Waves | Wave 3+ in Level 2 onward |

#### Splitter (Fragmenting Enemy)
| Property | Value |
|---|---|
| HP | 5 |
| Speed | 90 px/s |
| Size | 28×28 px |
| Hitbox | 24×24 px |
| Color | #FFDD44 (yellow) |
| Point Value | 60 |
| Bullet | None |
| Movement | Straight descent with slight sinusoidal wobble (amplitude 15px, 2 Hz) |
| On Death | Splits into 3 fragments at base position: one straight (0°), two angled (±45°); fragments size 10×10, HP 1, speed 150 px/s, color #FFAA00, points 5 each, no bullets |
| Spawn Waves | Wave 4+ in Level 2 onward |

#### Mine Layer (Area Denial)
| Property | Value |
|---|---|
| HP | 6 |
| Speed | 80 px/s |
| Size | 30×30 px |
| Hitbox | 26×26 px |
| Color | #44FF44 (green) |
| Point Value | 80 |
| Bullet | Drops 3 stationary mines during horizontal sweep; mines size 14×14, HP 2, color #44DD44, timed fuse 8s then explode dealing 15 damage in 80px radius; player-bullet collision destroys mine (no explosion on bullet kill) |
| Movement | Enters from left or right edge at y=150; sweeps horizontally across screen over 4s, dropping mines every 1s; exits opposite side and despairs |
| Spawn Waves | Wave 4+ in Level 3 onward |

#### Shielder (Support)
| Property | Value |
|---|---|
| HP | 10 |
| Speed | 50 px/s |
| Size | 34×34 px |
| Hitbox | 30×30 px |
| Color | #CCCCCC (silver) |
| Point Value | 100 |
| Bullet | None directly |
| Movement | Slow steady descent; tries to position near largest cluster of enemies |
| Ability | Projects a 120px-radius aura (visible as translucent silver circle, opacity 15%, shimmering); all enemies inside aura gain +3 bonus HP (current and max, stacks with other Shielders max +9); Shielder destroyed = aura removed |
| Spawn Waves | Wave 5+ in Level 3 onward |

---

### 1.2 BOSSES

#### BOSS 1 — "The Warden" (Level 1 Boss)
| Property | Value |
|---|---|
| HP | 300 |
| Size | 80×80 px |
| Hitbox | 70×70 px |
| Color | #DD3333 (crimson), darker #991111 core |
| Points | 1000 |
| Movement | Horizontal patrol at y=100, amplitude 150px, speed 80 px/s |

**Phase 1 (HP > 60%: 181-300 HP)**
- 5-way spread shot (angles: -40°, -20°, 0°, +20°, +40°), fires every 1.0s
- Bullet: red (#FF3333), speed 250 px/s, size 6×6
- Spawns 2 Drones from left/right screen edges every 5s

**Phase 2 (HP 30-60%: 91-180 HP)**
- Rotating spiral pattern: 8 bullets fired in a ring, each volley rotates origin angle by +15°; fires every 0.5s
- Bullet: orange (#FF6644), speed 220 px/s
- Summons 3 Tanks from top edge (rapid descent to y=180, stop, fire)
- Flash effect at phase transition (0.3s white flash)

**Phase 3 (HP < 30%: 1-90 HP)**
- ENRAGED state: movement speed doubled (160 px/s), patrol amplitude doubles (300px)
- Double spiral: 16 bullets (two offset rings), fires every 0.4s
- Adds aimed sniper shot at player every 2.0s (speed 450 px/s)
- Visual: Continuous red pulsing glow, smoke particles trailing from engine ports

**Entry Warning**: 2s "WARNING" text + screen flash red before boss appears

---

#### BOSS 2 — "The Behemoth" (Level 2 Boss)
| Property | Value |
|---|---|
| HP | 400 |
| Size | 100×70 px (wide oval) |
| Hitbox | 90×60 px |
| Color | #8B6914 (brown-gold), rocky texture |
| Points | 1500 |
| Movement | Slow wobbly descent; stops at y=80, then sways left-right (amplitude 80px, period 3s) |

**Phase 1 (HP > 50%: 201-400 HP)**
- 6-way spread (evenly spaced 60° arcs), fires every 1.5s
- Rock-fragment bullets: brown (#AA7722), speed 200 px/s, size 8×8
- Descends slowly over first 10s from y=-100 to y=80

**Phase 2 (HP ≤ 50%: 1-200 HP)**
- Splits into 2 independent chunks: "Behemoth Left" and "Behemoth Right" (each HP 200, size 50×50, color #9B7924, points 750 each, Phase 2 entry starts at the HP values they had)
- Each chunk moves independently: one patrols left half, one right half (patrol width 100px each)
- Each chunk fires 3-way spread (angles: -30°, 0°, +30°) every 1.2s
- Both chunks must be destroyed to clear the level
- Split animation: cracks form over 0.5s, then two halves separate with debris particles

**Death**: Both chunks explode; larger chunk explosion first, smaller 0.3s later

---

#### BOSS 3 — "The Constructor" (Level 3 Boss)
| Property | Value |
|---|---|
| HP | 600 |
| Size | 96×96 px |
| Hitbox | 84×84 px |
| Color | #8844CC (violet), lighter #AA66EE core |
| Points | 2500 |
| Movement | Figure-8 pattern at y=80; figure-8 width 200px, height 60px, cycle time 6s |

**Phase 1 (HP > 70%: 421-600 HP)**
- Launches 4 Splitters from its body every 3s (launched outward at ±45°, ±135° with speed 100px/s; Splitters then take normal descent behavior)
- Fires 12-bullet ring (30° spacing) every 2.0s; bullet speed 200 px/s
- Bullet: violet (#CC66FF), size 5×5

**Phase 2 (HP 40-70%: 241-420 HP)**
- Deploys 2 Mine Layers (one from each screen edge) every 8s
- Fires aimed triple-burst: 3 rapid shots (50ms apart) aimed at player; full burst fires every 2.0s
- Ring pattern expands: 16 bullets, 22.5° spacing
- Burst bullets: pink (#FF66CC), speed 350 px/s

**Phase 3 (HP < 40%: 1-240 HP)**
- Spawns 2 Shielders (positioned at its flanks) once
- Fires cross pattern: 4 cardinal (0°, 90°, 180°, 270°) + 4 diagonal (45°, 135°, 225°, 315°) bullets simultaneously every 0.8s
- ULTIMATE ability: Becomes invulnerable (transparent white overlay) for 3s while healing 30 HP; player sees "SHIELD UP" warning; cycle repeats every 12s while in this phase
- Bullets during invuln phase: still fire cross pattern
- Visual: Hexagonal shield panels flickering around body, core pulsing violet

---

#### BOSS 4 — "The War Factory" (Level 4 Boss)
| Property | Value |
|---|---|
| HP | 800 |
| Size | 140×120 px (rectangle) |
| Hitbox | 130×110 px |
| Color | #665544 (industrial gray/brown), #887766 accent |
| Points | 3500 |
| Movement | Stationary at top-center (x = canvasWidth/2, y = 40); slight idle vibration (±3px random jitter) |

**Design**: 4 visible turrets on hull (positions: top-left, top-right, bottom-left, bottom-right relative to factory center)

**Phase 1 (HP > 60%: 481-800 HP)**
- Each turret independently fires single aimed shot every 3.0s (staggered start times)
- Conveyor-belt spawn: spawns random enemy (Drone 40%, Weaver 30%, Tank 20%, Sniper 10%) from bottom of factory every 4s; enemy exits downward
- Bullet: gray (#888888), speed 300 px/s, size 6×6

**Phase 2 (HP 30-60%: 241-480 HP)**
- Turrets upgrade to laser beams: each turret sweeps a 30° arc (center angle aimed at player); laser is 6px wide, dark red (#CC2222), deals 8 damage per tick (10 ticks/s); turrets alternate which fires (at most 2 firing simultaneously)
- Spawn rate doubles: enemy every 2s
- Spawn types expand: Drone 25%, Weaver 25%, Tank 20%, Sniper 15%, Splitter 15%

**Phase 3 (HP < 30%: 1-240 HP)**
- ALL 4 turrets fire simultaneously in synchronized bullet-hell ring: 8 bullets per turret (evenly spaced 45°), total 32 bullets bloom every 1.5s
- Fires 2 homing missiles every 6s: missile size 12×6, speed 180 px/s, tracks player with turn rate 120°/s, HP 5 (destructible by player shots), deals 25 damage on contact
- Self-destruct sequence at 10% HP (80 HP): 25s countdown timer visible as red bar above factory; if timer expires, explosion deals 50 damage to player; destroying factory before timer = normal kill
- Visual: Sparks, smoke, growing orange glow on hull; screen shake on missile launch

---

#### BOSS 5 — "The Overlord" (Level 5 Final Boss)
| Property | Value |
|---|---|
| HP | 1200 |
| Size | 120×120 px |
| Hitbox | 100×100 px |
| Color | Primary #FF0000 (red), trim #FFD700 (gold), core #FF4400 |
| Points | 5000 |
| Movement | Complex orbital pattern + charge attacks |

**General Movement Pattern**:
- Orbits screen in large oval path (center at screen center, rx=200px, ry=150px), speed 120 px/s
- Every 10s: pauses orbit, locks onto player X position, charges straight down at 300 px/s to y=250, then returns to orbit

**Phase 1 (HP > 75%: 901-1200 HP)**
- Cycles through all 6 standard enemy bullet patterns in sequence (1 pattern per 1s, full cycle = 6s):
  1. Drone pattern: single straight shot, speed 250
  2. Weaver charge: no bullet, but boss briefly dashes 100px toward player
  3. Tank pattern: triple spread (0°, ±25°), speed 280
  4. Sniper pattern: aimed fast shot, speed 500
  5. Splitter scatter: 4 bullets in fan (0°, ±20°, ±40°), speed 220
  6. Mine drop: drops 2 stationary proximity orbs (HP 5, explode after 5s in 100px radius for 20 damage)

**Phase 2 (HP 50-75%: 601-900 HP)**
- Dual rotating laser beams: 2 beams 180° apart, rotate at 60°/s; beam width 8px, length infinite (to screen edge), deals 20 damage/tick (10 ticks/s); beams are cyan (#00FFFF) with white core
- Fires aimed homing missile every 4s: speed 150 px/s, tracks player with 90°/s turn rate, HP 8, deals 30 damage on contact, size 14×8
- Continues orbital movement pattern
- Visual: Gold aura glow appears around boss

**Phase 3 (HP 25-50%: 301-600 HP)**
- BULLET HELL PHASE
- Fires 32-bullet bloom (evenly spaced 11.25°) every 0.8s
- Bullet speed randomized: 200-350 px/s each
- Teleports to random position (any X, Y between 40 and 200) every 5s; 0.3s vanish + 0.3s reappear animation (shrink out / expand in)
- Bullet color alternating: red and gold

**Phase 4 (HP < 25%: 1-300 HP)**
- ALL PREVIOUS PATTERNS COMBINED but at reduced frequency:
  - Cycled bullet patterns: once per 8s (instead of every 6s)
  - Rotating lasers: rotate at 30°/s (instead of 60°/s)
  - Bullet hell: 16-bullet bloom every 1.5s (instead of 32/0.8s)
  - Homing missile: every 8s
- Spawns 8-12 Drones from edges every 3s
- Screen shake: 8px amplitude continuous while boss HP < 10%
- Background flashes red at 0.5s intervals
- Visual: Boss sparks and emits smoke, gold aura intensified, size grows by 15% (berserk visual)

**Entry Warning**: 3s siren flash + "FINAL BOSS — THE OVERLORD" text + dramatic screen darken

---

## 2. LEVEL PROGRESSION

### Level 1: "Orbital Perimeter"
| Property | Value |
|---|---|
| Waves | 5 |
| Background | Deep starfield; base color #0A0A1A; 3 parallax star layers (speed 0.3x, 0.6x, 1.0x of scroll); subtle blue nebula (#112244) at screen edges |
| Enemy Composition | Drone 60%, Weaver 25%, Tank 15% |
| Spawn Timing | Waves every 25s (after previous wave cleared + 3s intermission); individual spawns every 3.0s |
| Difficulty Multiplier | 1.0× |
| Boss | The Warden |

### Level 2: "Asteroid Field"
| Property | Value |
|---|---|
| Waves | 7 |
| Background | Base color #1A1510; rocky debris flying horizontally across screen (speed 100-200 px/s, 15-30 debris pieces on screen); large asteroid silhouettes scrolling down at 0.5× player scroll speed; occasional large asteroid shadow crossing (1 every 8s, size 200-400px, opacity 20%) |
| Enemy Composition | Drone 40%, Weaver 25%, Tank 15%, Sniper 15%, Splitter 5% |
| Spawn Timing | Waves every 20s; individual spawns every 2.5s |
| Difficulty Multiplier | 1.3× |
| Mid-Level HAZARD | At wave 4, 30-second asteroid storm: debris falls from top at random X positions (every 0.3-0.5s, size 15-35px, speed 250 px/s, deals 12 damage on contact); warning text "ASTEROID STORM" 2s before |
| Boss | The Behemoth |

### Level 3: "Nebula Depths"
| Property | Value |
|---|---|
| Waves | 8 |
| Background | Base color #0B0B2A; swirling violet/green nebula clouds (3 large cloud layers, slowly rotating at 5°/s, opacity 15-25%); floating particle effects (small glowing dots drifting at random speeds); slight visibility haze (enemies have 90% opacity at spawn, full by y=200) |
| Enemy Composition | Weaver 30%, Sniper 25%, Splitter 20%, Mine Layer 15%, Shielder 10% |
| Spawn Timing | Waves every 18s; individual spawns every 2.0s |
| Difficulty Multiplier | 1.6× |
| Boss | The Constructor |

### Level 4: "Enemy Stronghold"
| Property | Value |
|---|---|
| Waves | 9 |
| Background | Base color #1A0A0A; fortress wall structures scrolling on left/right sides (width 60px, height fills screen, dark gray #333 with red alert lights blinking at 1Hz); searchlight beams sweeping across (2 beams, 400px length, 30°/s rotation, opacity 10%, at y=100 and y=300); occasional red alert flash (full screen #FF0000 at 5% opacity for 100ms every 3s) |
| Enemy Composition | Tank 20%, Sniper 20%, Splitter 15%, Mine Layer 20%, Shielder 15%, Drone 10% |
| Spawn Timing | Waves every 16s; individual spawns every 1.8s |
| Difficulty Multiplier | 2.0× |
| Mid-Boss at Wave 5 | "The Overseer": HP 200, size 50×50, color #DD8844, fires 3-burst aimed shots every 1.2s, patrols at y=120, points 500 |
| Boss | The War Factory |

### Level 5: "The Core"
| Property | Value |
|---|---|
| Waves | 10 |
| Background | Base color #000011; pulsating red core at center-bottom of screen (pulse cycle 1.5s, size 80px → 120px, glow #FF2200); intense particle storms (200+ particles, moving upward at varying speeds, creating "rain" effect); dramatic color shifts on wave transitions |
| Enemy Composition | ELITE variants (all base enemy stats ×1.5 HP, speed, fire rate): Tank 20%, Sniper 20%, Splitter 20%, Mine Layer 20%, Shielder 20% |
| Spawn Timing | Waves every 14s; individual spawns every 1.5s |
| Difficulty Multiplier | 2.5× |
| Boss | The Overlord |

---

### Level Transition & Between-Level Shop

**Level Complete Sequence** (after boss defeat):
1. Boss death animation plays fully (0.8-1.5s depending on boss)
2. Screen freeze 0.5s
3. Screen fade to black 1s
4. "LEVEL [N] COMPLETE" text (white, glow, scale-in animation over 0.5s, hold 2s)
5. Score tally roll-up:
   - "ENEMIES DESTROYED: X" (count up)
   - "BOSS DEFEATED: +[points]" (flash)
   - "TIME BONUS: +[time_remaining × 5]" (if applicable)
   - "ACCURACY BONUS: +[accuracy × 200]" (roll up)
   - "NO-DAMAGE CLEAR: +500" (if applicable)
   - "TOTAL LEVEL SCORE: XXXXX"
   - Each line appears with 0.3s stagger; tally takes 3s total
6. "PROCEEDING TO SHOP..." text, fade to shop 0.5s

**SHOP SCREEN — "The Armory"**
- Background: Dark (#080820), large centered panel (600×400px, border #334, inner #112)
- Title: "THE ARMORY" at top (gold text #FFD700)
- Player's current score displayed top-right

**Available Upgrades** (4 permanent stat upgrades):
| Upgrade | Effect | Cost | Max Purchases |
|---|---|---|---|
| Hull Reinforcement | Max HP +25 | 500 | 5 (max +125) |
| Weapon Overclock | Fire Rate +10% | 400 | 5 (max +50%) |
| Armor-Piercing Rounds | Bullet Damage +1 | 600 | 5 (max +5) |
| Thruster Upgrade | Movement Speed +5% | 300 | 5 (max +25%) |
| Velocity Charger | Bullet Speed +10% | 350 | 5 (max +50%) |

**Available Power-Ups** (3 random one-time use for next level, each 200 points):
- Randomly selected from: Rapid Fire, Multi-Shot, Speed Boost, Damage Boost (excludes Shield Restore and Nova Blast)
- Each can be purchased once; activates at start of next level

**Buttons**:
- [NEXT LEVEL → "Level N: Name"] (prominent, bottom-right)
- Each upgrade shows: name, icon, current level (e.g., "Lv. 2/5"), cost, [BUY] button (grayed out if insufficient funds)

**Transition Out**: Fade to black 0.5s → Level start sequence

---

## 3. POWER-UPS

### 3.1 STANDARD POWER-UPS (5 types)

All standard power-ups drift downward at 80 px/s, bob horizontally ±10px (sine, 2Hz). Despawn at bottom of screen. Collected on player collision (30px pickup radius around player center).

#### 1. Shield Restore
| Property | Value |
|---|---|
| Color/Shape | Cyan (#00FFFF) rotating hexagon (8px line width, 16px radius, rotates 90°/s) |
| Effect | Instantly restores 25 HP (cannot exceed max HP) |
| Duration | Instant |
| Drop Rate | 8% from any enemy |
| Float Speed | 80 px/s |

#### 2. Rapid Fire
| Property | Value |
|---|---|
| Color/Shape | Orange (#FF8800) lightning bolt (3 zigzag segments, 20px tall) |
| Effect | Fire rate increased by 50% (e.g., base 0.4s → 0.2s between shots) |
| Duration | 8 seconds (shows countdown bar on HUD) |
| Drop Rate | 6% from any enemy |
| Float Speed | 80 px/s |

#### 3. Multi-Shot
| Property | Value |
|---|---|
| Color/Shape | Yellow (#FFDD00) triple arrow icon (3 parallel arrows pointing up, 18px wide) |
| Effect | Each shot fires 3 bullets instead of 1: center (0°), left (-15°), right (+15°) |
| Duration | 10 seconds |
| Drop Rate | 5% from any enemy |
| Float Speed | 80 px/s |

#### 4. Speed Boost
| Property | Value |
|---|---|
| Color/Shape | Blue (#4488FF) wing icon (two stylized feather wings, 22px wide) |
| Effect | Movement speed increased by 40% (300 → 420 px/s base) |
| Duration | 10 seconds |
| Drop Rate | 6% from any enemy |
| Float Speed | 80 px/s |

#### 5. Damage Boost
| Property | Value |
|---|---|
| Color/Shape | Red (#FF2222) crosshair/crossed-swords icon (20×20px) |
| Effect | Bullet damage doubled (×2.0) |
| Duration | 8 seconds |
| Drop Rate | 5% from any enemy |
| Float Speed | 80 px/s |

### 3.2 SUPER POWER-UP

#### Nova Blast (Rare)
| Property | Value |
|---|---|
| Color/Shape | White (#FFFFFF) pulsing star with gold (#FFD700) outer glow; 1.5× size of normal pickups (24px radius); leaves sparkle trail (gold particles, 5 per frame, fade over 0.3s) |
| Effect | (1) Instantly destroys ALL enemies on screen, dealing 100 damage to each; (2) If a boss is present, deals 50% of boss's current HP as damage (applied after enemy clear); (3) Player gains 2s invincibility after activation |
| Duration | Instant activation + 2s invincibility |
| Drop Rate | 0.5% from any enemy |
| Float Speed | 50 px/s (slower fall) |
| Special Visual | Pulsing glow (size oscillates 0.8× to 1.2× at 3Hz, opacity 70-100%); golden particle trail; screen flash white for 0.15s on collection |

### 3.3 HUD Integration for Power-Ups
- Active power-up icons shown at top-left of screen, stacked vertically
- Each icon has a shrinking vertical bar on its right side showing remaining duration
- Icons flash rapidly during last 2 seconds of duration (warning)
- Power-up name briefly flashes at center of screen on pickup (0.5s, fade out)
- Stacking rules: same power-up picked up again resets duration (does not stack effect)
- Different power-ups can all be active simultaneously

---

## 4. PLAYER

### 4.1 Base Stats
| Stat | Value |
|---|---|
| Max HP | 100 |
| Movement Speed | 300 px/s (8-directional: arrow keys or WASD) |
| Fire Rate | 1 shot every 0.4s (150 RPM) |
| Bullet Damage | 10 per hit |
| Bullet Speed | 600 px/s (straight upward) |
| Bullet Size | 4×12 px (elongated, cyan #00CCFF with white core) |
| Ship Visual Size | 32×40 px (triangular/arrow shape, angled wings, pointed nose) |
| Hitbox | 20×24 px (slightly smaller than visual, forgiving) |
| Start Position | Center-bottom: x = canvasWidth/2, y = canvasHeight - 80 |

### 4.2 Ship Visual Design
- **Primary hull**: #00CCFF (cyan-blue), sharp angular shape (arrowhead pointing up)
- **Wing accents**: #0088CC (darker blue), swept-back wing tips
- **Cockpit**: #FFFFFF center dot (4px)
- **Engine glow**: #FF6600 → #FFAA00 gradient at rear; 3-frame flicker animation (frames: 100% opacity, 70% opacity, 100% opacity; each frame 50ms)
- **Engine flame**: Trapezoid shape behind ship (8px wide at ship, tapers to 4px at bottom, 10px tall)
- **Shield aura** (when invincible): Semi-transparent white circle radius 30px around ship center; opacity pulses 20% ↔ 40% at 2Hz cycle; #FFFFFF with slight cyan tint

### 4.3 Invincibility Frames
- Triggered on taking ANY damage (regardless of amount)
- Duration: **1.5 seconds** of complete invincibility
- During invincibility:
  - Ship sprite blinks: alternating visible (100ms) → invisible (100ms) → repeat
  - Shield aura visible full duration
  - Player cannot take any damage (bullets pass through, enemies pass through)
  - Player bullets still fire and deal damage normally
  - Enemies still take collision damage if game supports ramming damage
- After invincibility ends: shield aura fades over 0.3s
- Minimum 0.5s cooldown between invincibility activations (to prevent exploits)

### 4.4 Death & Visual Feedback
- Player HP reaches 0 → Immediate death
- Death animation sequence:
  1. Ship freezes at position (0.1s)
  2. Explosion burst: 25 cyan + orange particles (size 3-6px), scatter in all directions at speeds 50-300 px/s, fade over 0.8s
  3. Screen shake: 5px amplitude, dampens over 0.3s
  4. "GAME OVER" overlay fades in (0.5s)
- Player respawns at start of level (if restart) or returns to main menu
- No lives system; each death = game over, restart from Level 1

---

## 5. SCORING SYSTEM

### 5.1 Enemy Point Values
| Enemy | Points |
|---|---|
| Drone | 10 |
| Weaver | 25 |
| Tank | 75 |
| Sniper | 50 |
| Splitter | 60 |
| Splitter Fragment | 5 |
| Mine Layer | 80 |
| Mine (destroyed by player) | 15 |
| Shielder | 100 |
| The Overseer (mini-boss) | 500 |
| The Warden (Boss 1) | 1000 |
| The Behemoth (Boss 2) | 1500 |
| The Constructor (Boss 3) | 2500 |
| The War Factory (Boss 4) | 3500 |
| The Overlord (Boss 5) | 5000 |
| Homing Missile (destroyed) | 100 |
| Asteroid debris | 5 |

### 5.2 Combo System
- **Combo Window**: 1.5 seconds between kills to maintain chain
- **Combo Counter**: Consecutive kills without breaking
- **Combo Break Conditions**: 1.5s without a kill OR player takes damage
- **Multiplier Tiers**:
  | Kills | Multiplier | Display Color |
  |---|---|---|
  | 1-4 | ×1.0 | White |
  | 5-9 | ×1.5 | Green #44FF44 |
  | 10-19 | ×2.0 | Yellow #FFFF44 |
  | 20-34 | ×2.5 | Orange #FFAA44 |
  | 35-49 | ×3.0 | Red #FF4444 |
  | 50-74 | ×4.0 | Purple #CC44FF |
  | 75-99 | ×5.0 | Gold #FFD700 |
  | 100+ | ×6.0 (MAX) | Rainbow cycling |

- All points earned apply current combo multiplier
- Combo display: Right side of screen, shows "COMBO ×[multiplier]" with kill count below; grows in size at higher tiers (1.0× → 1.8× font scale)
- Combo timer bar: Thin bar below combo text, depletes over 1.5s, resets on each kill; flashes red in last 0.3s
- **COMBO BREAK**: When combo breaks, "COMBO BREAKER" text appears briefly (0.8s, red, shake animation) at combo display location

### 5.3 End-of-Level Bonuses
| Bonus | Calculation | Condition |
|---|---|---|
| Time Bonus | Remaining par-time seconds × 5 | Level par times: L1=90s, L2=120s, L3=150s, L4=180s, L5=210s (from first enemy spawn to boss death) |
| Accuracy Bonus | (shots_hit / shots_fired) × 200 | Rounded to nearest integer |
| No-Damage Clear | +500 | Player took 0 damage during entire level |
| Perfect Level | +1500 | No-damage + all enemies killed (100% clear rate); displayed as "PERFECT!" in gold text with sparkle effect |

### 5.4 High Score System
- Stored in `localStorage` under key `stellar_survivor_highscores`
- Top 5 scores saved as JSON array: `[{score, level, date}, ...]`
- High score display on main menu (right panel, 5 entries)
- In-game HUD: current score top-left; high score top-right (updates in real-time)
- New high score: score text flashes gold 3 times (0.2s each), "NEW HIGH SCORE!" banner appears

---

## 6. WAVE SYSTEM

### 6.1 Wave Structure
Each level contains N waves (see Section 2). After the final wave, the boss fight begins immediately.

**Wave Lifecycle**:
1. **INTERMISSION** (3s): Brief pause after previous wave cleared. "WAVE [N]" text displays (scale-in, hold 1.5s, fade out). Background music intensifies slightly.
2. **SPAWN PHASE**: Enemies spawn according to the wave's pattern. Spawn window lasts 4-10s depending on wave count.
3. **CLEAR PHASE**: All spawned enemies must be destroyed. "ENEMIES REMAINING: [count]" shown at top of screen (small text).
4. **WAVE CLEAR**: All enemies destroyed → "WAVE CLEAR" text (0.8s) → Intermission → Next wave or Boss

### 6.2 Wave Enemy Count per Level
| Wave | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|
| 1 | 8 | 10 | 12 | 14 | 16 |
| 2 | 10 | 12 | 14 | 16 | 18 |
| 3 | 12 | 14 | 16 | 18 | 20 |
| 4 | 14 | 16 | 18 | 20 | 22 |
| 5 | 16 | 18 | 20 | 22* | 24 |
| 6 | — | 20 | 22 | 24 | 26 |
| 7 | — | 22 | 24 | 26 | 28 |
| 8 | — | — | 26 | 28 | 30 |
| 9 | — | — | — | 30 | 32 |
| 10 | — | — | — | — | 34 |

*Wave 5 in Level 4 is the mid-boss wave; spawns 15 enemies + The Overseer

### 6.3 Spawn Patterns

#### Pattern 1: LINE
- 6-10 enemies in a horizontal line across top of screen
- Spaced 60px apart, centered on screen width
- All enemies descend together at their normal speed
- Used in: Early waves (Wave 1-2 in all levels)

#### Pattern 2: V-FORMATION
- 5-9 enemies arranged in V shape (odd count only; point of V faces down)
- Spacing: 70px between adjacent enemies (both horizontal and vertical)
- V-center aligned to screen center
- All enemies descend together as a group
- Used in: Waves 2-4

#### Pattern 3: RANDOM SCATTER
- 8-15 enemies spawn at random X positions (range: 40px to canvasWidth-40px)
- Spawn at y = -50px to -10px (random), creating staggered entry
- Each enemy follows its normal movement pattern
- Used in: Waves 3-6

#### Pattern 4: CIRCLE
- 8-12 enemies arranged in a circle (radius 100px around a center point)
- Center point at x = screenCenter+randomOffset, y = 80
- Circle rotates at 30°/s as it descends
- All enemies maintain relative circle position while each fires independently
- Used in: Waves 4-7

#### Pattern 5: WALL
- 12-16 enemies in two columns: left column at x=70, right column at x=canvasWidth-70
- Columns march inward (each column moves 40px toward center over 2s)
- Then all enemies descend together
- Used in: Waves 5-8

#### Pattern 6: DIAMOND
- 9, 16, or 25 enemies (square numbers) arranged in diamond shape
- Row structure for 16: rows of 1, 3, 5, 3, 1 enemies
- Spacing: 55px horizontal, 50px vertical between center points
- Descends as a group, slight rotation (±10° oscillation)
- Used in: Waves 6+

#### Pattern 7: SWEEP
- Enemies enter from alternating edges in waves of 3-4
- Left edge → 3 enemies → 1s delay → Right edge → 3 enemies → repeat
- Each sweep group moves horizontally across screen then exits opposite side
- Used in: Waves 5+

### 6.4 Warning Indicators
| Event | Indicator | Duration |
|---|---|---|
| Enemy spawn (any pattern) | Red chevron (▼) at spawn location, 12px, flashing at 4Hz | 0.5s before spawn |
| Formation spawn | Dashed white outline of formation shape | 0.5s before enemies appear |
| Boss approaching | "WARNING" text (large, red, pulsing) + screen border flash red (4Hz) + screen shake | 2.0s before boss |
| Asteroid storm (L2) | "ASTEROID STORM INCOMING" text + screen border flash orange | 2.0s before hazard |
| Mine about to explode | Mine flashes white rapidly in last 1.5s (10Hz) | 1.5s before detonation |
| Boss phase change | Boss flashes white 3 times (0.1s each) + screen shake (3px, 0.2s) | At phase transition |

### 6.5 Difficulty Scaling Within Waves
- Per-wave scaling (within a level): enemy count +2 per wave, spawn interval -0.2s per wave, bullet speed +5% per wave
- Per-level scaling (across game): see Level Progression difficulty multipliers
- Boss HP scaling: Not just raw HP but also the phase thresholds (each phase represents a certain HP percentage as listed per boss)

---

## 7. GAME FLOW

### 7.1 State Machine

```
[STARTUP] → [MAIN MENU] → [LEVEL PLAY (1→5)] → [VICTORY]
                ↑                ↓                    ↓
                ↑          [GAME OVER] ←──────────────┘
                ↑                ↓
                ↑          [MAIN MENU]
                └────────────────┘
```

### 7.2 Startup Sequence
1. **Canvas init** (instant): Create canvas, detect screen size, set up 800×600 base resolution (scaled to fit viewport while maintaining aspect ratio)
2. **Asset loading** (0-2s): Show "STELLAR SURVIVOR" logo (white text with glow, center screen) + "LOADING..." below; loading bar (200px wide, fills over actual load time)
3. **Main Menu transition**: Logo shrinks to top-left corner position (0.5s animation), menu buttons appear

### 7.3 Main Menu
- **Background**: Level 1 starfield at full animation (seamless transition into gameplay)
- **Title**: "STELLAR SURVIVOR" — large text (48px), gold-to-cyan gradient, glow effect, subtle floating animation (±5px y at 0.5Hz)
- **Subtitle**: "An Arcade Space Shooter" (14px, gray, below title)
- **Menu Buttons** (centered, vertical stack, 40px spacing):
  - **[START GAME]** (green #44FF44 on hover) → Begins Level 1
  - **[HIGH SCORES]** (blue on hover) → Shows top 5 scores panel (slides in from right)
  - **[CONTROLS]** (white on hover) → Shows control scheme panel (slides in from right)
  - **[CREDITS]** (dim white) → Brief credits screen
- **High Scores Panel**: Semi-transparent overlay (80% black), 5 score entries, each shows rank, score, level reached, date; [BACK] button
- **Controls Panel**: Shows "WASD / Arrow Keys → Move", "Space / Click → Shoot (hold for auto-fire)", "P / Esc → Pause", "M → Mute Music"; [BACK] button

### 7.4 Level Play (In-Game HUD)
| Element | Position | Content |
|---|---|---|
| Score | Top-left | "SCORE: XXXXXX" (white) |
| High Score | Top-right | "HI: XXXXXX" (gold, smaller) |
| HP Bar | Bottom-left | Red bar (200px wide, 12px tall), "HP: XX/100" text below; bar color green > 50%, yellow 25-50%, red < 25% |
| Level/Wave | Top-center | "LEVEL X — WAVE Y" |
| Combo | Right side, vertically centered | "COMBO ×N.M" with kill count below |
| Active Power-Ups | Top-left, below score | Icons with duration bars |
| Boss HP Bar | Top-center (boss fights) | Wider bar (400px, 20px tall), "BOSS NAME" above, boss HP below; appears on boss entry |
| Enemies Remaining | Below Level/Wave text | Small gray text, "ENEMIES: X" |

### 7.5 Death → Game Over Flow
1. Player HP ≤ 0
2. Death animation plays (0.8s total)
3. Screen freeze 0.3s
4. "GAME OVER" overlay fades in (dark overlay 70% opacity, text "GAME OVER" in large red text, 60px, with shake animation)
5. Stats display (staggered, each appears 0.5s apart):
   - "LEVEL REACHED: X"
   - "ENEMIES DESTROYED: XXX"
   - "TOTAL SCORE: XXXXXX"
   - "HIGHEST COMBO: ×N.M (XX kills)"
   - "BOSSES DEFEATED: X/5"
   - "NEW HIGH SCORE!" (if applicable, gold flash)
6. Buttons appear after all stats shown (1s delay): **[TRY AGAIN]** (restart from Level 1), **[MAIN MENU]**

### 7.6 Victory Flow
1. The Overlord defeated (death animation: 1.5s dramatic explosion, gold/red particles, screen shake)
2. Screen freeze 0.5s
3. "VICTORY!" text (large, gold #FFD700, zoom-in effect, particle burst)
4. Victory stats display (same as Game Over but celebratory):
   - All Game Over stats
   - "TOTAL TIME: XX:XX"
   - "FINAL SCORE: XXXXXX" (includes all bonuses)
5. High score check and save
6. Buttons: **[PLAY AGAIN]** (restart from Level 1 with reset), **[MAIN MENU]**
7. Background: Special victory particles (golden confetti falling, fireworks bursts every 2s)

### 7.7 Pause Menu
- **Trigger**: Press P or Escape key
- **Effect**: All game timers freeze; dark overlay (70% opacity black) covers screen; player and enemies stop moving
- **Menu** (centered box, 300×220px, dark border):
  - "PAUSED" title (24px, white)
  - **[RESUME]** button → Resume gameplay
  - **[RESTART LEVEL]** button → Restart current level from Wave 1 (reset player to base stats for that level? No — keep purchased upgrades, reset HP to max, reset power-ups)
  - **[QUIT TO MENU]** → Return to main menu (confirm dialog: "Quit to menu? Progress will be lost." with [YES] [NO])
- Press P or Escape again also resumes
- Music continues playing (optional: volume reduced to 30% during pause)

### 7.8 Controls
| Input | Action |
|---|---|
| Arrow Keys / WASD | Move ship in 8 directions (diagonals supported) |
| Space / Left Mouse Button | Shoot (hold for auto-fire at max fire rate) |
| P / Escape | Pause/Resume |
| M | Mute/unmute music |
| R (on Game Over/Victory) | Quick restart |
| Enter (on menus) | Confirm selection |

---

## 8. TECHNICAL NOTES (for implementation reference)

### Canvas & Resolution
- **Base resolution**: 800×600 pixels
- **Scaling**: Scale to fit browser viewport while maintaining 4:3 aspect ratio; letterbox if needed
- **Rendering**: 60 FPS target; use `requestAnimationFrame` with delta-time for frame-rate independence

### Color Palette Summary
| Usage | Hex |
|---|---|
| Player primary | #00CCFF |
| Player engine | #FF6600 |
| Player bullet | #00CCFF → #FFFFFF |
| Enemy Drone | #FF4444 |
| Enemy Weaver | #FF8800 |
| Enemy Tank | #8844AA |
| Enemy Sniper | #44AAFF |
| Enemy Splitter | #FFDD44 |
| Enemy Mine Layer | #44FF44 |
| Enemy Shielder | #CCCCCC |
| Boss Warden | #DD3333 |
| Boss Behemoth | #8B6914 |
| Boss Constructor | #8844CC |
| Boss War Factory | #665544 |
| Boss Overlord | #FF0000 / #FFD700 |
| Power-up Shield | #00FFFF |
| Power-up Rapid | #FF8800 |
| Power-up Multi | #FFDD00 |
| Power-up Speed | #4488FF |
| Power-up Damage | #FF2222 |
| Power-up Nova | #FFFFFF / #FFD700 |
| UI text primary | #FFFFFF |
| UI text gold | #FFD700 |
| HP bar green | #44FF44 |
| HP bar yellow | #FFFF44 |
| HP bar red | #FF4444 |

### Sound Design Notes (for audio implementation)
- **Music**: Looping synthwave/chiptune tracks per level (optional mute with M key)
- **SFX needed**: Player shoot, enemy shoot, enemy death, power-up collect, Nova Blast, boss warning, boss phase change, level complete, combo break, player hit, player death, menu select, menu hover
- **Priority**: game-logic sound triggers over music (if resource constrained)

---

## DOCUMENT VERSION
- Version: 1.0
- Date: 2026-05-05
- Author: Game Design Lead, Stellar Survivor Studio
- Status: FINAL — Ready for implementation
