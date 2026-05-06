const fs = require('fs');

// Read all three files
let engineCore = fs.readFileSync('engine-core.js', 'utf8');
let levelsAssets = fs.readFileSync('levels-assets.js', 'utf8');
let gameplayRendering = fs.readFileSync('gameplay-rendering.js', 'utf8');

// Remove duplicate functions from engine-core (keep gameplay-rendering's more complete versions)
// Functions to remove from engine-core: hurtPlayer, killPlayer, respawnPlayer, activatePowerup, 
// updatePowerupTimers, checkDeathRespawn, loadLevel, clearCanvas, renderTouchControls

// Remove from engine-core (lines between markers):
// Remove from line starting with "function hurtPlayer()" through end of checkDeathRespawn
engineCore = engineCore.replace(
  /\/\/ ========== PLAYER STATE FUNCTIONS.*\n\nfunction hurtPlayer\(\)[\s\S]*?function checkDeathRespawn\(\)[\s\S]*?^  \}\n\}\n/,
  ''
);

// Remove the loadLevel function from engine-core (entire function)
engineCore = engineCore.replace(
  /\/\/ ========== LEVEL LOADING ==========[\s\S]*?\nfunction loadLevel\([^)]*\)[\s\S]*?^}\n/,
  ''
);

// Remove clearCanvas from engine-core (replace with empty since gameplay-rendering has it)
engineCore = engineCore.replace(
  /function clearCanvas\([^)]*\)[\s\S]*?^}\n/,
  ''
);

// Remove renderTouchControls from engine-core (replace with empty)
engineCore = engineCore.replace(
  /function renderTouchControls\([^)]*\)[\s\S]*?^}\n/,
  ''
);

// Build the complete HTML file
const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>Pixel Quest</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  background: #000;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
  width: 100vw;
}
canvas {
  display: block;
  image-rendering: pixelated;
  image-rendering: crisp-edges;
  touch-action: none;
}
</style>
</head>
<body>
<canvas id="game"></canvas>
<script>
// ========== CONSTANTS & CONFIG ==========
// (engine-core.js begins)

${engineCore}

// ===== LEVELS & ASSETS (Sections 4, 5, 6) =====

${levelsAssets}

// ===== GAMEPLAY & RENDERING (Sections 10-17) =====

${gameplayRendering}
</script>
</body>
</html>`;

fs.writeFileSync('index.html', html);
console.log('Written index.html (' + html.length + ' bytes, ~' + html.split('\n').length + ' lines)');
