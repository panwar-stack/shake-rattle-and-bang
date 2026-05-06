You are an expert agent team building a fully functional browser platform game inspired by classic plumber platformers. Do not use copyrighted Mario assets, Nintendo characters, Nintendo music, Nintendo sprites, or protected level designs. Create original characters, original pixel art, original sounds, and original level layouts while keeping the familiar platform game feel.
Must use agent team to accomplish this task. Dont be impatient. When runnning agent team, team members take time to finish the job.

Goal:
Build a complete browser game with exactly 4 playable levels. The game must run locally in a modern browser using HTML, CSS, and JavaScript. Prefer a single self contained HTML file unless there is a strong reason to split files.

Agent team:
1. Project Manager Agent
Coordinate the work, define milestones, keep scope limited to 4 levels, and ensure the final game is complete and playable.

2. Game Architect Agent
Design the code structure, game loop, state management, collision system, level system, asset loading approach, and browser compatibility plan.

3. Player Mechanics Agent
Implement smooth player movement, jumping, gravity, acceleration, friction, crouching if useful, enemy stomping, damage, lives, checkpoints, power ups, and responsive controls.

4. Level Design Agent
Create 4 original levels with increasing difficulty:
Level 1: tutorial grassland
Level 2: underground cave
Level 3: sky platforms
Level 4: castle finale with boss encounter

Each level must include a start point, hazards, enemies, collectibles, platforms, secrets, and a clear finish condition.

5. Enemy And Boss Agent
Implement at least 4 enemy types and 1 final boss. Enemies need movement patterns, collision behavior, defeat behavior, and basic animation.

6. Art And Audio Agent
Create original simple pixel art using CSS, Canvas drawing, or generated sprite data. Add original sound effects using Web Audio API. Include jump, coin, damage, enemy defeat, level clear, and game over sounds.

7. User Interface Agent
Create title screen, pause screen, level complete screen, game over screen, heads up display, score, coins, lives, timer, current level, and final victory screen.

8. Quality Assurance Agent
Test the full game manually through all 4 levels. Fix bugs in physics, collision, restarts, level transitions, enemy interactions, mobile scaling, and keyboard controls.

Functional requirements:
1. The game must run directly in the browser.
2. No external copyrighted assets.
3. Use original character and world design.
4. Include exactly 4 levels.
5. Include keyboard controls:
Left arrow or A moves left.
Right arrow or D moves right.
Space, W, or Up arrow jumps.
P pauses.
R restarts the current level.
6. Include touch controls for mobile browsers.
7. Include collectibles.
8. Include enemies.
9. Include hazards such as spikes, pits, lava, or moving traps.
10. Include power ups such as higher jump, temporary shield, or speed boost.
11. Include checkpoints.
12. Include scoring.
13. Include lives and game over.
14. Include level transitions.
15. Include a final boss in level 4.
16. Include a final victory screen after beating level 4.
17. Include clear comments in the code.
18. Include instructions for running the game.
19. The final result must be playable, polished, and complete.

Technical requirements:
1. Use vanilla JavaScript unless a library is absolutely necessary.
2. Prefer Canvas for rendering.
3. Use requestAnimationFrame for the game loop.
4. Use deterministic level data arrays or objects.
5. Use axis aligned collision detection.
6. Keep performance smooth at 60 frames per second where possible.
7. Make the viewport follow the player with camera scrolling.
8. Store best score in localStorage.
9. Include basic responsive layout.
10. Avoid build tools unless necessary.

Implementation process:
1. First, the agents should agree on the architecture and feature list.
2. Then build a minimal playable prototype with player movement, platforms, camera, and one test level.
3. Then add enemies, collectibles, hazards, lives, and scoring.
4. Then create all 4 levels.
5. Then add user interface screens.
6. Then add audio, polish, animations, and effects.
7. Then test all levels from start to finish.
8. Then provide the final complete code.

Final output:
Provide the complete working code.
Provide any setup instructions.
Provide a short summary of what was implemented.
Do not provide placeholders.
Do not leave unfinished functions.
Do not say the user needs to add assets later.
The game must be complete and runnable as delivered.