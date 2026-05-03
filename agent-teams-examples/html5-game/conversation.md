# Building an Advanced HTML5 Arcade Game

**Session ID:** ses_21372673affe7wo11yvEyO9vfZ
**Created:** 5/2/2026, 11:36:35 PM
**Updated:** 5/3/2026, 12:18:03 AM

---

## User

Act as a game development studio. Use agent team to design and build a complex HTML5 browser game using WebGL, Canvas, JavaScript, and modern browser APIs.

1. Game Design Team
Define the game concept, genre, core loop, player goals, win conditions, failure conditions, difficulty progression, enemy types, power ups, scoring, levels, and replay value.

2. Rendering Team
Implement high performance visual rendering using WebGL and Canvas. Include animated backgrounds, particle effects, lighting effects, camera movement, smooth transitions, and responsive scaling for different screen sizes.

3. Physics and Gameplay Team
Create responsive player movement, collision detection, enemy behavior, projectile systems, environmental hazards, object interactions, and balanced game mechanics.

4. Artificial Intelligence Team
Design intelligent enemy behavior with multiple states such as patrol, chase, attack, retreat, search, and adapt. Enemies should react to player actions and increase challenge over time.

5. User Interface Team
Create a polished game interface with main menu, pause menu, heads up display, health, score, timer, level indicator, upgrade menu, game over screen, and restart option.

6. Audio Team
Use browser based audio effects for actions such as shooting, explosions, damage, power ups, menu selection, and victory. Include background music or procedural audio when possible.

7. Performance Team
Optimize rendering, animation, memory usage, object pooling, frame timing, and input handling. The game should target smooth performance at sixty frames per second.

8. Quality Assurance Team
Test for bugs, edge cases, browser compatibility, responsive behavior, game balance, collision issues, restart behavior, and performance drops.

Game requirements:

Create an advanced arcade style action game with multiple levels, enemies, upgrades, particles, visual effects, sound effects, and progressively harder gameplay.

The final output must include:

1. Complete HTML5 code
2. Embedded CSS
3. JavaScript game engine logic
4. WebGL or Canvas rendering
5. Keyboard and mouse controls
6. Touch controls for mobile
7. Main menu
8. Pause and resume
9. Score system
10. Health system
11. Enemy artificial intelligence
12. Level progression
13. Particle effects
14. Sound effects
15. Restart and game over states
16. Clear comments explaining the major systems

Before writing the code, briefly describe the game concept and architecture. Then generate the full playable code.

Make the result production quality, visually impressive, and playable directly in a browser by saving the output as an HTML file. 

---

## Assistant (Build · DeepSeek V4 Pro · 13.1s)

_Thinking:_

The user wants me to create a complex HTML5 browser game using a multi-agent team approach. Let me break this down into a large-scale project and use the team system to coordinate the work. Let me first create the team, then delegate tasks to different specialized agents.

Let me think about the game concept first - an advanced arcade-style action game. I'll go with a "Space Assault" - a top-down space shooter with WebGL rendering, multiple enemy types, upgrades, particle effects, etc.

Let me create the team and spawn multiple agents to work on different aspects of this game.

Actually, let me think about this more carefully. The user wants a complete, production-quality HTML5 game. This is a massive undertaking. Let me use the team system effectively by spawning multiple agents that each work on different parts of the game, then I'll integrate everything.

Let me start by creating the team, then spawning design, rendering, physics, AI, UI, audio, and QA agents.

Actually, let me first create the team and then spawn the agents with specific tasks. Each agent should contribute their piece, and I'll integrate everything at the end.

Let me create a plan:

1. Create team "GameStudio"
2. Spawn design agent to define game concept
3. Spawn agents for different parts of the game

Let me start with creating the team and spawning the first batch of agents.

**Tool: team_create**

**Input:**
```json
{
  "name": "GameStudio",
  "goal": "Design and build a complete, production-quality HTML5 arcade space shooter game with WebGL/Canvas rendering, multiple levels, enemies, upgrades, particles, sound effects, and progressive difficulty. Final output is a single self-contained HTML file."
}
```

**Output:**
```
{
  "teamID": "680aaa58-5309-4d5b-8a23-f5ec923d55b3",
  "name": "GameStudio",
  "status": "active"
}
```

---

## Assistant (Build · DeepSeek V4 Pro · 51.0s)

_Thinking:_

Team created. Now let me spawn the first set of agents. Let me plan what each agent should do and what they should return. Since the final output needs to be a single HTML file, I need each agent to produce their part and I'll integrate them.

Let me spawn several agents in parallel:

1. Game Design Agent - Define the game concept, mechanics, enemies, levels, scoring
2. Rendering/Engine Agent - Handle WebGL/Canvas rendering, particle systems, visual effects
3. Physics/Gameplay Agent - Player movement, collision detection, projectile systems
4. AI Agent - Enemy behavior patterns
5. UI Agent - Menu systems, HUD, overlays
6. Audio Agent - Sound effects system

Each agent should write their part of the code. Actually, since this is a single HTML file, let me think about the architecture differently.

The game architecture:
- Main game loop
- Game states (menu, playing, paused, gameover)
- Player class
- Enemy classes (multiple types)
- Projectile/powerup systems
- Particle system
- Level system
- UI overlay system
- Audio system
- Input handling
- WebGL/Canvas rendering

Let me spawn agents to each produce a well-structured JavaScript module/system. Each agent should return code that can be integrated.

Actually, given the complexity, let me think about this more practically. The agents will each write code snippets. I need to:
1. Have the design agent define the concept
2. Have code agents write specific systems
3. Integrate everything into one file

Let me start by spawning the design agent and a few code agents. The design agent should finish first, then I can feed the design to the code agents.

Actually, let me rethink. I'll spawn:
1. A design agent that just investigates and returns a detailed game design document
2. Wait for that, then spawn code agents with the design spec

But actually, the agents might take a while and I need to coordinate. Let me just spawn all agents in parallel with a clear shared vision of the game.

Let me define the game concept myself (Space Assault - an arcade space shooter) and spawn agents to build different systems.

For practical reasons, let me spawn:
1. A general agent to write the full game code (the main agent)
2. Supporting agents for specific subsystems

Actually the most practical approach given the tool constraints: let me spawn a few agents to work on different files, but since the output is a single HTML file, I should have one main agent write the complete file, and supporting agents to review/test specific aspects.

Let me think again... The best approach for a single HTML file is:
1. Spawn 2-3 agents to write different major sections of the code
2. Integrate them into one file

Or alternatively, spawn one main agent to write the complete game and have QA/performance agents review it.

Let me go with a practical approach:
- Spawn 4 agents in parallel:
  - Game Designer: Returns a detailed game design document
  - Core Engine Developer: Writes core engine (rendering, physics, loop)
  - Gameplay Systems Developer: Writes enemies, AI, levels, powerups
  - UI/Audio Developer: Writes menus, HUD, audio system

Then I'll integrate the code.

Actually, this is getting overcomplicated. Let me just spawn the agents with clear code-writing tasks and integration instructions, then I'll combine the outputs.

Let me take a simpler approach: spawn 2-3 agents to write different major sections, then I'll do the integration.

Wait - looking at this more carefully, the agents are going to write code independently. They won't have shared context. This means I need to provide very detailed specifications to each agent so their code integrates cleanly.

Let me define the architecture upfront and give each agent clear specs:

**Game: "Void Strikers" - Advanced Arcade Space Shooter**

Architecture (all in single HTML file):
```
HTML Structure:
  <canvas id="gameCanvas">
  <div id="ui-overlay"> (menus, HUD)

JS Architecture:
  - Config object (game settings)
  - InputManager (keyboard, mouse, touch)
  - Renderer (WebGL/Canvas2D hybrid)
  - ParticleSystem
  - Player
  - Enemy classes (5 types)
  - Projectile classes
  - PowerUp system
  - LevelManager
  - AIManager
  - UIManager
  - AudioManager
  - Game class (main loop, state machine)
```

Let me spawn agents to build different parts. Each agent returns their code as a string I can integrate.

But actually, this is going to be really hard to coordinate between multiple agents writing code that needs to work together. Let me take a different approach:

1. Spawn 1 main agent to write the COMPLETE game
2. Spawn a QA agent to test it
3. Spawn a design agent to provide the spec

This is more practical. Let me do this.

Actually let me use the team more effectively. Let me spawn:

1. **Design Spec Agent** - Research and return detailed game design
2. **Then** - Spawn multiple code agents with specific tasks based on the design

Let me start with the design agent and a couple of parallel agents.

Now let me spawn the game design agent and supporting specialists in parallel to build this game efficiently.

**Tool: team_spawn**

**Input:**
```json
{
  "name": "game-designer",
  "agent_type": "general",
  "role_prompt": "You are the Game Design Lead for \"Void Strikers\" — an advanced arcade-style space shooter. Your job is to produce a DETAILED game design document. Return ONLY the design document — no code. Include:\n\n1. GAME CONCEPT: Name, genre, setting, visual style\n2. CORE LOOP: Minute-by-minute gameplay flow\n3. PLAYER: Ship abilities, movement speed, weapons (primary auto-fire, secondary charged shot), max health, invulnerability frames\n4. ENEMY TYPES (5 types, with stats):\n   - Scout: fast, low HP, zigzag movement\n   - Fighter: medium speed, shoots at player\n   - Tank: slow, high HP, shoots spread pattern\n   - Sniper: stays at distance, precise shots\n   - Boss: appears at end of each level (3 levels), multiple phases\n5. POWER-UPS (4 types): health restore, shield, weapon upgrade (3 levels: single, double, spread), speed boost\n6. SCORING: Points per enemy kill, combo multiplier that decays, bonus for collecting power-ups at full power\n7. LEVELS (3 levels): Enemy composition, spawn rates, difficulty curve, boss stats\n8. DIFFICULTY PROGRESSION: How enemy count, speed, HP, and spawn rate increase per level\n9. WIN/FAILURE CONDITIONS\n10. PARTICLES & VFX: Explosions, trails, impacts, screen shake\n11. AUDIO CUES: What sounds for what actions\n12. UI ELEMENTS: HUD layout, menus needed\n13. CONTROLS: Keyboard, mouse, touch\n\nOutput format: structured text with clear section headers. Be specific with numbers (HP values, speeds, points, etc). This will be used by the dev team to build the game."
}
```

**Output:**
```
Teammate spawned: game-designer (ses_213716dc1ffeZxikseEms172AH) [general]
```

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 48.8s)

_Thinking:_

The game designer agent is working on the design document. While waiting, let me also spawn the other development agents that can start working in parallel. I'll spawn:

1. A rendering/systems agent to build the core engine
2. A gameplay/AI agent to build game logic

But I should wait for the design document before having them write actual game-specific code. Let me spawn agents that can work on the more generic parts while the designer is working.

Actually, let me spawn agents now with a clear concept already in mind - a space shooter. The design details will come from the designer, but the core engine structure (game loop, rendering, input, audio, UI) can be built independently.

Let me spawn agents for:
1. Core Engine + Rendering (WebGL/Canvas, game loop, input, particles)
2. Gameplay Systems (Player, Enemies, AI, Collisions, Projectiles)
3. UI + Audio (Menus, HUD, sound effects)

These can work in parallel. I'll provide each with enough context to build their part, and I as the lead will integrate them.

Actually, on second thought, since the game designer is already working, let me wait for their output before spawning the dev agents. The designer will return soon and I can use the spec to give precise instructions. This will result in better integration.

Let me check team messages once more to see if the designer has finished yet. But the system will wake me when they finish. Let me just wait for now.

Hmm, but I should be productive. Let me spawn the other agents now with a sufficiently detailed spec based on what I already described. The designer is just formalizing things. Let me go ahead and spawn 3 dev agents in parallel.

Let me define the shared API/interfaces that all agents must follow:

```javascript
// Shared globals
const CONFIG = { /* game config */ };
const canvas, ctx, gl;
const input = { keys: {}, mouse: {x:0,y:0,down:false} };
const gameState = { state: 'menu', score: 0, combo: 0, level: 1, ... };
const player = { x, y, vx, vy, hp, maxHp, weaponLevel, shield, speed, ... };
const enemies = [];
const projectiles = [];
const powerups = [];
const particles = [];
const stars = []; // background
```

Each agent writes a self-contained JS module in IIFE format that extends the shared namespace. I'll integrate them into one HTML file.

Let me spawn the agents now.

Actually, let me just wait for the game designer and then spawn coding agents with precise specs. That will produce better results. The game designer should finish within this message cycle or the next.

Let me check team messages.

Designer is working on the spec. Let me spawn the development agents in parallel so they can start by building framework-agnostic subsystems while the designer finalizes specifics.

**Tool: team_spawn**

**Input:**
```json
{
  "name": "rendering-engine",
  "agent_type": "general",
  "role_prompt": "You are the Rendering Engine Developer for \"Void Strikers\", a space shooter game that will be a single self-contained HTML file. Write ONLY JavaScript code for the rendering system. Your code must be production-quality with clear comments.\n\nARCHITECTURE: The game uses a shared global namespace. Your code will be merged into one file with other subsystems. Use the following globals (already declared elsewhere):\n- `canvas` — the HTML canvas element\n- `ctx` — 2D canvas context (we use Canvas2D for broad compatibility with WebGL-like effects via composition)\n- `CONFIG` — shared config object with game settings\n- `gameState` — { state: 'menu'|'playing'|'paused'|'gameover'|'victory', score, combo, level, ... }\n- `player`, `enemies`, `projectiles`, `powerups`, `particles` — game object arrays/objects\n- `deltaTime` — frame delta in seconds (provided by game loop)\n\nIMPLEMENT THESE RENDERING SYSTEMS:\n\n1. **Starfield Background**: Animated parallax starfield with 200+ stars at varying depths (3 layers), with slow drift and twinkling effect. Use particle-style rendering.\n\n2. **Player Ship Rendering**: Draw a stylized spaceship (geometric: triangles, trapezoids) with engine glow effect that pulses. Must show shield when active (glowing circle around ship). Support weapon upgrade visuals (additional barrel shapes when weapon level increases).\n\n3. **Enemy Rendering** (5 types — draw each as distinct geometric shapes):\n   - Scout: Small diamond with trail\n   - Fighter: Arrow/triangle shape with wings\n   - Tank: Large hexagon with armor plates\n   - Sniper: Thin elongated diamond with targeting line\n   - Boss: Large complex shape with multiple segments\n   Each enemy should have hit flash (white flash when damaged) and death explosion effect.\n\n4. **Projectile Rendering**: Player bullets (glowing cyan/blue orbs with trail), enemy bullets (red/orange), charged shot (large energy ball with pulsing aura), boss special attacks.\n\n5. **Particle System**: \n   - Explosion particles (expanding ring + sparks)\n   - Engine trail particles (continuous from player thrusters)\n   - Impact particles (when bullets hit)\n   - Screen shake effect (based on shakeIntensity/magnitude globals)\n   - Power-up sparkle/glow effect\n   All particles should support: position, velocity, color, size, lifetime, alpha fade\n\n6. **Lighting/Glow Effects**: Use canvas composite operations (lighter blending) and radial gradients for glow on projectiles, explosions, and power-ups. Implement a subtle vignette effect.\n\n7. **Background Effects**: Nebula-like color gradients that subtly shift, grid lines for space-station levels.\n\n8. **Responsive Scaling**: Function `resizeCanvas()` that handles window resize, maintains aspect ratio, and scales all rendering.\n\n9. **Camera System**: Smooth camera that follows player with slight lag, bounded to level area. Camera shake on explosions/damage.\n\nWrite your code as a self-contained JavaScript object/module pattern. Use clear comments before each major function. The module should expose methods like:\n- `Renderer.init()`\n- `Renderer.render()`, `Renderer.renderBackground()`, `Renderer.renderPlayer()`, `Renderer.renderEnemies()`, `Renderer.renderProjectiles()`, `Renderer.renderParticles()`, `Renderer.renderHUD()` (basic HUD rendering if needed)\n- `Renderer.resizeCanvas()`\n\nDO NOT write HTML or CSS. Write ONLY the JavaScript rendering code. Make it visually impressive with lots of glow, color, and particle effects."
}
```

**Output:**
```
Teammate spawned: rendering-engine (ses_21370af15ffeRa8cVU5O2Kspi1) [general]
```

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 41.8s)

_Thinking:_

Good, both agents are working. Let me now spawn the remaining agents for gameplay systems, UI/audio, and QA so they can all work in parallel while the designer finalizes the spec.

Let me spawn:
1. physics-gameplay - Player, enemies, collisions, projectiles, powerups, level progression
2. ui-audio - Menus, HUD, sound effects
3. qa-tester - Will test the integrated game later

I should also include more specific info since the designer hasn't finished yet, but I have enough context to give good instructions.

Good progress. Let me spawn the remaining specialists in parallel.

**Tool: team_spawn**

**Input:**
```json
{
  "agent_type": "general",
  "name": "physics-gameplay",
  "role_prompt": "You are the Physics & Gameplay Developer for \"Void Strikers\", an arcade space shooter game in a single HTML file. Write ONLY JavaScript code for gameplay systems. Production quality with clear comments.\n\nSHARED GLOBALS (already declared, do not redeclare):\n- `canvas`, `ctx` — canvas and 2D context\n- `CONFIG` — game configuration object\n- `gameState` — { state: 'menu'|'playing'|'paused'|'gameover'|'victory', score: 0, combo: 0, comboMultiplier: 1, comboTimer: 0, level: 1, shakeMagnitude: 0 }\n- `input` — { keys: {}, mouse: {x:0,y:0,down:false}, touches: [] }\n- `deltaTime` — frame time in seconds\n- `camera` — { x:0, y:0, targetX:0, targetY:0, shakeX:0, shakeY:0 }\n- `particles` — array of particle objects\n- `stars` — array of background star objects\n\nIMPLEMENT:\n\n1. **Player Class/Object**: \n   - x, y (position), vx, vy (velocity), width, height (collision box ~30px)\n   - hp: 100, maxHp: 100, shield: 0 (absorbs damage), speed: 350 px/s\n   - weaponLevel: 1-3 (1=single, 2=double, 3=triple spread)\n   - invulnerable: false, invulnerableTimer: 0 (2 seconds of invulnerability after hit)\n   - shootTimer: 0, shootCooldown: 0.15s (auto-fire)\n   - chargeLevel: 0, maxCharge: 100, charging: false (hold space for charged shot)\n   - Methods: update(dt), shoot(), takeDamage(amount), applyPowerUp(type), reset()\n\n2. **Enemy Class** (5 types + Boss):\n   - Base properties: x, y, vx, vy, width, height, hp, maxHp, speed, damage, scoreValue, type\n   - Type-specific: behavior pattern, shoot timer, phase\n   - Spawn system: spawnEnemy(type, x, y) factory function\n   - Enemy update method with per-type behavior\n   - Enemy shoot method\n   - Hit flash when damaged (set flashTimer)\n\n3. **Projectile System**:\n   - Player bullets: speed 600, damage 10, size 4, color cyan\n   - Enemy bullets: speed 300, damage 15, size 3, color red\n   - Charged shot: speed 400, damage 50, size 12, color white-blue, pierces 3 enemies\n   - Object pool for bullets (pre-create array of 200, reuse dead bullets)\n   - Methods: createBullet(x,y,vx,vy,damage,owner,color,size), updateBullets()\n\n4. **Power-Up System**:\n   - Types: health (+30hp), shield (+50 shield), weaponUp (increase weaponLevel, max 3), speedBoost (+100 speed, 5s duration)\n   - Spawned on enemy death (15% chance), slowly floats downward\n   - Glow and bob animation\n   - Methods: spawnPowerUp(x,y), updatePowerUps(), collectPowerUp(powerup, player)\n\n5. **Collision Detection**:\n   - AABB (axis-aligned bounding box) collision between all entities\n   - Player bullets vs enemies\n   - Enemy bullets vs player\n   - Player vs enemy (contact damage)\n   - Player vs power-ups\n   - Efficient: use simple distance/AABB checks, no spatial hashing needed for < 100 entities\n\n6. **Level System**:\n   - 3 levels with increasing difficulty\n   - Each level: spawn waves of enemies, boss at end\n   - Level config object with wave definitions\n   - Level transition with brief message, enemy clear, score bonus\n   - Win condition: defeat level 3 boss\n\n7. **Combo System**:\n   - Each enemy kill increases combo counter\n   - Combo multiplier: 1x base, 1.5x at 10 kills, 2x at 25, 3x at 50, 5x at 100\n   - Combo decays after 2 seconds without kill\n   - Visual feedback: combo text shows on kills\n\n8. **Game State Management**:\n   - Functions: startGame(), pauseGame(), resumeGame(), gameOver(), restartGame(), nextLevel()\n   - State transitions with proper cleanup\n\n9. **Screen Shake**: Apply to camera on explosions and player damage\n\n10. **Spawn Management**: Wave-based spawning with configurable intervals, spawn caps, and difficulty scaling\n\nWrite as a self-contained module. DO NOT write HTML/CSS. ONLY JavaScript gameplay code. Make combat feel satisfying with good feedback loops."
}
```

**Output:**
```
Teammate spawned: physics-gameplay (ses_213700bb8ffeqB52PNYvUwmaqw) [general]
```

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 39.1s)

_Thinking:_

Good, I now have 3 agents working:
1. game-designer - working on design doc
2. rendering-engine - working on rendering code
3. physics-gameplay - working on gameplay code

Let me spawn the UI/Audio agent and QA agent now.

**Tool: team_spawn**

**Input:**
```json
{
  "agent_type": "general",
  "name": "ui-audio",
  "role_prompt": "You are the UI & Audio Developer for \"Void Strikers\", an arcade space shooter in a single HTML file. Write JavaScript code for UI systems AND audio systems. Production quality with clear comments.\n\nSHARED GLOBALS (do not redeclare):\n- `canvas`, `ctx`\n- `gameState` — { state: 'menu'|'playing'|'paused'|'gameover'|'victory', score: 0, combo: 0, comboMultiplier: 1, level: 1, ... }\n- `player` — player object with hp, maxHp, shield, weaponLevel, speedBoost, chargeLevel, maxCharge\n- `CONFIG` — game config\n- `deltaTime`\n- `input` — { keys: {}, mouse: {x,y,down} }\n\nIMPLEMENT:\n\n## UI SYSTEM (all drawn on canvas, no HTML overlay needed — overlay via canvas is fine):\n\n1. **Main Menu**:\n   - Game title \"VOID STRIKERS\" with glowing pulsing text effect\n   - Animated starfield background behind menu\n   - \"PRESS ENTER TO START\" with blinking effect\n   - \"CONTROLS: Arrow/WASD = Move | Space = Charge Shot | P = Pause\"\n   - High score display (stored in localStorage)\n\n2. **Pause Menu**:\n   - \"PAUSED\" overlay with semi-transparent dark backdrop\n   - \"Press P to Resume\"\n   - \"Press R to Restart\"\n   - \"Press M for Main Menu\"\n\n3. **HUD (Heads-Up Display)** - shown during gameplay:\n   - Top-left: Score with combo multiplier indicator (e.g., \"SCORE: 12,450 x2.5\" with combo glow)\n   - Top-right: Level indicator \"LEVEL 1\"\n   - Bottom-left: Health bar (red/green gradient, animated, with numeric HP)\n   - Below health: Shield bar (blue, shown when shield > 0)\n   - Bottom-center: Charge meter (show when charging, 0-100% bar)\n   - Bottom-right: Weapon level indicator (icons showing current weapon)\n   - Speed boost timer indicator when active\n   - Combo counter popup (appears briefly on kills — \"COMBO x15!\")\n\n4. **Game Over Screen**:\n   - \"GAME OVER\" with dramatic styling\n   - Final score display with combo stats\n   - \"Press R to Restart\"\n   - \"Press M for Main Menu\"\n\n5. **Victory Screen**:\n   - \"VICTORY!\" with celebratory effects\n   - Final score, enemies destroyed, max combo stats\n   - \"Press R to Play Again\"\n\n6. **Level Transition**: \"LEVEL 2\" announcement with fade in/out\n\n7. **UI Helper Functions**:\n   - `drawText(text, x, y, size, color, align, glow)` — text with optional glow\n   - `drawBar(x, y, width, height, value, maxValue, color1, color2)` — animated bar\n   - `drawButton(x, y, width, height, text)` — interactive button\n   - Text measuring and centering utilities\n\n## AUDIO SYSTEM (Web Audio API):\n\n8. **AudioContext Manager**: \n   - Create and resume AudioContext on first user interaction\n   - Master volume control\n   - Mute/unmute toggle (M key)\n\n9. **Sound Effect Synthesizer** (procedural audio using oscillators — no external files):\n   - `playShoot()` — short high-frequency blip (sine wave, quick decay)\n   - `playEnemyShoot()` — lower, rougher blip\n   - `playExplosion()` — noise burst + low rumble (white noise with bandpass filter, decaying)\n   - `playHit()` — impact sound (short noise burst)\n   - `playPowerUp()` — rising arpeggio (3 quick ascending notes)\n   - `playPlayerHit()` — low thud + alarm\n   - `playChargedShot()` — rising pitch sweep then release\n   - `playMenuSelect()` — UI click\n   - `playMenuHover()` — soft tick\n   - `playGameOver()` — descending tones\n   - `playVictory()` — triumphant ascending arpeggio\n   - `playBossWarning()` — pulsing low tone\n   - `playComboUp()` — pitch increases with combo level\n   - `playShieldBreak()` — shatter sound (noise + high pitch)\n\n10. **Background Music Generator** (procedural):\n    - Simple looping bass pattern using oscillators\n    - Tempo increases slightly per level\n    - Drone/pad in background using low-frequency triangle waves\n    - Music intensity changes based on enemy count (more enemies = more layers)\n\nWrite as module `UIManager` and `AudioManager`. DO NOT write HTML/CSS. ONLY JavaScript. Make the UI look polished with glowing text effects, smooth bar animations, and nice transitions."
}
```

**Output:**
```
Teammate spawned: ui-audio (ses_2136f72feffebSFkQoBgsRYRE3) [general]
```

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 27.5s)

_Thinking:_

All 4 agents are now spawned:
1. game-designer (ses_213716dc1ffeZxikseEms172AH) - Design document
2. rendering-engine (ses_21370af15ffeRa8cVU5O2Kspi1) - Rendering code
3. physics-gameplay (ses_213700bb8ffeqB52PNYvUwmaqw) - Gameplay code
4. ui-audio (ses_2136f72feffebSFkQoBgsRYRE3) - UI and Audio code

Now I should wait for them to finish their work. Let me check for any messages. The system will wake me when they send messages.

Let me just communicate the current status to the user and wait for the agents to deliver their work.

Actually, I should also spawn the QA tester now — they can start even without the code by knowing what to look for.

All 4 specialists are working in parallel. Let me also spawn the QA tester now so they're ready to verify the integrated game.

**Tool: team_spawn**

**Input:**
```json
{
  "agent_type": "general",
  "name": "qa-tester",
  "role_prompt": "You are the QA Tester for \"Void Strikers\", an arcade space shooter being built as a single HTML file with JavaScript. You will receive the complete game code later. For now, prepare by documenting what you will test.\n\nYour testing checklist (return this as structured output):\n\n1. **Browser Compatibility**: The game should work in Chrome, Firefox, Safari, Edge\n2. **Game States**: Test all state transitions (menu→playing→paused→gameover→menu, menu→playing→victory→menu)\n3. **Controls**: WASD and arrow keys for movement, Space for charge shot, P for pause, R for restart, M for mute\n4. **Touch Controls**: Mobile touch should work (virtual joystick or tap controls)\n5. **Player Systems**: Movement feels responsive, auto-fire works, charge shot charges and fires, health decreases on hit, invulnerability frames after hit, shield absorbs damage\n6. **Enemy AI**: All 5 types behave differently (scout zigzags, fighter pursues and shoots, tank slow/tanky, sniper keeps distance, boss has phases)\n7. **Collision Detection**: Player bullets hit enemies, enemy bullets hit player, player-enemy contact damage, power-up collection\n8. **Scoring & Combo**: Score increments on kills, combo multiplier increases and decays correctly\n9. **Level Progression**: Wave spawning works, boss appears at end, level transitions work, difficulty increases across 3 levels\n10. **Power-Ups**: Health, shield, weapon upgrade, speed boost all function correctly\n11. **Particles & VFX**: Explosions, trails, screen shake, glow effects all render\n12. **UI**: Main menu, pause menu, HUD (health, score, combo, charge, weapon level), game over, victory screens\n13. **Audio**: Sound effects play for actions, background music plays, mute toggle works\n14. **Performance**: 60fps target, no memory leaks (check over time), no frame drops during heavy action\n15. **Edge Cases**: Rapid pause/unpause, rapid restart, multiple power-ups at once, many enemies on screen, browser resize, tab switching\n16. **Game Balance**: Is the game winnable? Is it too easy/hard? Are enemy patterns fair?\n17. **Restart Behavior**: All state properly resets on restart\n\nReturn this as a structured QA checklist. When the game code is ready, you will be asked to review it against this checklist."
}
```

**Output:**
```
Teammate spawned: qa-tester (ses_2136f0795ffeGHa1759VEvw1G8) [general]
```

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 8.5s)

_Thinking:_

All 5 agents are now spawned:
1. game-designer - design document
2. rendering-engine - rendering code
3. physics-gameplay - gameplay code
4. ui-audio - UI and audio code
5. qa-tester - QA checklist

Now I should wait for them to finish. Let me provide a status update to the user and then wait for agent messages.

All 5 specialists are working in parallel:

| Agent | Role | Status |
|-------|------|--------|
| `game-designer` | Game design document | Working |
| `rendering-engine` | WebGL/Canvas rendering | Working |
| `physics-gameplay` | Gameplay & physics systems | Working |
| `ui-audio` | UI menus, HUD, procedural audio | Working |
| `qa-tester` | QA testing checklist | Working |

Once each agent delivers their code, I'll integrate everything into a single playable HTML file. Waiting for their results now.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
No pending messages.
Check complete. If teammates are still active, end this turn instead of polling.
Team messages are delivered asynchronously; busy teammates can only process broadcasts or direct messages at their next prompt boundary.
Do not send routine status-check broadcasts just because the mailbox is empty. Teammates will wake you when they have progress, blockers, or results.

Current team status:
- qa-tester (general, active, session ses_2136f0795ffeGHa1759VEvw1G8)
- ui-audio (general, active, session ses_2136f72feffebSFkQoBgsRYRE3)
- physics-gameplay (general, active, session ses_213700bb8ffeqB52PNYvUwmaqw)
- rendering-engine (general, active, session ses_21370af15ffeRa8cVU5O2Kspi1)
- game-designer (general, active, session ses_213716dc1ffeZxikseEms172AH)
```

---

## Assistant (Build · DeepSeek V4 Pro · 3.1s)

_Thinking:_

No messages yet - all agents are still working. I should wait for them to finish. The system will wake me when they send messages. Let me end my turn here and wait.

All agents are actively working. Waiting for their results — they'll notify me when ready.

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 3.6s)

_Thinking:_

The QA tester sent a progress update. Still waiting for the actual deliverables. Let me just wait for the agents to finish and send their results.

Acknowledged. Awaiting the completed deliverables from all agents.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
No pending messages.
Check complete. If teammates are still active, end this turn instead of polling.
Team messages are delivered asynchronously; busy teammates can only process broadcasts or direct messages at their next prompt boundary.
Do not send routine status-check broadcasts just because the mailbox is empty. Teammates will wake you when they have progress, blockers, or results.

Current team status:
- qa-tester (general, active, session ses_2136f0795ffeGHa1759VEvw1G8)
- ui-audio (general, active, session ses_2136f72feffebSFkQoBgsRYRE3)
- physics-gameplay (general, active, session ses_213700bb8ffeqB52PNYvUwmaqw)
- rendering-engine (general, active, session ses_21370af15ffeRa8cVU5O2Kspi1)
- game-designer (general, active, session ses_213716dc1ffeZxikseEms172AH)
```

---

## Assistant (Build · DeepSeek V4 Pro · 2.8s)

_Thinking:_

Still waiting for agents to finish. Let me end turn and wait.

Still in progress. Waiting for agent deliverables.

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 3.0s)

_Thinking:_

Progress update from physics-gameplay. Still waiting for actual code deliverables from all agents. Let me check if there are more messages.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
From game-designer (ses_213716dc1ffeZxikseEms172AH):
Teammate game-designer (general) completed and returned this result:

<teammate_result>
# VOID STRIKERS — GAME DESIGN DOCUMENT

---

## 1. GAME CONCEPT

- **Name:** Void Strikers
- **Genre:** Top-down vertical-scrolling arcade space shooter (bullet hell / danmaku-lite)
- **Setting:** Deep space, the "Void Expanse" — a hostile nebula rift filled with derelict alien war fleets. The player is the last pilot of the Strikers Guild, flying the experimental "Aether Hawk" starfighter to shut down the Void Core before it consumes the galaxy.
- **Visual Style:** Neon-on-black sci-fi aesthetic. Dark starfield background with parallax dust layers. Player/enemy ships use crisp geometric silhouettes with emissive glow (cyan for player, warm colors for enemies). Projectiles are bright geometric shapes with bloom halos. Particles use high-contrast additive blending. Faux-bloom via stacked semi-transparent sprites. 60 FPS target.

---

## 2. CORE LOOP (Minute-by-Minute)

| Time  | Phase                | Activity |
|-------|----------------------|----------|
| 0:00  | Level Start          | Player warps in from top. Brief text overlay: "WAVE X". 1.5s countdown before enemies spawn. |
| 0:02  | Scout Wave           | Groups of 3–5 Scouts enter in zigzag formation from top/sides. Easy combo building. |
| 0:10  | Fighter Wave         | Fighters enter in V-formations of 2–3, firing aimed single shots. Mix Scouts for variety. |
| 0:20  | Power-Up Drop        | Guaranteed power-up from a marked "carrier" enemy (glowing). Weapon upgrade or shield. |
| 0:25  | Tank + Sniper Pairs  | 1 Tank escorted by 2 Fighters. 1 Sniper sits at screen edge. Introduces multi-threat coordination. |
| 0:40  | Mixed Swarm          | 5 Scouts + 3 Fighters + 1 Tank simultaneously. Tests crowd control. |
| 0:55  | Calm Pause           | 5s breather — no enemies, starfield slows, ambient hum. Power-up spawns if player HP < 50%. |
| 1:00  | Boss Warning         | Screen-edge VFX, "WARNING" text pulses for 2s. |
| 1:02  | Boss Fight           | Multi-phase boss battle (see §4, §7). |
| 1:30+ | Victory / Transition | Score tally, combo bonus, "WARP TO NEXT SECTOR" or "GAME OVER". |

Loop repeats for Levels 2 and 3 with increased density and new enemy patterns.

---

## 3. PLAYER — AETHER HAWK

| Property              | Value                        |
|-----------------------|------------------------------|
| Max HP                | 5 (represented as 5 shield pips) |
| Invulnerability Frames| 1.5s on hit, with rapid flashing of ship sprite |
| Movement Speed        | 6 px/frame base (~360 px/s at 60 FPS) |
| Hitbox                | Small circle (6px diameter) at ship center — forgiving |
| Primary Weapon (auto) | Single-forward pulse cannon. Auto-fires every 0.15s (400 RPM). 1 damage per shot. Infinite ammo. |
| Secondary (charged)   | Hold [charge key] to charge. 3 charge levels based on hold duration: |
|                       | - Lv1 (0.5s): Energy bolt — 3 damage, penetrates 1 enemy, travels to top of screen |
|                       | - Lv2 (1.2s): Void lance — 8 damage, full-screen pierce, 20px wide beam |
|                       | - Lv3 (2.0s): Nova blast — screen-clearing 15 damage AOE ring expanding from player |
|                       | Releasing any charge fires immediately at current level. Must wait 3s cooldown after Lv2/Lv3 before recharging. |
| Visual                | Ship is ~40x48px. Three animation frames for idle thruster flicker. Banking sprite offsets on horizontal movement. |

---

## 4. ENEMY TYPES

### 4.1 SCOUT
| Stat          | Value                      |
|---------------|----------------------------|
| HP            | 1                          |
| Speed         | 5 px/frame                 |
| Movement      | Sine-wave zigzag (amplitude 40px, frequency 3Hz) |
| Damage to player | 1 (contact only)        |
| Points        | 100                        |
| Spawn         | Groups of 3–8, top/side edges |
| Visual        | Small diamond shape (16x16px), warm-yellow glow, thin motion trail |

### 4.2 FIGHTER
| Stat          | Value                      |
|---------------|----------------------------|
| HP            | 3                          |
| Speed         | 2.5 px/frame               |
| Movement      | Descends, then hovers at y=100–200, strafes slowly left-right |
| Attack        | Fires single aimed shot at player every 2s (projectile speed 4 px/frame, 1 damage) |
| Damage to player | 1 (contact)             |
| Points        | 250                        |
| Spawn         | V-formations of 2–4        |
| Visual        | Twin-wing silhouette (28x28px), orange-red glow, muzzle flash on fire |

### 4.3 TANK
| Stat          | Value                      |
|---------------|----------------------------|
| HP            | 10 (Level 1) / 15 (Lv2) / 20 (Lv3) |
| Speed         | 1.2 px/frame               |
| Movement      | Slow straight descent to y=200, then holds position, slight wobble |
| Attack        | 5-shot spread every 2.5s (fan at -30°, -15°, 0°, +15°, +30° from player direction). Projectile speed 3 px/frame, 1 damage each. |
| Damage to player | 2 (contact)             |
| Points        | 500                        |
| Spawn         | Solo or paired with 2 Fighters |
| Visual        | Large hexagonal hull (48x48px), red-magenta glow, armor plate overlay. Screen flashes slightly on entry. |

### 4.4 SNIPER
| Stat          | Value                      |
|---------------|----------------------------|
| HP            | 4                          |
| Speed         | 1.5 px/frame               |
| Movement      | Enters from side, stays at x=40–60 or x=580–600 (screen edge), drifts vertically |
| Attack        | Fires high-speed precision shot every 3s (speed 8 px/frame, 1 damage). Laser sight telegraph (thin red line for 0.8s before firing). |
| Points        | 350                        |
| Spawn         | Solo, always at screen edges |
| Visual        | Narrow needle-like ship (12x40px), white-blue glow, visible laser sight line pre-fire |

### 4.5 BOSS — VOID WARDEN (Level 1) / VOID SENTINEL (Lv2) / VOID OVERLORD (Lv3)
| Stat                   | Lv1 Warden | Lv2 Sentinel | Lv3 Overlord |
|------------------------|-----------|-------------|-------------|
| HP                     | 80        | 150         | 250         |
| Speed                  | 2         | 2.5         | 3           |
| Phases                 | 2         | 3           | 4           |
| Contact Damage         | 3         | 4           | 5           |
| Points                 | 5000      | 10000       | 20000       |
| Size                   | 120x120px | 140x140px   | 160x160px   |

**Phase Mechanics:**
- **Lv1 Warden — Phase 1 (HP 80–41):** Slow horizontal patrol, fires 3-way aimed spreads every 1.5s. Two invulnerable orbiting shield drones that block shots.
- **Lv1 Warden — Phase 2 (HP 40–0):** Drones destroyed. Boss speeds up 50%. Fires rotating spiral pattern (8 bullets, rotates 30° per volley, 1s interval). Screen shake on phase transition.
- **Lv2 Sentinel — Phase 1 (HP 150–101):** Alternates between bullet ring burst (12 radial bullets) and aimed triple-shot. Moves in smooth sine path.
- **Lv2 Sentinel — Phase 2 (HP 100–51):** Adds laser sweep — horizontal beam that sweeps top half of screen. Player must stay in safe zone (bottom). Beam does 2 damage/tick.
- **Lv2 Sentinel — Phase 3 (HP 50–0):** Enrages — all cooldowns halved. Summons 2 Fighters as adds every 10s.
- **Lv3 Overlord — Phase 1 (HP 250–176):** Full-screen bullet curtain (dense but slow, 2 px/frame). Homing missiles (3 per volley, track player for 3s).
- **Lv3 Overlord — Phase 2 (HP 175–101):** Criss-cross laser grid (4 overlapping beams rotating). Safe gaps between beams.
- **Lv3 Overlord — Phase 3 (HP 100–51):** Summons 2 Tanks. Boss teleports to random positions every 3s.
- **Lv3 Overlord — Phase 4 (HP 50–0):** All patterns combined at 1.5x speed. Desperation mode. Screen border crackles with energy VFX.

---

## 5. POWER-UPS

All power-ups drift downward at 1.5 px/frame after being dropped by destroyed enemies (10% drop chance from Fighters/Tanks/Snipers, guaranteed from "carrier" Scouts). Pickup range: 30px from player center. Power-ups flash for last 3s before expiring (8s total lifetime).

| Power-Up          | Color      | Symbol | Effect |
|-------------------|-----------|--------|--------|
| **Shield Restore** | Green     | ⊕      | Restores 1 HP. Cannot exceed max (5). If at full HP: +200 bonus points. |
| **Energy Shield**  | Blue      | ◈      | Temporary invulnerability for 5s. Flashing blue aura around ship. Does not stack — picking up another resets timer to 5s. |
| **Weapon Upgrade** | Orange    | ⇧      | Levels: Lv1 (default single shot), Lv2 (twin parallel shots, 16px apart), Lv3 (3-way spread: -10°, 0°, +10°). Upgrade advances 1 level per pickup. If already Lv3: +500 bonus points. Weapon level lost on death, resets to Lv1. |
| **Speed Boost**    | Yellow    | ↟      | +40% movement speed for 8s. Stacks duration — picking up another extends timer by 8s. Max buff duration 16s. If already at max duration: +300 bonus points. |

---

## 6. SCORING

| Event                        | Points        |
|------------------------------|---------------|
| Scout kill                   | 100           |
| Fighter kill                 | 250           |
| Tank kill                    | 500           |
| Sniper kill                  | 350           |
| Boss kill                    | 5000 / 10000 / 20000 (per level) |
| Full-HP power-up bonus       | +200          |
| Max-weapon power-up bonus    | +500          |
| Max-speed power-up bonus     | +300          |

**Combo Multiplier:**
- Kill an enemy: combo +1.
- Combo multiplier = `max(1, floor(combo / 5) + 1)`. So: 0–4 kills = 1x, 5–9 = 2x, 10–14 = 3x, 15–19 = 4x, 20+ = 5x (cap).
- Combo decays: loses 1 combo count per 2 seconds without a kill (grace period 2s). Dropping below a threshold reduces multiplier.
- On player death: combo resets to 0.
- Boss kills award a flat 2x multiplier bonus for the kill (does not stack with combo — whichever is higher).
- Score display: runs combo counter and multiplier next to score in HUD, gives "+COMBO X5" flash text on kill streaks.

**End-of-Level Bonus:**
- HP remaining: +1000 per HP pip
- Shield active at level end: +500
- Clear time bonus: base 3000, -100 per second over 90s (Level 1), 120s (Lv2), 150s (Lv3). Minimum 500.

---

## 7. LEVELS

### 7.1 LEVEL 1 — "The Outer Rift"
- **Enemy Composition:** Scouts 60%, Fighters 25%, Tanks 10%, Snipers 5%
- **Total Enemies:** ~45 (including boss)
- **Spawn Rate:** New group every 3–5s
- **Boss:** Void Warden (see §4.5)
- **Difficulty:** Tutorial-friendly. Slower bullets (3 px/frame). Telegraphed attacks. Guaranteed +1 HP power-up before boss.

### 7.2 LEVEL 2 — "Nebula Core"
- **Enemy Composition:** Scouts 40%, Fighters 30%, Tanks 20%, Snipers 10%
- **Total Enemies:** ~65
- **Spawn Rate:** New group every 2.5–4s
- **Boss:** Void Sentinel (see §4.5)
- **Difficulty:** Bullet speed increased to 4 px/frame. Fighters fire in bursts of 2. Tanks have +50% HP (15). Sniper telegraph reduced to 0.6s.

### 7.3 LEVEL 3 — "The Void Heart"
- **Enemy Composition:** Scouts 30%, Fighters 30%, Tanks 25%, Snipers 15%
- **Total Enemies:** ~85
- **Spawn Rate:** New group every 2–3s
- **Boss:** Void Overlord (see §4.5)
- **Difficulty:** Bullet speed at 5 px/frame. Fighters fire in bursts of 3. Tank spread widened to 7 shots (-45° to +45° range). Snipers fire every 2s. Enemies have +25% HP floor (Scout stays 1).

---

## 8. DIFFICULTY PROGRESSION TABLE

| Parameter          | Level 1 | Level 2 | Level 3 |
|-------------------|---------|---------|---------|
| Enemy HP multiplier | 1.0x   | 1.3x    | 1.6x    |
| Enemy speed mult.  | 1.0x   | 1.15x   | 1.3x    |
| Bullet speed (px/f) | 3      | 4       | 5       |
| Spawn interval (s)  | 3–5    | 2.5–4   | 2–3     |
| Max enemies on screen | 10   | 14      | 18      |
| Scout group size     | 3–5   | 4–7     | 5–8     |
| Fighter group size   | 2–3   | 3–4     | 3–5     |
| Tank HP              | 10    | 15      | 20      |
| Sniper fire interval (s) | 3 | 2.5    | 2       |
| Boss HP              | 80    | 150     | 250     |
| Boss phases          | 2     | 3       | 4       |

---

## 9. WIN / FAILURE CONDITIONS

**Failure:** Player HP reaches 0. Trigger death animation (ship breaks apart, screen flash, 1.5s pause). Show "GAME OVER" screen with:
- Final score
- Enemies destroyed
- Level reached
- "RETRY" and "MAIN MENU" buttons

**Win:** Defeat Level 3 Void Overlord boss. Trigger victory cinematic:
- Boss explosion VFX chain
- Slow-motion effect (0.3x speed for 3s)
- Score tally animation
- "YOU SAVED THE VOID" title card
- Final score with combo/hp/time bonuses totaled
- "PLAY AGAIN" and "MAIN MENU" buttons

**Lives / Continues:** No continues. Single-ship run. Losing means restarting from Level 1. Design intent: each run is ~5–8 minutes total. Short enough for "one more try" arcade feel.

---

## 10. PARTICLES & VFX

| Effect             | Trigger                     | Visual Description |
|--------------------|-----------------------------|--------------------|
| **Enemy Death Pop** | Any enemy destroyed        | 8–16 particles, enemy's color palette, random velocity (2–4 px/frame), fade over 0.4s, scale 0.5→0 |
| **Boss Explosion**  | Boss phase transition & death | Multi-stage: expanding ring (6 concentric circles, stagger 0.1s each), 40+ fragment particles, screen flash white→transparent over 0.3s |
| **Bullet Impact**   | Bullet hits enemy          | 3–4 spark particles at impact point, white→color, 0.2s life |
| **Player Hit Flash**| Player takes damage        | Screen border flashes red, ship flashes rapidly for iframe duration |
| **Player Death**    | HP reaches 0               | Ship breaks into 12 debris pieces, each with rotation + velocity. Expanding blue-white shockwave ring. Camera shake 8px amplitude for 0.5s. |
| **Weapon Trail**    | Player primary fire        | Thin cyan line trailing each bullet (6px long, fades behind) |
| **Charge Glow**     | Player charging secondary  | Expanding concentric circles at ship center, intensifying with charge level (cyan→white), particle accretion toward ship |
| **Nova Blast**      | Lv3 charge release         | Full-screen expanding ring (cyan-white), 30+ starburst particles, 0.5s screen shake (4px amplitude) |
| **Power-Up Trail**  | Power-up drifting          | 3–4 upward-rising sparkles in power-up's color, sine offset |
| **Shield Aura**     | Energy shield active       | Rotating hex-grid dome effect (blue, alpha 0.3), pulses on incoming damage |
| **Thruster Exhaust**| Player movement            | Flickering 2-frame orange-to-transparent gradient cone behind ship |
| **Screen Shake**    | Boss entry, player death, nova blast | Offset camera by `sin(time * 40) * amplitude`, amplitude decays over duration |

**Particle System Notes:**
- Use object pooling (pre-allocate 500 particles, recycle).
- All particles use additive blending (`globalCompositeOperation: 'lighter'`).
- Particle struct: `{ x, y, vx, vy, life, maxLife, size, color, alpha }`.

---

## 11. AUDIO CUES

All sounds generated procedurally via Web Audio API oscillators + noise (no external files). Use gain envelopes for articulation.

| Action                    | Sound Design                                              |
|---------------------------|-----------------------------------------------------------|
| Player primary fire       | Short square-wave blip, 800Hz→600Hz, 0.05s, low volume    |
| Player charge (holding)   | Rising sine tone 200Hz→800Hz over charge duration, with subtle vibrato |
| Player charge Lv1 release | White noise burst + 600Hz sine, 0.1s                       |
| Player charge Lv2 release | Low-frequency thump (80Hz sine 0.15s) + noise whoosh       |
| Player charge Lv3 release | Deep rumble (40Hz sawtooth, 0.3s) + long noise explosion   |
| Player hit                | Harsh noise burst, 0.1s, with 200Hz undertone. Pitch drops.|
| Player death              | Descending tone sweep 1000Hz→50Hz over 1s, layered with crackle |
| Enemy shoot               | Short triangle wave blip, 400Hz, 0.03s (different pitch per enemy type) |
| Scout death               | Quick 1000Hz→200Hz sweep, 0.1s                             |
| Fighter death             | Metallic ping: 1200Hz + 1400Hz sine, 0.15s                |
| Tank death                | Low explosion: deep noise burst 0.3s + 60Hz rumble         |
| Sniper death              | Sharp crack: 2000Hz→1000Hz fast sweep, 0.08s              |
| Boss phase transition     | Rising siren: 300Hz→900Hz sawtooth over 0.5s               |
| Boss death                | Chain of 5 explosions (0.1s apart), each at descending pitch |
| Power-up pickup           | Ascending 3-note arpeggio (C5→E5→G5), 0.15s total         |
| Shield activate           | Smooth 400Hz→600Hz sine swell, 0.2s                        |
| Shield deplete warning    | Rapid beeps: 800Hz, 0.05s each, 3 beeps                    |
| Combo milestone (x5, x10, etc.) | Rising chime: sine chord sweep, 0.3s                |
| Level start               | Descending 5-note fanfare (G4→E4→C4→G3→C3), 0.8s          |
| Victory                   | Major chord progression (C→F→G→C over 2s), with shimmer    |
| Game over                 | Slow minor chord fade (Am→Em, 2s), with static noise       |
| Menu select               | Soft click: 1000Hz sine, 0.02s                             |
| Menu confirm              | Two-tone: 800Hz→1200Hz, 0.1s                               |

**Audio Mix:**
- Master volume: 0.7
- SFX volume: 0.8
- Music (ambient drone): Continuous low-frequency pad (filtered sawtooth, slow LFO on filter cutoff). Volume 0.15. Pitch rises subtly with level progression.

---

## 12. UI ELEMENTS

### 12.1 HUD (In-Game Overlay, always visible)

| Element                | Position         | Description |
|------------------------|------------------|-------------|
| **Score**              | Top-left         | Large white text. Current score with combo multiplier parenthetical: `12,450 (x3)` |
| **Combo Counter**      | Below score      | Smaller text: `COMBO: 14`. Pulses on increment. Color shifts: white→yellow→orange→red as combo rises. |
| **HP Pips**            | Top-right        | 5 circular pips (filled cyan = full, empty outline = lost). Animate drain on hit. |
| **Weapon Level**       | Below HP         | Icon showing bullet count: `●`, `●●`, `●●●`. Color: orange. |
| **Charge Meter**       | Center-bottom    | Thin horizontal bar under player. Fills left→right as charge builds. Segments for Lv1/Lv2/Lv3 thresholds. Glows when ready. |
| **Shield Timer**       | Around HP pips   | Ring around HP section that depletes clockwise. Blue arc. |
| **Speed Boost Timer**  | Left of weapon icon | Small yellow bar, depletes horizontally. |
| **Boss HP Bar**        | Top-center       | Only visible during boss fights. Red bar with boss name. Phase markers (vertical ticks) on bar. |
| **Boss Name**          | Above boss bar   | White text, e.g. "VOID WARDEN" |
| **Wave Announcement**  | Center-screen    | Fades in/out: "WAVE 1" in large stylized text, 2s display |
| **Warning Indicator**  | Screen edges     | Red pulsing border on boss entry, sniper laser lock |

### 12.2 Menus

**Main Menu:**
- Game title "VOID STRIKERS" with animated starfield background
- "START GAME" button
- "HOW TO PLAY" button (opens controls/mechanics overlay)
- "HIGH SCORES" (localStorage top 5)
- Mute toggle (speaker icon)
- Version number bottom-right

**Pause Menu (ESC key / P):**
- Semi-transparent dark overlay (alpha 0.7)
- "RESUME", "RESTART", "MAIN MENU"
- Current score displayed
- Game time pauses completely

**Game Over Screen:**
- "GAME OVER" title
- Final score breakdown: kills × points + combo bonus + time bonus + HP bonus
- Enemies destroyed count
- "RETRY" (restarts Level 1)
- "MAIN MENU"

**Victory Screen:**
- "VOID CLEANSED" title
- Total score with animated tally
- Stats: enemies killed, max combo, time played, HP remaining
- "PLAY AGAIN", "MAIN MENU"

**How to Play Screen:**
- Controls diagram
- Enemy type gallery with short descriptions
- Power-up explanations
- Scoring and combo explanation
- Back button

---

## 13. CONTROLS

### 13.1 Keyboard (Primary)
| Key              | Action                          |
|------------------|---------------------------------|
| Arrow Keys / WASD| Move ship (8-directional)       |
| Space / Z        | Fire secondary (hold to charge, release to fire) |
| P / Escape       | Pause / Unpause                 |
| Enter            | Confirm menu selection          |
| Primary weapon   | Always auto-fires — no key needed |

### 13.2 Mouse
| Action           | Binding                    |
|------------------|----------------------------|
| Move             | Mouse position = ship position (ship follows cursor, clamped to game canvas bounds) |
| Charge + Fire    | Left mouse button (hold = charge, release = fire secondary) |
| Primary weapon   | Always auto-fires          |

### 13.3 Touch (Mobile)
| Action               | Binding                                              |
|----------------------|------------------------------------------------------|
| Move                 | Touch & drag — ship follows finger (offset so finger doesn't obscure ship — ship rendered 40px above touch point) |
| Charge + Fire        | Second finger (or dedicated charge button bottom-right of screen) — hold = charge, release = fire |
| Primary weapon       | Always auto-fires                                    |
| Pause                | Pause button top-right corner (40x40px touch target) |

**Touch Note:** Render virtual controls semi-transparent. Charge button: 60x60px circle, bottom-right. Pause: 40x40px icon, top-right. Both hidden after 3s of no touch input (reappear on tap).

---

## DESIGN NOTES FOR DEV TEAM

- **Canvas size:** 640x960 (portrait 2:3 ratio). Scale to fit viewport maintaining aspect ratio. Use CSS `image-rendering: pixelated` for crisp scaling.
- **Game Loop:** Fixed timestep at 60 FPS using `requestAnimationFrame` with delta-time accumulator. All speeds/cooldowns defined per-frame — convert to dt-based for consistent behavior on variable refresh rates.
- **State Machine:** MENU → PLAYING → PAUSED → GAMEOVER / VICTORY → MENU
- **Collision:** Circle-circle for all entities. Player hitbox is small circle. Enemy hitboxes are their sprite bounding circle scaled to 0.7. Bullet hitboxes are point-to-circle.
- **Object Pools:** Bullets (200), enemies (30 alive max), particles (500), power-ups (10). Recycle aggressively.
- **Spawn System:** Queue-based. Spawner reads from level definition JSON-like config. Tracks elapsed time, spawns waves at timed intervals with randomized position offsets.
- **Performance Budget:** < 2ms per frame for game logic + < 3ms for rendering. Target 60 FPS on mid-range mobile devices.

---

**Document Version:** 1.0 | **Status:** Ready for development handoff
</teammate_result>
```

---

## Assistant (Build · DeepSeek V4 Pro · 5.5s)

_Thinking:_

The game designer has completed the design document. This is very detailed and comprehensive. Now I need to wait for the other agents to finish their work:
1. rendering-engine - still working
2. physics-gameplay - still working  
3. ui-audio - still working
4. qa-tester - still working

Let me check for more messages to see if any others have completed.

Design document is complete. Detailed spec covers all 13 sections. Waiting for the remaining 4 agents to deliver their code modules.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
No pending messages.
Check complete. If teammates are still active, end this turn instead of polling.
Team messages are delivered asynchronously; busy teammates can only process broadcasts or direct messages at their next prompt boundary.
Do not send routine status-check broadcasts just because the mailbox is empty. Teammates will wake you when they have progress, blockers, or results.

Current team status:
- qa-tester (general, active, session ses_2136f0795ffeGHa1759VEvw1G8)
- ui-audio (general, active, session ses_2136f72feffebSFkQoBgsRYRE3)
- physics-gameplay (general, active, session ses_213700bb8ffeqB52PNYvUwmaqw)
- rendering-engine (general, active, session ses_21370af15ffeRa8cVU5O2Kspi1)
- game-designer (general, completed, session ses_213716dc1ffeZxikseEms172AH)
```

---

## Assistant (Build · DeepSeek V4 Pro · 3.0s)

_Thinking:_

The game designer is done. 4 other agents are still active. Let me wait for them.

Game designer is done. 4 agents still building their modules — awaiting their results.

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 5.1s)

_Thinking:_

QA tester has completed their checklist. Now I'm waiting for:
- rendering-engine - still working
- physics-gameplay - still working  
- ui-audio - still working

The game-designer and qa-tester are done. Let me check for more messages.

QA checklist complete — covers all 17 testing areas. Still waiting for rendering, physics, and UI/audio modules.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
No pending messages.
Check complete. If teammates are still active, end this turn instead of polling.
Team messages are delivered asynchronously; busy teammates can only process broadcasts or direct messages at their next prompt boundary.
Do not send routine status-check broadcasts just because the mailbox is empty. Teammates will wake you when they have progress, blockers, or results.

Current team status:
- qa-tester (general, completed, session ses_2136f0795ffeGHa1759VEvw1G8)
- ui-audio (general, active, session ses_2136f72feffebSFkQoBgsRYRE3)
- physics-gameplay (general, active, session ses_213700bb8ffeqB52PNYvUwmaqw)
- rendering-engine (general, active, session ses_21370af15ffeRa8cVU5O2Kspi1)
- game-designer (general, completed, session ses_213716dc1ffeZxikseEms172AH)
```

---

## Assistant (Build · DeepSeek V4 Pro · 2.7s)

_Thinking:_

2 completed (game-designer, qa-tester), 3 still active. Let me wait.

2/5 complete. Awaiting the 3 remaining code modules.

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 5.4s)

_Thinking:_

Rendering engine is done! They wrote a file at /Users/srpanwar/Documents/Workspace/brain/temp/renderer.js. Let me wait for the other two agents (physics-gameplay and ui-audio) to finish. But I could also read the renderer.js file now to start understanding it.

Actually, let me wait for all agents to finish before reading any code. Let me check more messages.

Rendering engine delivered. Let me check for the other agents' results.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
From rendering-engine (ses_21370af15ffeRa8cVU5O2Kspi1):
Teammate rendering-engine (general) completed and returned this result:

<teammate_result>
Rendering engine complete at `renderer.js`. The module (`Renderer`) exposes `init`, `render`, `renderBackground`, `renderPlayer`, `renderEnemies`, `renderProjectiles`, `renderParticles`, `renderHUD`, `resizeCanvas`, `triggerShake`, `getCamera`, and `getViewport`. All 9 systems are implemented with `lighter` composite blending and radial gradients for glow.
</teammate_result>
```

---

## Assistant (Build · DeepSeek V4 Pro · 3.0s)

_Thinking:_

Good. Still waiting for physics-gameplay and ui-audio. Let me check again.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
No pending messages.
Check complete. If teammates are still active, end this turn instead of polling.
Team messages are delivered asynchronously; busy teammates can only process broadcasts or direct messages at their next prompt boundary.
Do not send routine status-check broadcasts just because the mailbox is empty. Teammates will wake you when they have progress, blockers, or results.

Current team status:
- qa-tester (general, completed, session ses_2136f0795ffeGHa1759VEvw1G8)
- ui-audio (general, active, session ses_2136f72feffebSFkQoBgsRYRE3)
- physics-gameplay (general, active, session ses_213700bb8ffeqB52PNYvUwmaqw)
- rendering-engine (general, completed, session ses_21370af15ffeRa8cVU5O2Kspi1)
- game-designer (general, completed, session ses_213716dc1ffeZxikseEms172AH)
```

---

## Assistant (Build · DeepSeek V4 Pro · 3.0s)

_Thinking:_

3/5 completed. Waiting for physics-gameplay and ui-audio. Let me end my turn and wait.

3/5 complete — rendering, design, and QA done. Waiting for physics/gameplay and UI/audio modules.

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 3.5s)

_Thinking:_

UI-audio is done too. Now only physics-gameplay is still active. Let me check for more messages.

UI/Audio module delivered. Just waiting for physics/gameplay now.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
No pending messages.
Check complete. If teammates are still active, end this turn instead of polling.
Team messages are delivered asynchronously; busy teammates can only process broadcasts or direct messages at their next prompt boundary.
Do not send routine status-check broadcasts just because the mailbox is empty. Teammates will wake you when they have progress, blockers, or results.

Current team status:
- qa-tester (general, completed, session ses_2136f0795ffeGHa1759VEvw1G8)
- ui-audio (general, active, session ses_2136f72feffebSFkQoBgsRYRE3)
- physics-gameplay (general, active, session ses_213700bb8ffeqB52PNYvUwmaqw)
- rendering-engine (general, completed, session ses_21370af15ffeRa8cVU5O2Kspi1)
- game-designer (general, completed, session ses_213716dc1ffeZxikseEms172AH)
```

---

## Assistant (Build · DeepSeek V4 Pro · 2.6s)

_Thinking:_

4/5 complete. Only physics-gameplay is still active. Let me wait.

4/5 complete. Physics/gameplay is the last module remaining.

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 2.7s)

_Thinking:_

UI-audio is confirmed complete. Just waiting for physics-gameplay.

**Tool: team_get_messages**

**Input:**
```json
{}
```

**Output:**
```
No pending messages.
Check complete. If teammates are still active, end this turn instead of polling.
Team messages are delivered asynchronously; busy teammates can only process broadcasts or direct messages at their next prompt boundary.
Do not send routine status-check broadcasts just because the mailbox is empty. Teammates will wake you when they have progress, blockers, or results.

Current team status:
- qa-tester (general, completed, session ses_2136f0795ffeGHa1759VEvw1G8)
- ui-audio (general, completed, session ses_2136f72feffebSFkQoBgsRYRE3)
- physics-gameplay (general, active, session ses_213700bb8ffeqB52PNYvUwmaqw)
- rendering-engine (general, completed, session ses_21370af15ffeRa8cVU5O2Kspi1)
- game-designer (general, completed, session ses_213716dc1ffeZxikseEms172AH)
```

---

## Assistant (Build · DeepSeek V4 Pro · 2.5s)

_Thinking:_

Still waiting for physics/gameplay. Let me wait.

Last one — waiting for physics/gameplay module.

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 6.7s)

_Thinking:_

All 5 agents have completed their work! Now I need to:
1. Read all the generated files (renderer.js, ui-audio.js, and the physics-gameplay file)
2. Integrate them into a single HTML file
3. Make sure all the pieces work together

Let me first check what files were created, then read them all.

All 5 agents delivered. Let me now read all the generated modules and integrate them into the final game.

**Tool: glob**

**Input:**
```json
{
  "pattern": "**/*.js",
  "path": "/Users/srpanwar/Documents/Workspace/brain/temp"
}
```

**Output:**
```
/Users/srpanwar/Documents/Workspace/brain/temp/gameplay.js
/Users/srpanwar/Documents/Workspace/brain/temp/ui-audio.js
/Users/srpanwar/Documents/Workspace/brain/temp/renderer.js
```

---

## Assistant (Build · DeepSeek V4 Pro · 6.9s)

_Thinking:_

Three files created. Let me read them all in parallel.

**Tool: read**

**Input:**
```json
{
  "filePath": "/Users/srpanwar/Documents/Workspace/brain/temp/gameplay.js"
}
```

**Output:**
```
<path>/Users/srpanwar/Documents/Workspace/brain/temp/gameplay.js</path>
<type>file</type>
<content>
1: // =============================================================================
2: // VOID STRIKERS — Physics & Gameplay Module
3: // =============================================================================
4: // All gameplay systems: player, enemies, projectiles, power-ups, collisions,
5: // combo scoring, level/wave management, screen shake, state machine.
6: //
7: // Shared globals used (do NOT redeclare):
8: //   canvas, ctx, CONFIG, gameState, input, deltaTime, camera, particles, stars
9: // =============================================================================
10: 
11: // ---------------------------------------------------------------------------
12: // UTILITY HELPERS
13: // ---------------------------------------------------------------------------
14: 
15: /** Clamp value between min and max */
16: function clamp(val, min, max) { return Math.max(min, Math.min(max, val)); }
17: 
18: /** Linear interpolation */
19: function lerp(a, b, t) { return a + (b - a) * t; }
20: 
21: /** Random float in [min, max] */
22: function rand(min, max) { return Math.random() * (max - min) + min; }
23: 
24: /** Random int in [min, max] inclusive */
25: function randInt(min, max) { return Math.floor(rand(min, max + 1)); }
26: 
27: /** Axis-aligned bounding box collision test */
28: function aabb(a, b) {
29:   return a.x - a.width / 2 < b.x + b.width / 2 &&
30:          a.x + a.width / 2 > b.x - b.width / 2 &&
31:          a.y - a.height / 2 < b.y + b.height / 2 &&
32:          a.y + a.height / 2 > b.y - b.height / 2;
33: }
34: 
35: /** Squared distance between two points */
36: function distSq(x1, y1, x2, y2) { return (x2 - x1) ** 2 + (y2 - y1) ** 2; }
37: 
38: /** Angle from point a to point b (radians) */
39: function angleTo(x1, y1, x2, y2) { return Math.atan2(y2 - y1, x2 - x1); }
40: 
41: /** Whether a point is within canvas bounds (with margin) */
42: function onScreen(x, y, margin) {
43:   margin = margin || 80;
44:   return x > -margin && x < canvas.width + margin &&
45:          y > -margin && y < canvas.height + margin;
46: }
47: 
48: // ---------------------------------------------------------------------------
49: // SCREEN SHAKE
50: // ---------------------------------------------------------------------------
51: 
52: function triggerShake(magnitude, duration) {
53:   if (gameState.shakeMagnitude < magnitude) {
54:     gameState.shakeMagnitude = magnitude;
55:   }
56:   // Decay is handled in update — this just sets the peak
57: }
58: 
59: function updateShake(dt) {
60:   if (gameState.shakeMagnitude > 0.01) {
61:     var m = gameState.shakeMagnitude;
62:     camera.shakeX = (Math.random() - 0.5) * m * 2;
63:     camera.shakeY = (Math.random() - 0.5) * m * 2;
64:     gameState.shakeMagnitude *= Math.pow(0.05, dt); // decay to 5% per second
65:   } else {
66:     gameState.shakeMagnitude = 0;
67:     camera.shakeX = 0;
68:     camera.shakeY = 0;
69:   }
70: }
71: 
72: // ---------------------------------------------------------------------------
73: // PARTICLE HELPERS
74: // ---------------------------------------------------------------------------
75: 
76: /** Spawn an explosion burst of particles */
77: function spawnExplosion(x, y, count, color, speed, life) {
78:   count = count || 12;
79:   color = color || '#ff8800';
80:   speed = speed || 200;
81:   life = life || 0.6;
82:   for (var i = 0; i < count; i++) {
83:     var angle = (Math.PI * 2 / count) * i + rand(-0.3, 0.3);
84:     var spd = rand(speed * 0.5, speed);
85:     particles.push({
86:       x: x, y: y,
87:       vx: Math.cos(angle) * spd,
88:       vy: Math.sin(angle) * spd,
89:       life: rand(life * 0.5, life),
90:       maxLife: life,
91:       color: color,
92:       size: rand(2, 5),
93:       decay: true,
94:       type: 'explosion'
95:     });
96:   }
97: }
98: 
99: /** Spawn a small spark at a point */
100: function spawnSpark(x, y, color) {
101:   color = color || '#ffffff';
102:   for (var i = 0; i < 3; i++) {
103:     particles.push({
104:       x: x, y: y,
105:       vx: rand(-80, 80),
106:       vy: rand(-80, 80),
107:       life: rand(0.1, 0.3),
108:       maxLife: 0.3,
109:       color: color,
110:       size: rand(1, 2),
111:       decay: true,
112:       type: 'spark'
113:     });
114:   }
115: }
116: 
117: /** Spawn a ring burst (used for charged shot hit) */
118: function spawnRingBurst(x, y, color, count) {
119:   count = count || 16;
120:   color = color || '#ffffff';
121:   var speed = 120;
122:   for (var i = 0; i < count; i++) {
123:     var a = (Math.PI * 2 / count) * i;
124:     particles.push({
125:       x: x, y: y,
126:       vx: Math.cos(a) * speed,
127:       vy: Math.sin(a) * speed,
128:       life: 0.4, maxLife: 0.4,
129:       color: color, size: 3, decay: true,
130:       type: 'ring'
131:     });
132:   }
133: }
134: 
135: /** Update all particles (position, life) */
136: function updateParticles(dt) {
137:   for (var i = particles.length - 1; i >= 0; i--) {
138:     var p = particles[i];
139:     p.life -= dt;
140:     if (p.life <= 0) {
141:       particles.splice(i, 1);
142:       continue;
143:     }
144:     p.x += p.vx * dt;
145:     p.y += p.vy * dt;
146:     // Slow down
147:     p.vx *= 0.98;
148:     p.vy *= 0.98;
149:   }
150: }
151: 
152: // ---------------------------------------------------------------------------
153: // COMBO SYSTEM
154: // ---------------------------------------------------------------------------
155: 
156: function addKill(x, y) {
157:   gameState.combo++;
158:   gameState.comboTimer = 2.0; // 2 second decay window
159:   gameState.lastKillX = x;
160:   gameState.lastKillY = y;
161: 
162:   // Update multiplier based on thresholds
163:   var prevMult = gameState.comboMultiplier;
164:   if (gameState.combo >= 100)      gameState.comboMultiplier = 5;
165:   else if (gameState.combo >= 50)  gameState.comboMultiplier = 3;
166:   else if (gameState.combo >= 25)  gameState.comboMultiplier = 2;
167:   else if (gameState.combo >= 10)  gameState.comboMultiplier = 1.5;
168:   else                             gameState.comboMultiplier = 1;
169: 
170:   if (gameState.comboMultiplier > prevMult) {
171:     gameState.comboFlashTimer = 1.0; // flash when multiplier increases
172:     spawnRingBurst(x, y, '#ffff00', 12);
173:   }
174: }
175: 
176: function updateCombo(dt) {
177:   if (gameState.comboTimer > 0) {
178:     gameState.comboTimer -= dt;
179:     if (gameState.comboTimer <= 0) {
180:       gameState.combo = 0;
181:       gameState.comboMultiplier = 1;
182:     }
183:   }
184:   if (gameState.comboFlashTimer > 0) gameState.comboFlashTimer -= dt;
185: }
186: 
187: // ---------------------------------------------------------------------------
188: // BULLET POOL SYSTEM (single unified pool for renderer compatibility)
189: // ---------------------------------------------------------------------------
190: 
191: var BULLET_POOL_SIZE = 400;
192: var projectiles = [];
193: 
194: /** Initialize the unified projectile pool */
195: function initBulletPool() {
196:   projectiles = [];
197:   for (var i = 0; i < BULLET_POOL_SIZE; i++) {
198:     projectiles.push({
199:       x: 0, y: 0, vx: 0, vy: 0,
200:       damage: 0, type: 'enemyBullet', owner: 'enemy',
201:       color: '#ff4444', size: 3,
202:       alive: false, pierceCount: 0
203:     });
204:   }
205: }
206: 
207: /** Get a dead projectile from the pool */
208: function getDeadBullet() {
209:   for (var i = 0; i < projectiles.length; i++) {
210:     if (!projectiles[i].alive) return projectiles[i];
211:   }
212:   // Pool exhausted — recycle the bullet furthest off-screen
213:   var oldest = null, oldestDist = -1;
214:   for (var j = 0; j < projectiles.length; j++) {
215:     var d = distSq(projectiles[j].x, projectiles[j].y, canvas.width / 2, canvas.height / 2);
216:     if (d > oldestDist) { oldestDist = d; oldest = projectiles[j]; }
217:   }
218:   return oldest || projectiles[0];
219: }
220: 
221: /** Spawn a projectile into the world.
222:  *  @param {string} bulletType - 'playerBullet', 'enemyBullet', 'chargedShot' */
223: function spawnBullet(x, y, vx, vy, damage, owner, bulletType, color, size, pierce) {
224:   var b = getDeadBullet();
225:   b.x = x; b.y = y;
226:   b.vx = vx; b.vy = vy;
227:   b.damage = damage || 10;
228:   b.owner = owner;
229:   b.type = bulletType || (owner === 'player' ? 'playerBullet' : 'enemyBullet');
230:   b.color = color || (owner === 'player' ? '#00ffff' : '#ff4444');
231:   b.size = size || (owner === 'player' ? 4 : 3);
232:   b.alive = true;
233:   b.pierceCount = pierce || 0;
234:   return b;
235: }
236: 
237: /** Update all active projectiles (physics, trail, despawn) */
238: function updateBullets(dt) {
239:   for (var i = 0; i < projectiles.length; i++) {
240:     var b = projectiles[i];
241:     if (!b.alive) continue;
242:     b.x += b.vx * dt;
243:     b.y += b.vy * dt;
244: 
245:     // Trail particles for fast bullets
246:     if (Math.abs(b.vx) + Math.abs(b.vy) > 400) {
247:       if (Math.random() < 0.5) {
248:         particles.push({
249:           x: b.x, y: b.y,
250:           vx: rand(-20, 20), vy: rand(-20, 20),
251:           life: 0.15, maxLife: 0.15,
252:           color: b.color, size: b.size * 0.6, decay: true, type: 'spark'
253:         });
254:       }
255:     }
256: 
257:     // Despawn off-screen
258:     if (!onScreen(b.x, b.y, 60)) {
259:       b.alive = false;
260:     }
261:   }
262: }
263: 
264: // ---------------------------------------------------------------------------
265: // PLAYER
266: // ---------------------------------------------------------------------------
267: 
268: var player = {
269:   x: 0, y: 0,
270:   vx: 0, vy: 0,
271:   width: 30, height: 30,
272:   hp: 100, maxHp: 100,
273:   shield: 0,
274:   shieldActive: false,
275:   speed: 350,
276:   weaponLevel: 1,
277:   rotation: 0,
278:   scale: 1,
279:   invulnerable: false,
280:   invulnerableTimer: 0,
281:   shootTimer: 0,
282:   shootCooldown: 0.15,
283:   chargeLevel: 0,
284:   maxCharge: 100,
285:   charging: false,
286:   chargeCooldown: 0,
287:   speedBoostTimer: 0,
288:   engineFlicker: 0
289: };
290: 
291: function resetPlayer() {
292:   player.x = canvas.width / 2;
293:   player.y = canvas.height * 0.8;
294:   player.vx = 0;
295:   player.vy = 0;
296:   player.hp = 100;
297:   player.maxHp = 100;
298:   player.shield = 0;
299:   player.speed = CONFIG.playerSpeed || 350;
300:   player.weaponLevel = 1;
301:   player.invulnerable = false;
302:   player.invulnerableTimer = 0;
303:   player.shootTimer = 0;
304:   player.shootCooldown = CONFIG.playerShootCooldown || 0.15;
305:   player.chargeLevel = 0;
306:   player.maxCharge = 100;
307:   player.charging = false;
308:   player.chargeCooldown = 0;
309:   player.speedBoostTimer = 0;
310:   player.engineFlicker = 0;
311: }
312: 
313: function updatePlayer(dt) {
314:   if (gameState.state !== 'playing') return;
315: 
316:   // --- Movement ---
317:   var moveX = 0, moveY = 0;
318:   if (input.keys['ArrowLeft']  || input.keys['KeyA']) moveX -= 1;
319:   if (input.keys['ArrowRight'] || input.keys['KeyD']) moveX += 1;
320:   if (input.keys['ArrowUp']    || input.keys['KeyW']) moveY -= 1;
321:   if (input.keys['ArrowDown']  || input.keys['KeyS']) moveY += 1;
322: 
323:   // Normalize diagonal movement
324:   if (moveX !== 0 && moveY !== 0) {
325:     var norm = 0.70710678; // 1 / sqrt(2) for diagonal normalization
326:     moveX *= norm;
327:     moveY *= norm;
328:   }
329: 
330:   var currentSpeed = player.speed + (player.speedBoostTimer > 0 ? 120 : 0);
331:   player.vx = moveX * currentSpeed;
332:   player.vy = moveY * currentSpeed;
333:   player.x += player.vx * dt;
334:   player.y += player.vy * dt;
335: 
336:   // Clamp to canvas
337:   player.x = clamp(player.x, player.width / 2, canvas.width - player.width / 2);
338:   player.y = clamp(player.y, player.height / 2, canvas.height - player.height / 2);
339: 
340:   // Speed boost timer
341:   if (player.speedBoostTimer > 0) {
342:     player.speedBoostTimer -= dt;
343:   }
344: 
345:   // Engine flicker particle
346:   player.engineFlicker -= dt;
347:   if (player.engineFlicker <= 0) {
348:     player.engineFlicker = 0.04;
349:     particles.push({
350:       x: player.x + rand(-6, 6),
351:       y: player.y + player.height / 2 + 2,
352:       vx: rand(-20, 20),
353:       vy: rand(60, 120),
354:       life: 0.25, maxLife: 0.25,
355:       color: player.speedBoostTimer > 0 ? '#00ffff' : '#4488ff',
356:       size: rand(1, 3),
357:       decay: true,
358:       type: 'engine'
359:     });
360:   }
361: 
362:   // --- Invulnerability ---
363:   if (player.invulnerable) {
364:     player.invulnerableTimer -= dt;
365:     if (player.invulnerableTimer <= 0) {
366:       player.invulnerable = false;
367:     }
368:   }
369: 
370:   // --- Shooting ---
371:   var shootKeyDown = input.keys['KeyZ'] || input.keys['Space'] || input.keys['KeyJ'] || (input.mouse && input.mouse.down);
372:   var isCharging = input.keys['Space'] || input.keys['KeyJ'];
373: 
374:   // Auto-fire (tapping Z or mouse)
375:   if (shootKeyDown && !isCharging) {
376:     player.shootTimer -= dt;
377:     if (player.shootTimer <= 0) {
378:       playerShoot();
379:       player.shootTimer = player.shootCooldown;
380:     }
381:   }
382: 
383:   // Charged shot (hold Space/J)
384:   if (isCharging) {
385:     if (!player.charging) {
386:       player.charging = true;
387:       player.chargeLevel = 0;
388:     }
389:     player.chargeLevel = clamp(player.chargeLevel + (50 * dt), 0, player.maxCharge);
390: 
391:     if (player.chargeLevel >= player.maxCharge) {
392:       // Full charge visual feedback — auto-fire or release fires
393:       // Actually, charged shot fires on release (key-up handled in input system)
394:     }
395:   } else if (player.charging) {
396:     // Released — fire charged shot
397:     if (player.chargeLevel >= 30) {
398:       playerChargedShot();
399:     }
400:     player.charging = false;
401:     player.chargeLevel = 0;
402:   }
403: 
404:   // Charge cooldown
405:   if (player.chargeCooldown > 0) {
406:     player.chargeCooldown -= dt;
407:   }
408: 
409:   // Charge glow particles
410:   if (player.charging && player.chargeLevel > 20) {
411:     if (Math.random() < 0.6) {
412:       var glowAlpha = player.chargeLevel / player.maxCharge;
413:       particles.push({
414:         x: player.x + rand(-14, 14),
415:         y: player.y + rand(-10, 10),
416:         vx: rand(-30, 30),
417:         vy: rand(-30, -10),
418:         life: 0.3, maxLife: 0.3,
419:         color: '#88ccff',
420:         size: rand(2, 4) * glowAlpha,
421:         decay: true,
422:         type: 'spark'
423:       });
424:     }
425:   }
426: }
427: 
428: /** Standard shot — fires based on weapon level */
429: function playerShoot() {
430:   var bx = player.x;
431:   var by = player.y - player.height / 2;
432: 
433:   switch (player.weaponLevel) {
434:     case 1:
435:       spawnBullet(bx, by, 0, -600, 10, 'player', 'playerBullet', '#00ffff', 4, 0);
436:       break;
437:     case 2:
438:       spawnBullet(bx - 8, by, 0, -600, 10, 'player', 'playerBullet', '#00ffff', 4, 0);
439:       spawnBullet(bx + 8, by, 0, -600, 10, 'player', 'playerBullet', '#00ffff', 4, 0);
440:       break;
441:     case 3:
442:       spawnBullet(bx, by, 0, -650, 12, 'player', 'playerBullet', '#00ffff', 4, 0);
443:       spawnBullet(bx - 6, by + 2, -60, -600, 10, 'player', 'playerBullet', '#44ddff', 3, 0);
444:       spawnBullet(bx + 6, by + 2, 60, -600, 10, 'player', 'playerBullet', '#44ddff', 3, 0);
445:       break;
446:   }
447: 
448:   // Muzzle flash particle
449:   spawnSpark(bx, by - 5, '#00ffff');
450: }
451: 
452: /** Charged shot — big, slow, pierces enemies */
453: function playerChargedShot() {
454:   if (player.chargeCooldown > 0) return;
455:   player.chargeCooldown = 0.5;
456: 
457:   var power = clamp(player.chargeLevel / player.maxCharge, 0.3, 1);
458:   var damage = Math.floor(50 * power);
459:   var pierce = Math.floor(4 * power);
460:   var size = 4 + 8 * power;
461:   var speed = 250 + 200 * power;
462: 
463:   spawnBullet(player.x, player.y - player.height / 2, 0, -speed, damage, 'player', 'chargedShot', '#ffffff', size, pierce);
464: 
465:   // Muzzle burst
466:   spawnExplosion(player.x, player.y - player.height / 2, 20, '#88ccff', 150, 0.4);
467:   triggerShake(3 + 4 * power, 0.2);
468: }
469: 
470: function playerTakeDamage(amount) {
471:   if (player.invulnerable) return;
472:   if (gameState.state !== 'playing') return;
473: 
474:   // Shield absorbs damage first
475:   if (player.shield > 0) {
476:     var absorbed = Math.min(player.shield, amount);
477:     player.shield -= absorbed;
478:     amount -= absorbed;
479:     player.shieldActive = player.shield > 0;
480:     spawnSpark(player.x, player.y, '#4488ff');
481:     if (player.shield <= 0) {
482:       spawnExplosion(player.x, player.y, 8, '#4488ff', 100, 0.4);
483:     }
484:   }
485: 
486:   if (amount > 0) {
487:     player.hp -= amount;
488:     player.invulnerable = true;
489:     player.invulnerableTimer = 2.0;
490:     triggerShake(6, 0.3);
491:     spawnExplosion(player.x, player.y, 10, '#ff4444', 180, 0.5);
492: 
493:     // Reset combo on hit
494:     gameState.combo = 0;
495:     gameState.comboMultiplier = 1;
496: 
497:     if (player.hp <= 0) {
498:       player.hp = 0;
499:       spawnExplosion(player.x, player.y, 40, '#ff8800', 300, 1.0);
500:       triggerShake(15, 0.8);
501:       gameOver();
502:     }
503:   }
504: }
505: 
506: function playerApplyPowerUp(type) {
507:   switch (type) {
508:     case 'health':
509:       player.hp = Math.min(player.hp + 30, player.maxHp);
510:       spawnRingBurst(player.x, player.y, '#00ff66', 12);
511:       break;
512:     case 'shield':
513:       player.shield = Math.min(player.shield + 50, 100);
514:       player.shieldActive = true;
515:       spawnRingBurst(player.x, player.y, '#4488ff', 12);
516:       break;
517:     case 'weapon':
518:       if (player.weaponLevel < 3) {
519:         player.weaponLevel++;
520:       } else {
521:         gameState.score += 500 * gameState.comboMultiplier;
522:       }
523:       spawnRingBurst(player.x, player.y, '#ffaa00', 14);
524:       break;
525:     case 'speed':
526:       player.speedBoostTimer = 5.0;
527:       spawnRingBurst(player.x, player.y, '#00ffff', 10);
528:       break;
529:   }
530: }
531: 
532: // ---------------------------------------------------------------------------
533: // ENEMY TYPES & FACTORY
534: // ---------------------------------------------------------------------------
535: 
536: var ENEMY_DEFS = {
537:   scout: {
538:     name: 'Scout',
539:     width: 24, height: 24,
540:     hp: 20, speed: 80,
541:     damage: 15, scoreValue: 100,
542:     color: '#ff6644',
543:     shootCooldown: 0,
544:     behavior: 'straightDown'
545:   },
546:   fighter: {
547:     name: 'Fighter',
548:     width: 28, height: 28,
549:     hp: 40, speed: 130,
550:     damage: 20, scoreValue: 200,
551:     color: '#ff8844',
552:     shootCooldown: 1.5,
553:     behavior: 'sineWave'
554:   },
555:   tank: {
556:     name: 'Tank',
557:     width: 36, height: 36,
558:     hp: 80, speed: 50,
559:     damage: 30, scoreValue: 400,
560:     color: '#cc4422',
561:     shootCooldown: 2.0,
562:     behavior: 'tank'
563:   },
564:   speeder: {
565:     name: 'Speeder',
566:     width: 22, height: 22,
567:     hp: 15, speed: 260,
568:     damage: 25, scoreValue: 300,
569:     color: '#ffcc00',
570:     shootCooldown: 0,
571:     behavior: 'dive'
572:   },
573:   sniper: {
574:     name: 'Sniper',
575:     width: 26, height: 26,
576:     hp: 35, speed: 60,
577:     damage: 25, scoreValue: 350,
578:     color: '#ff4488',
579:     shootCooldown: 1.2,
580:     behavior: 'sniper'
581:   },
582:   boss: {
583:     name: 'Boss',
584:     width: 70, height: 70,
585:     hp: 500, speed: 40,
586:     damage: 40, scoreValue: 5000,
587:     color: '#ff2222',
588:     shootCooldown: 0.6,
589:     behavior: 'boss'
590:   }
591: };
592: 
593: var enemies = [];
594: 
595: /** Factory: create an enemy of given type */
596: function spawnEnemy(type, x, y) {
597:   var def = ENEMY_DEFS[type];
598:   if (!def) return null;
599: 
600:   // Scale boss HP by level
601:   var hpMult = 1;
602:   var spdMult = 1;
603:   if (type === 'boss') {
604:     hpMult = 1 + (gameState.level - 1) * 0.6;
605:     spdMult = 1 + (gameState.level - 1) * 0.15;
606:   }
607: 
608:   var e = {
609:     x: x, y: y,
610:     vx: 0, vy: def.speed * spdMult,
611:     width: def.width, height: def.height,
612:     hp: Math.floor(def.hp * hpMult),
613:     maxHp: Math.floor(def.hp * hpMult),
614:     speed: def.speed * spdMult,
615:     damage: def.damage,
616:     scoreValue: def.scoreValue,
617:     type: type,
618:     color: def.color,
619:     hitTimer: 0,
620:     deathTimer: 0,
621:     rotation: 0,
622:     scale: 1,
623:     shootTimer: rand(0, def.shootCooldown),
624:     shootCooldown: def.shootCooldown,
625:     phase: 0,
626:     behaviorTimer: 0,
627:     spawnX: x, spawnY: y,
628:     alive: true
629:   };
630:   enemies.push(e);
631:   return e;
632: }
633: 
634: function updateEnemies(dt) {
635:   for (var i = enemies.length - 1; i >= 0; i--) {
636:     var e = enemies[i];
637: 
638:     // Handle dead enemies with death animation
639:     if (!e.alive) {
640:       e.deathTimer -= dt;
641:       if (e.deathTimer <= 0) { enemies.splice(i, 1); }
642:       continue;
643:     }
644: 
645:     // Hit flash timer dec
646:     if (e.hitTimer > 0) e.hitTimer -= dt;
647: 
648:     // Behavior timer
649:     e.behaviorTimer += dt;
650:     e.shootTimer -= dt;
651: 
652:     // --- Per-type behavior ---
653:     switch (e.behavior || ENEMY_DEFS[e.type].behavior) {
654:       case 'straightDown':
655:         e.y += e.speed * dt;
656:         break;
657: 
658:       case 'sineWave':
659:         e.y += e.speed * dt;
660:         e.x = e.spawnX + Math.sin(e.behaviorTimer * 3) * 60;
661:         if (e.shootTimer <= 0 && e.shootCooldown > 0) {
662:           enemyShoot(e);
663:           e.shootTimer = e.shootCooldown;
664:         }
665:         break;
666: 
667:       case 'tank':
668:         e.y += e.speed * dt;
669:         if (e.y > 80) e.y = 80; // tanks stay near top
670:         // Slow horizontal drift
671:         e.x += Math.sin(e.behaviorTimer * 0.8) * 40 * dt;
672:         if (e.shootTimer <= 0 && e.shootCooldown > 0) {
673:           enemyShoot(e);
674:           e.shootTimer = e.shootCooldown;
675:         }
676:         break;
677: 
678:       case 'dive':
679:         // Speeders dive toward player
680:         var dx = player.x - e.x;
681:         var dy = player.y - e.y;
682:         var dist = Math.sqrt(dx * dx + dy * dy) || 1;
683:         var spd = e.speed;
684:         e.vx = (dx / dist) * spd;
685:         e.vy = (dy / dist) * spd;
686:         e.x += e.vx * dt;
687:         e.y += e.vy * dt;
688:         break;
689: 
690:       case 'sniper':
691:         // Snipers move to a position and stay
692:         if (e.y < 100) {
693:           // Move to sniping position
694:           e.y += e.speed * dt;
695:           e.x = e.spawnX + Math.sin(e.behaviorTimer * 1.5) * 40;
696:         } else {
697:           e.y = 100 + Math.sin(e.behaviorTimer * 0.7) * 20;
698:           e.x = e.spawnX + Math.sin(e.behaviorTimer * 1.5) * 50;
699:         }
700:         if (e.shootTimer <= 0 && e.shootCooldown > 0) {
701:           enemyShoot(e);
702:           e.shootTimer = e.shootCooldown;
703:         }
704:         break;
705: 
706:       case 'boss':
707:         updateBossBehavior(e, dt);
708:         break;
709: 
710:       default:
711:         e.y += e.speed * dt;
712:     }
713: 
714:     // Despawn if far off-screen bottom
715:     if (e.y > canvas.height + 120) {
716:       e.alive = false;
717:       enemies.splice(i, 1);
718:     }
719:   }
720: }
721: 
722: /** Boss multi-phase behavior */
723: function updateBossBehavior(boss, dt) {
724:   // Phase 1: enter from top, move to center-top
725:   if (boss.phase === 0) {
726:     if (boss.y < 120) {
727:       boss.y += boss.speed * dt;
728:       boss.x += (canvas.width / 2 - boss.x) * 0.02;
729:     } else {
730:       boss.phase = 1;
731:       boss.behaviorTimer = 0;
732:     }
733:   }
734:   // Phase 1: sweep left-right, shoot bursts
735:   else if (boss.phase === 1) {
736:     boss.x = canvas.width / 2 + Math.sin(boss.behaviorTimer * 1.2) * (canvas.width * 0.35);
737:     boss.y = 100 + Math.sin(boss.behaviorTimer * 0.5) * 30;
738: 
739:     if (boss.shootTimer <= 0) {
740:       // Burst fire: 3 shots toward player
741:       for (var i = -1; i <= 1; i++) {
742:         var a = angleTo(boss.x, boss.y + 35, player.x, player.y) + i * 0.2;
743:         spawnBullet(boss.x, boss.y + 35, Math.cos(a) * 220, Math.sin(a) * 220, 15, 'enemy', 'enemyBullet', '#ff4444', 3, 0);
744:       }
745:       boss.shootTimer = 0.8;
746:     }
747: 
748:     // Phase transition at 60% HP
749:     if (boss.hp < boss.maxHp * 0.6) {
750:       boss.phase = 2;
751:       boss.behaviorTimer = 0;
752:       spawnExplosion(boss.x, boss.y, 20, '#ff4400', 200, 0.6);
753:       triggerShake(4, 0.3);
754:     }
755:   }
756:   // Phase 2: faster, circular pattern, spread shots
757:   else if (boss.phase === 2) {
758:     boss.x = canvas.width / 2 + Math.sin(boss.behaviorTimer * 1.8) * (canvas.width * 0.35);
759:     boss.y = 120 + Math.cos(boss.behaviorTimer * 0.9) * 60;
760: 
761:     if (boss.shootTimer <= 0) {
762:       // Spread shot
763:       var baseAngle = angleTo(boss.x, boss.y + 35, player.x, player.y);
764:       for (var j = -2; j <= 2; j++) {
765:         var a2 = baseAngle + j * 0.25;
766:         spawnBullet(boss.x, boss.y + 35, Math.cos(a2) * 250, Math.sin(a2) * 250, 15, 'enemy', 'enemyBullet', '#ff6644', 3, 0);
767:       }
768:       boss.shootTimer = 0.5;
769:     }
770: 
771:     if (boss.hp < boss.maxHp * 0.25) {
772:       boss.phase = 3;
773:       boss.behaviorTimer = 0;
774:       spawnExplosion(boss.x, boss.y, 30, '#ff2200', 250, 0.8);
775:       triggerShake(6, 0.5);
776:     }
777:   }
778:   // Phase 3: enrage — fast, spam shots, harder patterns
779:   else {
780:     boss.x = canvas.width / 2 + Math.sin(boss.behaviorTimer * 2.5) * (canvas.width * 0.3);
781:     boss.y = 100 + Math.cos(boss.behaviorTimer * 1.4) * 80;
782: 
783:     if (boss.shootTimer <= 0) {
784:       // Circular burst
785:       var count = 8;
786:       for (var k = 0; k < count; k++) {
787:         var a3 = (Math.PI * 2 / count) * k + boss.behaviorTimer * 0.5;
788:         spawnBullet(boss.x, boss.y + 35, Math.cos(a3) * 200, Math.sin(a3) * 200, 15, 'enemy', 'enemyBullet', '#ff2244', 3, 0);
789:       }
790:       boss.shootTimer = 0.4;
791:     }
792:   }
793: }
794: 
795: /** Enemy fires a bullet toward the player */
796: function enemyShoot(enemy) {
797:   var a = angleTo(enemy.x, enemy.y + enemy.height / 2, player.x, player.y);
798: 
799:   if (enemy.type === 'tank') {
800:     // Tank: spread shot
801:     for (var i = -1; i <= 1; i++) {
802:       var spreadA = a + i * 0.3;
803:       spawnBullet(enemy.x, enemy.y + enemy.height / 2,
804:         Math.cos(spreadA) * 200, Math.sin(spreadA) * 200,
805:         enemy.damage, 'enemy', 'enemyBullet', '#ff6644', 4, 0);
806:     }
807:   } else if (enemy.type === 'sniper') {
808:     // Sniper: fast, accurate shot
809:     spawnBullet(enemy.x, enemy.y + enemy.height / 2,
810:       Math.cos(a) * 400, Math.sin(a) * 400,
811:       enemy.damage, 'enemy', 'enemyBullet', '#ff88aa', 5, 0);
812:   } else {
813:     // Default: single aimed shot
814:     spawnBullet(enemy.x, enemy.y + enemy.height / 2,
815:       Math.cos(a) * 220, Math.sin(a) * 220,
816:       enemy.damage, 'enemy', 'enemyBullet', '#ff4444', 3, 0);
817:   }
818: }
819: 
820: function damageEnemy(enemy, amount, bullet) {
821:   if (!enemy.alive) return;
822:   enemy.hitTimer = enemy.type === 'boss' ? 0.12 : 0.06;
823: 
824:   enemy.hp -= amount;
825:   spawnSpark(enemy.x, enemy.y, '#ffffff');
826: 
827:   // Pierce: reduce count, don't kill bullet
828:   if (bullet && bullet.pierceCount > 0) {
829:     bullet.pierceCount--;
830:   } else if (bullet) {
831:     bullet.alive = false;
832:   }
833: 
834:   if (enemy.hp <= 0) {
835:     enemy.alive = false;
836:     enemy.deathTimer = 0.5;
837:     var scoreEarned = enemy.scoreValue * gameState.comboMultiplier;
838:     gameState.score += scoreEarned;
839:     addKill(enemy.x, enemy.y);
840: 
841:     // Death effects
842:     if (enemy.type === 'boss') {
843:       spawnExplosion(enemy.x, enemy.y, 50, '#ff4400', 350, 1.5);
844:       spawnExplosion(enemy.x, enemy.y, 30, '#ffaa00', 250, 1.0);
845:       triggerShake(12, 1.0);
846:       // Drop shield power-up on boss death
847:       spawnPowerUp(enemy.x, enemy.y, 'weapon');
848:     } else {
849:       spawnExplosion(enemy.x, enemy.y, 8, enemy.color, 150, 0.5);
850:       // 15% chance to drop power-up
851:       if (Math.random() < 0.15) {
852:         var types = ['health', 'health', 'shield', 'weapon', 'speed'];
853:         var roll = types[randInt(0, types.length - 1)];
854:         if (roll === 'weapon' && player.weaponLevel >= 3) roll = 'health';
855:         spawnPowerUp(enemy.x, enemy.y, roll);
856:       }
857:     }
858:   }
859: }
860: 
861: // ---------------------------------------------------------------------------
862: // POWER-UP SYSTEM
863: // ---------------------------------------------------------------------------
864: 
865: var powerups = [];
866: var POWERUP_DEFS = {
867:   health:  { color: '#00ff66', glow: '#00ff66', type: 'health'  },
868:   shield:  { color: '#4488ff', glow: '#4488ff', type: 'shield'  },
869:   weapon:  { color: '#ffaa00', glow: '#ffaa00', type: 'weapon'  },
870:   speed:   { color: '#00ffff', glow: '#00ffff', type: 'speed'   }
871: };
872: 
873: function spawnPowerUp(x, y, type) {
874:   type = type || 'health';
875:   var def = POWERUP_DEFS[type];
876:   powerups.push({
877:     x: x, y: y,
878:     vy: 60,
879:     size: 12,
880:     type: type,
881:     color: def ? def.color : '#00ff66',
882:     glow: def ? def.glow : '#00ff66',
883:     alive: true,
884:     bobTimer: Math.random() * Math.PI * 2,
885:     lifeTimer: 8.0
886:   });
887: }
888: 
889: function updatePowerUps(dt) {
890:   for (var i = powerups.length - 1; i >= 0; i--) {
891:     var p = powerups[i];
892:     if (!p.alive) { powerups.splice(i, 1); continue; }
893: 
894:     p.y += p.vy * dt;
895:     p.bobTimer += dt * 4;
896:     p.lifeTimer -= dt;
897: 
898:     if (p.y > canvas.height + 40 || p.lifeTimer <= 0) {
899:       p.alive = false;
900:       powerups.splice(i, 1);
901:       continue;
902:     }
903: 
904:     if (Math.random() < 0.3) {
905:       particles.push({
906:         x: p.x + rand(-8, 8), y: p.y + rand(-8, 8),
907:         vx: rand(-15, 15), vy: rand(-30, -10),
908:         life: 0.4, maxLife: 0.4,
909:         color: p.glow, size: rand(1, 3), decay: true, type: 'spark'
910:       });
911:     }
912:   }
913: }
914: 
915: function collectPowerUp(powerUp) {
916:   if (!powerUp.alive) return;
917:   powerUp.alive = false;
918:   playerApplyPowerUp(powerUp.type);
919:   spawnExplosion(powerUp.x, powerUp.y, 6, powerUp.glow, 80, 0.3);
920: }
921: 
922: // ---------------------------------------------------------------------------
923: // COLLISION DETECTION
924: // ---------------------------------------------------------------------------
925: 
926: function checkCollisions() {
927:   var i, j;
928: 
929:   // --- Projectiles vs enemies AND enemy projectiles vs player ---
930:   for (i = 0; i < projectiles.length; i++) {
931:     var p = projectiles[i];
932:     if (!p.alive) continue;
933: 
934:     if (p.owner === 'player') {
935:       // Player bullet vs enemies
936:       for (j = enemies.length - 1; j >= 0; j--) {
937:         var e = enemies[j];
938:         if (!e.alive) continue;
939:         if (aabb(p, e)) {
940:           damageEnemy(e, p.damage, p);
941:           if (!p.alive) break; // bullet destroyed (unless piercing)
942:         }
943:       }
944:     } else {
945:       // Enemy bullet vs player
946:       if (aabb(p, player)) {
947:         playerTakeDamage(p.damage);
948:         p.alive = false;
949:       }
950:     }
951:   }
952: 
953:   // --- Player vs enemy (contact damage) ---
954:   for (j = enemies.length - 1; j >= 0; j--) {
955:     var ce = enemies[j];
956:     if (!ce.alive) continue;
957:     if (aabb(player, ce)) {
958:       playerTakeDamage(ce.damage);
959:       ce.alive = false;
960:       ce.deathTimer = 0.3;
961:       spawnExplosion(ce.x, ce.y, 6, ce.color, 120, 0.4);
962:     }
963:   }
964: 
965:   // --- Player vs power-ups ---
966:   for (i = powerups.length - 1; i >= 0; i--) {
967:     var pu = powerups[i];
968:     if (!pu.alive) continue;
969:     if (aabb(player, pu)) {
970:       collectPowerUp(pu);
971:     }
972:   }
973: }
974: 
975: // ---------------------------------------------------------------------------
976: // WAVE & LEVEL SYSTEM
977: // ---------------------------------------------------------------------------
978: 
979: var waveTimer = 0;
980: var waveIndex = 0;
981: var waveEnemiesRemaining = 0;
982: var levelBossSpawned = false;
983: var levelBossDefeated = false;
984: var levelTransitionTimer = 0;
985: 
986: // Level definitions with wave configurations
987: var LEVELS = [
988:   // Level 1 — Introduction
989:   {
990:     name: 'Orbital Approach',
991:     waves: [
992:       { enemies: [{ type: 'scout', count: 5, delay: 0.6 }], pauseAfter: 2.0 },
993:       { enemies: [{ type: 'scout', count: 8, delay: 0.5 }], pauseAfter: 2.5 },
994:       { enemies: [{ type: 'scout', count: 4, delay: 0.3 }, { type: 'fighter', count: 3, delay: 0.7 }], pauseAfter: 3.0 },
995:       { enemies: [{ type: 'fighter', count: 6, delay: 0.6 }], pauseAfter: 2.0 },
996:       { enemies: [{ type: 'scout', count: 6, delay: 0.3 }, { type: 'fighter', count: 4, delay: 0.5 }], pauseAfter: 2.0 }
997:     ],
998:     boss: { type: 'boss', hpMultiplier: 0.6 }
999:   },
1000:   // Level 2 — Escalation
1001:   {
1002:     name: 'Nebula Storm',
1003:     waves: [
1004:       { enemies: [{ type: 'fighter', count: 6, delay: 0.5 }], pauseAfter: 2.0 },
1005:       { enemies: [{ type: 'scout', count: 4, delay: 0.3 }, { type: 'tank', count: 2, delay: 1.0 }], pauseAfter: 3.0 },
1006:       { enemies: [{ type: 'speeder', count: 4, delay: 0.4 }], pauseAfter: 2.5 },
1007:       { enemies: [{ type: 'fighter', count: 5, delay: 0.4 }, { type: 'sniper', count: 2, delay: 1.0 }], pauseAfter: 3.0 },
1008:       { enemies: [{ type: 'tank', count: 3, delay: 0.8 }, { type: 'speeder', count: 3, delay: 0.4 }], pauseAfter: 2.0 },
1009:       { enemies: [{ type: 'scout', count: 8, delay: 0.3 }, { type: 'sniper', count: 2, delay: 1.0 }], pauseAfter: 2.0 }
1010:     ],
1011:     boss: { type: 'boss', hpMultiplier: 0.8 }
1012:   },
1013:   // Level 3 — Final Assault
1014:   {
1015:     name: 'Void Core',
1016:     waves: [
1017:       { enemies: [{ type: 'speeder', count: 5, delay: 0.3 }], pauseAfter: 2.0 },
1018:       { enemies: [{ type: 'fighter', count: 6, delay: 0.3 }, { type: 'sniper', count: 3, delay: 0.6 }], pauseAfter: 2.5 },
1019:       { enemies: [{ type: 'tank', count: 3, delay: 0.6 }, { type: 'speeder', count: 4, delay: 0.3 }], pauseAfter: 2.5 },
1020:       { enemies: [{ type: 'scout', count: 10, delay: 0.2 }, { type: 'fighter', count: 4, delay: 0.4 }], pauseAfter: 2.0 },
1021:       { enemies: [{ type: 'sniper', count: 4, delay: 0.5 }, { type: 'tank', count: 2, delay: 0.8 }], pauseAfter: 3.0 },
1022:       { enemies: [{ type: 'speeder', count: 5, delay: 0.25 }, { type: 'scout', count: 6, delay: 0.2 }, { type: 'fighter', count: 3, delay: 0.4 }], pauseAfter: 2.0 }
1023:     ],
1024:     boss: { type: 'boss', hpMultiplier: 1.0 }
1025:   }
1026: ];
1027: 
1028: var activeWave = null;
1029: var waveSubTimer = 0;
1030: var waveSubIndex = 0;
1031: var wavePauseTimer = 0;
1032: var spawnQueue = [];
1033: 
1034: /** Start a level */
1035: function startLevel(levelNum) {
1036:   gameState.level = levelNum;
1037:   gameState.combo = 0;
1038:   gameState.comboMultiplier = 1;
1039:   gameState.comboTimer = 0;
1040: 
1041:   waveIndex = 0;
1042:   waveTimer = 1.0; // short delay before first wave
1043:   levelBossSpawned = false;
1044:   levelBossDefeated = false;
1045:   levelTransitionTimer = 0;
1046:   activeWave = null;
1047:   wavePauseTimer = 0;
1048:   spawnQueue = [];
1049: 
1050:   // Clear all enemies and bullets
1051:   enemies = [];
1052:   for (var i = 0; i < projectiles.length; i++) projectiles[i].alive = false;
1053:   powerups = [];
1054: }
1055: 
1056: function updateLevel(dt) {
1057:   if (gameState.state !== 'playing') return;
1058: 
1059:   // Level transition animation
1060:   if (levelTransitionTimer > 0) {
1061:     levelTransitionTimer -= dt;
1062:     if (levelTransitionTimer <= 0) {
1063:       startLevel(gameState.level);
1064:     }
1065:     return;
1066:   }
1067: 
1068:   var levelDef = LEVELS[gameState.level - 1];
1069: 
1070:   // --- Wave pause between waves ---
1071:   if (wavePauseTimer > 0) {
1072:     wavePauseTimer -= dt;
1073:     return;
1074:   }
1075: 
1076:   // --- Process spawn queue ---
1077:   if (spawnQueue.length > 0) {
1078:     waveSubTimer -= dt;
1079:     while (waveSubTimer <= 0 && spawnQueue.length > 0) {
1080:       var entry = spawnQueue.shift();
1081:       var x = entry.x || rand(60, canvas.width - 60);
1082:       var y = entry.y || -40;
1083:       spawnEnemy(entry.type, x, y);
1084:       waveSubTimer += Math.max(entry.delay || 0.5, 0.05); // minimum delay prevents infinite loop
1085:     }
1086:     if (spawnQueue.length === 0) {
1087:       activeWave = null;
1088:     }
1089:     return;
1090:   }
1091: 
1092:   // --- Active wave handling ---
1093:   if (activeWave) return;
1094: 
1095:   // --- All enemies dead, check for level complete ---
1096:   if (enemies.length === 0) {
1097:     // If boss was defeated, level complete
1098:     if (levelBossDefeated) {
1099:       gameState.score += 1000 * gameState.level; // Level completion bonus
1100:       nextLevel();
1101:       return;
1102:     }
1103: 
1104:     // If all waves done, spawn boss
1105:     if (waveIndex >= levelDef.waves.length && !levelBossSpawned) {
1106:       levelBossSpawned = true;
1107:       var bossX = canvas.width / 2;
1108:       var bossY = -80;
1109:       spawnEnemy(levelDef.boss.type, bossX, bossY);
1110:       // Make boss hp match definition
1111:       var boss = enemies[enemies.length - 1];
1112:       if (boss) {
1113:         boss.hp = Math.floor(boss.maxHp * levelDef.boss.hpMultiplier);
1114:         boss.maxHp = boss.hp;
1115:       }
1116:       return;
1117:     }
1118: 
1119:     // Wait before next wave
1120:     waveTimer -= dt;
1121:     if (waveTimer <= 0) {
1122:       startNextWave();
1123:     }
1124:   }
1125: }
1126: 
1127: function startNextWave() {
1128:   var levelDef = LEVELS[gameState.level - 1];
1129:   if (waveIndex >= levelDef.waves.length) return;
1130: 
1131:   var wave = levelDef.waves[waveIndex];
1132:   waveIndex++;
1133: 
1134:   // Build spawn queue from wave definition
1135:   spawnQueue = [];
1136:   for (var i = 0; i < wave.enemies.length; i++) {
1137:     var group = wave.enemies[i];
1138:     for (var j = 0; j < group.count; j++) {
1139:       var x = rand(60, canvas.width - 60);
1140:       spawnQueue.push({ type: group.type, x: x, y: -40 - j * 30, delay: group.delay || 0.5 });
1141:     }
1142:   }
1143: 
1144:   waveSubTimer = 0.5;
1145:   activeWave = true;
1146:   wavePauseTimer = 0;
1147:   waveTimer = 0;
1148: }
1149: 
1150: function checkBossDefeated(enemy) {
1151:   if (enemy.type === 'boss' && !levelBossDefeated) {
1152:     levelBossDefeated = true;
1153:     // Clear remaining enemies
1154:     for (var i = 0; i < enemies.length; i++) {
1155:       if (enemies[i] !== enemy && enemies[i].alive) {
1156:         enemies[i].alive = false;
1157:         spawnExplosion(enemies[i].x, enemies[i].y, 6, enemies[i].color, 100, 0.4);
1158:       }
1159:     }
1160:     enemies = enemies.filter(function(e) { return e.alive; });
1161:   }
1162: }
1163: 
1164: // ---------------------------------------------------------------------------
1165: // GAME STATE MACHINE
1166: // ---------------------------------------------------------------------------
1167: 
1168: function startGame() {
1169:   gameState.state = 'playing';
1170:   gameState.score = 0;
1171:   gameState.combo = 0;
1172:   gameState.comboMultiplier = 1;
1173:   gameState.comboTimer = 0;
1174:   gameState.level = 1;
1175:   gameState.shakeMagnitude = 0;
1176: 
1177:   resetPlayer();
1178:   initBulletPool();
1179:   enemies = [];
1180:   powerups = [];
1181:   particles.length = 0;
1182: 
1183:   startLevel(1);
1184: }
1185: 
1186: function pauseGame() {
1187:   if (gameState.state === 'playing') {
1188:     gameState.state = 'paused';
1189:   }
1190: }
1191: 
1192: function resumeGame() {
1193:   if (gameState.state === 'paused') {
1194:     gameState.state = 'playing';
1195:   }
1196: }
1197: 
1198: function togglePause() {
1199:   if (gameState.state === 'playing') pauseGame();
1200:   else if (gameState.state === 'paused') resumeGame();
1201: }
1202: 
1203: function gameOver() {
1204:   gameState.state = 'gameover';
1205:   spawnExplosion(player.x, player.y, 50, '#ff4400', 350, 1.5);
1206:   triggerShake(15, 1.0);
1207: 
1208:   // Destroy all enemies
1209:   for (var i = 0; i < enemies.length; i++) {
1210:     enemies[i].alive = false;
1211:   }
1212:   enemies = [];
1213:   powerups = [];
1214: }
1215: 
1216: function restartGame() {
1217:   startGame();
1218: }
1219: 
1220: function nextLevel() {
1221:   if (gameState.level >= 3) {
1222:     // Victory!
1223:     gameState.state = 'victory';
1224:     gameState.score += 5000; // Victory bonus
1225:     spawnExplosion(canvas.width / 2, canvas.height / 2, 60, '#ffff00', 400, 2.0);
1226:     spawnExplosion(canvas.width / 2, canvas.height / 2, 30, '#ffffff', 300, 1.5);
1227:     triggerShake(20, 2.0);
1228:   } else {
1229:     gameState.level++;
1230:     levelTransitionTimer = 1.5; // brief pause before next level
1231:     // Clear screen
1232:     for (var i = 0; i < projectiles.length; i++) projectiles[i].alive = false;
1233:     enemies = [];
1234:     powerups = [];
1235:   }
1236: }
1237: 
1238: // ---------------------------------------------------------------------------
1239: // MAIN UPDATE LOOP
1240: // ---------------------------------------------------------------------------
1241: 
1242: /** Called every frame by the main game loop */
1243: function updateGameplay(dt) {
1244:   // Always update particles (they persist across states for visual juice)
1245:   updateParticles(dt);
1246: 
1247:   // Always decay shake
1248:   updateShake(dt);
1249: 
1250:   if (gameState.state !== 'playing') return;
1251: 
1252:   updatePlayer(dt);
1253:   updateBullets(dt);
1254:   updateEnemies(dt);
1255:   updatePowerUps(dt);
1256:   checkCollisions();
1257:   updateCombo(dt);
1258:   updateLevel(dt);
1259: 
1260:   // Check boss defeat (done after enemy update so boss is removed from array)
1261:   // This is handled in damageEnemy via checkBossDefeated
1262: }
1263: 
1264: // Patch damageEnemy to also check boss defeat
1265: var _damageEnemyOriginal = damageEnemy;
1266: damageEnemy = function(enemy, amount, bullet) {
1267:   _damageEnemyOriginal(enemy, amount, bullet);
1268:   if (enemy.hp <= 0 && enemy.type === 'boss') {
1269:     checkBossDefeated(enemy);
1270:   }
1271: };
1272: 
1273: // ---------------------------------------------------------------------------
1274: // BOOTSTRAP
1275: // ---------------------------------------------------------------------------
1276: 
1277: /** Initialize all gameplay systems — call once on page load */
1278: function initGameplay() {
1279:   initBulletPool();
1280:   resetPlayer();
1281:   enemies = [];
1282:   powerups = [];
1283:   waveIndex = 0;
1284:   waveTimer = 0;
1285:   levelBossSpawned = false;
1286:   levelBossDefeated = false;
1287:   levelTransitionTimer = 0;
1288:   activeWave = null;
1289:   spawnQueue = [];
1290:   wavePauseTimer = 0;
1291: }
1292: 
1293: initGameplay();

(End of file - total 1293 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/Users/srpanwar/Documents/Workspace/brain/temp/ui-audio.js"
}
```

**Output:**
```
<path>/Users/srpanwar/Documents/Workspace/brain/temp/ui-audio.js</path>
<type>file</type>
<content>
1: // ============================================================
2: // VOID STRIKERS — UI & Audio Manager
3: // Module: UIManager + AudioManager
4: // All rendering via Canvas 2D, all sound via Web Audio API
5: // ============================================================
6: 
7: // ------------------------------------------------------------
8: //  AUDIO MANAGER  (procedural sound synthesis, no external files)
9: // ------------------------------------------------------------
10: const AudioManager = (function () {
11:   "use strict";
12: 
13:   // -- private state ------------------------------------------
14:   let ctx         = null;          // AudioContext
15:   let masterGain  = null;         // master volume node
16:   let muted       = false;
17:   let masterVol   = 0.6;          // 0.0 – 1.0
18:   let initialized = false;
19: 
20:   // music nodes (kept alive so we can stop / tweak them)
21:   let musicNodes   = [];          // active oscillator / gain pairs
22:   let musicRunning = false;
23:   let musicIntensity = 0;        // 0..1   (driven by enemy count)
24:   let musicLevel    = 1;
25: 
26:   // -- helpers -----------------------------------------------
27:   function ensureCtx() {
28:     if (!ctx) {
29:       ctx = new (window.AudioContext || window.webkitAudioContext)();
30:       masterGain = ctx.createGain();
31:       masterGain.gain.value = muted ? 0 : masterVol;
32:       masterGain.connect(ctx.destination);
33:     }
34:     if (ctx.state === "suspended") ctx.resume();
35:   }
36: 
37:   /** play a simple tone / noise burst
38:    *  opts.delay (seconds) — offset from now before playback begins */
39:   function playTone(opts) {
40:     if (muted) return;
41:     ensureCtx();
42:     const delay = opts.delay || 0;
43:     const now   = ctx.currentTime + delay;
44: 
45:     const oscCount = opts.oscCount || 1;
46:     const gains    = [];
47: 
48:     for (let i = 0; i < oscCount; i++) {
49:       const osc = ctx.createOscillator();
50:       const gn  = ctx.createGain();
51: 
52:       osc.type = opts.type || "sine";
53:       osc.frequency.setValueAtTime(
54:         (opts.freq || 440) * (opts.detune ? 1 + (i * opts.detune) : 1),
55:         now
56:       );
57:       if (opts.freqEnd) {
58:         osc.frequency.linearRampToValueAtTime(opts.freqEnd, now + opts.dur);
59:       }
60:       if (opts.freqSweep) {
61:         osc.frequency.setValueAtTime(opts.freqSweep[0], now);
62:         osc.frequency.linearRampToValueAtTime(opts.freqSweep[1], now + opts.dur);
63:       }
64: 
65:       gn.gain.setValueAtTime(opts.vol || 0.3, now);
66:       gn.gain.exponentialRampToValueAtTime(0.001, now + opts.dur);
67: 
68:       osc.connect(gn);
69:       gn.connect(masterGain);
70:       osc.start(now);
71:       osc.stop(now + opts.dur + 0.05);
72:       gains.push(gn);
73:     }
74:     // noise layer (optional)
75:     if (opts.noise) {
76:       const bufSize = Math.ceil(ctx.sampleRate * opts.dur);
77:       const buffer  = ctx.createBuffer(1, bufSize, ctx.sampleRate);
78:       const data    = buffer.getChannelData(0);
79:       for (let i = 0; i < bufSize; i++) data[i] = (Math.random() * 2 - 1) * opts.noise;
80:       const src = ctx.createBufferSource();
81:       src.buffer = buffer;
82:       const gn2 = ctx.createGain();
83:       gn2.gain.setValueAtTime((opts.noiseVol || 0.2), now);
84:       gn2.gain.exponentialRampToValueAtTime(0.001, now + opts.dur);
85:       if (opts.noiseFilter) {
86:         const filt = ctx.createBiquadFilter();
87:         filt.type = "bandpass";
88:         filt.frequency.value = opts.noiseFilter;
89:         filt.Q.value = 0.8;
90:         src.connect(filt);
91:         filt.connect(gn2);
92:       } else {
93:         src.connect(gn2);
94:       }
95:       gn2.connect(masterGain);
96:       src.start(now);
97:       src.stop(now + opts.dur + 0.05);
98:       gains.push(gn2);
99:     }
100:     return gains;
101:   }
102: 
103:   // -- public API --------------------------------------------
104: 
105:   /** Call once on first user interaction to unlock AudioContext */
106:   function init() {
107:     ensureCtx();
108:     initialized = true;
109:   }
110: 
111:   function setMasterVolume(v) {
112:     masterVol = Math.max(0, Math.min(1, v));
113:     if (!muted && masterGain) masterGain.gain.setValueAtTime(masterVol, ctx.currentTime);
114:   }
115: 
116:   function toggleMute() {
117:     muted = !muted;
118:     if (masterGain) {
119:       masterGain.gain.setValueAtTime(muted ? 0 : masterVol, ctx.currentTime);
120:     }
121:     return muted;
122:   }
123: 
124:   // --- sound effects ---
125: 
126:   function playShoot() {
127:     playTone({ freq: 880, freqEnd: 1760, type: "sine", dur: 0.08, vol: 0.18 });
128:   }
129: 
130:   function playEnemyShoot() {
131:     playTone({ freq: 330, freqEnd: 220, type: "square", dur: 0.12, vol: 0.12, noise: 0.15, noiseVol: 0.07, noiseFilter: 600 });
132:   }
133: 
134:   function playExplosion() {
135:     // low rumble + noise burst
136:     playTone({ freq: 80, freqEnd: 30, type: "sawtooth", dur: 0.35, vol: 0.22 });
137:     playTone({ noise: 0.8, noiseVol: 0.3, noiseFilter: 300, dur: 0.40 });
138:   }
139: 
140:   function playHit() {
141:     playTone({ freq: 1200, freqEnd: 400, type: "square", dur: 0.06, vol: 0.15 });
142:     playTone({ noise: 0.3, noiseVol: 0.10, dur: 0.06 });
143:   }
144: 
145:   function playPowerUp() {
146:     // rising 3-note arpeggio
147:     [523, 659, 784].forEach((f, i) => {
148:       playTone({ freq: f, type: "sine", dur: 0.15, vol: 0.2, delay: i * 0.10 });
149:     });
150:   }
151: 
152:   function playPlayerHit() {
153:     // low thud + alarm tone
154:     playTone({ freq: 60, freqEnd: 20, type: "triangle", dur: 0.3, vol: 0.30 });
155:     playTone({ freq: 200, freqEnd: 600, type: "sawtooth", dur: 0.15, vol: 0.10 });
156:   }
157: 
158:   function playChargedShot() {
159:     // rising sweep then release
160:     playTone({ freqSweep: [100, 1200], type: "sine", dur: 0.35, vol: 0.25 });
161:     playTone({ freqSweep: [100, 1200], type: "sawtooth", dur: 0.35, vol: 0.06, detune: 0.03 });
162:     playTone({ noise: 0.4, noiseVol: 0.10, noiseFilter: 800, dur: 0.20 });
163:   }
164: 
165:   function playMenuSelect() {
166:     playTone({ freq: 600, type: "square", dur: 0.08, vol: 0.15 });
167:     playTone({ freq: 900, type: "square", dur: 0.06, vol: 0.12, delay: 0.04 });
168:   }
169: 
170:   function playMenuHover() {
171:     playTone({ freq: 440, type: "sine", dur: 0.04, vol: 0.10 });
172:   }
173: 
174:   function playGameOver() {
175:     // descending tones
176:     [400, 300, 200, 100].forEach((f, i) => {
177:       setTimeout(() => {
178:         playTone({ freq: f, freqEnd: f * 0.5, type: "triangle", dur: 0.4, vol: 0.18 });
179:       }, i * 150);
180:     });
181:   }
182: 
183:   function playVictory() {
184:     // triumphant ascending arpeggio
185:     [523, 659, 784, 1047, 1319].forEach((f, i) => {
186:       setTimeout(() => {
187:         playTone({ freq: f, type: "sine", dur: 0.3, vol: 0.18 });
188:       }, i * 100);
189:     });
190:   }
191: 
192:   function playBossWarning() {
193:     // pulsing low tone
194:     for (let i = 0; i < 3; i++) {
195:       setTimeout(() => {
196:         playTone({ freq: 80, type: "sawtooth", dur: 0.5, vol: 0.20 });
197:       }, i * 600);
198:     }
199:   }
200: 
201:   function playComboUp(comboLevel) {
202:     const baseFreq = 400 + comboLevel * 80;
203:     playTone({ freq: baseFreq, freqEnd: baseFreq * 1.5, type: "sine", dur: 0.12, vol: Math.min(0.25, 0.10 + comboLevel * 0.02) });
204:   }
205: 
206:   function playShieldBreak() {
207:     // shatter — noise burst with high frequencies
208:     playTone({ noise: 0.9, noiseVol: 0.30, noiseFilter: 2000, dur: 0.25 });
209:     playTone({ freq: 2000, freqEnd: 4000, type: "square", dur: 0.20, vol: 0.12 });
210:     playTone({ freq: 3000, freqEnd: 100, type: "sawtooth", dur: 0.30, vol: 0.10 });
211:   }
212: 
213:   // --- background music generator ---
214: 
215:   /** start procedural music loop */
216:   function startMusic(level) {
217:     musicLevel = level || 1;
218:     if (musicRunning) stopMusic();
219:     musicRunning = true;
220:     ensureCtx();
221:     _musicLoop();
222:   }
223: 
224:   /** stop music and dispose nodes */
225:   function stopMusic() {
226:     musicRunning = false;
227:     musicNodes.forEach(n => {
228:       try { n.stop(); } catch (e) { /* already stopped */ }
229:     });
230:     musicNodes = [];
231:   }
232: 
233:   /** call each frame to update intensity based on enemy count */
234:   function updateMusic(enemyCount, maxEnemies) {
235:     musicIntensity = maxEnemies > 0 ? enemyCount / maxEnemies : 0;
236:   }
237: 
238:   // internal music step — creates a bar's worth of notes
239:   function _musicLoop() {
240:     if (!musicRunning || muted || !ctx) { musicNodes = []; return; }
241: 
242:     const now     = ctx.currentTime;
243:     const bpm     = 110 + musicLevel * 8;            // tempo increases with level
244:     const barLen  = 60 / bpm * 4;                    // 4 beats / bar
245:     const bassFreqs = [55, 65.4, 73.4, 82.4];       // A2, C3, D3, E3 — loop pattern
246:     // pad drone (triangle, very quiet)
247:     const padFreq  = 110 * (1 + (musicLevel - 1) * 0.3);
248: 
249:     // fresh array for this bar
250:     const nodesThisBar = [];
251: 
252:     // --- bass line ---
253:     bassFreqs.forEach((f, i) => {
254:       const osc = ctx.createOscillator();
255:       const gn  = ctx.createGain();
256:       osc.type = "sawtooth";
257:       osc.frequency.value = f;
258:       gn.gain.value = 0;
259:       const beatTime = now + i * (barLen / 4);
260:       // quick attack, sustain, release
261:       gn.gain.setValueAtTime(0.14, beatTime);
262:       gn.gain.linearRampToValueAtTime(0.10, beatTime + 0.05);
263:       gn.gain.setValueAtTime(0.10, beatTime + (barLen / 4) * 0.8);
264:       gn.gain.linearRampToValueAtTime(0, beatTime + (barLen / 4));
265: 
266:       osc.connect(gn);
267:       gn.connect(masterGain);
268:       osc.start(beatTime);
269:       osc.stop(beatTime + barLen / 4 + 0.1);
270:       nodesThisBar.push(osc);
271:     });
272: 
273:     // --- pad drone ---
274:     const padOsc = ctx.createOscillator();
275:     const padGn  = ctx.createGain();
276:     padOsc.type = "triangle";
277:     padOsc.frequency.value = padFreq;
278:     padGn.gain.value = 0.04 + musicIntensity * 0.03;
279:     padOsc.connect(padGn);
280:     padGn.connect(masterGain);
281:     padOsc.start(now);
282:     padOsc.stop(now + barLen + 0.1);
283:     nodesThisBar.push(padOsc);
284: 
285:     // --- intensity layer: extra arp when many enemies ---
286:     if (musicIntensity > 0.4) {
287:       const arpFreqs = [330, 440, 550, 660, 440, 550, 660, 880];
288:       for (let i = 0; i < 8; i++) {
289:         const osc2 = ctx.createOscillator();
290:         const gn2  = ctx.createGain();
291:         osc2.type = "square";
292:         osc2.frequency.value = arpFreqs[i % arpFreqs.length];
293:         const bt = now + i * (barLen / 8);
294:         gn2.gain.setValueAtTime(0.06 * musicIntensity, bt);
295:         gn2.gain.linearRampToValueAtTime(0, bt + barLen / 8);
296:         osc2.connect(gn2);
297:         gn2.connect(masterGain);
298:         osc2.start(bt);
299:         osc2.stop(bt + barLen / 8 + 0.05);
300:         nodesThisBar.push(osc2);
301:       }
302:     }
303: 
304:     // --- hi-hat tick on beats ---
305:     for (let i = 0; i < 16; i++) {
306:       const bufSize = ctx.sampleRate * 0.04;
307:       const buffer  = ctx.createBuffer(1, bufSize, ctx.sampleRate);
308:       const data    = buffer.getChannelData(0);
309:       for (let s = 0; s < bufSize; s++) data[s] = (Math.random() * 2 - 1) * Math.exp(-s / (bufSize * 0.3));
310:       const src = ctx.createBufferSource();
311:       src.buffer = buffer;
312:       const gn3 = ctx.createGain();
313:       const filt = ctx.createBiquadFilter();
314:       filt.type = "highpass";
315:       filt.frequency.value = 3000;
316:       gn3.gain.setValueAtTime(0.05, now + i * (barLen / 16));
317:       gn3.gain.linearRampToValueAtTime(0, now + i * (barLen / 16) + 0.04);
318:       src.connect(filt);
319:       filt.connect(gn3);
320:       gn3.connect(masterGain);
321:       src.start(now + i * (barLen / 16));
322:       src.stop(now + i * (barLen / 16) + 0.05);
323:       nodesThisBar.push(src);
324:     }
325: 
326:     // schedule next bar
327:     musicNodes = nodesThisBar;
328:     setTimeout(_musicLoop, barLen * 1000);
329:   }
330: 
331:   // -- expose -------------------------------------------------
332:   return {
333:     init, setMasterVolume, toggleMute, get muted() { return muted; },
334:     playShoot, playEnemyShoot, playExplosion, playHit,
335:     playPowerUp, playPlayerHit, playChargedShot,
336:     playMenuSelect, playMenuHover,
337:     playGameOver, playVictory, playBossWarning,
338:     playComboUp, playShieldBreak,
339:     startMusic, stopMusic, updateMusic,
340:   };
341: })();
342: 
343: 
344: // ------------------------------------------------------------
345: //  UI MANAGER  (all drawing on the game canvas)
346: // ------------------------------------------------------------
347: const UIManager = (function () {
348:   "use strict";
349: 
350:   // -- private animation state --------------------------------
351:   let animTime       = 0;          // total elapsed for animations
352:   let starfield      = [];         // menu background stars
353:   let comboPopupTimer = 0;         // seconds remaining on combo popup
354:   let comboPopupText  = "";
355:   let lastComboPopup  = "";
356:   let transitionAlpha = 0;
357:   let transitionText  = "";
358:   let transitionDir   = 0;         // 1=fade in, -1=fade out
359: 
360:   // hp bar smoothing
361:   let displayHp      = 100;
362:   let displayShield  = 0;
363:   let displayCharge  = 0;
364: 
365:   // -- starfield initialisation -------------------------------
366:   function initStars(w, h) {
367:     starfield = [];
368:     for (let i = 0; i < 200; i++) {
369:       starfield.push({
370:         x: Math.random() * w,
371:         y: Math.random() * h,
372:         r: Math.random() * 2 + 0.5,
373:         speed: Math.random() * 40 + 10,
374:         brightness: Math.random() * 0.6 + 0.4,
375:       });
376:     }
377:   }
378: 
379:   // -- helper: draw text with optional glow -------------------
380:   function drawText(text, x, y, size, color, align, glowColor, glowBlur) {
381:     ctx.save();
382:     ctx.textAlign = align || "center";
383:     ctx.textBaseline = "middle";
384:     ctx.font = `bold ${size}px "Courier New", monospace`;
385: 
386:     if (glowColor) {
387:       ctx.shadowColor = glowColor;
388:       ctx.shadowBlur  = glowBlur || 10;
389:     }
390: 
391:     // draw outline stroke for readability
392:     ctx.strokeStyle = "rgba(0,0,0,0.7)";
393:     ctx.lineWidth   = 2;
394:     ctx.strokeText(text, x, y);
395:     // fill
396:     ctx.fillStyle = color;
397:     ctx.fillText(text, x, y);
398: 
399:     ctx.restore();
400:   }
401: 
402:   // -- helper: animated bar (gradient fill) -------------------
403:   function drawBar(x, y, w, h, value, maxValue, color1, color2, bgColor, borderColor) {
404:     const ratio = Math.max(0, Math.min(1, value / (maxValue || 1)));
405:     ctx.save();
406: 
407:     // background
408:     ctx.fillStyle = bgColor || "rgba(0,0,0,0.5)";
409:     ctx.fillRect(x, y, w, h);
410: 
411:     // fill with gradient
412:     if (ratio > 0) {
413:       const grad = ctx.createLinearGradient(x, y, x + w * ratio, y);
414:       grad.addColorStop(0, color1);
415:       grad.addColorStop(1, color2);
416:       ctx.fillStyle = grad;
417:       ctx.fillRect(x, y, w * ratio, h);
418:     }
419: 
420:     // border
421:     ctx.strokeStyle = borderColor || "#fff";
422:     ctx.lineWidth   = 1.5;
423:     ctx.strokeRect(x, y, w, h);
424: 
425:     ctx.restore();
426:   }
427: 
428:   // -- helper: draw interactive button ------------------------
429:   function drawButton(x, y, w, h, text, hovered) {
430:     ctx.save();
431:     ctx.fillStyle = hovered ? "rgba(255,255,255,0.2)" : "rgba(255,255,255,0.08)";
432:     ctx.fillRect(x, y, w, h);
433:     ctx.strokeStyle = hovered ? "#fff" : "#888";
434:     ctx.lineWidth = 2;
435:     ctx.strokeRect(x, y, w, h);
436:     drawText(text, x + w / 2, y + h / 2, 16, hovered ? "#fff" : "#ccc", "center", hovered ? "#fff" : null, hovered ? 8 : 0);
437:     ctx.restore();
438:   }
439: 
440:   // -- helper: text width -------------------------------------
441:   function textWidth(text, size) {
442:     ctx.save();
443:     ctx.font = `bold ${size}px "Courier New", monospace`;
444:     const w = ctx.measureText(text).width;
445:     ctx.restore();
446:     return w;
447:   }
448: 
449:   // -- combo popup trigger ------------------------------------
450:   function triggerComboPopup(combo) {
451:     comboPopupText  = `COMBO x${combo}!`;
452:     lastComboPopup  = comboPopupText;
453:     comboPopupTimer = 1.5;
454:   }
455: 
456:   // -- level transition trigger -------------------------------
457:   function triggerLevelTransition(level) {
458:     transitionText  = `LEVEL ${level}`;
459:     transitionAlpha = 0;
460:     transitionDir   = 1;  // fade in
461:   }
462: 
463:   // -- main menu drawing --------------------------------------
464:   function drawMainMenu() {
465:     if (!canvas) return;
466:     const W = canvas.width, H = canvas.height;
467:     if (W <= 0 || H <= 0) return;
468:     const t = animTime;
469: 
470:     // animated starfield background
471:     ctx.fillStyle = "#0a0a1a";
472:     ctx.fillRect(0, 0, W, H);
473:     starfield.forEach(s => {
474:       s.y += s.speed * deltaTime;
475:       if (s.y > H) { s.y = -2; s.x = Math.random() * W; }
476:       const twinkle = 0.5 + 0.5 * Math.sin(t * 3 + s.x * 0.1);
477:       const alpha = s.brightness * twinkle;
478:       ctx.fillStyle = `rgba(255,255,255,${alpha})`;
479:       ctx.beginPath();
480:       ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
481:       ctx.fill();
482:     });
483: 
484:     // pulsing glowing title
485:     const pulse  = 1 + Math.sin(t * 2) * 0.06;
486:     const glowPulse = 14 + Math.sin(t * 2.5) * 4;
487:     drawText("VOID", W / 2, H * 0.25, Math.floor(72 * pulse), "#00ffff", "center", "#00ffff", glowPulse);
488:     drawText("STRIKERS", W / 2, H * 0.38, Math.floor(56 * pulse), "#ff00ff", "center", "#ff00ff", glowPulse);
489: 
490:     // blinking "PRESS ENTER"
491:     const blink = Math.sin(t * 4) > 0;
492:     if (blink) {
493:       drawText("PRESS ENTER TO START", W / 2, H * 0.62, 22, "#ffffff", "center", "#ffffff", 6);
494:     }
495: 
496:     // controls info
497:     const ctrlY = H * 0.73;
498:     drawText("CONTROLS", W / 2, ctrlY, 14, "#888888", "center");
499:     drawText("Arrow / WASD = Move  |  Space = Charge Shot  |  P = Pause", W / 2, ctrlY + 24, 12, "#666666", "center");
500:     drawText("M = Mute  |  R = Restart", W / 2, ctrlY + 42, 12, "#666666", "center");
501: 
502:     // high score
503:     const hs = localStorage.getItem("voidStrikers_highScore") || 0;
504:     if (hs > 0) {
505:       drawText(`HIGH SCORE: ${Number(hs).toLocaleString()}`, W / 2, H * 0.92, 16, "#ffdd44", "center", "#ffdd44", 6);
506:     }
507:   }
508: 
509:   // -- pause menu drawing -------------------------------------
510:   function drawPauseMenu() {
511:     if (!canvas) return;
512:     const W = canvas.width, H = canvas.height;
513:     if (W <= 0 || H <= 0) return;
514: 
515:     // semi-transparent backdrop
516:     ctx.fillStyle = "rgba(0,0,0,0.65)";
517:     ctx.fillRect(0, 0, W, H);
518: 
519:     drawText("PAUSED", W / 2, H * 0.35, 56, "#ffffff", "center", "#ffffff", 16);
520:     drawText("Press P to Resume",  W / 2, H * 0.52, 20, "#cccccc", "center", "#cccccc", 4);
521:     drawText("Press R to Restart", W / 2, H * 0.60, 20, "#cccccc", "center", "#cccccc", 4);
522:     drawText("Press M for Main Menu", W / 2, H * 0.68, 20, "#cccccc", "center", "#cccccc", 4);
523:   }
524: 
525:   // -- HUD drawing --------------------------------------------
526:   function drawHUD() {
527:     if (!canvas || !player || !gameState) return;
528:     const W = canvas.width, H = canvas.height;
529:     if (W <= 0 || H <= 0) return;
530:     const margin    = 16;
531:     const barWidth  = 180;
532:     const barHeight = 14;
533: 
534:     displayHp     += (player.hp - displayHp) * Math.min(deltaTime * 6, 1);
535:     displayShield  += ((player.shield || 0) - displayShield) * Math.min(deltaTime * 6, 1);
536:     displayCharge  += ((player.chargeLevel || 0) - displayCharge) * Math.min(deltaTime * 10, 1);
537: 
538:     // ---- top-left: score + combo multiplier ----
539:     const comboMul = (gameState.comboMultiplier || 1).toFixed(1);
540:     const comboActive = gameState.comboMultiplier > 1;
541:     const comboGlow  = comboActive ? Math.sin(animTime * 6) * 0.3 + 0.7 : 0;
542:     const scoreStr   = `SCORE: ${(gameState.score || 0).toLocaleString()}`;
543:     const mulStr     = ` x${comboMul}`;
544:     drawText(scoreStr, margin, margin + 8, 18, "#ffffff", "left");
545:     if (comboActive) {
546:       drawText(mulStr, margin + textWidth(scoreStr, 18) + 4, margin + 8, 18,
547:         `rgba(255,${Math.floor(200 + comboGlow * 55)},0,${0.8 + comboGlow * 0.2})`, "left",
548:         `rgba(255,${Math.floor(200 + comboGlow * 55)},0,1)`, 6 + comboGlow * 6);
549:     }
550: 
551:     // ---- top-right: level ----
552:     drawText(`LEVEL ${gameState.level || 1}`, W - margin, margin + 8, 18, "#00ccff", "right",
553:       "#00ccff", 6);
554: 
555:     // ---- bottom-left: health bar ----
556:     const barX = margin;
557:     const barY = H - margin - 60;
558:     const hpRatio = displayHp / (player.maxHp || 100);
559:     // colour shifts red → yellow → green
560:     const hpR = hpRatio < 0.5 ? 255 : Math.floor(255 * (1 - hpRatio) * 2);
561:     const hpG = hpRatio < 0.5 ? Math.floor(255 * hpRatio * 2) : 255;
562:     drawBar(barX, barY, barWidth, barHeight, displayHp, player.maxHp || 100,
563:       `rgb(${hpR},${Math.max(hpG,30)},0)`, "#00ff33",
564:       "rgba(0,0,0,0.6)", "#aaa");
565:     drawText(`HP  ${Math.ceil(displayHp)} / ${player.maxHp || 100}`,
566:       barX + barWidth / 2, barY + barHeight / 2, 11, "#fff", "center");
567: 
568:     // ---- shield bar (below HP) ----
569:     const maxShield = player.maxShield || (player.maxHp ? player.maxHp * 0.5 : 50);
570:     if ((player.shield || 0) > 0 || displayShield > 0.5) {
571:       const sy = barY + barHeight + 4;
572:       drawBar(barX, sy, barWidth, barHeight - 2, displayShield, maxShield,
573:         "#4488ff", "#88ccff",
574:         "rgba(0,0,0,0.6)", "#5588ff");
575:       drawText(`SHIELD`, barX + barWidth / 2, sy + (barHeight - 2) / 2, 9, "#88ccff", "center");
576:     }
577: 
578:     // ---- bottom-right: weapon level ----
579:     const wl = player.weaponLevel || 1;
580:     const weaponNames = ["BLASTER", "TWIN", "SPREAD", "LASER", "VORTEX"];
581:     const weaponName  = weaponNames[Math.min(wl - 1, weaponNames.length - 1)];
582:     const wIconSize = 18;
583:     const wX = W - margin - 140;
584:     const wY = H - margin - 40;
585:     drawText(`⚡ ${weaponName}`, wX, wY, 14,
586:       wl >= 4 ? "#ff44ff" : wl >= 3 ? "#ff8800" : wl >= 2 ? "#ffcc00" : "#00ffcc",
587:       "right", null, 0);
588:     // small weapon level dots
589:     for (let i = 1; i <= 5; i++) {
590:       const filled = i <= wl;
591:       ctx.beginPath();
592:       ctx.arc(wX + i * 20, wY + 22, 4, 0, Math.PI * 2);
593:       ctx.fillStyle = filled ? (i >= 4 ? "#ff44ff" : i >= 3 ? "#ff8800" : "#00ffcc") : "#333";
594:       ctx.fill();
595:       ctx.strokeStyle = "#555";
596:       ctx.lineWidth = 1;
597:       ctx.stroke();
598:     }
599: 
600:     // ---- bottom-center: charge meter ----
601:     if (player.chargeLevel > 0 || displayCharge > 0.5) {
602:       const cw = 140, ch = 10;
603:       const cx = W / 2 - cw / 2;
604:       const cy = H - margin - 30;
605:       const chargePct = displayCharge / (player.maxCharge || 100);
606:       drawBar(cx, cy, cw, ch, displayCharge, player.maxCharge || 100,
607:         "#00ffff", "#ff00ff",
608:         "rgba(0,0,0,0.5)", "#00ffff");
609:       drawText("CHARGE", W / 2, cy + ch / 2, 9, "#00ffff", "center", "#00ffff", 4);
610:     }
611: 
612:     // ---- speed boost timer ----
613:     if (player.speedBoost > 0) {
614:       const sbStr = `SPEED ${player.speedBoost.toFixed(1)}s`;
615:       drawText(sbStr, margin, barY - 24, 14, "#ffff00", "left", "#ffff00", 5);
616:     }
617: 
618:     // ---- combo popup (centre, temporary) ----
619:     if (comboPopupTimer > 0) {
620:       comboPopupTimer -= deltaTime;
621:       const alpha = Math.min(1, comboPopupTimer / 0.3);
622:       const scale  = 1 + (1.5 - Math.min(1.5, comboPopupTimer)) * 0.4;
623:       const c = comboPopupText.split("x");
624:       const baseY = H * 0.3 + Math.sin(animTime * 5) * 8;  // slight bob
625:       ctx.save();
626:       ctx.globalAlpha = alpha;
627:       drawText(comboPopupText, W / 2, baseY, Math.floor(36 * scale), "#ff8800", "center", "#ff8800", 12);
628:       ctx.restore();
629:     }
630:   }
631: 
632:   // -- game over screen ---------------------------------------
633:   function drawGameOver() {
634:     if (!canvas || !gameState) return;
635:     const W = canvas.width, H = canvas.height;
636:     if (W <= 0 || H <= 0) return;
637: 
638:     ctx.fillStyle = "rgba(10,0,0,0.75)";
639:     ctx.fillRect(0, 0, W, H);
640: 
641:     // dramatic shake offset
642:     const shakeX = Math.sin(animTime * 50) * 3;
643:     const shakeY = Math.cos(animTime * 47) * 2;
644: 
645:     drawText("GAME OVER", W / 2 + shakeX, H * 0.28 + shakeY, 60, "#ff2222", "center", "#ff2222", 20);
646: 
647:     // stats
648:     const score = (gameState.score || 0).toLocaleString();
649:     const enemiesDestroyed = (gameState.enemiesKilled || 0).toLocaleString();
650:     const maxCombo = (gameState.maxCombo || 0);
651:     drawText(`FINAL SCORE: ${score}`, W / 2, H * 0.46, 26, "#ffdd44", "center", "#ffdd44", 8);
652:     drawText(`Enemies Destroyed: ${enemiesDestroyed}   Max Combo: x${maxCombo}`,
653:       W / 2, H * 0.54, 16, "#aaaaaa", "center");
654:     drawText("Press R to Restart",   W / 2, H * 0.70, 18, "#cccccc", "center", "#cccccc", 4);
655:     drawText("Press M for Main Menu", W / 2, H * 0.78, 18, "#cccccc", "center", "#cccccc", 4);
656:   }
657: 
658:   // -- victory screen -----------------------------------------
659:   function drawVictory() {
660:     if (!canvas || !gameState) return;
661:     const W = canvas.width, H = canvas.height;
662:     if (W <= 0 || H <= 0) return;
663: 
664:     ctx.fillStyle = "rgba(0,5,20,0.7)";
665:     ctx.fillRect(0, 0, W, H);
666: 
667:     const pulse = 1 + Math.sin(animTime * 3) * 0.04;
668:     drawText("VICTORY!", W / 2, H * 0.25, Math.floor(64 * pulse), "#ffcc00", "center", "#ffcc00", 22);
669: 
670:     const score = (gameState.score || 0).toLocaleString();
671:     const enemiesDestroyed = (gameState.enemiesKilled || 0).toLocaleString();
672:     drawText(`SCORE: ${score}`, W / 2, H * 0.42, 28, "#ffffff", "center", "#ffffff", 8);
673:     drawText(`Enemies Destroyed: ${enemiesDestroyed}`, W / 2, H * 0.50, 18, "#88ccff", "center");
674:     drawText(`Max Combo: x${gameState.maxCombo || 0}   Level Reached: ${gameState.level || 1}`,
675:       W / 2, H * 0.57, 16, "#888888", "center");
676:     drawText("Press R to Play Again", W / 2, H * 0.72, 20, "#ffffff", "center", "#ffffff", 6);
677:   }
678: 
679:   // -- level transition overlay -------------------------------
680:   function drawLevelTransition() {
681:     if (!canvas) return false;
682:     const W = canvas.width, H = canvas.height;
683:     if (W <= 0 || H <= 0) return false;
684: 
685:     // animate alpha based on direction
686:     if (transitionDir === 1) {
687:       transitionAlpha += deltaTime * 2;
688:       if (transitionAlpha >= 1) { transitionDir = -1; transitionAlpha = 1; }
689:     } else if (transitionDir === -1) {
690:       transitionAlpha -= deltaTime * 2;
691:       if (transitionAlpha <= 0) { transitionDir = 0; transitionAlpha = 0; transitionText = ""; }
692:     }
693:     if (transitionAlpha <= 0) return;
694: 
695:     ctx.save();
696:     ctx.globalAlpha = transitionAlpha;
697: 
698:     // dark backdrop with scanline feel
699:     ctx.fillStyle = "#000";
700:     ctx.fillRect(0, 0, W, H);
701: 
702:     const scale = 1 + transitionAlpha * 0.3;
703:     drawText(transitionText, W / 2, H / 2, Math.floor(56 * scale), "#00ffff", "center", "#00ffff", 20 * transitionAlpha);
704: 
705:     ctx.restore();
706: 
707:     return transitionDir !== 0;
708:   }
709: 
710:   // -- main update (called every frame) -----------------------
711:   function update(dt) {
712:     animTime += dt;
713:     if (!canvas) return;
714: 
715:     // ensure stars on first frame
716:     if (starfield.length === 0 && canvas.width > 0) {
717:       initStars(canvas.width, canvas.height);
718:     }
719:   }
720: 
721:   // -- public extra helpers -----------------------------------
722:   function onResize() {
723:     initStars(canvas.width, canvas.height);
724:   }
725: 
726:   return {
727:     // core draw / update
728:     update,
729:     drawMainMenu,
730:     drawPauseMenu,
731:     drawHUD,
732:     drawGameOver,
733:     drawVictory,
734:     drawLevelTransition,
735:     // helpers
736:     drawText,
737:     drawBar,
738:     drawButton,
739:     textWidth,
740:     // triggers
741:     triggerComboPopup,
742:     triggerLevelTransition,
743:     // state
744:     onResize,
745:     get comboPopupTimer() { return comboPopupTimer; },
746:     get transitionActive() { return transitionDir !== 0; },
747:   };
748: })();

(End of file - total 748 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/Users/srpanwar/Documents/Workspace/brain/temp/renderer.js"
}
```

**Output:**
```
<path>/Users/srpanwar/Documents/Workspace/brain/temp/renderer.js</path>
<type>file</type>
<content>
1: /**
2:  * Void Strikers — Rendering Engine
3:  *
4:  * A self-contained module that provides all visual rendering for the game.
5:  * Relies on shared globals: canvas, ctx, CONFIG, gameState, player, enemies,
6:  * projectiles, powerups, particles, deltaTime, shakeIntensity.
7:  *
8:  * All rendering uses Canvas2D with composite blending for glow / lighting.
9:  */
10: 
11: const Renderer = (function () {
12:     'use strict';
13: 
14:     // ──────────────────────────────────────────────
15:     // PRIVATE STATE
16:     // ──────────────────────────────────────────────
17: 
18:     /** Accumulated time in seconds – drives animations, twinkling, pulsing etc. */
19:     var _time = 0;
20: 
21:     /** Camera position (smoothed) and shake offsets */
22:     var _camera = {
23:         x: 0,
24:         y: 0,
25:         targetX: 0,
26:         targetY: 0,
27:         shakeX: 0,
28:         shakeY: 0,
29:         shakeTimer: 0,      // remaining shake duration (seconds)
30:         shakeMagnitude: 0   // current shake amplitude (pixels)
31:     };
32: 
33:     /** Starfield — three layers of star arrays */
34:     var _stars = { far: [], mid: [], near: [] };
35: 
36:     /** Nebula gradient shift counter */
37:     var _nebulaShift = 0;
38: 
39:     /** Grid-line phase for space-station levels */
40:     var _gridPhase = 0;
41: 
42:     /** Cached canvas dimensions for resize */
43:     var _width = 0;
44:     var _height = 0;
45: 
46:     /** Desired game aspect ratio */
47:     var ASPECT = 16 / 9;
48: 
49:     // ──────────────────────────────────────────────
50:     // HELPERS
51:     // ──────────────────────────────────────────────
52: 
53:     /** Linear interpolation */
54:     function lerp(a, b, t) { return a + (b - a) * t; }
55: 
56:     /** Clamp value between min and max */
57:     function clamp(v, lo, hi) { return v < lo ? lo : v > hi ? hi : v; }
58: 
59:     /** Convert degrees to radians */
60:     function deg2rad(d) { return d * Math.PI / 180; }
61: 
62:     /** 2D distance */
63:     function dist(x1, y1, x2, y2) {
64:         var dx = x2 - x1, dy = y2 - y1;
65:         return Math.sqrt(dx * dx + dy * dy);
66:     }
67: 
68:     /** Wrap angle to [-PI, PI] */
69:     function angleLerp(a, b, t) {
70:         var d = b - a;
71:         while (d > Math.PI) d -= Math.PI * 2;
72:         while (d < -Math.PI) d += Math.PI * 2;
73:         return a + d * t;
74:     }
75: 
76:     /** Random float in [min, max) */
77:     function rand(min, max) { return Math.random() * (max - min) + min; }
78: 
79:     /** Random int in [min, max] inclusive */
80:     function randInt(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }
81: 
82:     // ──────────────────────────────────────────────
83:     // 1. STARFIELD BACKGROUND
84:     // ──────────────────────────────────────────────
85: 
86:     /**
87:      * Generate a single star with randomised properties for a given depth layer.
88:      * @param {number} depth 0=far, 1=mid, 2=near
89:      * @returns {Object} star data
90:      */
91:     function _createStar(depth) {
92:         var layerSpeed = [
93:             CONFIG.starSpeedFar  || 5,
94:             CONFIG.starSpeedMid  || 15,
95:             CONFIG.starSpeedNear || 30
96:         ];
97:         var layerSize = [
98:             CONFIG.starSizeFar  || [0.3, 0.8],
99:             CONFIG.starSizeMid  || [0.6, 1.4],
100:             CONFIG.starSizeNear || [1.0, 2.5]
101:         ];
102:         var s = {
103:             x: Math.random() * (_width  || 1920),
104:             y: Math.random() * (_height || 1080),
105:             size: rand(layerSize[depth][0], layerSize[depth][1]),
106:             brightness: rand(0.3, 1.0),
107:             twinkleOffset: rand(0, Math.PI * 2),
108:             twinkleSpeed:  rand(0.5, 3.0),
109:             speed:         layerSpeed[depth],
110:             layer:         depth
111:         };
112:         return s;
113:     }
114: 
115:     /**
116:      * Initialise star arrays — 200+ stars across 3 layers.
117:      * Call once during setup (after canvas sizing).
118:      */
119:     function _initStars() {
120:         _stars.far.length  = 0;
121:         _stars.mid.length  = 0;
122:         _stars.near.length = 0;
123:         for (var i = 0; i < 100; i++) _stars.far.push(_createStar(0));
124:         for (var j = 0; j < 80;  j++) _stars.mid.push(_createStar(1));
125:         for (var k = 0; k < 50;  k++) _stars.near.push(_createStar(2));
126:     }
127: 
128:     /**
129:      * Update and render the starfield for one layer.
130:      * @param {Array} stars
131:      * @param {number} speedMultiplier  how fast this layer drifts
132:      */
133:     function _renderStarLayer(stars, speedMultiplier) {
134:         var len = stars.length;
135:         for (var i = 0; i < len; i++) {
136:             var s = stars[i];
137: 
138:             // Twinkling alpha
139:             var twinkle = Math.sin(_time * s.twinkleSpeed + s.twinkleOffset) * 0.5 + 0.5;
140:             var alpha = Math.max(0.1, s.brightness * (0.5 + 0.5 * twinkle));
141: 
142:             // Draw star as a tiny filled circle with optional glow
143:             ctx.save();
144:             ctx.globalAlpha = alpha;
145:             ctx.fillStyle = '#ffffff';
146: 
147:             // Subtle glow for near / mid stars via radial gradient
148:             if (s.layer > 0) {
149:                 var grd = ctx.createRadialGradient(s.x, s.y, 0, s.x, s.y, s.size * 3);
150:                 grd.addColorStop(0, 'rgba(180,210,255,' + alpha + ')');
151:                 grd.addColorStop(0.3, 'rgba(140,180,255,' + (alpha * 0.6) + ')');
152:                 grd.addColorStop(1, 'rgba(80,120,200,0)');
153:                 ctx.fillStyle = grd;
154:             }
155: 
156:             ctx.beginPath();
157:             ctx.arc(s.x, s.y, s.size, 0, Math.PI * 2);
158:             ctx.fill();
159:             ctx.restore();
160: 
161:             // Drift downward (parallax)
162:             s.y += s.speed * speedMultiplier * (deltaTime || 0.016);
163:             if (s.y > _height + 10) {
164:                 s.y = -10;
165:                 s.x = Math.random() * _width;
166:             }
167:         }
168:     }
169: 
170:     // ──────────────────────────────────────────────
171:     // 2. PLAYER SHIP RENDERING
172:     // ──────────────────────────────────────────────
173: 
174:     /**
175:      * Draw the player's ship as a geometric composition:
176:      * main triangular body + trapezoidal wings + cockpit + engine glow.
177:      */
178:     function _renderPlayerShip() {
179:         if (!player || !player.x || !player.y) return;
180: 
181:         var px = player.x - _camera.x;
182:         var py = player.y - _camera.y;
183:         var rot = player.rotation || 0;
184:         var scale = player.scale || 1;
185: 
186:         // Weapon level affects visual
187:         var wpnLevel = player.weaponLevel || 1;
188: 
189:         ctx.save();
190:         ctx.translate(px, py);
191:         ctx.rotate(rot);
192:         ctx.scale(scale, scale);
193: 
194:         // -- Engine glow (pulsing behind ship) --
195:         var glowPulse = Math.sin(_time * 8) * 0.3 + 0.7;
196:         var engineGrd = ctx.createRadialGradient(0, 18, 2, 0, 28, 20);
197:         engineGrd.addColorStop(0, 'rgba(0,200,255,' + (0.9 * glowPulse) + ')');
198:         engineGrd.addColorStop(0.4, 'rgba(0,140,255,' + (0.5 * glowPulse) + ')');
199:         engineGrd.addColorStop(1, 'rgba(0,60,200,0)');
200:         ctx.fillStyle = engineGrd;
201:         ctx.beginPath();
202:         ctx.arc(0, 20, 16, 0, Math.PI * 2);
203:         ctx.fill();
204: 
205:         // Left engine
206:         ctx.beginPath();
207:         ctx.arc(-10, 14, 8, 0, Math.PI * 2);
208:         ctx.fill();
209:         // Right engine
210:         ctx.beginPath();
211:         ctx.arc(10, 14, 8, 0, Math.PI * 2);
212:         ctx.fill();
213: 
214:         // -- Main body (central triangle pointing up) --
215:         ctx.fillStyle = CONFIG.playerColor || '#00ccff';
216:         ctx.strokeStyle = '#004466';
217:         ctx.lineWidth = 1.5;
218:         ctx.beginPath();
219:         ctx.moveTo(0, -22);       // nose
220:         ctx.lineTo(-12, 10);       // left mid
221:         ctx.lineTo(-6, 6);         // left inner
222:         ctx.lineTo(0, 22);         // tail bottom
223:         ctx.lineTo(6, 6);          // right inner
224:         ctx.lineTo(12, 10);        // right mid
225:         ctx.closePath();
226:         ctx.fill();
227:         ctx.stroke();
228: 
229:         // -- Left wing (trapezoid) --
230:         ctx.fillStyle = '#0088cc';
231:         ctx.strokeStyle = '#004466';
232:         ctx.lineWidth = 1.2;
233:         ctx.beginPath();
234:         ctx.moveTo(-12, 6);
235:         ctx.lineTo(-24, 18);
236:         ctx.lineTo(-16, 22);
237:         ctx.lineTo(-6, 14);
238:         ctx.closePath();
239:         ctx.fill();
240:         ctx.stroke();
241: 
242:         // -- Right wing (trapezoid) --
243:         ctx.beginPath();
244:         ctx.moveTo(12, 6);
245:         ctx.lineTo(24, 18);
246:         ctx.lineTo(16, 22);
247:         ctx.lineTo(6, 14);
248:         ctx.closePath();
249:         ctx.fill();
250:         ctx.stroke();
251: 
252:         // -- Cockpit highlight --
253:         var cockpitGrd = ctx.createLinearGradient(0, -16, 0, 0);
254:         cockpitGrd.addColorStop(0, 'rgba(100,230,255,0.9)');
255:         cockpitGrd.addColorStop(1, 'rgba(0,120,200,0.3)');
256:         ctx.fillStyle = cockpitGrd;
257:         ctx.beginPath();
258:         ctx.moveTo(0, -16);
259:         ctx.lineTo(-5, 0);
260:         ctx.lineTo(5, 0);
261:         ctx.closePath();
262:         ctx.fill();
263: 
264:         // -- Weapon upgrade visuals (extra barrel shapes) --
265:         if (wpnLevel >= 2) {
266:             // Level 2: small wing cannons
267:             ctx.fillStyle = '#ffaa00';
268:             ctx.strokeStyle = '#884400';
269:             ctx.lineWidth = 1;
270:             _drawCannon(-20, 12, 0.5);
271:             _drawCannon(20, 12, 0.5);
272:         }
273:         if (wpnLevel >= 3) {
274:             // Level 3: medium cannons further out
275:             ctx.fillStyle = '#ff6600';
276:             ctx.strokeStyle = '#662200';
277:             ctx.lineWidth = 1;
278:             _drawCannon(-26, 8, 0.65);
279:             _drawCannon(26, 8, 0.65);
280:         }
281:         if (wpnLevel >= 4) {
282:             // Level 4: large cannons with glow
283:             ctx.fillStyle = '#ff3300';
284:             ctx.strokeStyle = '#441100';
285:             ctx.lineWidth = 1.2;
286:             _drawCannon(-30, 4, 0.8);
287:             _drawCannon(30, 4, 0.8);
288:         }
289: 
290:         // -- Shield (if active) --
291:         if (player.shieldActive) {
292:             var shieldAlpha = 0.3 + Math.sin(_time * 6) * 0.15;
293:             var shieldGrd = ctx.createRadialGradient(0, 0, 20, 0, 0, 32);
294:             shieldGrd.addColorStop(0, 'rgba(0,180,255,0)');
295:             shieldGrd.addColorStop(0.7, 'rgba(0,180,255,' + (shieldAlpha * 0.5) + ')');
296:             shieldGrd.addColorStop(0.85, 'rgba(0,200,255,' + shieldAlpha + ')');
297:             shieldGrd.addColorStop(1, 'rgba(0,220,255,0)');
298:             ctx.fillStyle = shieldGrd;
299:             ctx.beginPath();
300:             ctx.arc(0, 0, 32, 0, Math.PI * 2);
301:             ctx.fill();
302: 
303:             // Animated shield arcs
304:             ctx.strokeStyle = 'rgba(0,220,255,' + (shieldAlpha + 0.2) + ')';
305:             ctx.lineWidth = 2;
306:             for (var a = 0; a < 4; a++) {
307:                 var startAngle = (_time * 2 + a * Math.PI / 2) % (Math.PI * 2);
308:                 ctx.beginPath();
309:                 ctx.arc(0, 0, 30, startAngle, startAngle + 0.8);
310:                 ctx.stroke();
311:             }
312:         }
313: 
314:         ctx.restore();
315:     }
316: 
317:     /** Helper: draw a single cannon barrel */
318:     function _drawCannon(cx, cy, s) {
319:         ctx.beginPath();
320:         ctx.moveTo(cx - 3 * s, cy);
321:         ctx.lineTo(cx - 2 * s, cy - 8 * s);
322:         ctx.lineTo(cx + 2 * s, cy - 8 * s);
323:         ctx.lineTo(cx + 3 * s, cy);
324:         ctx.closePath();
325:         ctx.fill();
326:         ctx.stroke();
327:     }
328: 
329:     // ──────────────────────────────────────────────
330:     // 3. ENEMY RENDERING
331:     // ──────────────────────────────────────────────
332: 
333:     /**
334:      * Render all enemies, dispatching to type-specific drawing.
335:      * Handles hit-flash (white flash on damage) and death effects.
336:      */
337:     function _renderEnemies() {
338:         if (!enemies || !enemies.length) return;
339: 
340:         for (var i = 0; i < enemies.length; i++) {
341:             var e = enemies[i];
342:             if (!e || !e.alive && !e.deathTimer) continue;
343: 
344:             var ex = e.x - _camera.x;
345:             var ey = e.y - _camera.y;
346:             var er = e.rotation || 0;
347:             var scale = e.scale || 1;
348: 
349:             // Hit flash — briefly tint white
350:             var hitFlash = e.hitTimer > 0;
351: 
352:             // Death effect
353:             if (!e.alive && e.deathTimer > 0) {
354:                 _renderEnemyDeath(ex, ey, e);
355:                 continue;
356:             }
357:             if (!e.alive) continue;
358: 
359:             ctx.save();
360:             ctx.translate(ex, ey);
361:             ctx.rotate(er);
362:             ctx.scale(scale, scale);
363: 
364:             if (hitFlash) {
365:                 ctx.globalCompositeOperation = 'lighter';
366:             }
367: 
368:             switch (e.type) {
369:                 case 'scout':   _drawScout(e, hitFlash);   break;
370:                 case 'fighter': _drawFighter(e, hitFlash); break;
371:                 case 'tank':    _drawTank(e, hitFlash);    break;
372:                 case 'sniper':  _drawSniper(e, hitFlash);  break;
373:                 case 'boss':    _drawBoss(e, hitFlash);    break;
374:                 default:        _drawScout(e, hitFlash);   break;
375:             }
376: 
377:             ctx.restore();
378:         }
379:     }
380: 
381:     /** Scout: Small diamond with a faint trail */
382:     function _drawScout(e, flash) {
383:         var baseColor = CONFIG.scoutColor || '#ff66cc';
384:         ctx.fillStyle = flash ? '#ffffff' : baseColor;
385:         ctx.strokeStyle = flash ? '#ffffff' : '#cc3388';
386:         ctx.lineWidth = 1;
387:         ctx.beginPath();
388:         ctx.moveTo(0, -10);
389:         ctx.lineTo(7, 0);
390:         ctx.lineTo(0, 10);
391:         ctx.lineTo(-7, 0);
392:         ctx.closePath();
393:         ctx.fill();
394:         ctx.stroke();
395: 
396:         // Inner accent
397:         ctx.fillStyle = flash ? '#ffffff' : '#ff99dd';
398:         ctx.beginPath();
399:         ctx.moveTo(0, -5);
400:         ctx.lineTo(3, 0);
401:         ctx.lineTo(0, 5);
402:         ctx.lineTo(-3, 0);
403:         ctx.closePath();
404:         ctx.fill();
405: 
406:         // Engine trail dot
407:         ctx.fillStyle = 'rgba(255,102,204,0.6)';
408:         ctx.beginPath();
409:         ctx.arc(0, 12, 2, 0, Math.PI * 2);
410:         ctx.fill();
411:     }
412: 
413:     /** Fighter: Arrow / triangle with wing shapes */
414:     function _drawFighter(e, flash) {
415:         var baseColor = CONFIG.fighterColor || '#ff4444';
416:         ctx.fillStyle = flash ? '#ffffff' : baseColor;
417:         ctx.strokeStyle = flash ? '#ffffff' : '#991111';
418:         ctx.lineWidth = 1.2;
419: 
420:         // Arrow head pointing up
421:         ctx.beginPath();
422:         ctx.moveTo(0, -14);
423:         ctx.lineTo(-9, 6);
424:         ctx.lineTo(-4, 3);
425:         ctx.lineTo(-4, 14);
426:         ctx.lineTo(4, 14);
427:         ctx.lineTo(4, 3);
428:         ctx.lineTo(9, 6);
429:         ctx.closePath();
430:         ctx.fill();
431:         ctx.stroke();
432: 
433:         // Wing accents
434:         ctx.fillStyle = flash ? '#ffffff' : '#cc2222';
435:         ctx.beginPath();
436:         ctx.moveTo(-9, 6);
437:         ctx.lineTo(-18, 10);
438:         ctx.lineTo(-9, 12);
439:         ctx.closePath();
440:         ctx.fill();
441:         ctx.beginPath();
442:         ctx.moveTo(9, 6);
443:         ctx.lineTo(18, 10);
444:         ctx.lineTo(9, 12);
445:         ctx.closePath();
446:         ctx.fill();
447:     }
448: 
449:     /** Tank: Large hexagon with armor plates */
450:     function _drawTank(e, flash) {
451:         var baseColor = CONFIG.tankColor || '#ff8833';
452:         var r = 16;
453:         ctx.fillStyle = flash ? '#ffffff' : baseColor;
454:         ctx.strokeStyle = flash ? '#ffffff' : '#884411';
455:         ctx.lineWidth = 1.5;
456: 
457:         // Hexagon
458:         ctx.beginPath();
459:         for (var i = 0; i < 6; i++) {
460:             var angle = deg2rad(60 * i - 90);
461:             var px = Math.cos(angle) * r;
462:             var py = Math.sin(angle) * r;
463:             if (i === 0) ctx.moveTo(px, py);
464:             else ctx.lineTo(px, py);
465:         }
466:         ctx.closePath();
467:         ctx.fill();
468:         ctx.stroke();
469: 
470:         // Armor plate lines
471:         ctx.strokeStyle = flash ? '#ffffff' : '#aa5511';
472:         ctx.lineWidth = 1;
473:         ctx.beginPath();
474:         ctx.moveTo(-10, -4);
475:         ctx.lineTo(10, -4);
476:         ctx.moveTo(-13, 8);
477:         ctx.lineTo(13, 8);
478:         ctx.moveTo(-6, -12);
479:         ctx.lineTo(-6, -6);
480:         ctx.moveTo(6, -12);
481:         ctx.lineTo(6, -6);
482:         ctx.stroke();
483: 
484:         // Center dot
485:         ctx.fillStyle = flash ? '#ffffff' : '#ffaa66';
486:         ctx.beginPath();
487:         ctx.arc(0, 0, 4, 0, Math.PI * 2);
488:         ctx.fill();
489:     }
490: 
491:     /** Sniper: Thin elongated diamond with targeting line */
492:     function _drawSniper(e, flash) {
493:         var baseColor = CONFIG.sniperColor || '#aadd00';
494:         ctx.fillStyle = flash ? '#ffffff' : baseColor;
495:         ctx.strokeStyle = flash ? '#ffffff' : '#668800';
496:         ctx.lineWidth = 1;
497: 
498:         // Elongated diamond (vertical)
499:         ctx.beginPath();
500:         ctx.moveTo(0, -20);
501:         ctx.lineTo(5, 0);
502:         ctx.lineTo(0, 14);
503:         ctx.lineTo(-5, 0);
504:         ctx.closePath();
505:         ctx.fill();
506:         ctx.stroke();
507: 
508:         // Targeting lens at front
509:         ctx.fillStyle = flash ? '#ffffff' : '#ccff33';
510:         ctx.beginPath();
511:         ctx.arc(0, -16, 3, 0, Math.PI * 2);
512:         ctx.fill();
513: 
514:         // Targeting line extending forward (shows where sniper is aiming)
515:         if (e.lookX !== undefined && e.lookY !== undefined) {
516:             ctx.strokeStyle = 'rgba(170,221,0,0.3)';
517:             ctx.lineWidth = 0.5;
518:             ctx.setLineDash([4, 8]);
519:             // Convert world look direction to local space — approximate as forward for simplicity
520:             // Full implementation would rotate based on e.lookX/e.lookY
521:             ctx.beginPath();
522:             ctx.moveTo(0, -25);
523:             ctx.lineTo(0, -90);
524:             ctx.stroke();
525:             ctx.setLineDash([]);
526:         }
527: 
528:         // Side fins
529:         ctx.fillStyle = flash ? '#ffffff' : '#88bb00';
530:         ctx.beginPath();
531:         ctx.moveTo(-5, 6);
532:         ctx.lineTo(-11, 10);
533:         ctx.lineTo(-5, 10);
534:         ctx.closePath();
535:         ctx.fill();
536:         ctx.beginPath();
537:         ctx.moveTo(5, 6);
538:         ctx.lineTo(11, 10);
539:         ctx.lineTo(5, 10);
540:         ctx.closePath();
541:         ctx.fill();
542:     }
543: 
544:     /** Boss: Large complex multi-segment shape */
545:     function _drawBoss(e, flash) {
546:         var baseColor = CONFIG.bossColor || '#ff3333';
547:         var r = 35;
548:         var pulse = Math.sin(_time * 2.5) * 0.1 + 0.9;
549: 
550:         // Outer hull (octagonal)
551:         ctx.fillStyle = flash ? '#ffffff' : baseColor;
552:         ctx.strokeStyle = flash ? '#ffffff' : '#880000';
553:         ctx.lineWidth = 2;
554:         ctx.beginPath();
555:         for (var i = 0; i < 8; i++) {
556:             var angle = deg2rad(45 * i - 90);
557:             var radius = (i % 2 === 0) ? r : r * 0.85;
558:             var px = Math.cos(angle) * radius;
559:             var py = Math.sin(angle) * radius;
560:             if (i === 0) ctx.moveTo(px, py);
561:             else ctx.lineTo(px, py);
562:         }
563:         ctx.closePath();
564:         ctx.fill();
565:         ctx.stroke();
566: 
567:         // Inner armor ring
568:         ctx.fillStyle = flash ? '#ffffff' : '#cc1111';
569:         ctx.beginPath();
570:         ctx.arc(0, 0, 22, 0, Math.PI * 2);
571:         ctx.fill();
572: 
573:         // Glowing core
574:         var coreGrd = ctx.createRadialGradient(0, 0, 4, 0, 0, 16);
575:         coreGrd.addColorStop(0, flash ? '#ffffff' : 'rgba(255,200,50,' + pulse + ')');
576:         coreGrd.addColorStop(0.5, flash ? '#ffffff' : 'rgba(255,100,0,' + (pulse * 0.6) + ')');
577:         coreGrd.addColorStop(1, 'rgba(255,0,0,0)');
578:         ctx.fillStyle = coreGrd;
579:         ctx.beginPath();
580:         ctx.arc(0, 0, 16, 0, Math.PI * 2);
581:         ctx.fill();
582: 
583:         // Segment lines radiating outward
584:         ctx.strokeStyle = flash ? '#ffffff' : 'rgba(255,255,255,0.15)';
585:         ctx.lineWidth = 1;
586:         for (var j = 0; j < 8; j++) {
587:             var a2 = deg2rad(45 * j - 90);
588:             ctx.beginPath();
589:             ctx.moveTo(0, 0);
590:             ctx.lineTo(Math.cos(a2) * 32, Math.sin(a2) * 32);
591:             ctx.stroke();
592:         }
593: 
594:         // Boss turret barrels (4 small cannons)
595:         ctx.fillStyle = flash ? '#ffffff' : '#ff6600';
596:         for (var k = 0; k < 4; k++) {
597:             var a3 = deg2rad(90 * k + _time * 40);
598:             ctx.save();
599:             ctx.rotate(a3);
600:             ctx.fillRect(-2, -28, 4, 10);
601:             ctx.restore();
602:         }
603:     }
604: 
605:     /** Death explosion effect for an enemy */
606:     function _renderEnemyDeath(ex, ey, e) {
607:         var progress = 1 - (e.deathTimer / (e.maxDeathTime || 0.5));
608:         var alpha = 1 - progress;
609: 
610:         // Expanding ring
611:         var ringRadius = progress * (e.width || 40) * 1.5;
612:         ctx.save();
613:         ctx.globalAlpha = alpha;
614:         ctx.strokeStyle = e.deathColor || '#ff8800';
615:         ctx.lineWidth = 3 * alpha;
616:         ctx.beginPath();
617:         ctx.arc(ex, ey, ringRadius, 0, Math.PI * 2);
618:         ctx.stroke();
619: 
620:         // Inner flash
621:         var flashGrd = ctx.createRadialGradient(ex, ey, 0, ex, ey, ringRadius);
622:         flashGrd.addColorStop(0, 'rgba(255,200,100,' + alpha + ')');
623:         flashGrd.addColorStop(0.5, 'rgba(255,100,0,' + (alpha * 0.6) + ')');
624:         flashGrd.addColorStop(1, 'rgba(255,0,0,0)');
625:         ctx.fillStyle = flashGrd;
626:         ctx.beginPath();
627:         ctx.arc(ex, ey, ringRadius, 0, Math.PI * 2);
628:         ctx.fill();
629: 
630:         ctx.restore();
631:     }
632: 
633:     // ──────────────────────────────────────────────
634:     // 4. PROJECTILE RENDERING
635:     // ──────────────────────────────────────────────
636: 
637:     function _renderProjectiles() {
638:         if (!projectiles || !projectiles.length) return;
639: 
640:         for (var i = 0; i < projectiles.length; i++) {
641:             var p = projectiles[i];
642:             if (!p || !p.alive) continue;
643: 
644:             var px = p.x - _camera.x;
645:             var py = p.y - _camera.y;
646: 
647:             switch (p.type) {
648:                 case 'playerBullet':
649:                     _drawPlayerBullet(px, py, p);
650:                     break;
651:                 case 'enemyBullet':
652:                     _drawEnemyBullet(px, py, p);
653:                     break;
654:                 case 'chargedShot':
655:                     _drawChargedShot(px, py, p);
656:                     break;
657:                 case 'bossAttack':
658:                     _drawBossAttack(px, py, p);
659:                     break;
660:                 default:
661:                     _drawEnemyBullet(px, py, p);
662:             }
663:         }
664:     }
665: 
666:     /** Player bullet — glowing cyan/blue orb with trail */
667:     function _drawPlayerBullet(px, py, p) {
668:         var s = p.size || 3;
669:         ctx.save();
670: 
671:         // Glow aura (larger radial gradient, lighter blending)
672:         ctx.globalCompositeOperation = 'lighter';
673:         var grd = ctx.createRadialGradient(px, py, 0, px, py, s * 4);
674:         grd.addColorStop(0, 'rgba(0,220,255,0.9)');
675:         grd.addColorStop(0.3, 'rgba(0,160,255,0.5)');
676:         grd.addColorStop(0.7, 'rgba(0,80,200,0.15)');
677:         grd.addColorStop(1, 'rgba(0,40,120,0)');
678:         ctx.fillStyle = grd;
679:         ctx.beginPath();
680:         ctx.arc(px, py, s * 4, 0, Math.PI * 2);
681:         ctx.fill();
682: 
683:         // Core
684:         ctx.fillStyle = '#ffffff';
685:         ctx.beginPath();
686:         ctx.arc(px, py, s * 0.6, 0, Math.PI * 2);
687:         ctx.fill();
688:         ctx.fillStyle = '#00eeff';
689:         ctx.beginPath();
690:         ctx.arc(px, py, s, 0, Math.PI * 2);
691:         ctx.fill();
692: 
693:         ctx.restore();
694:     }
695: 
696:     /** Enemy bullet — red/orange with trail */
697:     function _drawEnemyBullet(px, py, p) {
698:         var s = p.size || 4;
699:         ctx.save();
700:         ctx.globalCompositeOperation = 'lighter';
701: 
702:         var grd = ctx.createRadialGradient(px, py, 0, px, py, s * 3);
703:         grd.addColorStop(0, 'rgba(255,100,30,0.9)');
704:         grd.addColorStop(0.4, 'rgba(255,60,10,0.5)');
705:         grd.addColorStop(1, 'rgba(255,20,0,0)');
706:         ctx.fillStyle = grd;
707:         ctx.beginPath();
708:         ctx.arc(px, py, s * 3, 0, Math.PI * 2);
709:         ctx.fill();
710: 
711:         // Core
712:         ctx.fillStyle = '#ffffff';
713:         ctx.beginPath();
714:         ctx.arc(px, py, s * 0.5, 0, Math.PI * 2);
715:         ctx.fill();
716:         ctx.fillStyle = '#ff4422';
717:         ctx.beginPath();
718:         ctx.arc(px, py, s, 0, Math.PI * 2);
719:         ctx.fill();
720: 
721:         ctx.restore();
722:     }
723: 
724:     /** Charged shot — large energy ball with pulsing aura */
725:     function _drawChargedShot(px, py, p) {
726:         var s = p.size || 12;
727:         var pulse = Math.sin(_time * 12) * 0.2 + 0.8;
728:         ctx.save();
729:         ctx.globalCompositeOperation = 'lighter';
730: 
731:         // Outer pulsing aura
732:         var outerGrd = ctx.createRadialGradient(px, py, s * 0.5, px, py, s * 2.5 * pulse);
733:         outerGrd.addColorStop(0, 'rgba(0,200,255,0.4)');
734:         outerGrd.addColorStop(0.5, 'rgba(80,100,255,0.2)');
735:         outerGrd.addColorStop(1, 'rgba(0,0,200,0)');
736:         ctx.fillStyle = outerGrd;
737:         ctx.beginPath();
738:         ctx.arc(px, py, s * 2.5 * pulse, 0, Math.PI * 2);
739:         ctx.fill();
740: 
741:         // Main glow
742:         var mainGrd = ctx.createRadialGradient(px, py, 0, px, py, s * 1.5);
743:         mainGrd.addColorStop(0, 'rgba(200,240,255,0.95)');
744:         mainGrd.addColorStop(0.3, 'rgba(0,180,255,0.7)');
745:         mainGrd.addColorStop(1, 'rgba(0,60,200,0)');
746:         ctx.fillStyle = mainGrd;
747:         ctx.beginPath();
748:         ctx.arc(px, py, s * 1.5, 0, Math.PI * 2);
749:         ctx.fill();
750: 
751:         // Electric arcs around the ball
752:         ctx.strokeStyle = 'rgba(200,240,255,' + (0.6 + Math.sin(_time * 20) * 0.3) + ')';
753:         ctx.lineWidth = 1;
754:         for (var a = 0; a < 5; a++) {
755:             var arcAngle = _time * 3 + a * Math.PI * 2 / 5;
756:             ctx.beginPath();
757:             ctx.arc(px, py, s * 1.3, arcAngle, arcAngle + 0.6);
758:             ctx.stroke();
759:         }
760: 
761:         // Core
762:         ctx.fillStyle = '#ffffff';
763:         ctx.beginPath();
764:         ctx.arc(px, py, s * 0.4, 0, Math.PI * 2);
765:         ctx.fill();
766: 
767:         ctx.restore();
768:     }
769: 
770:     /** Boss special attack — large swirling projectile */
771:     function _drawBossAttack(px, py, p) {
772:         var s = p.size || 10;
773:         ctx.save();
774:         ctx.globalCompositeOperation = 'lighter';
775: 
776:         // Spiral effect
777:         var grd = ctx.createRadialGradient(px, py, 0, px, py, s * 2);
778:         grd.addColorStop(0, 'rgba(255,50,80,0.95)');
779:         grd.addColorStop(0.4, 'rgba(200,30,60,0.6)');
780:         grd.addColorStop(1, 'rgba(100,0,30,0)');
781:         ctx.fillStyle = grd;
782:         ctx.beginPath();
783:         ctx.arc(px, py, s * 2, 0, Math.PI * 2);
784:         ctx.fill();
785: 
786:         // Rotating spikes
787:         ctx.strokeStyle = 'rgba(255,100,50,0.8)';
788:         ctx.lineWidth = 2;
789:         for (var i = 0; i < 6; i++) {
790:             var spikeAngle = _time * 6 + i * Math.PI / 3;
791:             var sx1 = px + Math.cos(spikeAngle) * s * 0.6;
792:             var sy1 = py + Math.sin(spikeAngle) * s * 0.6;
793:             var sx2 = px + Math.cos(spikeAngle) * s * 2;
794:             var sy2 = py + Math.sin(spikeAngle) * s * 2;
795:             ctx.beginPath();
796:             ctx.moveTo(sx1, sy1);
797:             ctx.lineTo(sx2, sy2);
798:             ctx.stroke();
799:         }
800: 
801:         // Core
802:         ctx.fillStyle = '#ffffff';
803:         ctx.beginPath();
804:         ctx.arc(px, py, s * 0.5, 0, Math.PI * 2);
805:         ctx.fill();
806: 
807:         ctx.restore();
808:     }
809: 
810:     // ──────────────────────────────────────────────
811:     // 5. PARTICLE SYSTEM
812:     // ──────────────────────────────────────────────
813: 
814:     /**
815:      * Render all active particles. Each particle has:
816:      *   x, y, vx, vy, color, size, life, maxLife, type
817:      * Types: 'explosion', 'ring', 'spark', 'engine', 'impact', 'powerup'
818:      */
819:     function _renderParticles() {
820:         if (!particles || !particles.length) return;
821: 
822:         for (var i = 0; i < particles.length; i++) {
823:             var p = particles[i];
824:             if (!p || p.life <= 0) continue;
825: 
826:             var px = p.x - _camera.x;
827:             var py = p.y - _camera.y;
828:             var alpha = p.life / p.maxLife;
829: 
830:             switch (p.type) {
831:                 case 'explosion':
832:                     _drawExplosionParticle(px, py, p, alpha);
833:                     break;
834:                 case 'ring':
835:                     _drawRingParticle(px, py, p, alpha);
836:                     break;
837:                 case 'spark':
838:                     _drawSparkParticle(px, py, p, alpha);
839:                     break;
840:                 case 'engine':
841:                     _drawEngineParticle(px, py, p, alpha);
842:                     break;
843:                 case 'impact':
844:                     _drawImpactParticle(px, py, p, alpha);
845:                     break;
846:                 case 'powerup':
847:                     _drawPowerupParticle(px, py, p, alpha);
848:                     break;
849:                 default:
850:                     _drawSparkParticle(px, py, p, alpha);
851:             }
852:         }
853:     }
854: 
855:     /** Explosion particle: expanding circle with fade */
856:     function _drawExplosionParticle(px, py, p, alpha) {
857:         var progress = 1 - alpha;
858:         var s = p.size * (0.5 + progress);
859:         ctx.save();
860:         ctx.globalAlpha = alpha;
861:         ctx.globalCompositeOperation = 'lighter';
862: 
863:         var grd = ctx.createRadialGradient(px, py, 0, px, py, s);
864:         grd.addColorStop(0, p.color || '#ffaa00');
865:         grd.addColorStop(0.6, 'rgba(255,100,0,0.4)');
866:         grd.addColorStop(1, 'rgba(255,0,0,0)');
867:         ctx.fillStyle = grd;
868:         ctx.beginPath();
869:         ctx.arc(px, py, s, 0, Math.PI * 2);
870:         ctx.fill();
871: 
872:         ctx.restore();
873:     }
874: 
875:     /** Ring particle: expanding ring for shockwave */
876:     function _drawRingParticle(px, py, p, alpha) {
877:         var progress = 1 - alpha;
878:         var radius = p.size * progress;
879:         ctx.save();
880:         ctx.globalAlpha = alpha;
881:         ctx.strokeStyle = p.color || '#ffcc00';
882:         ctx.lineWidth = 3 * alpha;
883:         ctx.beginPath();
884:         ctx.arc(px, py, radius, 0, Math.PI * 2);
885:         ctx.stroke();
886:         ctx.restore();
887:     }
888: 
889:     /** Spark particle: small fast-moving dot */
890:     function _drawSparkParticle(px, py, p, alpha) {
891:         ctx.save();
892:         ctx.globalAlpha = alpha;
893:         ctx.globalCompositeOperation = 'lighter';
894:         ctx.fillStyle = p.color || '#ffcc44';
895:         ctx.beginPath();
896:         ctx.arc(px, py, p.size * alpha, 0, Math.PI * 2);
897:         ctx.fill();
898:         ctx.restore();
899:     }
900: 
901:     /** Engine trail particle: fading blue/cyan glow */
902:     function _drawEngineParticle(px, py, p, alpha) {
903:         ctx.save();
904:         ctx.globalAlpha = alpha * 0.6;
905:         ctx.globalCompositeOperation = 'lighter';
906: 
907:         var grd = ctx.createRadialGradient(px, py, 0, px, py, p.size);
908:         grd.addColorStop(0, 'rgba(100,220,255,' + alpha + ')');
909:         grd.addColorStop(0.5, 'rgba(0,140,255,' + (alpha * 0.5) + ')');
910:         grd.addColorStop(1, 'rgba(0,60,200,0)');
911:         ctx.fillStyle = grd;
912:         ctx.beginPath();
913:         ctx.arc(px, py, p.size, 0, Math.PI * 2);
914:         ctx.fill();
915: 
916:         ctx.restore();
917:     }
918: 
919:     /** Impact particle: bright flash spark */
920:     function _drawImpactParticle(px, py, p, alpha) {
921:         ctx.save();
922:         ctx.globalAlpha = alpha;
923:         ctx.globalCompositeOperation = 'lighter';
924: 
925:         var grd = ctx.createRadialGradient(px, py, 0, px, py, p.size);
926:         grd.addColorStop(0, 'rgba(255,255,255,' + alpha + ')');
927:         grd.addColorStop(0.4, (p.color || 'rgba(255,200,100)') + ',' + (alpha * 0.7) + ')');
928:         grd.addColorStop(1, 'rgba(255,100,0,0)');
929:         ctx.fillStyle = grd;
930:         ctx.beginPath();
931:         ctx.arc(px, py, p.size, 0, Math.PI * 2);
932:         ctx.fill();
933: 
934:         ctx.restore();
935:     }
936: 
937:     /** Power-up particle: sparkle with glow */
938:     function _drawPowerupParticle(px, py, p, alpha) {
939:         ctx.save();
940:         ctx.globalAlpha = alpha;
941:         ctx.globalCompositeOperation = 'lighter';
942: 
943:         // Cross-shaped sparkle
944:         var s = p.size;
945:         ctx.strokeStyle = (p.color || '#ffdd00') + ',' + alpha + ')';
946:         ctx.lineWidth = 1.2;
947:         ctx.beginPath();
948:         ctx.moveTo(px - s, py);
949:         ctx.lineTo(px + s, py);
950:         ctx.moveTo(px, py - s);
951:         ctx.lineTo(px, py + s);
952:         ctx.stroke();
953: 
954:         // Glow center
955:         var grd = ctx.createRadialGradient(px, py, 0, px, py, s * 0.7);
956:         grd.addColorStop(0, 'rgba(255,255,255,' + alpha + ')');
957:         grd.addColorStop(1, 'rgba(255,200,0,0)');
958:         ctx.fillStyle = grd;
959:         ctx.beginPath();
960:         ctx.arc(px, py, s * 0.7, 0, Math.PI * 2);
961:         ctx.fill();
962: 
963:         ctx.restore();
964:     }
965: 
966:     // ──────────────────────────────────────────────
967:     // 6. LIGHTING / GLOW & VIGNETTE
968:     // ──────────────────────────────────────────────
969: 
970:     /**
971:      * Draw a subtle vignette (dark edges) over the whole viewport.
972:      */
973:     function _renderVignette() {
974:         var w = _width;
975:         var h = _height;
976:         var grd = ctx.createRadialGradient(w / 2, h / 2, w * 0.35, w / 2, h / 2, w * 0.75);
977:         grd.addColorStop(0, 'rgba(0,0,0,0)');
978:         grd.addColorStop(0.5, 'rgba(0,0,0,0.05)');
979:         grd.addColorStop(1, 'rgba(0,0,0,0.5)');
980:         ctx.fillStyle = grd;
981:         ctx.fillRect(0, 0, w, h);
982:     }
983: 
984:     // ──────────────────────────────────────────────
985:     // 7. BACKGROUND EFFECTS
986:     // ──────────────────────────────────────────────
987: 
988:     /**
989:      * Nebula-like colour gradients that subtly shift over time.
990:      * Also renders starfield and optional grid lines for space-station levels.
991:      */
992:     function _renderBackgroundEffects() {
993:         var w = _width;
994:         var h = _height;
995:         var shift = Math.sin(_time * 0.15) * 0.3 + 0.5;
996: 
997:         // Deep space base
998:         var spaceGrd = ctx.createLinearGradient(0, 0, w, h);
999:         spaceGrd.addColorStop(0, 'rgb(5,5,25)');
1000:         spaceGrd.addColorStop(0.3, 'rgb(8,4,20)');
1001:         spaceGrd.addColorStop(0.6, 'rgb(4,6,18)');
1002:         spaceGrd.addColorStop(1, 'rgb(3,3,15)');
1003:         ctx.fillStyle = spaceGrd;
1004:         ctx.fillRect(0, 0, w, h);
1005: 
1006:         // Nebula blobs (offset by camera for parallax)
1007:         var cx = _camera.x * 0.02;
1008:         var cy = _camera.y * 0.02;
1009:         _nebulaShift += (deltaTime || 0.016) * 0.5;
1010: 
1011:         // Blue nebula
1012:         ctx.save();
1013:         ctx.globalAlpha = 0.08 + shift * 0.05;
1014:         ctx.globalCompositeOperation = 'lighter';
1015:         var neb1x = (w * 0.25 + cx * 10 + Math.sin(_nebulaShift * 0.7) * 60) % w;
1016:         var neb1y = (h * 0.4 + cy * 10 + Math.cos(_nebulaShift * 0.5) * 40) % h;
1017:         var nebGrd1 = ctx.createRadialGradient(neb1x, neb1y, 0, neb1x, neb1y, w * 0.3);
1018:         nebGrd1.addColorStop(0, 'rgba(30,60,180,0.6)');
1019:         nebGrd1.addColorStop(1, 'rgba(5,10,40,0)');
1020:         ctx.fillStyle = nebGrd1;
1021:         ctx.fillRect(0, 0, w, h);
1022: 
1023:         // Purple nebula
1024:         ctx.globalAlpha = 0.06 + shift * 0.04;
1025:         var neb2x = (w * 0.7 + cx * 8 + Math.cos(_nebulaShift * 0.6) * 50) % w;
1026:         var neb2y = (h * 0.6 + cy * 8 + Math.sin(_nebulaShift * 0.4) * 30) % h;
1027:         var nebGrd2 = ctx.createRadialGradient(neb2x, neb2y, 0, neb2x, neb2y, w * 0.25);
1028:         nebGrd2.addColorStop(0, 'rgba(80,20,120,0.5)');
1029:         nebGrd2.addColorStop(1, 'rgba(5,5,20,0)');
1030:         ctx.fillStyle = nebGrd2;
1031:         ctx.fillRect(0, 0, w, h);
1032: 
1033:         ctx.restore();
1034: 
1035:         // Grid lines for space-station levels
1036:         if (CONFIG.levelType === 'station' || CONFIG.currentLevel >= 3) {
1037:             _renderGridLines();
1038:         }
1039: 
1040:         // Render starfield over the background
1041:         _renderStarLayer(_stars.far,  0.4);
1042:         _renderStarLayer(_stars.mid,  0.6);
1043:         _renderStarLayer(_stars.near, 1.0);
1044:     }
1045: 
1046:     /** Grid lines that scroll for space-station levels */
1047:     function _renderGridLines() {
1048:         _gridPhase += (deltaTime || 0.016) * 30;
1049: 
1050:         var gridSize = CONFIG.gridSize || 60;
1051:         var offsetX = (_camera.x * 0.3 + _gridPhase) % gridSize;
1052:         var offsetY = (_camera.y * 0.3) % gridSize;
1053: 
1054:         ctx.save();
1055:         ctx.globalAlpha = 0.04;
1056:         ctx.strokeStyle = '#4488ff';
1057:         ctx.lineWidth = 0.5;
1058: 
1059:         // Vertical lines
1060:         for (var x = offsetX; x < _width; x += gridSize) {
1061:             ctx.beginPath();
1062:             ctx.moveTo(x, 0);
1063:             ctx.lineTo(x, _height);
1064:             ctx.stroke();
1065:         }
1066: 
1067:         // Horizontal lines
1068:         for (var y = offsetY; y < _height; y += gridSize) {
1069:             ctx.beginPath();
1070:             ctx.moveTo(0, y);
1071:             ctx.lineTo(_width, y);
1072:             ctx.stroke();
1073:         }
1074: 
1075:         ctx.restore();
1076:     }
1077: 
1078:     // ──────────────────────────────────────────────
1079:     // 8. CAMERA SYSTEM
1080:     // ──────────────────────────────────────────────
1081: 
1082:     /**
1083:      * Update camera: smoothly follow the player with slight lag, apply bounds,
1084:      * and offset for screen shake.
1085:      */
1086:     function _updateCamera() {
1087:         if (!player || !player.x || !player.y) return;
1088: 
1089:         // Target: center on player
1090:         _camera.targetX = player.x - _width / 2;
1091:         _camera.targetY = player.y - _height / 2;
1092: 
1093:         // Clamp to level bounds (if defined in CONFIG)
1094:         var levelW = CONFIG.levelWidth  || _width * 3;
1095:         var levelH = CONFIG.levelHeight || _height * 3;
1096:         _camera.targetX = clamp(_camera.targetX, 0, levelW - _width);
1097:         _camera.targetY = clamp(_camera.targetY, 0, levelH - _height);
1098: 
1099:         // Smooth follow (lag factor from config or default)
1100:         var lerpFactor = CONFIG.cameraSmoothing || 0.08;
1101:         _camera.x = lerp(_camera.x, _camera.targetX, lerpFactor);
1102:         _camera.y = lerp(_camera.y, _camera.targetY, lerpFactor);
1103: 
1104:         // Shake
1105:         var shakeMag = (typeof shakeIntensity !== 'undefined') ? shakeIntensity : 0;
1106:         if (shakeMag > 0 || _camera.shakeTimer > 0) {
1107:             _camera.shakeMagnitude = Math.max(_camera.shakeMagnitude, shakeMag || 0);
1108:             _camera.shakeTimer = Math.max(_camera.shakeTimer, (typeof shakeIntensity !== 'undefined' && shakeIntensity > 0) ? 0.3 : 0);
1109: 
1110:             // Decay shake
1111:             _camera.shakeMagnitude *= Math.pow(0.02, deltaTime || 0.016);
1112:             _camera.shakeTimer -= deltaTime || 0.016;
1113: 
1114:             if (_camera.shakeMagnitude < 0.3) _camera.shakeMagnitude = 0;
1115:             if (_camera.shakeTimer < 0) _camera.shakeTimer = 0;
1116: 
1117:             // Random offset per frame
1118:             var mag = _camera.shakeMagnitude;
1119:             _camera.shakeX = (Math.random() - 0.5) * 2 * mag;
1120:             _camera.shakeY = (Math.random() - 0.5) * 2 * mag;
1121:         } else {
1122:             _camera.shakeX = 0;
1123:             _camera.shakeY = 0;
1124:         }
1125: 
1126:         _camera.x += _camera.shakeX;
1127:         _camera.y += _camera.shakeY;
1128:     }
1129: 
1130:     // ──────────────────────────────────────────────
1131:     // 9. RESPONSIVE SCALING
1132:     // ──────────────────────────────────────────────
1133: 
1134:     /**
1135:      * Resize the canvas to fill the window while maintaining the game's
1136:      * aspect ratio (letterboxing if needed). Reinitialise starfield.
1137:      */
1138:     function _resizeCanvas() {
1139:         var winW = window.innerWidth;
1140:         var winH = window.innerHeight;
1141:         var winAspect = winW / winH;
1142: 
1143:         if (winAspect > ASPECT) {
1144:             // Window is wider than game
1145:             _height = winH;
1146:             _width  = _height * ASPECT;
1147:         } else {
1148:             // Window is taller than game
1149:             _width  = winW;
1150:             _height = _width / ASPECT;
1151:         }
1152: 
1153:         canvas.width  = _width;
1154:         canvas.height = _height;
1155:         canvas.style.width  = _width  + 'px';
1156:         canvas.style.height = _height + 'px';
1157:         canvas.style.position = 'absolute';
1158:         canvas.style.left = ((winW - _width)  / 2) + 'px';
1159:         canvas.style.top  = ((winH - _height) / 2) + 'px';
1160: 
1161:         // Rebuild starfield for new dimensions
1162:         _initStars();
1163:     }
1164: 
1165:     // ──────────────────────────────────────────────
1166:     // 10. HUD RENDERING
1167:     // ──────────────────────────────────────────────
1168: 
1169:     /**
1170:      * Draw basic HUD: score, combo, level, lives, weapon indicator.
1171:      */
1172:     function _renderHUD() {
1173:         ctx.save();
1174:         ctx.fillStyle = '#ffffff';
1175:         ctx.font = (CONFIG.hudFontSize || 18) + 'px "Courier New", monospace';
1176:         ctx.textBaseline = 'top';
1177:         ctx.shadowColor = '#000000';
1178:         ctx.shadowBlur = 4;
1179: 
1180:         // Score
1181:         var score = gameState.score || 0;
1182:         ctx.fillText('SCORE: ' + score, 20, 20);
1183: 
1184:         // Combo (if active)
1185:         if (gameState.combo > 1) {
1186:             ctx.fillStyle = '#ffcc00';
1187:             ctx.font = 'bold ' + (CONFIG.hudFontSize || 18) + 'px "Courier New", monospace';
1188:             ctx.fillText('COMBO x' + gameState.combo, 20, 44);
1189:         }
1190: 
1191:         // Level
1192:         var lvl = gameState.level || CONFIG.currentLevel || 1;
1193:         ctx.fillStyle = '#88ccff';
1194:         ctx.fillText('LEVEL ' + lvl, _width - 160, 20);
1195: 
1196:         // Lives / health
1197:         if (player) {
1198:             var lives = player.lives || 0;
1199:             var hp = player.hp || 0;
1200:             var maxHp = player.maxHp || 100;
1201: 
1202:             // Lives as ship icons
1203:             ctx.fillStyle = '#00ccff';
1204:             for (var i = 0; i < lives; i++) {
1205:                 ctx.fillText('\u25B2', _width - 160 + i * 22, 44);
1206:             }
1207: 
1208:             // Health bar
1209:             var barX = 20;
1210:             var barY = _height - 30;
1211:             var barW = 200;
1212:             var barH = 12;
1213:             var hpRatio = hp / maxHp;
1214: 
1215:             ctx.fillStyle = 'rgba(0,0,0,0.5)';
1216:             ctx.fillRect(barX, barY, barW, barH);
1217:             ctx.fillStyle = hpRatio > 0.5 ? '#00ff66' : hpRatio > 0.25 ? '#ffaa00' : '#ff2222';
1218:             ctx.fillRect(barX, barY, barW * hpRatio, barH);
1219:             ctx.strokeStyle = '#ffffff';
1220:             ctx.lineWidth = 1;
1221:             ctx.strokeRect(barX, barY, barW, barH);
1222:         }
1223: 
1224:         // Weapon level indicator
1225:         if (player && player.weaponLevel) {
1226:             ctx.fillStyle = '#ff8800';
1227:             ctx.fillText('WPN LV.' + player.weaponLevel, 20, _height - 50);
1228:         }
1229: 
1230:         ctx.restore();
1231:     }
1232: 
1233:     /**
1234:      * Render the pause overlay.
1235:      */
1236:     function _renderPauseOverlay() {
1237:         ctx.save();
1238:         ctx.fillStyle = 'rgba(0,0,0,0.5)';
1239:         ctx.fillRect(0, 0, _width, _height);
1240: 
1241:         ctx.fillStyle = '#ffffff';
1242:         ctx.font = 'bold 48px "Courier New", monospace';
1243:         ctx.textAlign = 'center';
1244:         ctx.textBaseline = 'middle';
1245:         ctx.shadowColor = '#000000';
1246:         ctx.shadowBlur = 10;
1247:         ctx.fillText('PAUSED', _width / 2, _height / 2);
1248:         ctx.font = '20px "Courier New", monospace';
1249:         ctx.fillText('Press P to resume', _width / 2, _height / 2 + 40);
1250:         ctx.restore();
1251:     }
1252: 
1253:     /**
1254:      * Render the game-over screen.
1255:      */
1256:     function _renderGameOver() {
1257:         ctx.save();
1258:         ctx.fillStyle = 'rgba(0,0,0,0.7)';
1259:         ctx.fillRect(0, 0, _width, _height);
1260: 
1261:         ctx.fillStyle = '#ff3333';
1262:         ctx.font = 'bold 56px "Courier New", monospace';
1263:         ctx.textAlign = 'center';
1264:         ctx.textBaseline = 'middle';
1265:         ctx.shadowColor = '#000000';
1266:         ctx.shadowBlur = 15;
1267:         ctx.fillText('GAME OVER', _width / 2, _height / 2 - 40);
1268: 
1269:         ctx.fillStyle = '#ffffff';
1270:         ctx.font = '24px "Courier New", monospace';
1271:         ctx.fillText('SCORE: ' + (gameState.score || 0), _width / 2, _height / 2 + 20);
1272:         ctx.fillText('LEVEL: ' + (gameState.level || CONFIG.currentLevel || 1), _width / 2, _height / 2 + 50);
1273:         ctx.font = '18px "Courier New", monospace';
1274:         ctx.fillText('Press ENTER to restart', _width / 2, _height / 2 + 90);
1275: 
1276:         ctx.restore();
1277:     }
1278: 
1279:     /**
1280:      * Render the victory screen.
1281:      */
1282:     function _renderVictory() {
1283:         ctx.save();
1284:         ctx.fillStyle = 'rgba(0,0,0,0.7)';
1285:         ctx.fillRect(0, 0, _width, _height);
1286: 
1287:         ctx.fillStyle = '#ffcc00';
1288:         ctx.font = 'bold 56px "Courier New", monospace';
1289:         ctx.textAlign = 'center';
1290:         ctx.textBaseline = 'middle';
1291:         ctx.shadowColor = '#000000';
1292:         ctx.shadowBlur = 15;
1293:         ctx.fillText('VICTORY!', _width / 2, _height / 2 - 40);
1294: 
1295:         ctx.fillStyle = '#ffffff';
1296:         ctx.font = '24px "Courier New", monospace';
1297:         ctx.fillText('FINAL SCORE: ' + (gameState.score || 0), _width / 2, _height / 2 + 20);
1298:         ctx.font = '18px "Courier New", monospace';
1299:         ctx.fillText('Press ENTER to play again', _width / 2, _height / 2 + 60);
1300: 
1301:         ctx.restore();
1302:     }
1303: 
1304:     /**
1305:      * Render the main menu.
1306:      */
1307:     function _renderMenu() {
1308:         ctx.save();
1309: 
1310:         // Draw full starfield even on menu
1311:         _renderBackgroundEffects();
1312: 
1313:         // Title
1314:         ctx.fillStyle = '#00eeff';
1315:         ctx.font = 'bold 64px "Courier New", monospace';
1316:         ctx.textAlign = 'center';
1317:         ctx.textBaseline = 'middle';
1318:         ctx.shadowColor = '#004466';
1319:         ctx.shadowBlur = 20;
1320:         ctx.fillText('VOID STRIKERS', _width / 2, _height / 2 - 60);
1321: 
1322:         ctx.shadowBlur = 0;
1323:         ctx.fillStyle = '#ccddff';
1324:         ctx.font = '20px "Courier New", monospace';
1325:         ctx.fillText('Press ENTER to start', _width / 2, _height / 2 + 20);
1326: 
1327:         ctx.fillStyle = '#888899';
1328:         ctx.font = '14px "Courier New", monospace';
1329:         ctx.fillText('Arrow keys to move  |  Space to fire  |  P to pause', _width / 2, _height / 2 + 55);
1330:         ctx.fillText('C for charged shot', _width / 2, _height / 2 + 75);
1331: 
1332:         ctx.restore();
1333:     }
1334: 
1335:     // ──────────────────────────────────────────────
1336:     // PUBLIC API
1337:     // ──────────────────────────────────────────────
1338: 
1339:     return {
1340: 
1341:         /**
1342:          * Initialise rendering: create starfield, set up initial camera.
1343:          * Call once after canvas and context are available.
1344:          */
1345:         init: function () {
1346:             _resizeCanvas();
1347:             _initStars();
1348:             _camera.x = 0;
1349:             _camera.y = 0;
1350:             _time = 0;
1351:         },
1352: 
1353:         /**
1354:          * Main render entry point. Called every frame by the game loop.
1355:          * Dispatches to appropriate renderer based on gameState.state.
1356:          */
1357:         render: function () {
1358:             if (!ctx || !canvas) return;
1359: 
1360:             _time += deltaTime || 0.016;
1361: 
1362:             // Prevent rendering during invalid state
1363:             if (!gameState || !gameState.state) return;
1364: 
1365:             // Clear with background
1366:             ctx.clearRect(0, 0, _width, _height);
1367: 
1368:             var state = gameState.state;
1369: 
1370:             // Menu gets its own full render
1371:             if (state === 'menu') {
1372:                 _renderMenu();
1373:                 return;
1374:             }
1375: 
1376:             // Background (starfield + nebula + grid)
1377:             _renderBackgroundEffects();
1378: 
1379:             // Update camera (not during menu)
1380:             _updateCamera();
1381: 
1382:             // In-game or paused with scene visible
1383:             if (state === 'playing' || state === 'paused') {
1384:                 // Translate entire scene by camera
1385:                 ctx.save();
1386:                 // Camera translation is baked into individual draw calls already,
1387:                 // since each draws at (x - camera.x, y - camera.y).
1388: 
1389:                 // Draw game objects in order
1390:                 _renderProjectiles();
1391:                 _renderEnemies();
1392:                 _renderParticles();
1393:                 _renderPlayerShip();
1394: 
1395:                 // Power-ups (simple glowing orb with icon)
1396:                 if (powerups && powerups.length) {
1397:                     _renderPowerups();
1398:                 }
1399: 
1400:                 ctx.restore();
1401: 
1402:                 // Vignette overlay
1403:                 _renderVignette();
1404: 
1405:                 // HUD (always on top, not affected by camera)
1406:                 _renderHUD();
1407: 
1408:                 // Pause overlay
1409:                 if (state === 'paused') {
1410:                     _renderPauseOverlay();
1411:                 }
1412:             } else if (state === 'gameover') {
1413:                 // Show last frame + overlay
1414:                 _renderProjectiles();
1415:                 _renderEnemies();
1416:                 _renderParticles();
1417:                 _renderPlayerShip();
1418:                 if (powerups && powerups.length) _renderPowerups();
1419:                 _renderVignette();
1420:                 _renderHUD();
1421:                 _renderGameOver();
1422:             } else if (state === 'victory') {
1423:                 _renderProjectiles();
1424:                 _renderEnemies();
1425:                 _renderParticles();
1426:                 _renderPlayerShip();
1427:                 if (powerups && powerups.length) _renderPowerups();
1428:                 _renderVignette();
1429:                 _renderHUD();
1430:                 _renderVictory();
1431:             }
1432:         },
1433: 
1434:         /**
1435:          * Render background only (starfield, nebula, grid).
1436:          * Useful if main loop wants to defer background to a separate pass.
1437:          */
1438:         renderBackground: function () {
1439:             _renderBackgroundEffects();
1440:         },
1441: 
1442:         /**
1443:          * Render the player ship.
1444:          */
1445:         renderPlayer: function () {
1446:             _renderPlayerShip();
1447:         },
1448: 
1449:         /**
1450:          * Render all enemies.
1451:          */
1452:         renderEnemies: function () {
1453:             _renderEnemies();
1454:         },
1455: 
1456:         /**
1457:          * Render all projectiles.
1458:          */
1459:         renderProjectiles: function () {
1460:             _renderProjectiles();
1461:         },
1462: 
1463:         /**
1464:          * Render all particles.
1465:          */
1466:         renderParticles: function () {
1467:             _renderParticles();
1468:         },
1469: 
1470:         /**
1471:          * Render HUD overlay.
1472:          */
1473:         renderHUD: function () {
1474:             _renderHUD();
1475:         },
1476: 
1477:         /**
1478:          * Resize the canvas to current window dimensions.
1479:          * Should be called on window resize.
1480:          */
1481:         resizeCanvas: function () {
1482:             _resizeCanvas();
1483:         },
1484: 
1485:         /**
1486:          * Trigger screen shake with given magnitude and duration (seconds).
1487:          * @param {number} magnitude  pixels of shake
1488:          * @param {number} duration   seconds
1489:          */

(Output capped at 50 KB. Showing lines 1-1489. Use offset=1490 to continue.)
</content>
```

---

## Assistant (Build · DeepSeek V4 Pro · 52.3s)

_Thinking:_

I've read all three files. Let me continue reading the renderer.js since it got cut off. Let me also see if there's a powerup rendering function in renderer.js.

Now I need to understand the full picture:

1. **gameplay.js** (1293 lines): Contains all gameplay logic - player, enemies, projectiles, powerups, collisions, combo, levels, state machine. It declares `player`, `enemies`, `projectiles`, `powerups`, `particles` as globals (with var).

2. **ui-audio.js** (748 lines): Contains `AudioManager` (const, procedural audio) and `UIManager` (const, canvas UI drawing). Uses shared globals like `canvas`, `ctx`, `gameState`, `player`, `deltaTime`.

3. **renderer.js** (1489+ lines): Contains `Renderer` (const) with all rendering systems. Has its own camera system and handles all visual rendering including game state rendering.

Now I need to:
1. Integrate all three into a single HTML file
2. Add the HTML structure (canvas, styling)
3. Add the input handling system
4. Add the main game loop
5. Add the CONFIG object
6. Add the gameState object
7. Wire everything together

There are some conflicts/incompatibilities I need to resolve:
- Both `gameplay.js` and `renderer.js` have their own camera systems. `gameplay.js` uses a global `camera` object, while `renderer.js` has its own internal `_camera`. I need to unify this.
- Both `renderer.js` and `ui-audio.js` have HUD rendering and screen rendering (main menu, pause, game over, victory). The UIManager is more polished, so I should use UIManager for menus/HUD and Renderer for game objects.
- `renderer.js` has its own menu/gameover/victory rendering that I should skip in favor of UIManager.
- `gameplay.js` uses `var` for globals like `player`, `enemies`, `projectiles`, `powerups`, `particles` - these are fine as they'll be in the global scope.
- `renderer.js` references `shakeIntensity` which isn't defined in gameplay.js (it uses `gameState.shakeMagnitude` and its own internal `_camera`)

Let me plan the architecture:

**HTML file structure:**
1. HTML5 boilerplate with meta viewport, touch-action none
2. CSS: fullscreen canvas, dark background, no scrolling
3. JS:
   a. CONFIG object
   b. gameState object  
   c. canvas, ctx setup
   d. InputManager
   e. Camera system (unified)
   f. gameplay.js code (modified to use unified camera)
   g. renderer.js code (modified for compatibility)
   h. ui-audio.js code
   i. Main game loop
   j. Event listeners
   k. Initialization

Let me think about the key integration points:

1. **Camera**: gameplay.js uses `camera = { x:0, y:0, targetX:0, targetY:0, shakeX:0, shakeY:0 }`. renderer.js has its own `_camera`. I'll use the gameplay.js camera as the source and have the renderer use it. Actually, renderer.js uses its own private camera object. I need to either expose it or use the gameplay one.

2. **Screen Shake**: gameplay.js sets `gameState.shakeMagnitude` and updates `camera.shakeX/shakeY`. renderer.js uses `shakeIntensity` global and has its own shake logic. I need to unify.

3. **Rendering during gameplay**: The main loop should call `Renderer.render()` for game objects and `UIManager.drawHUD()` for HUD. But since Renderer.render also draws HUD, I need to handle that.

4. **Menus**: `renderer.js` has `_renderMenu()`, `_renderGameOver()`, `_renderVictory()`, `_renderPauseOverlay()`. `ui-audio.js` has `drawMainMenu()`, `drawPauseMenu()`, `drawHUD()`, `drawGameOver()`, `drawVictory()`, `drawLevelTransition()`.

The UIManager versions are more polished, so I'll use those for menus/HUD and have Renderer only render game objects.

Let me now think about how to restructure:

**Main game loop:**
```
function gameLoop() {
  requestAnimationFrame(gameLoop);
  deltaTime = ...;
  
  // Update
  InputManager.update();
  updateGameplay(deltaTime); // from gameplay.js
  UIManager.update(deltaTime);
  AudioManager.updateMusic(enemies.length, 20);
  
  // Render
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  if (gameState.state === 'menu') {
    UIManager.drawMainMenu();
  } else if (gameState.state === 'playing' || gameState.state === 'paused') {
    Renderer.renderBackground();
    Renderer.renderPlayer();
    Renderer.renderEnemies();
    Renderer.renderProjectiles();
    Renderer.renderParticles();
    Renderer.renderVignette();
    UIManager.drawHUD();
    if (gameState.state === 'paused') UIManager.drawPauseMenu();
  } else if (gameState.state === 'gameover') {
    Renderer.renderBackground();
    Renderer.renderParticles();
    UIManager.drawGameOver();
  } else if (gameState.state === 'victory') {
    Renderer.renderBackground();
    Renderer.renderParticles();
    UIManager.drawVictory();
  }
  
  UIManager.drawLevelTransition();
}
```

But wait, the renderer's `render()` method handles a lot of this at once. I need to either:
a) Use Renderer.render() as the main dispatching mechanism and just overlay UIManager on top
b) Break apart Renderer.render() and use its individual methods

Option (a) is simpler but we'd get double HUD/menu rendering. Let me modify the renderer to skip its menu/HUD rendering and leave that to UIManager.

Actually, the most practical approach given the complexity: I'll build a single integrated file that fixes all the incompatibilities. Let me write it now.

Key things to fix:
1. Remove the UIManager-related menu/gameover/victory/pause from Renderer.render() (since UIManager handles those)
2. Make Renderer use gameplay.js's camera/shake system instead of its own
3. Add InputManager
4. Fix CONFIG defaults
5. Fix gameState initialization
6. Add powerup rendering in Renderer (it references `_renderPowerups()` but the file might have been cut off)
7. Wire up all event listeners

Let me check if renderer.js has a _renderPowerups function. The file was cut off at line 1489. Let me read the rest.

Let me read the rest of the renderer.js to see the remaining functions.

**Tool: read**

**Input:**
```json
{
  "filePath": "/Users/srpanwar/Documents/Workspace/brain/temp/renderer.js",
  "offset": 1490
}
```

**Output:**
```
<path>/Users/srpanwar/Documents/Workspace/brain/temp/renderer.js</path>
<type>file</type>
<content>
1490:         triggerShake: function (magnitude, duration) {
1491:             _camera.shakeMagnitude = Math.max(_camera.shakeMagnitude, magnitude || 5);
1492:             _camera.shakeTimer = Math.max(_camera.shakeTimer, duration || 0.3);
1493:         },
1494: 
1495:         /**
1496:          * Get the current camera bounds (for culling, etc.).
1497:          */
1498:         getCamera: function () {
1499:             return {
1500:                 x: _camera.x,
1501:                 y: _camera.y,
1502:                 width: _width,
1503:                 height: _height
1504:             };
1505:         },
1506: 
1507:         /**
1508:          * Get the current viewport dimensions.
1509:          */
1510:         getViewport: function () {
1511:             return { width: _width, height: _height };
1512:         }
1513:     };
1514: 
1515:     // ──────────────────────────────────────────────
1516:     // PRIVATE: POWER-UP RENDERING
1517:     // ──────────────────────────────────────────────
1518: 
1519:     /**
1520:      * Render power-up pickup items as glowing orbs with an icon.
1521:      */
1522:     function _renderPowerups() {
1523:         for (var i = 0; i < powerups.length; i++) {
1524:             var pu = powerups[i];
1525:             if (!pu || !pu.alive) continue;
1526: 
1527:             var px = pu.x - _camera.x;
1528:             var py = pu.y - _camera.y;
1529:             var pulse = Math.sin(_time * 5) * 0.2 + 0.8;
1530:             var s = pu.size || 12;
1531: 
1532:             ctx.save();
1533:             ctx.translate(px, py);
1534:             ctx.globalCompositeOperation = 'lighter';
1535: 
1536:             // Outer glow ring
1537:             ctx.strokeStyle = 'rgba(255,255,200,' + (pulse * 0.6) + ')';
1538:             ctx.lineWidth = 2;
1539:             ctx.beginPath();
1540:             ctx.arc(0, 0, s * 1.4, 0, Math.PI * 2);
1541:             ctx.stroke();
1542: 
1543:             // Inner glow
1544:             var grd = ctx.createRadialGradient(0, 0, s * 0.3, 0, 0, s);
1545:             grd.addColorStop(0, 'rgba(255,255,200,' + pulse + ')');
1546:             grd.addColorStop(0.5, 'rgba(255,200,50,' + (pulse * 0.6) + ')');
1547:             grd.addColorStop(1, 'rgba(255,100,0,0)');
1548:             ctx.fillStyle = grd;
1549:             ctx.beginPath();
1550:             ctx.arc(0, 0, s, 0, Math.PI * 2);
1551:             ctx.fill();
1552: 
1553:             // Icon based on type
1554:             ctx.fillStyle = '#ffffff';
1555:             ctx.font = 'bold ' + (s * 1.2) + 'px "Courier New", monospace';
1556:             ctx.textAlign = 'center';
1557:             ctx.textBaseline = 'middle';
1558:             switch (pu.type) {
1559:                 case 'weapon':   ctx.fillText('W', 0, 1); break;
1560:                 case 'shield':   ctx.fillText('S', 0, 1); break;
1561:                 case 'health':   ctx.fillText('+', 0, 1); break;
1562:                 case 'speed':    ctx.fillText('\u25B6', 0, 1); break; // ▶
1563:                 default:         ctx.fillText('?', 0, 1); break;
1564:             }
1565: 
1566:             ctx.restore();
1567:         }
1568:     }
1569: 
1570: })();

(End of file - total 1570 lines)
</content>
```

---

## User

---

## Assistant (Build · DeepSeek V4 Pro · 93.1s)

_Thinking:_

Now I have all three files completely read. The physics-gameplay agent is confirming completion. All 5 agents have delivered. Now I need to create the single HTML file that integrates everything.

Let me analyze the compatibility issues:

1. **Camera system mismatch**: 
   - `gameplay.js` uses global `camera` object with `x, y, targetX, targetY, shakeX, shakeY` 
   - `renderer.js` has its own internal `_camera` with same properties plus shakeTimer/shakeMagnitude
   - `gameplay.js` updateShake sets `camera.shakeX/shakeY` and `camera.x/y` via `gameState.shakeMagnitude`
   - `renderer.js` `_updateCamera` manages its own camera following player with smoothing
   
   Solution: The renderer has a richer camera with smoothing and level bounds. I'll make the renderer's camera the source of truth. But gameplay.js uses `camera` directly. I need to bridge them.

2. **Screen shake**: 
   - gameplay.js sets `gameState.shakeMagnitude` and directly updates `camera.shakeX/shakeY`
   - renderer.js checks for `shakeIntensity` global and manages its own shake
   - ui-audio.js doesn't use shake directly

   Solution: Have gameplay.js use a shared shake system. 

3. **Menu/HUD rendering**:
   - renderer.js has its own menu, pause, game over, victory rendering
   - ui-audio.js has more polished versions of the same
   - Solution: Use UIManager for all UI, Renderer for game objects

4. **Power-up rendering**: In `gameplay.js`, the powerup has `bobTimer` for animation. In `renderer.js`, powerup is rendered using `_renderPowerups()`. But the gameplay powerup uses `vy: 60` and bob animation. renderer draws at (pu.y - _camera.y) which is good.

5. **Input handling**: Not explicitly defined in any module. Need to create.

6. **CONFIG object**: Each module references CONFIG but it's not defined. Need to create.

7. **gameState**: Not defined. Need to create.

8. **deltaTime**: Not defined. Need to compute in game loop.

Let me now build the integrated HTML file. The approach:

1. Create the HTML structure
2. Define CONFIG and gameState  
3. Create InputManager
4. Set up canvas
5. Modify and integrate gameplay.js (keep most of it but bridge camera)
6. Modify and integrate renderer.js (use gameplay.js globals, remove menu/gameover/victory rendering from renderer since UIManager handles it)
7. Integrate ui-audio.js (as-is, since it's self-contained with const)
8. Create main game loop
9. Hook up events
10. Initialize everything

Note: The modules use different patterns:
- gameplay.js uses `var` declarations at global scope
- renderer.js uses `const Renderer = (function() { ... })();`
- ui-audio.js uses `const AudioManager = (function() { ... })();` and `const UIManager = (function() { ... })();`

This is fine since `const` block-scoped declarations can coexist with `var`.

Key concerns for integration:
- Renderer.render() handles menu/gameover/victory states internally. I'll modify the main loop to call separate functions.
- Actually, it's better to NOT modify the agent-written code too much. Instead, I'll have the main game loop do the dispatching based on state and call the right renderers.

Let me think about the game loop:

```
function gameLoop(timestamp) {
  requestAnimationFrame(gameLoop);
  
  // Delta time
  var now = performance.now();
  deltaTime = Math.min((now - lastTime) / 1000, 0.05); // cap at 50ms
  lastTime = now;
  
  // Timing fix: cap dt
  _accumulatedDt = deltaTime;
  
  if (gameState.state !== 'menu' && gameState.state !== 'paused' && 
      gameState.state !== 'gameover' && gameState.state !== 'victory') {
    // Actually playing
  }
  
  // Update gameplay (handles state internally)
  updateGameplay(deltaTime);
  
  // Update UI
  UIManager.update(deltaTime);
  
  // Music
  AudioManager.updateMusic(enemies.length, 20);
  
  // Render
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  // Render based on state
  var state = gameState.state;
  
  if (state === 'menu') {
    UIManager.drawMainMenu();
  } else if (state === 'playing') {
    Renderer.renderBackground();
    Renderer.renderPlayer();
    Renderer.renderEnemies();
    Renderer.renderProjectiles();
    Renderer.renderParticles();
    // powerups
    Renderer._renderPowerups ? ... : ...
    UIManager.drawHUD();
  } else if (state === 'paused') {
    Renderer.renderBackground();
    Renderer.renderPlayer();
    Renderer.renderEnemies();
    Renderer.renderProjectiles();
    Renderer.renderParticles();
    UIManager.drawHUD();
    UIManager.drawPauseMenu();
  } else if (state === 'gameover') {
    Renderer.renderBackground();
    Renderer.renderParticles();
    UIManager.drawGameOver();
  } else if (state === 'victory') {
    Renderer.renderBackground();
    Renderer.renderParticles();
    UIManager.drawVictory();
  }
  
  UIManager.drawLevelTransition();
}
```

Wait, but the Renderer's internal methods like `_renderPowerups` are private (not exported). The renderer only exports `render()`, `renderBackground()`, etc. But `render()` does a lot internally and dispatches based on state with its own HUD/menu rendering. I need to work with this.

Let me look at what Renderer exports: `init`, `render`, `renderBackground`, `renderPlayer`, `renderEnemies`, `renderProjectiles`, `renderParticles`, `renderHUD`, `resizeCanvas`, `triggerShake`, `getCamera`, `getViewport`.

The `render()` method internally handles:
- Clearing
- Menu rendering
- Background effects
- Camera update
- Game objects (player, enemies, projectiles, particles, powerups)
- Vignette
- HUD
- Pause, Game Over, Victory overlays

The problem is that `render()` renders its OWN menus, HUD, overlays that conflict with UIManager.

Solution: I'll modify Renderer's `render()` method to skip the menu/gameover/victory/pause states (by not calling those, or by removing those branches). Actually, the easiest approach is to NOT call `Renderer.render()` at all for game states where UIManager should handle it. Instead, I'll call the individual render methods.

But `_renderPowerups()` is private and not exported! I need to either export it or handle it differently.

Let me rethink: The cleanest approach is to modify the game loop to handle all state dispatching and call individual renderer methods. But I need access to private methods.

Alternative: Let me wrap/modify the renderer slightly. Or better yet, I'll restructure the game loop to use `Renderer.render()` but NOT use its screen overlays (I'll render UIManager OVER the renderer output).

Here's the plan:
1. In game loop, call `Renderer.render()` - this handles background, game objects, camera, vignette, HUD
2. Then OVERLAY UIManager content on top (which will cover/override any renderer-baked menus/HUD)

But this causes double-rendering of HUD and menus. The better approach:

For 'menu' state: Don't call Renderer.render() at all, just use UIManager.drawMainMenu()
For 'playing'/'paused': Call individual Renderer methods for game objects, then UIManager for HUD/menus
For 'gameover'/'victory': Just use UIManager

But I need access to `_renderPowerups`... Let me modify the renderer to also export a renderPowerups method. I'll add it to the returned object.

Actually, you know what, let me just take a different approach entirely. Instead of trying to perfectly integrate the 3 files as-is, I'll create a single clean HTML file that includes all the code with modifications baked in. Since I've read all three files, I understand their structure well enough to do this.

Let me write the complete integrated HTML file now. This will be a large file but it's the cleanest approach.

Here's my plan for the file:

```
1. HTML boilerplate + CSS
2. <canvas id="game">
3. <script>
   // === CONFIG ===
   const CONFIG = { ... };
   
   // === GAME STATE ===
   const gameState = { ... };
   
   // === CANVAS SETUP ===
   const canvas, ctx;
   
   // === INPUT MANAGER ===
   const Input = { ... };
   
   // === Shared camera ===
   let camera = { ... };
   let deltaTime = 0;
   
   // === PARTICLES container ===
   let particles = [];
   const MAX_PARTICLES = 500;
   
   // === RENDERER (modified) ===
   // Include renderer.js with modifications
   
   // === GAMEPLAY (modified) ===  
   // Include gameplay.js with modifications
   
   // === UI MANAGER ===
   // Include ui-audio.js UIManager part
   
   // === AUDIO MANAGER ===
   // Include ui-audio.js AudioManager part
   
   // === GAME LOOP ===
   function gameLoop() { ... }
   
   // === EVENT LISTENERS ===
   // Keyboard, mouse, touch, resize
   
   // === INITIALIZATION ===
   // onload
</script>
```

OK, this is going to be a very large file. Let me write it efficiently, combining all three modules while fixing the integration issues.

Key integration fixes needed:
1. Add `_renderPowerups` to Renderer's public API
2. Renderer's `render()` method needs to exclude its own menu/gameover/victory/pause overlays (since UIManager handles them)
3. Camera: Make gameplay.js and renderer.js share the same camera object
4. Screen shake: Unify
5. Input handling: Create shared input object
6. CONFIG defaults

Actually, let me think about this differently. The simplest approach that maintains code integrity:

**Main game loop dispatching:**
- For `menu` state: Call `UIManager.update(dt)`, `UIManager.drawMainMenu()`
- For `playing` state: Call `updateGameplay(dt)`, `Renderer.renderBackground()`, then use a modified version of render logic for game objects, then `UIManager.drawHUD()`
- For `paused` state: Call `Renderer.renderBackground()`, game objects, `UIManager.drawHUD()`, `UIManager.drawPauseMenu()`
- For `gameover` state: `UIManager.drawGameOver()`
- For `victory` state: `UIManager.drawVictory()`

For the game object rendering in playing/paused states, I need:
- Renderer.renderPlayer()
- Renderer.renderEnemies() 
- Renderer.renderProjectiles()
- Renderer.renderParticles()
- _renderPowerups() — need to export

Let me handle this: I'll modify the `Renderer` return object to include `renderPowerups` by converting `_renderPowerups` to a public method. Or, I can just inline the powerup rendering in the game loop.

Actually, the cleanest approach is to just NOT use Renderer at all for the final integrated HTML. Instead, I'll write a single unified rendering system that calls individual drawing functions. But that would discard the agent work. Let me find a middle ground.

OK here's my final approach: Write a single HTML file where I:
1. Keep the gameplay.js logic intact (it's well-written)
2. Include the renderer but modify it slightly to export the powerup renderer and to skip its own screen overlays
3. Include UIManager and AudioManager from ui-audio.js with minimal changes
4. Create the main loop that coordinates everything

The main modifications to renderer:
- Remove `_renderMenu()`, `_renderPauseOverlay()`, `_renderGameOver()`, `_renderVictory()` from render flow
- Export `renderPowerups` method
- Make render() NOT clear the canvas (let the main loop handle that)
- Or better: have render() only handle background + game objects, and the main loop calls UIManager for overlays

Actually I realize I'm overthinking this. Let me just write the file. I'll combine everything, with the renderer extended to expose what it needs. The file will be large but functional.

Let me write it now.

All 5 agents delivered. Now I'm integrating all modules into a single production-ready HTML file. Let me create it.

**Tool: bash**

**Input:**
```json
{
  "command": "wc -l /Users/srpanwar/Documents/Workspace/brain/temp/gameplay.js /Users/srpanwar/Documents/Workspace/brain/temp/ui-audio.js /Users/srpanwar/Documents/Workspace/brain/temp/renderer.js",
  "description": "Count lines of all modules"
}
```

**Output:**
```
    1293 /Users/srpanwar/Documents/Workspace/brain/temp/gameplay.js
     748 /Users/srpanwar/Documents/Workspace/brain/temp/ui-audio.js
    1570 /Users/srpanwar/Documents/Workspace/brain/temp/renderer.js
    3611 total

```

---

## Assistant (Build · DeepSeek V4 Pro · 783.5s)

_Thinking:_

3611 total lines. Now let me create the complete integrated HTML file. I'll carefully combine all the modules, fixing the integration points.

Key integration points:
1. Camera: gameplay.js declares `camera` as var; renderer has private `_camera`. I'll use gameplay.js's camera and modify renderer to use it.
2. Screen shake: gameplay.js uses `gameState.shakeMagnitude` → `camera.shakeX/Y`; renderer uses `shakeIntensity`. I'll unify.
3. Input handling: Not in any module; need to create.
4. CONFIG and gameState: Not defined; need to create.
5. deltaTime: Computed in main loop.
6. particles array: gameplay.js pushes to it; need to initialize it.
7. renderer needs access to powerup rendering, which is currently private.

Let me write the complete file now. This will be around 4000+ lines when combined.

Rather than repeating all the code, I'll be strategic:
- I'll include gameplay.js mostly as-is (it uses var globals which naturally work)
- I'll modify renderer.js to work with gameplay.js's camera/shake system
- I'll include ui-audio.js's AudioManager and UIManager with minor modifications
- I'll add the InputManager, CONFIG, gameState, and main loop

Let me start writing. This is going to be a long file, so let me write it efficiently.

Now I'll create the complete integrated game. This will combine all 3611 lines of agent code plus the integration layer.

**Tool: write**

**Input:**
```json
{
  "filePath": "/Users/srpanwar/Documents/Workspace/brain/temp/void-strikers.html",
  "content": "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no, viewport-fit=cover\">\n<meta name=\"apple-mobile-web-app-capable\" content=\"yes\">\n<title>Void Strikers</title>\n<style>\n  * { margin: 0; padding: 0; box-sizing: border-box; }\n  html, body { width: 100%; height: 100%; overflow: hidden; background: #000; touch-action: none; -webkit-touch-callout: none; -webkit-user-select: none; user-select: none; }\n  canvas { display: block; image-rendering: auto; }\n</style>\n</head>\n<body>\n<canvas id=\"game\"></canvas>\n\n<script>\n// ============================================================================\n// VOID STRIKERS — Complete Game Engine\n// ============================================================================\n// Integration of: gameplay.js + renderer.js + ui-audio.js + input + main loop\n// ============================================================================\n\n'use strict';\n\n// ---- DOM Elements ----\nvar canvas = document.getElementById('game');\nvar ctx = canvas.getContext('2d');\n\n// ---- Configuration ----\nvar CONFIG = {\n  gameWidth: 640,\n  gameHeight: 960,\n  starSpeedFar: 10,\n  starSpeedMid: 20,\n  starSpeedNear: 35,\n  starSizeFar: [0.4, 1.0],\n  starSizeMid: [0.8, 1.6],\n  starSizeNear: [1.2, 2.8],\n  playerColor: '#00ccff',\n  playerSpeed: 350,\n  playerShootCooldown: 0.15,\n  scoutColor: '#ff66cc',\n  fighterColor: '#ff4444',\n  tankColor: '#ff8833',\n  sniperColor: '#aadd00',\n  bossColor: '#ff3333',\n  cameraSmoothing: 0.08,\n  hudFontSize: 16\n};\n\n// ---- Game State ----\nvar gameState = {\n  state: 'menu',\n  score: 0,\n  combo: 0,\n  comboMultiplier: 1,\n  comboTimer: 0,\n  comboFlashTimer: 0,\n  comboPopupText: '',\n  lastKillX: 0,\n  lastKillY: 0,\n  level: 1,\n  shakeMagnitude: 0,\n  maxCombo: 0,\n  enemiesKilled: 0\n};\n\n// ---- Delta Time ----\nvar deltaTime = 0.016;\nvar gameTime = 0;\n\n// ---- Camera ----\nvar camera = {\n  x: 0, y: 0,\n  targetX: 0, targetY: 0,\n  shakeX: 0, shakeY: 0\n};\n\n// ---- Particle Pool ----\nvar particles = [];\nvar MAX_PARTICLES = 500;\n\n// ============================================================================\n// INPUT MANAGER\n// ============================================================================\nvar input = {\n  keys: {},\n  mouse: { x: 0, y: 0, down: false },\n  touches: [],\n  _keydown: function(e) {\n    input.keys[e.code] = true;\n    if (e.code === 'Space' || e.code === 'KeyW' || e.code === 'KeyA' ||\n        e.code === 'KeyS' || e.code === 'KeyD' || e.code.startsWith('Arrow')) {\n      e.preventDefault();\n    }\n    if (e.code === 'KeyP') {\n      if (gameState.state === 'playing') { pauseGame(); AudioManager.playMenuSelect(); }\n      else if (gameState.state === 'paused') { resumeGame(); AudioManager.playMenuSelect(); }\n      else if (gameState.state === 'menu') { startGame(); AudioManager.playMenuSelect(); }\n    }\n    if (e.code === 'KeyM') { AudioManager.toggleMute(); }\n    if (e.code === 'KeyR') {\n      if (gameState.state === 'gameover' || gameState.state === 'victory') {\n        restartGame();\n        AudioManager.playMenuSelect();\n        AudioManager.startMusic(1);\n      } else if (gameState.state === 'paused') {\n        restartGame();\n        AudioManager.playMenuSelect();\n        AudioManager.startMusic(1);\n      }\n    }\n    if (e.code === 'Enter' || e.code === 'Space') {\n      if (gameState.state === 'menu') {\n        AudioManager.init();\n        startGame();\n        AudioManager.playMenuSelect();\n        AudioManager.startMusic(1);\n      }\n    }\n  },\n  _keyup: function(e) {\n    input.keys[e.code] = false;\n  },\n  _mousemove: function(e) {\n    var rect = canvas.getBoundingClientRect();\n    var scaleX = CONFIG.gameWidth / rect.width;\n    var scaleY = CONFIG.gameHeight / rect.height;\n    input.mouse.x = (e.clientX - rect.left) * scaleX;\n    input.mouse.y = (e.clientY - rect.top) * scaleY;\n  },\n  _mousedown: function(e) { input.mouse.down = true; e.preventDefault(); },\n  _mouseup: function(e) { input.mouse.down = false; },\n  _touchstart: function(e) {\n    e.preventDefault();\n    AudioManager.init();\n    input.touches = [];\n    for (var i = 0; i < e.touches.length; i++) {\n      var t = e.touches[i];\n      var rect = canvas.getBoundingClientRect();\n      var scaleX = CONFIG.gameWidth / rect.width;\n      var scaleY = CONFIG.gameHeight / rect.height;\n      input.touches.push({ x: (t.clientX - rect.left) * scaleX, y: (t.clientY - rect.top) * scaleY, id: t.identifier });\n    }\n    if (gameState.state === 'menu') { startGame(); AudioManager.playMenuSelect(); AudioManager.startMusic(1); }\n  },\n  _touchmove: function(e) {\n    e.preventDefault();\n    for (var i = 0; i < e.touches.length; i++) {\n      var t = e.touches[i];\n      var rect = canvas.getBoundingClientRect();\n      var scaleX = CONFIG.gameWidth / rect.width;\n      var scaleY = CONFIG.gameHeight / rect.height;\n      if (input.touches[i]) {\n        input.touches[i].x = (t.clientX - rect.left) * scaleX;\n        input.touches[i].y = (t.clientY - rect.top) * scaleY;\n      }\n    }\n  },\n  _touchend: function(e) {\n    e.preventDefault();\n    input.touches = [];\n    for (var i = 0; i < e.touches.length; i++) {\n      var t = e.touches[i];\n      var rect = canvas.getBoundingClientRect();\n      var scaleX = CONFIG.gameWidth / rect.width;\n      var scaleY = CONFIG.gameHeight / rect.height;\n      input.touches.push({ x: (t.clientX - rect.left) * scaleX, y: (t.clientY - rect.top) * scaleY, id: t.identifier });\n    }\n  }\n};\n\ndocument.addEventListener('keydown', input._keydown);\ndocument.addEventListener('keyup', input._keyup);\ncanvas.addEventListener('mousemove', input._mousemove);\ncanvas.addEventListener('mousedown', input._mousedown);\ncanvas.addEventListener('mouseup', input._mouseup);\ncanvas.addEventListener('touchstart', input._touchstart, { passive: false });\ncanvas.addEventListener('touchmove', input._touchmove, { passive: false });\ncanvas.addEventListener('touchend', input._touchend, { passive: false });\ncanvas.addEventListener('touchcancel', input._touchend, { passive: false });\n\n// ============================================================================\n// RESIZE SYSTEM\n// ============================================================================\nfunction resizeCanvas() {\n  var winW = window.innerWidth;\n  var winH = window.innerHeight;\n  var aspect = CONFIG.gameWidth / CONFIG.gameHeight;\n  var winAspect = winW / winH;\n  var w, h;\n  if (winAspect > aspect) {\n    h = winH;\n    w = h * aspect;\n  } else {\n    w = winW;\n    h = w / aspect;\n  }\n  CONFIG.gameWidth = Math.floor(w);\n  CONFIG.gameHeight = Math.floor(h);\n  canvas.width = CONFIG.gameWidth;\n  canvas.height = CONFIG.gameHeight;\n  canvas.style.width = w + 'px';\n  canvas.style.height = h + 'px';\n  canvas.style.position = 'absolute';\n  canvas.style.left = Math.floor((winW - w) / 2) + 'px';\n  canvas.style.top = Math.floor((winH - h) / 2) + 'px';\n  if (UIManager) UIManager.onResize();\n}\n\nwindow.addEventListener('resize', resizeCanvas);\nwindow.addEventListener('orientationchange', function() { setTimeout(resizeCanvas, 100); });\nresizeCanvas();\n\n// ============================================================================\n// UTILITY HELPERS\n// ============================================================================\nfunction clamp(val, min, max) { return Math.max(min, Math.min(max, val)); }\nfunction lerp(a, b, t) { return a + (b - a) * t; }\nfunction rand(min, max) { return Math.random() * (max - min) + min; }\nfunction randInt(min, max) { return Math.floor(rand(min, max + 1)); }\nfunction distSq(x1, y1, x2, y2) { return (x2 - x1) ** 2 + (y2 - y1) ** 2; }\nfunction angleTo(x1, y1, x2, y2) { return Math.atan2(y2 - y1, x2 - x1); }\nfunction onScreen(x, y, margin) {\n  margin = margin || 80;\n  return x > -margin && x < CONFIG.gameWidth + margin && y > -margin && y < CONFIG.gameHeight + margin;\n}\n\n// ============================================================================\n// SCREEN SHAKE\n// ============================================================================\nfunction triggerShake(magnitude) {\n  gameState.shakeMagnitude = Math.max(gameState.shakeMagnitude, magnitude || 3);\n}\nfunction updateShake(dt) {\n  if (gameState.shakeMagnitude > 0.01) {\n    var m = gameState.shakeMagnitude;\n    camera.shakeX = (Math.random() - 0.5) * m * 2;\n    camera.shakeY = (Math.random() - 0.5) * m * 2;\n    gameState.shakeMagnitude *= Math.pow(0.05, dt);\n  } else {\n    gameState.shakeMagnitude = 0;\n    camera.shakeX = 0;\n    camera.shakeY = 0;\n  }\n}\n\n// ============================================================================\n// PARTICLE HELPERS\n// ============================================================================\nfunction spawnExplosion(x, y, count, color, speed, life) {\n  count = count || 12; color = color || '#ff8800'; speed = speed || 200; life = life || 0.6;\n  while (particles.length > MAX_PARTICLES) particles.shift();\n  for (var i = 0; i < count; i++) {\n    var angle = (Math.PI * 2 / count) * i + rand(-0.3, 0.3);\n    var spd = rand(speed * 0.5, speed);\n    particles.push({\n      x: x, y: y, vx: Math.cos(angle) * spd, vy: Math.sin(angle) * spd,\n      life: rand(life * 0.5, life), maxLife: life,\n      color: color, size: rand(2, 5), decay: true, type: 'explosion'\n    });\n  }\n}\nfunction spawnSpark(x, y, color) {\n  color = color || '#ffffff';\n  for (var i = 0; i < 3; i++) {\n    particles.push({\n      x: x, y: y, vx: rand(-80, 80), vy: rand(-80, 80),\n      life: rand(0.1, 0.3), maxLife: 0.3, color: color, size: rand(1, 2), decay: true, type: 'spark'\n    });\n  }\n}\nfunction spawnRingBurst(x, y, color, count) {\n  count = count || 16; color = color || '#ffffff';\n  var speed = 120;\n  for (var i = 0; i < count; i++) {\n    var a = (Math.PI * 2 / count) * i;\n    particles.push({ x: x, y: y, vx: Math.cos(a) * speed, vy: Math.sin(a) * speed, life: 0.4, maxLife: 0.4, color: color, size: 3, type: 'ring' });\n  }\n}\nfunction updateParticles(dt) {\n  for (var i = particles.length - 1; i >= 0; i--) {\n    var p = particles[i];\n    p.life -= dt;\n    if (p.life <= 0) { particles.splice(i, 1); continue; }\n    p.x += p.vx * dt;\n    p.y += p.vy * dt;\n    p.vx *= 0.98;\n    p.vy *= 0.98;\n  }\n}\n\n// ============================================================================\n// COMBO SYSTEM\n// ============================================================================\nfunction addKill(x, y) {\n  gameState.combo++;\n  gameState.enemiesKilled++;\n  gameState.comboTimer = 2.0;\n  gameState.lastKillX = x;\n  gameState.lastKillY = y;\n\n  var prevMult = gameState.comboMultiplier;\n  if (gameState.combo >= 100)      gameState.comboMultiplier = 5;\n  else if (gameState.combo >= 50)  gameState.comboMultiplier = 3;\n  else if (gameState.combo >= 25)  gameState.comboMultiplier = 2;\n  else if (gameState.combo >= 10)  gameState.comboMultiplier = 1.5;\n  else                             gameState.comboMultiplier = 1;\n\n  if (gameState.comboMultiplier > prevMult) {\n    gameState.comboFlashTimer = 1.0;\n    spawnRingBurst(x, y, '#ffff00', 12);\n    AudioManager.playComboUp(gameState.combo);\n  }\n  if (gameState.combo > gameState.maxCombo) gameState.maxCombo = gameState.combo;\n\n  UIManager.triggerComboPopup(gameState.combo);\n}\nfunction updateCombo(dt) {\n  if (gameState.comboTimer > 0) {\n    gameState.comboTimer -= dt;\n    if (gameState.comboTimer <= 0) { gameState.combo = 0; gameState.comboMultiplier = 1; }\n  }\n  if (gameState.comboFlashTimer > 0) gameState.comboFlashTimer -= dt;\n}\n\n// ============================================================================\n// BULLET POOL SYSTEM\n// ============================================================================\nvar BULLET_POOL_SIZE = 400;\nvar projectiles = [];\n\nfunction initBulletPool() {\n  projectiles = [];\n  for (var i = 0; i < BULLET_POOL_SIZE; i++) {\n    projectiles.push({\n      x: 0, y: 0, vx: 0, vy: 0, damage: 0, type: 'enemyBullet', owner: 'enemy',\n      color: '#ff4444', size: 3, alive: false, pierceCount: 0\n    });\n  }\n}\n\nfunction getDeadBullet() {\n  for (var i = 0; i < projectiles.length; i++) {\n    if (!projectiles[i].alive) return projectiles[i];\n  }\n  var oldest = null, oldestDist = -1;\n  for (var j = 0; j < projectiles.length; j++) {\n    var d = distSq(projectiles[j].x, projectiles[j].y, CONFIG.gameWidth / 2, CONFIG.gameHeight / 2);\n    if (d > oldestDist) { oldestDist = d; oldest = projectiles[j]; }\n  }\n  return oldest || projectiles[0];\n}\n\nfunction spawnBullet(x, y, vx, vy, damage, owner, bulletType, color, size, pierce) {\n  var b = getDeadBullet();\n  b.x = x; b.y = y; b.vx = vx; b.vy = vy;\n  b.damage = damage || 10;\n  b.owner = owner;\n  b.type = bulletType || (owner === 'player' ? 'playerBullet' : 'enemyBullet');\n  b.color = color || (owner === 'player' ? '#00ffff' : '#ff4444');\n  b.size = size || (owner === 'player' ? 4 : 3);\n  b.alive = true;\n  b.pierceCount = pierce || 0;\n  return b;\n}\n\nfunction updateBullets(dt) {\n  for (var i = 0; i < projectiles.length; i++) {\n    var b = projectiles[i];\n    if (!b.alive) continue;\n    b.x += b.vx * dt;\n    b.y += b.vy * dt;\n    if (Math.abs(b.vx) + Math.abs(b.vy) > 400 && Math.random() < 0.5) {\n      particles.push({ x: b.x, y: b.y, vx: rand(-20,20), vy: rand(-20,20), life: 0.15, maxLife: 0.15, color: b.color, size: b.size*0.6, type: 'spark' });\n    }\n    if (!onScreen(b.x, b.y, 60)) { b.alive = false; }\n  }\n}\n\n// ============================================================================\n// PLAYER\n// ============================================================================\nvar player = {\n  x: 0, y: 0, vx: 0, vy: 0, width: 30, height: 30,\n  hp: 100, maxHp: 100, shield: 0, shieldActive: false,\n  speed: 350, weaponLevel: 1, rotation: 0, scale: 1,\n  invulnerable: false, invulnerableTimer: 0,\n  shootTimer: 0, shootCooldown: 0.15,\n  chargeLevel: 0, maxCharge: 100, charging: false, chargeCooldown: 0,\n  speedBoostTimer: 0, engineFlicker: 0\n};\n\nfunction resetPlayer() {\n  player.x = CONFIG.gameWidth / 2;\n  player.y = CONFIG.gameHeight * 0.8;\n  player.vx = 0; player.vy = 0;\n  player.hp = 100; player.maxHp = 100;\n  player.shield = 0; player.shieldActive = false;\n  player.speed = CONFIG.playerSpeed || 350;\n  player.weaponLevel = 1;\n  player.invulnerable = false; player.invulnerableTimer = 0;\n  player.shootTimer = 0; player.shootCooldown = CONFIG.playerShootCooldown || 0.15;\n  player.chargeLevel = 0; player.maxCharge = 100;\n  player.charging = false; player.chargeCooldown = 0;\n  player.speedBoostTimer = 0; player.engineFlicker = 0;\n}\n\nfunction updatePlayer(dt) {\n  if (gameState.state !== 'playing') return;\n\n  // Movement\n  var moveX = 0, moveY = 0;\n  if (input.keys['ArrowLeft'] || input.keys['KeyA']) moveX -= 1;\n  if (input.keys['ArrowRight'] || input.keys['KeyD']) moveX += 1;\n  if (input.keys['ArrowUp'] || input.keys['KeyW']) moveY -= 1;\n  if (input.keys['ArrowDown'] || input.keys['KeyS']) moveY += 1;\n\n  // Touch movement\n  if (input.touches.length > 0) {\n    var t = input.touches[0];\n    var targetX = t.x, targetY = t.y - 40;\n    var dx = targetX - player.x, dy = targetY - player.y;\n    var dist = Math.sqrt(dx * dx + dy * dy);\n    if (dist > 10) { moveX = (dx / dist); moveY = (dy / dist); }\n  }\n\n  if (moveX !== 0 && moveY !== 0) { moveX *= 0.70710678; moveY *= 0.70710678; }\n\n  var currentSpeed = player.speed + (player.speedBoostTimer > 0 ? 120 : 0);\n  player.vx = moveX * currentSpeed;\n  player.vy = moveY * currentSpeed;\n  player.x += player.vx * dt;\n  player.y += player.vy * dt;\n\n  player.x = clamp(player.x, 20, CONFIG.gameWidth - 20);\n  player.y = clamp(player.y, 20, CONFIG.gameHeight - 20);\n\n  // Speed boost timer\n  if (player.speedBoostTimer > 0) player.speedBoostTimer -= dt;\n\n  // Engine flicker\n  player.engineFlicker -= dt;\n  if (player.engineFlicker <= 0) {\n    player.engineFlicker = 0.04;\n    if (particles.length < MAX_PARTICLES) {\n      particles.push({ x: player.x+rand(-6,6), y: player.y+player.height/2+2, vx:rand(-20,20), vy:rand(60,120), life:0.25, maxLife:0.25, color: '#4488ff', size:rand(1,3), type:'engine' });\n    }\n  }\n\n  // Invulnerability\n  if (player.invulnerable) { player.invulnerableTimer -= dt; if (player.invulnerableTimer <= 0) player.invulnerable = false; }\n\n  // Shooting\n  var isCharging = input.keys['Space'] || input.keys['KeyJ'] || (input.touches.length > 1);\n  if (isCharging) {\n    if (!player.charging) { player.charging = true; player.chargeLevel = 0; }\n    player.chargeLevel = clamp(player.chargeLevel + (50 * dt), 0, player.maxCharge);\n  } else if (player.charging) {\n    if (player.chargeLevel >= 30) { playerChargedShot(); AudioManager.playChargedShot(); }\n    player.charging = false;\n    player.chargeLevel = 0;\n  }\n\n  if (player.chargeCooldown > 0) player.chargeCooldown -= dt;\n\n  // Charge particles\n  if (player.charging && player.chargeLevel > 20 && Math.random() < 0.6) {\n    if (particles.length < MAX_PARTICLES) {\n      particles.push({ x:player.x+rand(-14,14), y:player.y+rand(-10,10), vx:rand(-30,30), vy:rand(-30,-10), life:0.3, maxLife:0.3, color:'#88ccff', size:rand(2,4), type:'spark' });\n    }\n  }\n}\n\nfunction playerShoot() {\n  var bx = player.x, by = player.y - player.height / 2;\n  switch (player.weaponLevel) {\n    case 1: spawnBullet(bx, by, 0, -600, 10, 'player', 'playerBullet', '#00ffff', 4, 0); break;\n    case 2: spawnBullet(bx-8, by, 0, -600, 10, 'player', 'playerBullet', '#00ffff', 4, 0); spawnBullet(bx+8, by, 0, -600, 10, 'player', 'playerBullet', '#00ffff', 4, 0); break;\n    case 3: spawnBullet(bx, by, 0, -650, 12, 'player', 'playerBullet', '#00ffff', 4, 0); spawnBullet(bx-6, by+2, -60, -600, 10, 'player', 'playerBullet', '#44ddff', 3, 0); spawnBullet(bx+6, by+2, 60, -600, 10, 'player', 'playerBullet', '#44ddff', 3, 0); break;\n  }\n  spawnSpark(bx, by - 5, '#00ffff');\n  AudioManager.playShoot();\n}\n\nfunction playerChargedShot() {\n  if (player.chargeCooldown > 0) return;\n  player.chargeCooldown = 0.5;\n  var power = clamp(player.chargeLevel / player.maxCharge, 0.3, 1);\n  var damage = Math.floor(50 * power);\n  var pierce = Math.floor(4 * power);\n  var size = 4 + 8 * power;\n  var speed = 250 + 200 * power;\n  spawnBullet(player.x, player.y - player.height / 2, 0, -speed, damage, 'player', 'chargedShot', '#ffffff', size, pierce);\n  spawnExplosion(player.x, player.y - player.height / 2, 20, '#88ccff', 150, 0.4);\n  triggerShake(3 + 4 * power);\n}\n\nfunction playerTakeDamage(amount) {\n  if (player.invulnerable) return;\n  if (gameState.state !== 'playing') return;\n\n  if (player.shield > 0) {\n    var absorbed = Math.min(player.shield, amount);\n    player.shield -= absorbed;\n    amount -= absorbed;\n    player.shieldActive = player.shield > 0;\n    spawnSpark(player.x, player.y, '#4488ff');\n    if (player.shield <= 0) { spawnExplosion(player.x, player.y, 8, '#4488ff', 100, 0.4); AudioManager.playShieldBreak(); }\n  }\n\n  if (amount > 0) {\n    player.hp -= amount;\n    player.invulnerable = true;\n    player.invulnerableTimer = 2.0;\n    triggerShake(6);\n    spawnExplosion(player.x, player.y, 10, '#ff4444', 180, 0.5);\n    AudioManager.playPlayerHit();\n    gameState.combo = 0;\n    gameState.comboMultiplier = 1;\n    if (player.hp <= 0) {\n      player.hp = 0;\n      spawnExplosion(player.x, player.y, 40, '#ff8800', 300, 1.0);\n      triggerShake(15);\n      AudioManager.playGameOver();\n      AudioManager.stopMusic();\n      gameOver();\n    }\n  }\n}\n\nfunction playerApplyPowerUp(type) {\n  AudioManager.playPowerUp();\n  switch (type) {\n    case 'health': player.hp = Math.min(player.hp + 30, player.maxHp); spawnRingBurst(player.x, player.y, '#00ff66', 12); break;\n    case 'shield': player.shield = 100; player.shieldActive = true; spawnRingBurst(player.x, player.y, '#4488ff', 12); break;\n    case 'weapon': if (player.weaponLevel < 3) player.weaponLevel++; else gameState.score += 500 * gameState.comboMultiplier; spawnRingBurst(player.x, player.y, '#ffaa00', 14); break;\n    case 'speed': player.speedBoostTimer = 5.0; spawnRingBurst(player.x, player.y, '#00ffff', 10); break;\n  }\n}\n\n// ============================================================================\n// ENEMY TYPES & FACTORY\n// ============================================================================\nvar ENEMY_DEFS = {\n  scout: { name:'Scout',width:24,height:24,hp:20,speed:80,damage:15,scoreValue:100,color:'#ff6644',shootCooldown:0,behavior:'straightDown' },\n  fighter:{ name:'Fighter',width:28,height:28,hp:40,speed:130,damage:20,scoreValue:200,color:'#ff8844',shootCooldown:1.5,behavior:'sineWave' },\n  tank:  { name:'Tank',width:36,height:36,hp:80,speed:50,damage:30,scoreValue:400,color:'#cc4422',shootCooldown:2.0,behavior:'tank' },\n  speeder:{ name:'Speeder',width:22,height:22,hp:15,speed:260,damage:25,scoreValue:300,color:'#ffcc00',shootCooldown:0,behavior:'dive' },\n  sniper:{ name:'Sniper',width:26,height:26,hp:35,speed:60,damage:25,scoreValue:350,color:'#ff4488',shootCooldown:1.2,behavior:'sniper' },\n  boss:  { name:'Boss',width:70,height:70,hp:500,speed:40,damage:40,scoreValue:5000,color:'#ff2222',shootCooldown:0.6,behavior:'boss' }\n};\n\nvar enemies = [];\n\nfunction spawnEnemy(type, x, y) {\n  var def = ENEMY_DEFS[type];\n  if (!def) return null;\n  var hpMult = 1, spdMult = 1;\n  if (type === 'boss') { hpMult = 1 + (gameState.level-1)*0.6; spdMult = 1 + (gameState.level-1)*0.15; }\n  var e = {\n    x: x, y: y, vx: 0, vy: def.speed * spdMult,\n    width: def.width, height: def.height,\n    hp: Math.floor(def.hp * hpMult), maxHp: Math.floor(def.hp * hpMult),\n    speed: def.speed * spdMult, damage: def.damage, scoreValue: def.scoreValue,\n    type: type, color: def.color,\n    hitTimer: 0, deathTimer: 0, rotation: 0, scale: 1,\n    shootTimer: rand(0, def.shootCooldown), shootCooldown: def.shootCooldown,\n    phase: 0, behaviorTimer: 0, spawnX: x, spawnY: y, alive: true\n  };\n  enemies.push(e);\n  return e;\n}\n\nfunction updateEnemies(dt) {\n  for (var i = enemies.length - 1; i >= 0; i--) {\n    var e = enemies[i];\n    if (!e.alive) { e.deathTimer -= dt; if (e.deathTimer <= 0) { enemies.splice(i, 1); } continue; }\n    if (e.hitTimer > 0) e.hitTimer -= dt;\n    e.behaviorTimer += dt;\n    e.shootTimer -= dt;\n\n    switch (e.behavior || ENEMY_DEFS[e.type].behavior) {\n      case 'straightDown': e.y += e.speed * dt; break;\n      case 'sineWave':\n        e.y += e.speed * dt;\n        e.x = e.spawnX + Math.sin(e.behaviorTimer * 3) * 60;\n        if (e.shootTimer <= 0 && e.shootCooldown > 0) { enemyShoot(e); e.shootTimer = e.shootCooldown; AudioManager.playEnemyShoot(); }\n        break;\n      case 'tank':\n        e.y += e.speed * dt;\n        if (e.y > 80) e.y = 80;\n        e.x += Math.sin(e.behaviorTimer * 0.8) * 40 * dt;\n        if (e.shootTimer <= 0 && e.shootCooldown > 0) { enemyShoot(e); e.shootTimer = e.shootCooldown; AudioManager.playEnemyShoot(); }\n        break;\n      case 'dive':\n        var dx = player.x - e.x, dy = player.y - e.y;\n        var dist = Math.sqrt(dx*dx+dy*dy) || 1;\n        e.vx = (dx/dist)*e.speed; e.vy = (dy/dist)*e.speed;\n        e.x += e.vx*dt; e.y += e.vy*dt;\n        break;\n      case 'sniper':\n        if (e.y < 100) { e.y += e.speed*dt; e.x = e.spawnX + Math.sin(e.behaviorTimer*1.5)*40; }\n        else { e.y = 100 + Math.sin(e.behaviorTimer*0.7)*20; e.x = e.spawnX + Math.sin(e.behaviorTimer*1.5)*50; }\n        if (e.shootTimer <= 0 && e.shootCooldown > 0) { enemyShoot(e); e.shootTimer = e.shootCooldown; AudioManager.playEnemyShoot(); }\n        break;\n      case 'boss': updateBossBehavior(e, dt); break;\n      default: e.y += e.speed * dt;\n    }\n\n    if (e.y > CONFIG.gameHeight + 120) { e.alive = false; enemies.splice(i, 1); }\n  }\n}\n\nfunction updateBossBehavior(boss, dt) {\n  if (boss.phase === 0) {\n    if (boss.y < 120) { boss.y += boss.speed * dt; boss.x += (CONFIG.gameWidth/2 - boss.x) * 0.02; }\n    else { boss.phase = 1; boss.behaviorTimer = 0; }\n  }\n  else if (boss.phase === 1) {\n    boss.x = CONFIG.gameWidth/2 + Math.sin(boss.behaviorTimer*1.2)*(CONFIG.gameWidth*0.35);\n    boss.y = 100 + Math.sin(boss.behaviorTimer*0.5)*30;\n    if (boss.shootTimer <= 0) {\n      for (var i = -1; i <= 1; i++) {\n        var a = angleTo(boss.x, boss.y+35, player.x, player.y) + i*0.2;\n        spawnBullet(boss.x, boss.y+35, Math.cos(a)*220, Math.sin(a)*220, 15, 'enemy', 'enemyBullet', '#ff4444', 3, 0);\n      }\n      boss.shootTimer = 0.8;\n      AudioManager.playEnemyShoot();\n    }\n    if (boss.hp < boss.maxHp*0.6) { boss.phase = 2; boss.behaviorTimer = 0; spawnExplosion(boss.x, boss.y, 20, '#ff4400', 200, 0.6); triggerShake(4); AudioManager.playBossWarning(); }\n  }\n  else if (boss.phase === 2) {\n    boss.x = CONFIG.gameWidth/2 + Math.sin(boss.behaviorTimer*1.8)*(CONFIG.gameWidth*0.35);\n    boss.y = 120 + Math.cos(boss.behaviorTimer*0.9)*60;\n    if (boss.shootTimer <= 0) {\n      var baseA = angleTo(boss.x, boss.y+35, player.x, player.y);\n      for (var j = -2; j <= 2; j++) {\n        var a2 = baseA + j*0.25;\n        spawnBullet(boss.x, boss.y+35, Math.cos(a2)*250, Math.sin(a2)*250, 15, 'enemy', 'enemyBullet', '#ff6644', 3, 0);\n      }\n      boss.shootTimer = 0.5;\n      AudioManager.playEnemyShoot();\n    }\n    if (boss.hp < boss.maxHp*0.25) { boss.phase = 3; boss.behaviorTimer = 0; spawnExplosion(boss.x, boss.y, 30, '#ff2200', 250, 0.8); triggerShake(6); AudioManager.playBossWarning(); }\n  }\n  else {\n    boss.x = CONFIG.gameWidth/2 + Math.sin(boss.behaviorTimer*2.5)*(CONFIG.gameWidth*0.3);\n    boss.y = 100 + Math.cos(boss.behaviorTimer*1.4)*80;\n    if (boss.shootTimer <= 0) {\n      var count = 8;\n      for (var k = 0; k < count; k++) {\n        var a3 = (Math.PI*2/count)*k + boss.behaviorTimer*0.5;\n        spawnBullet(boss.x, boss.y+35, Math.cos(a3)*200, Math.sin(a3)*200, 15, 'enemy', 'enemyBullet', '#ff2244', 3, 0);\n      }\n      boss.shootTimer = 0.4;\n      AudioManager.playEnemyShoot();\n    }\n  }\n}\n\nfunction enemyShoot(enemy) {\n  var a = angleTo(enemy.x, enemy.y+enemy.height/2, player.x, player.y);\n  if (enemy.type === 'tank') {\n    for (var i = -1; i <= 1; i++) {\n      var spreadA = a + i*0.3;\n      spawnBullet(enemy.x, enemy.y+enemy.height/2, Math.cos(spreadA)*200, Math.sin(spreadA)*200, enemy.damage, 'enemy', 'enemyBullet', '#ff6644', 4, 0);\n    }\n  } else if (enemy.type === 'sniper') {\n    spawnBullet(enemy.x, enemy.y+enemy.height/2, Math.cos(a)*400, Math.sin(a)*400, enemy.damage, 'enemy', 'enemyBullet', '#ff88aa', 5, 0);\n  } else {\n    spawnBullet(enemy.x, enemy.y+enemy.height/2, Math.cos(a)*220, Math.sin(a)*220, enemy.damage, 'enemy', 'enemyBullet', '#ff4444', 3, 0);\n  }\n}\n\nfunction damageEnemy(enemy, amount, bullet) {\n  if (!enemy.alive) return;\n  enemy.hitTimer = enemy.type === 'boss' ? 0.12 : 0.06;\n  enemy.hp -= amount;\n  spawnSpark(enemy.x, enemy.y, '#ffffff');\n  AudioManager.playHit();\n\n  if (bullet && bullet.pierceCount > 0) { bullet.pierceCount--; }\n  else if (bullet) { bullet.alive = false; }\n\n  if (enemy.hp <= 0) {\n    enemy.alive = false;\n    enemy.deathTimer = 0.5;\n    var scoreEarned = enemy.scoreValue * gameState.comboMultiplier;\n    gameState.score += scoreEarned;\n    addKill(enemy.x, enemy.y);\n\n    if (enemy.type === 'boss') {\n      spawnExplosion(enemy.x, enemy.y, 50, '#ff4400', 350, 1.5);\n      spawnExplosion(enemy.x, enemy.y, 30, '#ffaa00', 250, 1.0);\n      triggerShake(12);\n      AudioManager.playExplosion();\n      spawnPowerUp(enemy.x, enemy.y, 'weapon');\n      checkBossDefeated(enemy);\n    } else {\n      spawnExplosion(enemy.x, enemy.y, 8, enemy.color, 150, 0.5);\n      AudioManager.playExplosion();\n      if (Math.random() < 0.15) {\n        var types = ['health', 'health', 'shield', 'weapon', 'speed'];\n        var roll = types[randInt(0, types.length-1)];\n        if (roll === 'weapon' && player.weaponLevel >= 3) roll = 'health';\n        spawnPowerUp(enemy.x, enemy.y, roll);\n      }\n    }\n  }\n}\n\n// ============================================================================\n// POWER-UP SYSTEM\n// ============================================================================\nvar powerups = [];\n\nfunction spawnPowerUp(x, y, type) {\n  type = type || 'health';\n  var colors = { health:'#00ff66', shield:'#4488ff', weapon:'#ffaa00', speed:'#00ffff' };\n  powerups.push({\n    x: x, y: y, vy: 60, size: 12, type: type,\n    color: colors[type] || '#00ff66', glow: colors[type] || '#00ff66',\n    alive: true, bobTimer: Math.random()*Math.PI*2, lifeTimer: 8.0\n  });\n}\n\nfunction updatePowerUps(dt) {\n  for (var i = powerups.length - 1; i >= 0; i--) {\n    var p = powerups[i];\n    if (!p.alive) { powerups.splice(i, 1); continue; }\n    p.y += p.vy * dt;\n    p.bobTimer += dt * 4;\n    p.lifeTimer -= dt;\n    if (p.y > CONFIG.gameHeight+40 || p.lifeTimer <= 0) { p.alive = false; powerups.splice(i, 1); continue; }\n    if (Math.random() < 0.3 && particles.length < MAX_PARTICLES) {\n      particles.push({ x:p.x+rand(-8,8), y:p.y+rand(-8,8), vx:rand(-15,15), vy:rand(-30,-10), life:0.4, maxLife:0.4, color:p.glow, size:rand(1,3), type:'spark' });\n    }\n  }\n}\n\nfunction collectPowerUp(powerUp) {\n  if (!powerUp.alive) return;\n  powerUp.alive = false;\n  playerApplyPowerUp(powerUp.type);\n  spawnExplosion(powerUp.x, powerUp.y, 6, powerUp.glow, 80, 0.3);\n}\n\n// ============================================================================\n// COLLISION DETECTION\n// ============================================================================\nfunction aabb(a, b) {\n  return a.x - a.width/2 < b.x + b.width/2 &&\n         a.x + a.width/2 > b.x - b.width/2 &&\n         a.y - a.height/2 < b.y + b.height/2 &&\n         a.y + a.height/2 > b.y - b.height/2;\n}\n\nfunction checkCollisions() {\n  var i, j;\n  for (i = 0; i < projectiles.length; i++) {\n    var p = projectiles[i];\n    if (!p.alive) continue;\n    if (p.owner === 'player') {\n      for (j = enemies.length-1; j >= 0; j--) {\n        if (!enemies[j].alive) continue;\n        if (aabb(p, enemies[j])) { damageEnemy(enemies[j], p.damage, p); if (!p.alive) break; }\n      }\n    } else {\n      if (aabb(p, player)) { playerTakeDamage(p.damage); p.alive = false; }\n    }\n  }\n  for (j = enemies.length-1; j >= 0; j--) {\n    if (!enemies[j].alive) continue;\n    if (aabb(player, enemies[j])) { playerTakeDamage(enemies[j].damage); enemies[j].alive = false; enemies[j].deathTimer = 0.3; spawnExplosion(enemies[j].x, enemies[j].y, 6, enemies[j].color, 120, 0.4); }\n  }\n  for (i = powerups.length-1; i >= 0; i--) {\n    if (!powerups[i].alive) continue;\n    if (aabb(player, powerups[i])) { collectPowerUp(powerups[i]); }\n  }\n}\n\n// ============================================================================\n// WAVE & LEVEL SYSTEM\n// ============================================================================\nvar waveTimer = 0, waveIndex = 0;\nvar levelBossSpawned = false, levelBossDefeated = false;\nvar levelTransitionTimer = 0;\nvar activeWave = null, waveSubTimer = 0, wavePauseTimer = 0, spawnQueue = [];\n\nvar LEVELS = [\n  { name:'Orbital Approach', waves:[\n    { enemies:[{type:'scout',count:5,delay:0.6}], pauseAfter:2.0 },\n    { enemies:[{type:'scout',count:8,delay:0.5}], pauseAfter:2.5 },\n    { enemies:[{type:'scout',count:4,delay:0.3},{type:'fighter',count:3,delay:0.7}], pauseAfter:3.0 },\n    { enemies:[{type:'fighter',count:6,delay:0.6}], pauseAfter:2.0 },\n    { enemies:[{type:'scout',count:6,delay:0.3},{type:'fighter',count:4,delay:0.5}], pauseAfter:2.0 }\n  ], boss:{type:'boss',hpMultiplier:0.6} },\n  { name:'Nebula Storm', waves:[\n    { enemies:[{type:'fighter',count:6,delay:0.5}], pauseAfter:2.0 },\n    { enemies:[{type:'scout',count:4,delay:0.3},{type:'tank',count:2,delay:1.0}], pauseAfter:3.0 },\n    { enemies:[{type:'speeder',count:4,delay:0.4}], pauseAfter:2.5 },\n    { enemies:[{type:'fighter',count:5,delay:0.4},{type:'sniper',count:2,delay:1.0}], pauseAfter:3.0 },\n    { enemies:[{type:'tank',count:3,delay:0.8},{type:'speeder',count:3,delay:0.4}], pauseAfter:2.0 },\n    { enemies:[{type:'scout',count:8,delay:0.3},{type:'sniper',count:2,delay:1.0}], pauseAfter:2.0 }\n  ], boss:{type:'boss',hpMultiplier:0.8} },\n  { name:'Void Core', waves:[\n    { enemies:[{type:'speeder',count:5,delay:0.3}], pauseAfter:2.0 },\n    { enemies:[{type:'fighter',count:6,delay:0.3},{type:'sniper',count:3,delay:0.6}], pauseAfter:2.5 },\n    { enemies:[{type:'tank',count:3,delay:0.6},{type:'speeder',count:4,delay:0.3}], pauseAfter:2.5 },\n    { enemies:[{type:'scout',count:10,delay:0.2},{type:'fighter',count:4,delay:0.4}], pauseAfter:2.0 },\n    { enemies:[{type:'sniper',count:4,delay:0.5},{type:'tank',count:2,delay:0.8}], pauseAfter:3.0 },\n    { enemies:[{type:'speeder',count:5,delay:0.25},{type:'scout',count:6,delay:0.2},{type:'fighter',count:3,delay:0.4}], pauseAfter:2.0 }\n  ], boss:{type:'boss',hpMultiplier:1.0} }\n];\n\nfunction startLevel(levelNum) {\n  gameState.level = levelNum;\n  gameState.combo = 0;\n  gameState.comboMultiplier = 1;\n  gameState.comboTimer = 0;\n  waveIndex = 0; waveTimer = 1.0;\n  levelBossSpawned = false; levelBossDefeated = false;\n  levelTransitionTimer = 0;\n  activeWave = null; wavePauseTimer = 0; spawnQueue = [];\n  enemies = [];\n  for (var i = 0; i < projectiles.length; i++) projectiles[i].alive = false;\n  powerups = [];\n  UIManager.triggerLevelTransition(levelNum);\n}\n\nfunction updateLevel(dt) {\n  if (gameState.state !== 'playing') return;\n  if (levelTransitionTimer > 0) { levelTransitionTimer -= dt; if (levelTransitionTimer <= 0) startLevel(gameState.level); return; }\n  var levelDef = LEVELS[gameState.level-1];\n  if (wavePauseTimer > 0) { wavePauseTimer -= dt; return; }\n  if (spawnQueue.length > 0) {\n    waveSubTimer -= dt;\n    while (waveSubTimer <= 0 && spawnQueue.length > 0) {\n      var entry = spawnQueue.shift();\n      spawnEnemy(entry.type, entry.x || rand(60, CONFIG.gameWidth-60), entry.y || -40);\n      waveSubTimer += Math.max(entry.delay || 0.5, 0.05);\n    }\n    if (spawnQueue.length === 0) activeWave = null;\n    return;\n  }\n  if (activeWave) return;\n  if (enemies.length === 0) {\n    if (levelBossDefeated) { gameState.score += 1000 * gameState.level; nextLevel(); return; }\n    if (waveIndex >= levelDef.waves.length && !levelBossSpawned) {\n      levelBossSpawned = true;\n      AudioManager.playBossWarning();\n      spawnEnemy(levelDef.boss.type, CONFIG.gameWidth/2, -80);\n      var boss = enemies[enemies.length-1];\n      if (boss) { boss.hp = Math.floor(boss.maxHp*levelDef.boss.hpMultiplier); boss.maxHp = boss.hp; }\n      return;\n    }\n    waveTimer -= dt;\n    if (waveTimer <= 0) startNextWave();\n  }\n}\n\nfunction startNextWave() {\n  var levelDef = LEVELS[gameState.level-1];\n  if (waveIndex >= levelDef.waves.length) return;\n  var wave = levelDef.waves[waveIndex++];\n  spawnQueue = [];\n  for (var i = 0; i < wave.enemies.length; i++) {\n    var group = wave.enemies[i];\n    for (var j = 0; j < group.count; j++) {\n      spawnQueue.push({ type: group.type, x: rand(60, CONFIG.gameWidth-60), y: -40-j*30, delay: group.delay||0.5 });\n    }\n  }\n  waveSubTimer = 0.5; activeWave = true; wavePauseTimer = 0; waveTimer = 0;\n}\n\nfunction checkBossDefeated(enemy) {\n  if (enemy.type === 'boss' && !levelBossDefeated) {\n    levelBossDefeated = true;\n    for (var i = 0; i < enemies.length; i++) {\n      if (enemies[i] !== enemy && enemies[i].alive) {\n        enemies[i].alive = false; spawnExplosion(enemies[i].x, enemies[i].y, 6, enemies[i].color, 100, 0.4);\n      }\n    }\n    enemies = enemies.filter(function(e) { return e.alive; });\n  }\n}\n\n// ============================================================================\n// GAME STATE MACHINE\n// ============================================================================\nfunction startGame() {\n  gameState.state = 'playing';\n  gameState.score = 0;\n  gameState.combo = 0; gameState.comboMultiplier = 1; gameState.comboTimer = 0;\n  gameState.level = 1; gameState.shakeMagnitude = 0;\n  gameState.maxCombo = 0; gameState.enemiesKilled = 0;\n  resetPlayer();\n  initBulletPool();\n  enemies = []; powerups = []; particles.length = 0;\n  startLevel(1);\n}\n\nfunction pauseGame() { if (gameState.state === 'playing') gameState.state = 'paused'; }\nfunction resumeGame() { if (gameState.state === 'paused') gameState.state = 'playing'; }\nfunction gameOver() {\n  gameState.state = 'gameover';\n  spawnExplosion(player.x, player.y, 50, '#ff4400', 350, 1.5);\n  triggerShake(15);\n  for (var i = 0; i < enemies.length; i++) enemies[i].alive = false;\n  enemies = []; powerups = [];\n  var hs = parseInt(localStorage.getItem('voidStrikers_highScore') || 0);\n  if (gameState.score > hs) localStorage.setItem('voidStrikers_highScore', gameState.score);\n}\nfunction restartGame() { startGame(); }\nfunction nextLevel() {\n  if (gameState.level >= 3) {\n    gameState.state = 'victory'; gameState.score += 5000;\n    spawnExplosion(CONFIG.gameWidth/2, CONFIG.gameHeight/2, 60, '#ffff00', 400, 2.0);\n    spawnExplosion(CONFIG.gameWidth/2, CONFIG.gameHeight/2, 30, '#ffffff', 300, 1.5);\n    triggerShake(20);\n    AudioManager.stopMusic(); AudioManager.playVictory();\n    var hs = parseInt(localStorage.getItem('voidStrikers_highScore') || 0);\n    if (gameState.score > hs) localStorage.setItem('voidStrikers_highScore', gameState.score);\n  } else {\n    gameState.level++;\n    levelTransitionTimer = 1.5;\n    for (var i = 0; i < projectiles.length; i++) projectiles[i].alive = false;\n    enemies = []; powerups = [];\n  }\n}\n\nfunction updateGameplay(dt) {\n  updateParticles(dt);\n  updateShake(dt);\n  if (gameState.state !== 'playing') return;\n  updatePlayer(dt);\n  updateBullets(dt);\n  updateEnemies(dt);\n  updatePowerUps(dt);\n  checkCollisions();\n  updateCombo(dt);\n  updateLevel(dt);\n}\n\nfunction initGameplay() {\n  initBulletPool();\n  resetPlayer();\n  enemies = []; powerups = [];\n  waveIndex = 0; waveTimer = 0;\n  levelBossSpawned = false; levelBossDefeated = false;\n  levelTransitionTimer = 0;\n  activeWave = null; spawnQueue = []; wavePauseTimer = 0;\n}\n\n// ============================================================================\n// AUDIO MANAGER\n// ============================================================================\nvar AudioManager = (function () {\n  var ctx = null, masterGain = null, muted = false, masterVol = 0.6;\n  var musicNodes = [], musicRunning = false, musicIntensity = 0, musicLevel = 1;\n\n  function ensureCtx() {\n    if (!ctx) {\n      ctx = new (window.AudioContext || window.webkitAudioContext)();\n      masterGain = ctx.createGain();\n      masterGain.gain.value = muted ? 0 : masterVol;\n      masterGain.connect(ctx.destination);\n    }\n    if (ctx.state === 'suspended') ctx.resume();\n  }\n\n  function playTone(opts) {\n    if (muted) return;\n    ensureCtx();\n    var delay = opts.delay || 0, now = ctx.currentTime + delay;\n    var gains = [];\n    for (var i = 0; i < (opts.oscCount || 1); i++) {\n      var osc = ctx.createOscillator(), gn = ctx.createGain();\n      osc.type = opts.type || 'sine';\n      osc.frequency.setValueAtTime((opts.freq || 440) * (opts.detune ? 1 + i*opts.detune : 1), now);\n      if (opts.freqEnd) osc.frequency.linearRampToValueAtTime(opts.freqEnd, now+opts.dur);\n      if (opts.freqSweep) { osc.frequency.setValueAtTime(opts.freqSweep[0], now); osc.frequency.linearRampToValueAtTime(opts.freqSweep[1], now+opts.dur); }\n      gn.gain.setValueAtTime(opts.vol || 0.3, now);\n      gn.gain.exponentialRampToValueAtTime(0.001, now+opts.dur);\n      osc.connect(gn); gn.connect(masterGain);\n      osc.start(now); osc.stop(now+opts.dur+0.05);\n      gains.push(gn);\n    }\n    if (opts.noise) {\n      var bufSize = Math.ceil(ctx.sampleRate * opts.dur);\n      var buffer = ctx.createBuffer(1, bufSize, ctx.sampleRate);\n      var data = buffer.getChannelData(0);\n      for (var j = 0; j < bufSize; j++) data[j] = (Math.random()*2-1) * opts.noise;\n      var src = ctx.createBufferSource(); src.buffer = buffer;\n      var gn2 = ctx.createGain();\n      gn2.gain.setValueAtTime(opts.noiseVol || 0.2, now);\n      gn2.gain.exponentialRampToValueAtTime(0.001, now+opts.dur);\n      if (opts.noiseFilter) { var filt = ctx.createBiquadFilter(); filt.type = 'bandpass'; filt.frequency.value = opts.noiseFilter; filt.Q.value = 0.8; src.connect(filt); filt.connect(gn2); }\n      else src.connect(gn2);\n      gn2.connect(masterGain); src.start(now); src.stop(now+opts.dur+0.05);\n      gains.push(gn2);\n    }\n    return gains;\n  }\n\n  function init() { ensureCtx(); }\n  function toggleMute() { muted = !muted; if (masterGain) masterGain.gain.setValueAtTime(muted ? 0 : masterVol, ctx.currentTime); return muted; }\n\n  function playShoot() { playTone({ freq:880, freqEnd:1760, type:'sine', dur:0.08, vol:0.18 }); }\n  function playEnemyShoot() { playTone({ freq:330, freqEnd:220, type:'square', dur:0.12, vol:0.12, noise:0.15, noiseVol:0.07, noiseFilter:600 }); }\n  function playExplosion() { playTone({ freq:80, freqEnd:30, type:'sawtooth', dur:0.35, vol:0.22 }); playTone({ noise:0.8, noiseVol:0.3, noiseFilter:300, dur:0.40 }); }\n  function playHit() { playTone({ freq:1200, freqEnd:400, type:'square', dur:0.06, vol:0.15 }); playTone({ noise:0.3, noiseVol:0.1, dur:0.06 }); }\n  function playPowerUp() { [523,659,784].forEach(function(f,i){ playTone({ freq:f, type:'sine', dur:0.15, vol:0.2, delay:i*0.10 }); }); }\n  function playPlayerHit() { playTone({ freq:60, freqEnd:20, type:'triangle', dur:0.3, vol:0.30 }); playTone({ freq:200, freqEnd:600, type:'sawtooth', dur:0.15, vol:0.10 }); }\n  function playChargedShot() { playTone({ freqSweep:[100,1200], type:'sine', dur:0.35, vol:0.25 }); playTone({ freqSweep:[100,1200], type:'sawtooth', dur:0.35, vol:0.06, detune:0.03 }); playTone({ noise:0.4, noiseVol:0.10, noiseFilter:800, dur:0.20 }); }\n  function playMenuSelect() { playTone({ freq:600, type:'square', dur:0.08, vol:0.15 }); }\n  function playGameOver() { [400,300,200,100].forEach(function(f,i){ setTimeout(function(){ playTone({ freq:f, freqEnd:f*0.5, type:'triangle', dur:0.4, vol:0.18 }); }, i*150); }); }\n  function playVictory() { [523,659,784,1047,1319].forEach(function(f,i){ setTimeout(function(){ playTone({ freq:f, type:'sine', dur:0.3, vol:0.18 }); }, i*100); }); }\n  function playBossWarning() { for (var i = 0; i < 3; i++) { setTimeout(function(){ playTone({ freq:80, type:'sawtooth', dur:0.5, vol:0.20 }); }, i*600); } }\n  function playComboUp(lvl) { playTone({ freq:400+lvl*80, freqEnd:(400+lvl*80)*1.5, type:'sine', dur:0.12, vol:Math.min(0.25, 0.10+lvl*0.02) }); }\n  function playShieldBreak() { playTone({ noise:0.9, noiseVol:0.30, noiseFilter:2000, dur:0.25 }); playTone({ freq:2000, freqEnd:4000, type:'square', dur:0.20, vol:0.12 }); }\n\n  function startMusic(level) { musicLevel = level || 1; if (musicRunning) stopMusic(); musicRunning = true; ensureCtx(); _musicLoop(); }\n  function stopMusic() { musicRunning = false; musicNodes.forEach(function(n){ try { n.stop(); } catch(e){} }); musicNodes = []; }\n  function updateMusic(enemyCount, maxEnemies) { musicIntensity = maxEnemies > 0 ? enemyCount / maxEnemies : 0; }\n\n  function _musicLoop() {\n    if (!musicRunning || muted || !ctx) { return; }\n    var now = ctx.currentTime;\n    var bpm = 110 + musicLevel * 8, barLen = 60/bpm * 4;\n    var bassFreqs = [55, 65.4, 73.4, 82.4];\n    var padFreq = 110 * (1 + (musicLevel-1)*0.3);\n    var nodesThisBar = [];\n\n    bassFreqs.forEach(function(f, i) {\n      var osc = ctx.createOscillator(), gn = ctx.createGain();\n      osc.type = 'sawtooth'; osc.frequency.value = f;\n      gn.gain.value = 0;\n      var beatTime = now + i * (barLen/4);\n      gn.gain.setValueAtTime(0.14, beatTime);\n      gn.gain.linearRampToValueAtTime(0.10, beatTime+0.05);\n      gn.gain.setValueAtTime(0.10, beatTime+(barLen/4)*0.8);\n      gn.gain.linearRampToValueAtTime(0, beatTime+(barLen/4));\n      osc.connect(gn); gn.connect(masterGain);\n      osc.start(beatTime); osc.stop(beatTime+barLen/4+0.1);\n      nodesThisBar.push(osc);\n    });\n\n    var padOsc = ctx.createOscillator(), padGn = ctx.createGain();\n    padOsc.type = 'triangle'; padOsc.frequency.value = padFreq;\n    padGn.gain.value = 0.04 + musicIntensity * 0.03;\n    padOsc.connect(padGn); padGn.connect(masterGain);\n    padOsc.start(now); padOsc.stop(now+barLen+0.1);\n    nodesThisBar.push(padOsc);\n\n    if (musicIntensity > 0.4) {\n      var arpFreqs = [330,440,550,660,440,550,660,880];\n      for (var i = 0; i < 8; i++) {\n        var osc2 = ctx.createOscillator(), gn2 = ctx.createGain();\n        osc2.type = 'square'; osc2.frequency.value = arpFreqs[i % arpFreqs.length];\n        var bt = now + i * (barLen/8);\n        gn2.gain.setValueAtTime(0.06*musicIntensity, bt);\n        gn2.gain.linearRampToValueAtTime(0, bt+barLen/8);\n        osc2.connect(gn2); gn2.connect(masterGain);\n        osc2.start(bt); osc2.stop(bt+barLen/8+0.05);\n        nodesThisBar.push(osc2);\n      }\n    }\n\n    for (var j = 0; j < 16; j++) {\n      var bufSize = ctx.sampleRate * 0.04;\n      var buffer = ctx.createBuffer(1, bufSize, ctx.sampleRate);\n      var data = buffer.getChannelData(0);\n      for (var s = 0; s < bufSize; s++) data[s] = (Math.random()*2-1) * Math.exp(-s/(bufSize*0.3));\n      var src = ctx.createBufferSource(); src.buffer = buffer;\n      var gn3 = ctx.createGain();\n      var filt = ctx.createBiquadFilter(); filt.type = 'highpass'; filt.frequency.value = 3000;\n      gn3.gain.setValueAtTime(0.05, now+j*(barLen/16));\n      gn3.gain.linearRampToValueAtTime(0, now+j*(barLen/16)+0.04);\n      src.connect(filt); filt.connect(gn3); gn3.connect(masterGain);\n      src.start(now+j*(barLen/16)); src.stop(now+j*(barLen/16)+0.05);\n      nodesThisBar.push(src);\n    }\n\n    musicNodes = nodesThisBar;\n    setTimeout(_musicLoop, barLen * 1000);\n  }\n\n  return {\n    init: init, toggleMute: toggleMute, get muted() { return muted; },\n    playShoot: playShoot, playEnemyShoot: playEnemyShoot, playExplosion: playExplosion,\n    playHit: playHit, playPowerUp: playPowerUp, playPlayerHit: playPlayerHit,\n    playChargedShot: playChargedShot, playMenuSelect: playMenuSelect,\n    playGameOver: playGameOver, playVictory: playVictory, playBossWarning: playBossWarning,\n    playComboUp: playComboUp, playShieldBreak: playShieldBreak,\n    startMusic: startMusic, stopMusic: stopMusic, updateMusic: updateMusic\n  };\n})();\n\n// ============================================================================\n// UI MANAGER\n// ============================================================================\nvar UIManager = (function () {\n  var animTime = 0;\n  var starfield = [];\n  var comboPopupTimer = 0, comboPopupText = '';\n  var transitionAlpha = 0, transitionText = '', transitionDir = 0;\n  var displayHp = 100, displayShield = 0, displayCharge = 0;\n\n  function initStars(w, h) {\n    starfield = [];\n    for (var i = 0; i < 200; i++) {\n      starfield.push({ x: Math.random()*w, y: Math.random()*h, r: Math.random()*2+0.5, speed: Math.random()*40+10, brightness: Math.random()*0.6+0.4 });\n    }\n  }\n\n  function drawText(text, x, y, size, color, align, glowColor, glowBlur) {\n    ctx.save();\n    ctx.textAlign = align || 'center';\n    ctx.textBaseline = 'middle';\n    ctx.font = 'bold ' + size + 'px \"Courier New\", monospace';\n    if (glowColor) { ctx.shadowColor = glowColor; ctx.shadowBlur = glowBlur || 10; }\n    ctx.strokeStyle = 'rgba(0,0,0,0.7)'; ctx.lineWidth = 2; ctx.strokeText(text, x, y);\n    ctx.fillStyle = color; ctx.fillText(text, x, y);\n    ctx.restore();\n  }\n\n  function drawBar(x, y, w, h, value, maxValue, color1, color2, bgColor, borderColor) {\n    var ratio = Math.max(0, Math.min(1, value/(maxValue||1)));\n    ctx.save();\n    ctx.fillStyle = bgColor || 'rgba(0,0,0,0.5)'; ctx.fillRect(x, y, w, h);\n    if (ratio > 0) {\n      var grad = ctx.createLinearGradient(x, y, x+w*ratio, y);\n      grad.addColorStop(0, color1); grad.addColorStop(1, color2);\n      ctx.fillStyle = grad; ctx.fillRect(x, y, w*ratio, h);\n    }\n    ctx.strokeStyle = borderColor || '#fff'; ctx.lineWidth = 1.5; ctx.strokeRect(x, y, w, h);\n    ctx.restore();\n  }\n\n  function textWidth(text, size) {\n    ctx.save(); ctx.font = 'bold ' + size + 'px \"Courier New\", monospace'; var w = ctx.measureText(text).width; ctx.restore(); return w;\n  }\n\n  function triggerComboPopup(combo) { comboPopupText = 'COMBO x' + combo + '!'; comboPopupTimer = 1.5; }\n  function triggerLevelTransition(level) { transitionText = 'LEVEL ' + level; transitionAlpha = 0; transitionDir = 1; }\n\n  function drawMainMenu() {\n    var W = CONFIG.gameWidth, H = CONFIG.gameHeight, t = animTime;\n    ctx.fillStyle = '#0a0a1a'; ctx.fillRect(0, 0, W, H);\n    starfield.forEach(function(s) {\n      s.y += s.speed * deltaTime;\n      if (s.y > H) { s.y = -2; s.x = Math.random()*W; }\n      var twinkle = 0.5 + 0.5*Math.sin(t*3+s.x*0.1);\n      var alpha = s.brightness*twinkle;\n      ctx.fillStyle = 'rgba(255,255,255,' + alpha + ')';\n      ctx.beginPath(); ctx.arc(s.x, s.y, s.r, 0, Math.PI*2); ctx.fill();\n    });\n\n    var pulse = 1 + Math.sin(t*2)*0.06;\n    var glowPulse = 14 + Math.sin(t*2.5)*4;\n    drawText('VOID', W/2, H*0.22, Math.floor(72*pulse), '#00ffff', 'center', '#00ffff', glowPulse);\n    drawText('STRIKERS', W/2, H*0.36, Math.floor(56*pulse), '#ff00ff', 'center', '#ff00ff', glowPulse);\n\n    if (Math.sin(t*4) > 0) { drawText('PRESS ENTER OR TAP TO START', W/2, H*0.58, 20, '#ffffff', 'center', '#ffffff', 6); }\n\n    drawText('CONTROLS', W/2, H*0.70, 14, '#888888', 'center');\n    drawText('Arrow/WASD = Move  |  Space = Charge Shot  |  P = Pause', W/2, H*0.70+24, 12, '#666666', 'center');\n    drawText('M = Mute  |  R = Restart', W/2, H*0.70+42, 12, '#666666', 'center');\n\n    var hs = localStorage.getItem('voidStrikers_highScore') || 0;\n    if (hs > 0) { drawText('HIGH SCORE: ' + Number(hs).toLocaleString(), W/2, H*0.92, 16, '#ffdd44', 'center', '#ffdd44', 6); }\n  }\n\n  function drawPauseMenu() {\n    var W = CONFIG.gameWidth, H = CONFIG.gameHeight;\n    ctx.fillStyle = 'rgba(0,0,0,0.65)'; ctx.fillRect(0, 0, W, H);\n    drawText('PAUSED', W/2, H*0.35, 56, '#ffffff', 'center', '#ffffff', 16);\n    drawText('Press P to Resume', W/2, H*0.52, 20, '#cccccc', 'center', '#cccccc', 4);\n    drawText('Press R to Restart', W/2, H*0.60, 20, '#cccccc', 'center', '#cccccc', 4);\n    drawText('Press M to Toggle Mute', W/2, H*0.68, 20, '#cccccc', 'center', '#cccccc', 4);\n  }\n\n  function drawHUD() {\n    var W = CONFIG.gameWidth, H = CONFIG.gameHeight, margin = 12, barW = 170, barH = 12;\n    displayHp += (player.hp - displayHp) * Math.min(deltaTime*6, 1);\n    displayShield += ((player.shield||0) - displayShield) * Math.min(deltaTime*6, 1);\n    displayCharge += ((player.chargeLevel||0) - displayCharge) * Math.min(deltaTime*10, 1);\n\n    var comboMul = (gameState.comboMultiplier||1).toFixed(1);\n    var comboActive = gameState.comboMultiplier > 1;\n    var comboGlow = comboActive ? Math.sin(animTime*6)*0.3+0.7 : 0;\n    drawText('SCORE: ' + (gameState.score||0).toLocaleString(), margin, margin+8, 16, '#ffffff', 'left');\n    if (comboActive) {\n      drawText(' x' + comboMul, margin + textWidth('SCORE: ' + (gameState.score||0).toLocaleString(), 16) + 4, margin+8, 16,\n        'rgba(255,' + Math.floor(200+comboGlow*55) + ',0,0.9)', 'left', 'rgba(255,' + Math.floor(200+comboGlow*55) + ',0,1)', 6+comboGlow*6);\n    }\n\n    drawText('LEVEL ' + (gameState.level||1), W-margin, margin+8, 16, '#00ccff', 'right', '#00ccff', 6);\n\n    var barX = margin, barY = H - margin - 60;\n    var hpRatio = displayHp / (player.maxHp||100);\n    var hpR = hpRatio < 0.5 ? 255 : Math.floor(255*(1-hpRatio)*2);\n    var hpG = hpRatio < 0.5 ? Math.floor(255*hpRatio*2) : 255;\n    drawBar(barX, barY, barW, barH, displayHp, player.maxHp||100, 'rgb('+hpR+','+Math.max(hpG,30)+',0)', '#00ff33', 'rgba(0,0,0,0.6)', '#aaa');\n    drawText('HP ' + Math.ceil(displayHp) + '/' + (player.maxHp||100), barX+barW/2, barY+barH/2, 10, '#fff', 'center');\n\n    var maxShield = 100;\n    if (player.shield > 0 || displayShield > 0.5) {\n      var sy = barY + barH + 4;\n      drawBar(barX, sy, barW, barH-2, displayShield, maxShield, '#4488ff', '#88ccff', 'rgba(0,0,0,0.6)', '#5588ff');\n      drawText('SHIELD', barX+barW/2, sy+(barH-2)/2, 8, '#88ccff', 'center');\n    }\n\n    var weaponNames = ['BLASTER','TWIN','SPREAD'];\n    var weaponName = weaponNames[Math.min(player.weaponLevel-1, weaponNames.length-1)];\n    var wlX = W - margin - 80, wlY = H - margin - 40;\n    drawText(weaponName, wlX+70, wlY, 12, '#ff8800', 'right');\n    for (var i = 1; i <= 3; i++) {\n      var filled = i <= player.weaponLevel;\n      ctx.beginPath(); ctx.arc(wlX+i*20, wlY+18, 4, 0, Math.PI*2);\n      ctx.fillStyle = filled ? '#00ffcc' : '#333'; ctx.fill();\n      ctx.strokeStyle = '#555'; ctx.lineWidth = 1; ctx.stroke();\n    }\n\n    if (player.chargeLevel > 0 || displayCharge > 0.5) {\n      var cw = 120, ch = 8, cx = W/2-cw/2, cy = H-margin-27;\n      drawBar(cx, cy, cw, ch, displayCharge, player.maxCharge||100, '#00ffff', '#ff00ff', 'rgba(0,0,0,0.5)', '#00ffff');\n      drawText('CHARGE', W/2, cy+ch/2, 8, '#00ffff', 'center', '#00ffff', 4);\n    }\n\n    if (player.speedBoostTimer > 0) {\n      drawText('SPEED ' + player.speedBoostTimer.toFixed(1) + 's', margin, barY-20, 12, '#ffff00', 'left', '#ffff00', 5);\n    }\n\n    if (comboPopupTimer > 0) {\n      comboPopupTimer -= deltaTime;\n      var alpha = Math.min(1, comboPopupTimer/0.3);\n      var scale = 1 + (1.5 - Math.min(1.5, comboPopupTimer)) * 0.4;\n      var baseY = H * 0.3 + Math.sin(animTime*5)*8;\n      ctx.save(); ctx.globalAlpha = alpha;\n      drawText(comboPopupText, W/2, baseY, Math.floor(36*scale), '#ff8800', 'center', '#ff8800', 12);\n      ctx.restore();\n    }\n  }\n\n  function drawGameOver() {\n    var W = CONFIG.gameWidth, H = CONFIG.gameHeight;\n    ctx.fillStyle = 'rgba(10,0,0,0.75)'; ctx.fillRect(0, 0, W, H);\n    var shakeX = Math.sin(animTime*50)*3, shakeY = Math.cos(animTime*47)*2;\n    drawText('GAME OVER', W/2+shakeX, H*0.28+shakeY, 52, '#ff2222', 'center', '#ff2222', 20);\n    drawText('FINAL SCORE: ' + (gameState.score||0).toLocaleString(), W/2, H*0.46, 24, '#ffdd44', 'center', '#ffdd44', 8);\n    drawText('Enemies Destroyed: ' + (gameState.enemiesKilled||0) + ' | Max Combo: x' + (gameState.maxCombo||0), W/2, H*0.54, 14, '#aaaaaa', 'center');\n    drawText('Press R to Restart', W/2, H*0.70, 18, '#cccccc', 'center', '#cccccc', 4);\n    drawText('Press M for Main Menu', W/2, H*0.78, 18, '#cccccc', 'center', '#cccccc', 4);\n  }\n\n  function drawVictory() {\n    var W = CONFIG.gameWidth, H = CONFIG.gameHeight;\n    ctx.fillStyle = 'rgba(0,5,20,0.7)'; ctx.fillRect(0, 0, W, H);\n    var pulse = 1 + Math.sin(animTime*3)*0.04;\n    drawText('VICTORY!', W/2, H*0.25, Math.floor(60*pulse), '#ffcc00', 'center', '#ffcc00', 22);\n    drawText('SCORE: ' + (gameState.score||0).toLocaleString(), W/2, H*0.42, 26, '#ffffff', 'center', '#ffffff', 8);\n    drawText('Enemies Destroyed: ' + (gameState.enemiesKilled||0) + ' | Max Combo: x' + (gameState.maxCombo||0), W/2, H*0.50, 16, '#88ccff', 'center');\n    drawText('Press R to Play Again', W/2, H*0.68, 20, '#ffffff', 'center', '#ffffff', 6);\n  }\n\n  function drawLevelTransition() {\n    var W = CONFIG.gameWidth, H = CONFIG.gameHeight;\n    if (transitionDir === 1) { transitionAlpha += deltaTime*2; if (transitionAlpha >= 1) { transitionDir = -1; transitionAlpha = 1; } }\n    else if (transitionDir === -1) { transitionAlpha -= deltaTime*2; if (transitionAlpha <= 0) { transitionDir = 0; transitionAlpha = 0; transitionText = ''; } }\n    if (transitionAlpha <= 0) return;\n    ctx.save(); ctx.globalAlpha = transitionAlpha;\n    ctx.fillStyle = '#000'; ctx.fillRect(0, 0, W, H);\n    var scale = 1 + transitionAlpha*0.3;\n    drawText(transitionText, W/2, H/2, Math.floor(56*scale), '#00ffff', 'center', '#00ffff', 20*transitionAlpha);\n    ctx.restore();\n  }\n\n  function update(dt) { animTime += dt; if (starfield.length === 0 && CONFIG.gameWidth > 0) initStars(CONFIG.gameWidth, CONFIG.gameHeight); }\n  function onResize() { initStars(CONFIG.gameWidth, CONFIG.gameHeight); }\n\n  return {\n    update: update, drawMainMenu: drawMainMenu, drawPauseMenu: drawPauseMenu,\n    drawHUD: drawHUD, drawGameOver: drawGameOver, drawVictory: drawVictory,\n    drawLevelTransition: drawLevelTransition, drawText: drawText, drawBar: drawBar,\n    textWidth: textWidth, triggerComboPopup: triggerComboPopup,\n    triggerLevelTransition: triggerLevelTransition, onResize: onResize\n  };\n})();\n\n// ============================================================================\n// RENDERER\n// ============================================================================\nvar Renderer = (function () {\n  var _time = 0;\n  var _stars = { far: [], mid: [], near: [] };\n  var _nebulaShift = 0;\n\n  function _createStar(depth) {\n    var layerSpeed = [5, 15, 30];\n    var layerSize = [[0.3, 0.8], [0.6, 1.4], [1.0, 2.5]];\n    return {\n      x: Math.random()*CONFIG.gameWidth, y: Math.random()*CONFIG.gameHeight,\n      size: rand(layerSize[depth][0], layerSize[depth][1]),\n      brightness: rand(0.3, 1.0),\n      twinkleOffset: rand(0, Math.PI*2), twinkleSpeed: rand(0.5, 3.0),\n      speed: layerSpeed[depth], layer: depth\n    };\n  }\n\n  function _initStars() {\n    _stars.far.length = 0; _stars.mid.length = 0; _stars.near.length = 0;\n    for (var i = 0; i < 100; i++) _stars.far.push(_createStar(0));\n    for (var j = 0; j < 80; j++)  _stars.mid.push(_createStar(1));\n    for (var k = 0; k < 50; k++)  _stars.near.push(_createStar(2));\n  }\n\n  function _renderStarLayer(stars, speedMul) {\n    for (var i = 0; i < stars.length; i++) {\n      var s = stars[i];\n      var twinkle = Math.sin(_time*s.twinkleSpeed+s.twinkleOffset)*0.5+0.5;\n      var alpha = Math.max(0.1, s.brightness*(0.5+0.5*twinkle));\n      ctx.save(); ctx.globalAlpha = alpha; ctx.fillStyle = '#ffffff';\n      if (s.layer > 0) {\n        var grd = ctx.createRadialGradient(s.x, s.y, 0, s.x, s.y, s.size*3);\n        grd.addColorStop(0, 'rgba(180,210,255,'+alpha+')');\n        grd.addColorStop(0.3, 'rgba(140,180,255,'+(alpha*0.6)+')');\n        grd.addColorStop(1, 'rgba(80,120,200,0)');\n        ctx.fillStyle = grd;\n      }\n      ctx.beginPath(); ctx.arc(s.x, s.y, s.size, 0, Math.PI*2); ctx.fill();\n      ctx.restore();\n      s.y += s.speed * speedMul * deltaTime;\n      if (s.y > CONFIG.gameHeight+10) { s.y = -10; s.x = Math.random()*CONFIG.gameWidth; }\n    }\n  }\n\n  function _renderPlayerShip() {\n    if (!player || !player.x || !player.y) return;\n    var px = player.x - camera.x;\n    var py = player.y - camera.y;\n    var rot = player.rotation || 0;\n    var scale = player.scale || 1;\n    var wpnLevel = player.weaponLevel || 1;\n\n    ctx.save(); ctx.translate(px, py); ctx.rotate(rot); ctx.scale(scale, scale);\n\n    // Engine glow\n    var glowPulse = Math.sin(_time*8)*0.3+0.7;\n    var engineGrd = ctx.createRadialGradient(0, 18, 2, 0, 28, 20);\n    engineGrd.addColorStop(0, 'rgba(0,200,255,'+(0.9*glowPulse)+')');\n    engineGrd.addColorStop(0.4, 'rgba(0,140,255,'+(0.5*glowPulse)+')');\n    engineGrd.addColorStop(1, 'rgba(0,60,200,0)');\n    ctx.fillStyle = engineGrd;\n    ctx.beginPath(); ctx.arc(0, 20, 16, 0, Math.PI*2); ctx.fill();\n    ctx.beginPath(); ctx.arc(-10, 14, 8, 0, Math.PI*2); ctx.fill();\n    ctx.beginPath(); ctx.arc(10, 14, 8, 0, Math.PI*2); ctx.fill();\n\n    // Main body\n    ctx.fillStyle = '#00ccff'; ctx.strokeStyle = '#004466'; ctx.lineWidth = 1.5;\n    ctx.beginPath();\n    ctx.moveTo(0, -22); ctx.lineTo(-12, 10); ctx.lineTo(-6, 6);\n    ctx.lineTo(0, 22); ctx.lineTo(6, 6); ctx.lineTo(12, 10);\n    ctx.closePath(); ctx.fill(); ctx.stroke();\n\n    // Wings\n    ctx.fillStyle = '#0088cc'; ctx.strokeStyle = '#004466'; ctx.lineWidth = 1.2;\n    ctx.beginPath();\n    ctx.moveTo(-12, 6); ctx.lineTo(-24, 18); ctx.lineTo(-16, 22); ctx.lineTo(-6, 14);\n    ctx.closePath(); ctx.fill(); ctx.stroke();\n    ctx.beginPath();\n    ctx.moveTo(12, 6); ctx.lineTo(24, 18); ctx.lineTo(16, 22); ctx.lineTo(6, 14);\n    ctx.closePath(); ctx.fill(); ctx.stroke();\n\n    // Cockpit\n    var cockpitGrd = ctx.createLinearGradient(0, -16, 0, 0);\n    cockpitGrd.addColorStop(0, 'rgba(100,230,255,0.9)');\n    cockpitGrd.addColorStop(1, 'rgba(0,120,200,0.3)');\n    ctx.fillStyle = cockpitGrd;\n    ctx.beginPath(); ctx.moveTo(0, -16); ctx.lineTo(-5, 0); ctx.lineTo(5, 0); ctx.closePath(); ctx.fill();\n\n    // Weapon upgrades\n    if (wpnLevel >= 2) {\n      ctx.fillStyle = '#ffaa00'; ctx.strokeStyle = '#884400'; ctx.lineWidth = 1;\n      _drawCannon(-20, 12, 0.5); _drawCannon(20, 12, 0.5);\n    }\n    if (wpnLevel >= 3) {\n      ctx.fillStyle = '#ff6600'; ctx.strokeStyle = '#662200'; ctx.lineWidth = 1;\n      _drawCannon(-26, 8, 0.65); _drawCannon(26, 8, 0.65);\n    }\n\n    // Shield\n    if (player.shieldActive) {\n      var shieldAlpha = 0.3 + Math.sin(_time*6)*0.15;\n      var shieldGrd = ctx.createRadialGradient(0, 0, 20, 0, 0, 32);\n      shieldGrd.addColorStop(0, 'rgba(0,180,255,0)');\n      shieldGrd.addColorStop(0.7, 'rgba(0,180,255,'+(shieldAlpha*0.5)+')');\n      shieldGrd.addColorStop(0.85, 'rgba(0,200,255,'+shieldAlpha+')');\n      shieldGrd.addColorStop(1, 'rgba(0,220,255,0)');\n      ctx.fillStyle = shieldGrd;\n      ctx.beginPath(); ctx.arc(0, 0, 32, 0, Math.PI*2); ctx.fill();\n      ctx.strokeStyle = 'rgba(0,220,255,'+(shieldAlpha+0.2)+')'; ctx.lineWidth = 2;\n      for (var a = 0; a < 4; a++) {\n        var startAngle = (_time*2+a*Math.PI/2)%(Math.PI*2);\n        ctx.beginPath(); ctx.arc(0, 0, 30, startAngle, startAngle+0.8); ctx.stroke();\n      }\n    }\n    ctx.restore();\n  }\n\n  function _drawCannon(cx, cy, s) {\n    ctx.beginPath();\n    ctx.moveTo(cx-3*s, cy); ctx.lineTo(cx-2*s, cy-8*s);\n    ctx.lineTo(cx+2*s, cy-8*s); ctx.lineTo(cx+3*s, cy);\n    ctx.closePath(); ctx.fill(); ctx.stroke();\n  }\n\n  function _renderEnemies() {\n    if (!enemies || !enemies.length) return;\n    for (var i = 0; i < enemies.length; i++) {\n      var e = enemies[i];\n      if (!e || !e.alive && !e.deathTimer) continue;\n      var ex = e.x - camera.x, ey = e.y - camera.y;\n      if (!e.alive && e.deathTimer > 0) { _renderEnemyDeath(ex, ey, e); continue; }\n      if (!e.alive) continue;\n      ctx.save(); ctx.translate(ex, ey); ctx.rotate(e.rotation||0); ctx.scale(e.scale||1, e.scale||1);\n      if (e.hitTimer > 0) ctx.globalCompositeOperation = 'lighter';\n      switch (e.type) {\n        case 'scout': _drawScout(e); break;\n        case 'fighter': _drawFighter(e); break;\n        case 'tank': _drawTank(e); break;\n        case 'sniper': _drawSniper(e); break;\n        case 'boss': _drawBoss(e); break;\n        case 'speeder': _drawSpeeder(e); break;\n        default: _drawScout(e);\n      }\n      ctx.restore();\n    }\n  }\n\n  function _drawScout(e) {\n    var c = e.hitTimer > 0 ? '#ffffff' : e.color;\n    ctx.fillStyle = c; ctx.strokeStyle = '#cc3388'; ctx.lineWidth = 1;\n    ctx.beginPath(); ctx.moveTo(0, -10); ctx.lineTo(7, 0); ctx.lineTo(0, 10); ctx.lineTo(-7, 0); ctx.closePath();\n    ctx.fill(); ctx.stroke();\n    ctx.fillStyle = e.hitTimer > 0 ? '#ffffff' : '#ff99dd';\n    ctx.beginPath(); ctx.moveTo(0, -5); ctx.lineTo(3, 0); ctx.lineTo(0, 5); ctx.lineTo(-3, 0); ctx.closePath(); ctx.fill();\n  }\n\n  function _drawSpeeder(e) {\n    var c = e.hitTimer > 0 ? '#ffffff' : e.color;\n    ctx.fillStyle = c; ctx.strokeStyle = '#886600'; ctx.lineWidth = 1;\n    ctx.beginPath(); ctx.moveTo(0, -12); ctx.lineTo(8, 4); ctx.lineTo(3, 8); ctx.lineTo(-3, 8); ctx.lineTo(-8, 4); ctx.closePath();\n    ctx.fill(); ctx.stroke();\n    // Motion streak\n    ctx.strokeStyle = 'rgba(255,200,0,0.4)'; ctx.lineWidth = 2;\n    ctx.beginPath(); ctx.moveTo(0, 10); ctx.lineTo(0, 24); ctx.stroke();\n  }\n\n  function _drawFighter(e) {\n    var c = e.hitTimer > 0 ? '#ffffff' : e.color;\n    ctx.fillStyle = c; ctx.strokeStyle = '#991111'; ctx.lineWidth = 1.2;\n    ctx.beginPath(); ctx.moveTo(0, -14); ctx.lineTo(-9, 6); ctx.lineTo(-4, 3); ctx.lineTo(-4, 14); ctx.lineTo(4, 14); ctx.lineTo(4, 3); ctx.lineTo(9, 6); ctx.closePath();\n    ctx.fill(); ctx.stroke();\n    ctx.fillStyle = e.hitTimer > 0 ? '#ffffff' : '#cc2222';\n    ctx.beginPath(); ctx.moveTo(-9, 6); ctx.lineTo(-18, 10); ctx.lineTo(-9, 12); ctx.closePath(); ctx.fill();\n    ctx.beginPath(); ctx.moveTo(9, 6); ctx.lineTo(18, 10); ctx.lineTo(9, 12); ctx.closePath(); ctx.fill();\n  }\n\n  function _drawTank(e) {\n    var c = e.hitTimer > 0 ? '#ffffff' : e.color;\n    var r = 16;\n    ctx.fillStyle = c; ctx.strokeStyle = '#884411'; ctx.lineWidth = 1.5;\n    ctx.beginPath();\n    for (var i = 0; i < 6; i++) {\n      var angle = (Math.PI*2/6)*i - Math.PI/2;\n      var px = Math.cos(angle)*r, py = Math.sin(angle)*r;\n      if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);\n    }\n    ctx.closePath(); ctx.fill(); ctx.stroke();\n    ctx.strokeStyle = '#aa5511'; ctx.lineWidth = 1;\n    ctx.beginPath(); ctx.moveTo(-10, -4); ctx.lineTo(10, -4); ctx.moveTo(-13, 8); ctx.lineTo(13, 8); ctx.stroke();\n    ctx.fillStyle = e.hitTimer > 0 ? '#ffffff' : '#ffaa66';\n    ctx.beginPath(); ctx.arc(0, 0, 4, 0, Math.PI*2); ctx.fill();\n  }\n\n  function _drawSniper(e) {\n    var c = e.hitTimer > 0 ? '#ffffff' : e.color;\n    ctx.fillStyle = c; ctx.strokeStyle = '#668800'; ctx.lineWidth = 1;\n    ctx.beginPath(); ctx.moveTo(0, -20); ctx.lineTo(5, 0); ctx.lineTo(0, 14); ctx.lineTo(-5, 0); ctx.closePath();\n    ctx.fill(); ctx.stroke();\n    ctx.fillStyle = '#ccff33';\n    ctx.beginPath(); ctx.arc(0, -16, 3, 0, Math.PI*2); ctx.fill();\n    // Targeting laser\n    ctx.strokeStyle = 'rgba(170,221,0,0.2)'; ctx.lineWidth = 0.5;\n    ctx.beginPath(); ctx.moveTo(0, -25); ctx.lineTo(0, -80); ctx.stroke();\n    ctx.fillStyle = '#88bb00';\n    ctx.beginPath(); ctx.moveTo(-5, 6); ctx.lineTo(-11, 10); ctx.lineTo(-5, 10); ctx.closePath(); ctx.fill();\n    ctx.beginPath(); ctx.moveTo(5, 6); ctx.lineTo(11, 10); ctx.lineTo(5, 10); ctx.closePath(); ctx.fill();\n  }\n\n  function _drawBoss(e) {\n    var c = e.hitTimer > 0 ? '#ffffff' : e.color;\n    var r = 35;\n    var pulse = Math.sin(_time*2.5)*0.1+0.9;\n    ctx.fillStyle = c; ctx.strokeStyle = '#880000'; ctx.lineWidth = 2;\n    ctx.beginPath();\n    for (var i = 0; i < 8; i++) {\n      var angle = (Math.PI*2/8)*i - Math.PI/2;\n      var radius = (i%2===0) ? r : r*0.85;\n      var px = Math.cos(angle)*radius, py = Math.sin(angle)*radius;\n      if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);\n    }\n    ctx.closePath(); ctx.fill(); ctx.stroke();\n\n    ctx.fillStyle = '#cc1111';\n    ctx.beginPath(); ctx.arc(0, 0, 22, 0, Math.PI*2); ctx.fill();\n\n    var coreGrd = ctx.createRadialGradient(0, 0, 4, 0, 0, 16);\n    coreGrd.addColorStop(0, 'rgba(255,200,50,'+pulse+')');\n    coreGrd.addColorStop(0.5, 'rgba(255,100,0,'+(pulse*0.6)+')');\n    coreGrd.addColorStop(1, 'rgba(255,0,0,0)');\n    ctx.fillStyle = coreGrd;\n    ctx.beginPath(); ctx.arc(0, 0, 16, 0, Math.PI*2); ctx.fill();\n\n    ctx.strokeStyle = 'rgba(255,255,255,0.15)'; ctx.lineWidth = 1;\n    for (var j = 0; j < 8; j++) {\n      var a2 = (Math.PI*2/8)*j - Math.PI/2;\n      ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(Math.cos(a2)*32, Math.sin(a2)*32); ctx.stroke();\n    }\n\n    ctx.fillStyle = '#ff6600';\n    for (var k = 0; k < 4; k++) {\n      var a3 = Math.PI/2*k + _time*2;\n      ctx.save(); ctx.rotate(a3); ctx.fillRect(-2, -28, 4, 10); ctx.restore();\n    }\n  }\n\n  function _renderEnemyDeath(ex, ey, e) {\n    var progress = 1 - (e.deathTimer / 0.5);\n    var alpha = 1 - progress;\n    var ringRadius = progress * (e.width || 40) * 1.5;\n    ctx.save(); ctx.globalAlpha = alpha;\n    ctx.strokeStyle = '#ff8800'; ctx.lineWidth = 3*alpha;\n    ctx.beginPath(); ctx.arc(ex, ey, ringRadius, 0, Math.PI*2); ctx.stroke();\n    var flashGrd = ctx.createRadialGradient(ex, ey, 0, ex, ey, ringRadius);\n    flashGrd.addColorStop(0, 'rgba(255,200,100,'+alpha+')');\n    flashGrd.addColorStop(0.5, 'rgba(255,100,0,'+(alpha*0.6)+')');\n    flashGrd.addColorStop(1, 'rgba(255,0,0,0)');\n    ctx.fillStyle = flashGrd;\n    ctx.beginPath(); ctx.arc(ex, ey, ringRadius, 0, Math.PI*2); ctx.fill();\n    ctx.restore();\n  }\n\n  function _renderProjectiles() {\n    if (!projectiles || !projectiles.length) return;\n    for (var i = 0; i < projectiles.length; i++) {\n      var p = projectiles[i];\n      if (!p || !p.alive) continue;\n      var px = p.x - camera.x, py = p.y - camera.y;\n      switch (p.type) {\n        case 'playerBullet': _drawPlayerBullet(px, py, p); break;\n        case 'enemyBullet': _drawEnemyBullet(px, py, p); break;\n        case 'chargedShot': _drawChargedShot(px, py, p); break;\n        default: _drawEnemyBullet(px, py, p);\n      }\n    }\n  }\n\n  function _drawPlayerBullet(px, py, p) {\n    var s = p.size || 3;\n    ctx.save(); ctx.globalCompositeOperation = 'lighter';\n    var grd = ctx.createRadialGradient(px, py, 0, px, py, s*4);\n    grd.addColorStop(0, 'rgba(0,220,255,0.9)');\n    grd.addColorStop(0.3, 'rgba(0,160,255,0.5)');\n    grd.addColorStop(0.7, 'rgba(0,80,200,0.15)');\n    grd.addColorStop(1, 'rgba(0,40,120,0)');\n    ctx.fillStyle = grd;\n    ctx.beginPath(); ctx.arc(px, py, s*4, 0, Math.PI*2); ctx.fill();\n    ctx.fillStyle = '#ffffff';\n    ctx.beginPath(); ctx.arc(px, py, s*0.6, 0, Math.PI*2); ctx.fill();\n    ctx.fillStyle = '#00eeff';\n    ctx.beginPath(); ctx.arc(px, py, s, 0, Math.PI*2); ctx.fill();\n    ctx.restore();\n  }\n\n  function _drawEnemyBullet(px, py, p) {\n    var s = p.size || 4;\n    ctx.save(); ctx.globalCompositeOperation = 'lighter';\n    var grd = ctx.createRadialGradient(px, py, 0, px, py, s*3);\n    grd.addColorStop(0, 'rgba(255,100,30,0.9)');\n    grd.addColorStop(0.4, 'rgba(255,60,10,0.5)');\n    grd.addColorStop(1, 'rgba(255,20,0,0)');\n    ctx.fillStyle = grd;\n    ctx.beginPath(); ctx.arc(px, py, s*3, 0, Math.PI*2); ctx.fill();\n    ctx.fillStyle = '#ffffff';\n    ctx.beginPath(); ctx.arc(px, py, s*0.5, 0, Math.PI*2); ctx.fill();\n    ctx.fillStyle = '#ff4422';\n    ctx.beginPath(); ctx.arc(px, py, s, 0, Math.PI*2); ctx.fill();\n    ctx.restore();\n  }\n\n  function _drawChargedShot(px, py, p) {\n    var s = p.size || 12;\n    var pulse = Math.sin(_time*12)*0.2+0.8;\n    ctx.save(); ctx.globalCompositeOperation = 'lighter';\n    var outerGrd = ctx.createRadialGradient(px, py, s*0.5, px, py, s*2.5*pulse);\n    outerGrd.addColorStop(0, 'rgba(0,200,255,0.4)');\n    outerGrd.addColorStop(0.5, 'rgba(80,100,255,0.2)');\n    outerGrd.addColorStop(1, 'rgba(0,0,200,0)');\n    ctx.fillStyle = outerGrd;\n    ctx.beginPath(); ctx.arc(px, py, s*2.5*pulse, 0, Math.PI*2); ctx.fill();\n    var mainGrd = ctx.createRadialGradient(px, py, 0, px, py, s*1.5);\n    mainGrd.addColorStop(0, 'rgba(200,240,255,0.95)');\n    mainGrd.addColorStop(0.3, 'rgba(0,180,255,0.7)');\n    mainGrd.addColorStop(1, 'rgba(0,60,200,0)');\n    ctx.fillStyle = mainGrd;\n    ctx.beginPath(); ctx.arc(px, py, s*1.5, 0, Math.PI*2); ctx.fill();\n    ctx.strokeStyle = 'rgba(200,240,255,'+(0.6+Math.sin(_time*20)*0.3)+')'; ctx.lineWidth = 1;\n    for (var a = 0; a < 5; a++) {\n      var arcAngle = _time*3 + a*Math.PI*2/5;\n      ctx.beginPath(); ctx.arc(px, py, s*1.3, arcAngle, arcAngle+0.6); ctx.stroke();\n    }\n    ctx.fillStyle = '#ffffff';\n    ctx.beginPath(); ctx.arc(px, py, s*0.4, 0, Math.PI*2); ctx.fill();\n    ctx.restore();\n  }\n\n  function _renderParticles() {\n    if (!particles || !particles.length) return;\n    for (var i = 0; i < particles.length; i++) {\n      var p = particles[i];\n      if (!p || p.life <= 0) continue;\n      var px = p.x - camera.x, py = p.y - camera.y;\n      var alpha = p.life / (p.maxLife || 0.5);\n      ctx.save(); ctx.globalCompositeOperation = 'lighter';\n      switch (p.type) {\n        case 'explosion':\n          var progress = 1 - alpha;\n          var grd = ctx.createRadialGradient(px, py, 0, px, py, p.size*(0.5+progress));\n          grd.addColorStop(0, p.color||'#ffaa00');\n          grd.addColorStop(0.6, 'rgba(255,100,0,0.4)');\n          grd.addColorStop(1, 'rgba(255,0,0,0)');\n          ctx.globalAlpha = alpha; ctx.fillStyle = grd;\n          ctx.beginPath(); ctx.arc(px, py, p.size*(0.5+progress), 0, Math.PI*2); ctx.fill();\n          break;\n        case 'ring':\n          ctx.globalAlpha = alpha; ctx.strokeStyle = p.color||'#ffcc00'; ctx.lineWidth = 3*alpha;\n          ctx.beginPath(); ctx.arc(px, py, p.size*(1-alpha), 0, Math.PI*2); ctx.stroke();\n          break;\n        case 'spark':\n          ctx.globalAlpha = alpha; ctx.fillStyle = p.color||'#ffcc44';\n          ctx.beginPath(); ctx.arc(px, py, (p.size||2)*alpha, 0, Math.PI*2); ctx.fill();\n          break;\n        case 'engine':\n          ctx.globalAlpha = alpha*0.6;\n          var egrd = ctx.createRadialGradient(px, py, 0, px, py, p.size||3);\n          egrd.addColorStop(0, 'rgba(100,220,255,'+alpha+')');\n          egrd.addColorStop(0.5, 'rgba(0,140,255,'+(alpha*0.5)+')');\n          egrd.addColorStop(1, 'rgba(0,60,200,0)');\n          ctx.fillStyle = egrd;\n          ctx.beginPath(); ctx.arc(px, py, p.size||3, 0, Math.PI*2); ctx.fill();\n          break;\n        default:\n          ctx.globalAlpha = alpha; ctx.fillStyle = p.color||'#fff';\n          ctx.beginPath(); ctx.arc(px, py, (p.size||2)*alpha, 0, Math.PI*2); ctx.fill();\n      }\n      ctx.restore();\n    }\n  }\n\n  function _renderPowerups() {\n    for (var i = 0; i < powerups.length; i++) {\n      var pu = powerups[i];\n      if (!pu || !pu.alive) continue;\n      var px = pu.x - camera.x, py = pu.y - camera.y;\n      var pulse = Math.sin(_time*5)*0.2+0.8;\n      var s = pu.size || 12;\n      ctx.save(); ctx.translate(px, py); ctx.globalCompositeOperation = 'lighter';\n      ctx.strokeStyle = 'rgba(255,255,200,'+(pulse*0.6)+')'; ctx.lineWidth = 2;\n      ctx.beginPath(); ctx.arc(0, 0, s*1.4, 0, Math.PI*2); ctx.stroke();\n      var grd = ctx.createRadialGradient(0, 0, s*0.3, 0, 0, s);\n      grd.addColorStop(0, pu.glow||'rgba(255,255,200,'+pulse+')');\n      grd.addColorStop(0.5, 'rgba(255,200,50,'+(pulse*0.6)+')');\n      grd.addColorStop(1, 'rgba(255,100,0,0)');\n      ctx.fillStyle = grd;\n      ctx.beginPath(); ctx.arc(0, 0, s, 0, Math.PI*2); ctx.fill();\n      ctx.fillStyle = '#ffffff';\n      ctx.font = 'bold '+(s*1.2)+'px \"Courier New\", monospace';\n      ctx.textAlign = 'center'; ctx.textBaseline = 'middle';\n      switch (pu.type) { case 'weapon': ctx.fillText('W', 0, 1); break; case 'shield': ctx.fillText('S', 0, 1); break; case 'health': ctx.fillText('+', 0, 1); break; case 'speed': ctx.fillText('>', 0, 1); break; default: ctx.fillText('?', 0, 1); }\n      ctx.restore();\n    }\n  }\n\n  function _renderVignette() {\n    var w = CONFIG.gameWidth, h = CONFIG.gameHeight;\n    var grd = ctx.createRadialGradient(w/2, h/2, w*0.35, w/2, h/2, w*0.75);\n    grd.addColorStop(0, 'rgba(0,0,0,0)'); grd.addColorStop(0.5, 'rgba(0,0,0,0.05)'); grd.addColorStop(1, 'rgba(0,0,0,0.5)');\n    ctx.fillStyle = grd; ctx.fillRect(0, 0, w, h);\n  }\n\n  function _renderNebula() {\n    var w = CONFIG.gameWidth, h = CONFIG.gameHeight;\n    var shift = Math.sin(_time*0.15)*0.3+0.5;\n    var spaceGrd = ctx.createLinearGradient(0, 0, w, h);\n    spaceGrd.addColorStop(0, 'rgb(5,5,25)'); spaceGrd.addColorStop(0.3, 'rgb(8,4,20)');\n    spaceGrd.addColorStop(0.6, 'rgb(4,6,18)'); spaceGrd.addColorStop(1, 'rgb(3,3,15)');\n    ctx.fillStyle = spaceGrd; ctx.fillRect(0, 0, w, h);\n\n    _nebulaShift += deltaTime * 0.5;\n    var cx = camera.x * 0.02, cy = camera.y * 0.02;\n    ctx.save(); ctx.globalAlpha = 0.08 + shift*0.05; ctx.globalCompositeOperation = 'lighter';\n    var neb1x = (w*0.25 + cx*10 + Math.sin(_nebulaShift*0.7)*60) % w;\n    var neb1y = (h*0.4 + cy*10 + Math.cos(_nebulaShift*0.5)*40) % h;\n    var nebGrd1 = ctx.createRadialGradient(neb1x, neb1y, 0, neb1x, neb1y, w*0.3);\n    nebGrd1.addColorStop(0, 'rgba(30,60,180,0.6)'); nebGrd1.addColorStop(1, 'rgba(5,10,40,0)');\n    ctx.fillStyle = nebGrd1; ctx.fillRect(0, 0, w, h);\n    ctx.globalAlpha = 0.06 + shift*0.04;\n    var neb2x = (w*0.7 + cx*8 + Math.cos(_nebulaShift*0.6)*50) % w;\n    var neb2y = (h*0.6 + cy*8 + Math.sin(_nebulaShift*0.4)*30) % h;\n    var nebGrd2 = ctx.createRadialGradient(neb2x, neb2y, 0, neb2x, neb2y, w*0.25);\n    nebGrd2.addColorStop(0, 'rgba(80,20,120,0.5)'); nebGrd2.addColorStop(1, 'rgba(5,5,20,0)');\n    ctx.fillStyle = nebGrd2; ctx.fillRect(0, 0, w, h);\n    ctx.restore();\n  }\n\n  function _updateCamera() {\n    if (!player || !player.x || !player.y) return;\n    camera.targetX = player.x - CONFIG.gameWidth / 2;\n    camera.targetY = player.y - CONFIG.gameHeight / 2;\n    camera.targetX = clamp(camera.targetX, -100, 100);\n    camera.targetY = clamp(camera.targetY, -100, 100);\n    var lerpFactor = CONFIG.cameraSmoothing || 0.08;\n    camera.x = lerp(camera.x, camera.targetX, lerpFactor);\n    camera.y = lerp(camera.y, camera.targetY, lerpFactor);\n    camera.x += camera.shakeX || 0;\n    camera.y += camera.shakeY || 0;\n  }\n\n  function renderBackground() {\n    _renderNebula();\n    _renderStarLayer(_stars.far, 0.4);\n    _renderStarLayer(_stars.mid, 0.6);\n    _renderStarLayer(_stars.near, 1.0);\n  }\n\n  function init() { _initStars(); _time = 0; }\n  function renderFull() { _time += deltaTime; }\n\n  return {\n    init: init, renderBackground: renderBackground, renderPlayer: _renderPlayerShip,\n    renderEnemies: _renderEnemies, renderProjectiles: _renderProjectiles,\n    renderParticles: _renderParticles, renderPowerups: _renderPowerups,\n    renderVignette: _renderVignette, renderFull: renderFull,\n    updateCamera: _updateCamera\n  };\n})();\n\n// ============================================================================\n// GAME LOOP\n// ============================================================================\nvar lastTime = performance.now();\nvar fpsCounter = 0, fpsTime = 0, currentFPS = 60;\n\nfunction gameLoop(timestamp) {\n  requestAnimationFrame(gameLoop);\n\n  var now = performance.now();\n  deltaTime = Math.min((now - lastTime) / 1000, 0.05);\n  lastTime = now;\n\n  // FPS tracking\n  fpsCounter++;\n  fpsTime += deltaTime;\n  if (fpsTime >= 1) { currentFPS = Math.round(fpsCounter / fpsTime); fpsCounter = 0; fpsTime = 0; }\n\n  gameTime += deltaTime;\n\n  // Update\n  Renderer.renderFull();\n  Renderer.updateCamera();\n  UIManager.update(deltaTime);\n  updateGameplay(deltaTime);\n  AudioManager.updateMusic(enemies.length, 20);\n\n  // Render\n  ctx.clearRect(0, 0, CONFIG.gameWidth, CONFIG.gameHeight);\n\n  switch (gameState.state) {\n    case 'menu':\n      UIManager.drawMainMenu();\n      break;\n\n    case 'playing':\n      Renderer.renderBackground();\n      Renderer.renderProjectiles();\n      Renderer.renderEnemies();\n      Renderer.renderParticles();\n      Renderer.renderPowerups();\n      Renderer.renderPlayer();\n      Renderer.renderVignette();\n      UIManager.drawHUD();\n      break;\n\n    case 'paused':\n      Renderer.renderBackground();\n      Renderer.renderProjectiles();\n      Renderer.renderEnemies();\n      Renderer.renderParticles();\n      Renderer.renderPowerups();\n      Renderer.renderPlayer();\n      Renderer.renderVignette();\n      UIManager.drawHUD();\n      UIManager.drawPauseMenu();\n      break;\n\n    case 'gameover':\n      Renderer.renderBackground();\n      Renderer.renderParticles();\n      UIManager.drawGameOver();\n      break;\n\n    case 'victory':\n      Renderer.renderBackground();\n      Renderer.renderParticles();\n      UIManager.drawVictory();\n      break;\n  }\n\n  UIManager.drawLevelTransition();\n}\n\n// ============================================================================\n// INITIALIZATION\n// ============================================================================\nfunction init() {\n  resizeCanvas();\n  Renderer.init();\n  initGameplay();\n  UIManager.onResize();\n  requestAnimationFrame(gameLoop);\n}\n\n// Handle visibility change (pause when tab hidden)\ndocument.addEventListener('visibilitychange', function() {\n  if (document.hidden && gameState.state === 'playing') {\n    pauseGame();\n  }\n});\n\n// Prevent default for arrow keys and space globally\nwindow.addEventListener('keydown', function(e) {\n  if (e.code === 'Space' || e.code === 'ArrowUp' || e.code === 'ArrowDown' ||\n      e.code === 'ArrowLeft' || e.code === 'ArrowRight') {\n    e.preventDefault();\n  }\n});\n\nwindow.addEventListener('load', init);\n\n</script>\n</body>\n</html>\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## User

continue

---

## Assistant (Build · DeepSeek V4 Pro · 8.9s)

_Thinking:_

The user said "continue". I've already written the complete game file. Let me verify it's valid and check its size, then clean up by shutting down the team and removing the temp files. Let me also verify the game file is correct by checking its line count and doing a quick syntax check.

Let me verify the game file is valid and clean up the temp files.

**Tool: bash**

**Input:**
```json
{
  "description": "Check game file size and syntax",
  "command": "wc -l /Users/srpanwar/Documents/Workspace/brain/temp/void-strikers.html && node -e \"try { new Function(require('fs').readFileSync('/Users/srpanwar/Documents/Workspace/brain/temp/void-strikers.html','utf8').match(/<script>([\\s\\S]*)<\\/script>/)[1]); console.log('JS syntax OK'); } catch(e) { console.log('Syntax error:', e.message); }\""
}
```

**Output:**
```
    1867 /Users/srpanwar/Documents/Workspace/brain/temp/void-strikers.html
JS syntax OK

```

---

## Assistant (Build · DeepSeek V4 Pro · 6.5s)

_Thinking:_

1867 lines, syntax is OK. Now let me clean up — remove the temp .js files since they're now integrated into the HTML file, and shut down the team.

JavaScript syntax checks out. Let me clean up the intermediate files and shut down the team.

**Tool: bash**

**Input:**
```json
{
  "command": "rm /Users/srpanwar/Documents/Workspace/brain/temp/gameplay.js /Users/srpanwar/Documents/Workspace/brain/temp/ui-audio.js /Users/srpanwar/Documents/Workspace/brain/temp/renderer.js",
  "description": "Remove intermediate agent files"
}
```

**Output:**
```
(no output)
```

---

## Assistant (Build · DeepSeek V4 Pro · 3.0s)

_Thinking:_

Good. Now let me shut down the team since the work is complete.

**Tool: team_shutdown**

**Input:**
```json
{}
```

**Output:**
```
Team shut down successfully.
```

---

## Assistant (Build · DeepSeek V4 Pro · 15.4s)

_Thinking:_

Everything is done. Let me provide a final summary to the user.

The game is complete. Here's a summary of what was built:

---

## Void Strikers — Complete HTML5 Arcade Shooter

**File:** `void-strikers.html` (1867 lines, self-contained)

### Game Features
| System | Details |
|--------|---------|
| **Rendering** | Canvas2D with lighter blending, radial gradients, parallax starfield (230 stars, 3 layers), nebula backgrounds, vignette |
| **Player** | Geometric ship with engine glow, shield aura, 3 weapon levels via power-ups, charge shot with electric arcs |
| **Enemies** | 6 types: Scout (zigzag), Fighter (pursue+shoot), Tank (spread), Speeder (dive), Sniper (distance), Boss (3-phase) |
| **Boss** | Multi-phase with enrage patterns, circular bullet bursts, phase transition VFX |
| **Levels** | 3 levels with wave-based spawning, increasing difficulty, boss per level |
| **Power-ups** | Health, Shield, Weapon Upgrade, Speed Boost — 15% drop chance |
| **Particles** | Explosions, rings, sparks, engine trails, power-up sparkles |
| **Combo** | 1x–5x multiplier at 10/25/50/100 kills, 2s decay window |
| **Audio** | Procedural Web Audio (14 SFX + dynamic background music with bass/pad/arp/hi-hat, tempo/level scaling) |
| **UI** | Main menu with glowing title, HUD (health bar, shield bar, charge meter, weapon level, combo popup), pause, game over, victory screens |
| **Controls** | WASD/Arrows + Space (charge shot), P (pause), M (mute), touch drag movement + multi-touch charge |
| **Scaling** | Responsive canvas, maintains portrait aspect ratio, letterboxed |

### How to Play
Open `void-strikers.html` in any modern browser. Press Enter or tap to start.

---

