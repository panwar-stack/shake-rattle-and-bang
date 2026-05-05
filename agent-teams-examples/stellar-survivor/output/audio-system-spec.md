# STELLAR SURVIVOR — Complete Audio System Design
## Audio Engineer: Procedural Web Audio API Specification

---

# 1. AUDIO ROUTING GRAPH

```
  ┌─────────────────────┐
  │    AudioContext      │
  │  (lazy-init on       │
  │   user gesture)      │
  └────────┬────────────┘
           │
    ┌──────▼──────┐
    │ Master Gain  │  ← global volume (default 0.3)
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │  Master Out  │  → context.destination
    └─────────────┘

SFX PATH:                    MUSIC PATH:
┌──────────────┐            ┌──────────────┐
│ Per-Sound    │            │ Bass Drone   │
│ Osc/Noise/   │            │ Oscillator   │──┐
│ Filter/Gain  │            └──────────────┘  │
│ (one-shot)   │            ┌──────────────┐  │
└──────┬───────┘            │ Arpeggio     │  │
       │                    │ Seq (4 osc)  │──┤
┌──────▼───────┐            └──────────────┘  │
│  SFX Bus     │            ┌──────────────┐  │
│  Gain (0.7)  │            │ Drum Noise   │  │
└──────┬───────┘            │ Sequencer    │──┤
       │                    └──────────────┘  │
┌──────▼───────┐                              │
│  Compressor  │            ┌───────────────┐ │
│  thresh:-24  │            │ Music Bus     │◄┘
│  ratio:4:1   │            │ Gain (0.4)    │
│  atk:5ms     │            └───────┬───────┘
│  rel:50ms    │                    │
└──────┬───────┘            ┌───────▼───────┐
       │                    │  Ducking      │
       │                    │  Gain (0.0-   │
       │                    │  1.0)         │
       └────────┬───────────┘               │
                │            └───────┬───────┘
         ┌──────▼───────┐           │
         │  Pseudo-      │◄──────────┘
         │  Reverb Send  │
         │  (Delay-based)│
         └──────┬───────┘
                │
         ┌──────▼───────┐
         │  Master Gain  │
         └──────────────┘
```

All nodes created once in `init()`. Per-sound oscillators/noise sources created on-demand in each `playSound()` call.

---

# 2. AUDIO ENGINE SETUP — init()

```javascript
class AudioManager {
  constructor() {
    this.ctx = null;           // AudioContext
    this.initialized = false;
    
    // Master
    this.masterGain = null;
    
    // SFX path
    this.sfxGain = null;
    this.sfxCompressor = null;
    
    // Music path
    this.musicGain = null;
    this.duckingGain = null;
    
    // Reverb
    this.reverbSend = null;
    this.reverbGain = null;
    
    // Pre-created reverb delay lines
    this.reverbDelays = [];
    
    // Music nodes (persistent)
    this.bassOsc = null;
    this.bassGain = null;
    this.bassFilter = null;
    this.musicIntervalId = null;
    this.musicSeqStep = 0;
    
    // State
    this.muted = false;
    this.musicPlaying = false;
    this.currentLevel = 1;
    this.sfxCount = 0;
    this.sfxDecayTimer = null;
    this.musicIntensity = 0; // 0.0 - 1.0
    
    // Volume settings
    this._masterVol = 0.3;
    this._sfxVol = 0.7;
    this._musicVol = 0.4;
  }
  
  init() {
    if (this.initialized) return;
    
    this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    
    // ── MASTER ──────────────────────────────
    this.masterGain = this.ctx.createGain();
    this.masterGain.gain.value = this._masterVol;
    this.masterGain.connect(this.ctx.destination);
    
    // ── SFX PATH ────────────────────────────
    this.sfxGain = this.ctx.createGain();
    this.sfxGain.gain.value = this._sfxVol;
    
    this.sfxCompressor = this.ctx.createDynamicsCompressor();
    this.sfxCompressor.threshold.setValueAtTime(-24, this.ctx.currentTime);
    this.sfxCompressor.ratio.setValueAtTime(4, this.ctx.currentTime);
    this.sfxCompressor.attack.setValueAtTime(0.005, this.ctx.currentTime);
    this.sfxCompressor.release.setValueAtTime(0.05, this.ctx.currentTime);
    this.sfxCompressor.knee.setValueAtTime(30, this.ctx.currentTime);
    
    this.sfxGain.connect(this.sfxCompressor);
    
    // ── MUSIC PATH ──────────────────────────
    this.musicGain = this.ctx.createGain();
    this.musicGain.gain.value = this._musicVol;
    
    this.duckingGain = this.ctx.createGain();
    this.duckingGain.gain.value = 1.0;
    
    this.musicGain.connect(this.duckingGain);
    
    // ── REVERB (delay-based pseudo-reverb) ──
    this.reverbGain = this.ctx.createGain();
    this.reverbGain.gain.value = 0.0;
    this.reverbSend = this.ctx.createGain();
    this.reverbSend.gain.value = 0.3;
    
    const preDelay = this.ctx.createDelay(0.05);
    preDelay.delayTime.value = 0.01;
    
    // Early reflection delays
    for (let i = 0; i < 4; i++) {
      const delay = this.ctx.createDelay(0.1);
      delay.delayTime.value = 0.015 + i * 0.012;
      const fbGain = this.ctx.createGain();
      fbGain.gain.value = 0.12 / (i + 1);
      delay.connect(fbGain);
      fbGain.connect(delay); // feedback loop
      fbGain.connect(this.reverbGain);
      this.reverbSend.connect(delay);
      this.reverbDelays.push({ delay, fbGain });
    }
    
    // Wet/dry routing
    this.sfxCompressor.connect(this.masterGain);        // dry SFX
    this.duckingGain.connect(this.masterGain);           // dry music
    this.reverbGain.connect(this.masterGain);            // wet reverb
    this.sfxCompressor.connect(this.reverbSend);         // SFX → reverb send
    
    this.initialized = true;
  }
```

---

# 3. SOUND EFFECTS — Exact Generation Patterns

All sounds follow this pattern: create oscillator/noise source → route through optional filter → route through envelope gain → connect to `this.sfxGain` → `.start(now)` → `.stop(now + dur)`.

## Helper: createEnvelope(now, gainNode, attack, hold, decay, peakLevel)

```javascript
createEnvelope(now, gainNode, attack, hold, decay, peakLevel = 0.5) {
  gainNode.gain.setValueAtTime(0, now);
  gainNode.gain.linearRampToValueAtTime(peakLevel, now + attack);
  if (hold > 0) {
    gainNode.gain.setValueAtTime(peakLevel, now + attack + hold);
  }
  gainNode.gain.exponentialRampToValueAtTime(0.001, now + attack + hold + decay);
}
```

---

### a) PLAYER_SHOOT — laser blip

```javascript
case 'PLAYER_SHOOT':
  const psOsc = this.ctx.createOscillator();
  psOsc.type = 'square';
  psOsc.frequency.setValueAtTime(800, now);
  psOsc.frequency.exponentialRampToValueAtTime(400, now + 0.05);
  
  const psFilter = this.ctx.createBiquadFilter();
  psFilter.type = 'lowpass';
  psFilter.frequency.value = 2000;
  psFilter.Q.value = 1;
  
  const psGain = this.ctx.createGain();
  this.createEnvelope(now, psGain, 0.002, 0.0, 0.048, 0.4);
  
  psOsc.connect(psFilter);
  psFilter.connect(psGain);
  psGain.connect(this.sfxGain);
  psOsc.start(now);
  psOsc.stop(now + 0.05);
  break;
```

### b) PLAYER_HIT — low thud

```javascript
case 'PLAYER_HIT':
  // Noise burst
  const phBufferSize = this.ctx.sampleRate * 0.1;
  const phBuffer = this.ctx.createBuffer(1, phBufferSize, this.ctx.sampleRate);
  const phData = phBuffer.getChannelData(0);
  for (let i = 0; i < phBufferSize; i++) {
    phData[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / phBufferSize, 3);
  }
  const phNoise = this.ctx.createBufferSource();
  phNoise.buffer = phBuffer;
  
  // Sine thud
  const phOsc = this.ctx.createOscillator();
  phOsc.type = 'sine';
  phOsc.frequency.value = 200;
  
  const phGainN = this.ctx.createGain();
  const phGainO = this.ctx.createGain();
  this.createEnvelope(now, phGainN, 0.001, 0.0, 0.099, 0.35);
  this.createEnvelope(now, phGainO, 0.001, 0.0, 0.099, 0.25);
  
  // Distortion via WaveShaper
  const phDist = this.ctx.createWaveShaper();
  phDist.curve = this.makeDistortionCurve(50);
  phDist.oversample = '2x';
  
  phNoise.connect(phGainN);
  phGainN.connect(phDist);
  phDist.connect(this.sfxGain);
  
  phOsc.connect(phGainO);
  phGainO.connect(this.sfxGain);
  
  phNoise.start(now);
  phNoise.stop(now + 0.1);
  phOsc.start(now);
  phOsc.stop(now + 0.1);
  break;
```

### c) ENEMY_SHOOT — harsher laser

```javascript
case 'ENEMY_SHOOT':
  const esOsc = this.ctx.createOscillator();
  esOsc.type = 'sawtooth';
  esOsc.frequency.setValueAtTime(400, now);
  esOsc.frequency.exponentialRampToValueAtTime(200, now + 0.07);
  
  const esFilter = this.ctx.createBiquadFilter();
  esFilter.type = 'lowpass';
  esFilter.frequency.value = 1500;
  
  const esGain = this.ctx.createGain();
  this.createEnvelope(now, esGain, 0.003, 0.0, 0.067, 0.35);
  
  esOsc.connect(esFilter);
  esFilter.connect(esGain);
  esGain.connect(this.sfxGain);
  esOsc.start(now);
  esOsc.stop(now + 0.07);
  break;
```

### d) ENEMY_DEATH — small explosion

```javascript
case 'ENEMY_DEATH':
  const edDuration = 0.15 + params.intensity * 0.1;
  const edBufferSize = Math.floor(this.ctx.sampleRate * edDuration);
  const edBuffer = this.ctx.createBuffer(1, edBufferSize, this.ctx.sampleRate);
  const edData = edBuffer.getChannelData(0);
  for (let i = 0; i < edBufferSize; i++) {
    const t = i / edBufferSize;
    edData[i] = (Math.random() * 2 - 1) * Math.pow(1 - t, 2) * 0.8;
  }
  const edNoise = this.ctx.createBufferSource();
  edNoise.buffer = edBuffer;
  
  const edBandpass = this.ctx.createBiquadFilter();
  edBandpass.type = 'bandpass';
  edBandpass.frequency.setValueAtTime(800, now);
  edBandpass.frequency.exponentialRampToValueAtTime(200, now + edDuration);
  edBandpass.Q.value = 1.5;
  
  const edGain = this.ctx.createGain();
  this.createEnvelope(now, edGain, 0.005, 0.02, edDuration - 0.03, 0.4);
  
  // Send to reverb
  this.reverbGain.gain.setValueAtTime(0.15, now);
  this.reverbGain.gain.exponentialRampToValueAtTime(0.001, now + edDuration + 0.3);
  
  edNoise.connect(edBandpass);
  edBandpass.connect(edGain);
  edGain.connect(this.sfxGain);
  edNoise.start(now);
  edNoise.stop(now + edDuration);
  break;
```

### e) POWERUP_COLLECT — rising arpeggio

```javascript
case 'POWERUP_COLLECT':
  const notes = [523.25, 659.25, 783.99]; // C5, E5, G5
  const noteLen = 0.03;
  notes.forEach((freq, i) => {
    const osc = this.ctx.createOscillator();
    osc.type = 'sine';
    osc.frequency.value = freq;
    
    // Vibrato via OscillatorNode modulating frequency
    const vibrato = this.ctx.createOscillator();
    vibrato.frequency.value = 8;
    const vibratoGain = this.ctx.createGain();
    vibratoGain.gain.value = 6;
    vibrato.connect(vibratoGain);
    vibratoGain.connect(osc.frequency);
    vibrato.start(now + i * noteLen);
    vibrato.stop(now + (i + 1) * noteLen);
    
    const gain = this.ctx.createGain();
    this.createEnvelope(now + i * noteLen, gain, 0.002, 0.01, noteLen - 0.012, 0.4);
    
    osc.connect(gain);
    gain.connect(this.sfxGain);
    osc.start(now + i * noteLen);
    osc.stop(now + (i + 1) * noteLen);
  });
  break;
```

### f) SHIELD_ACTIVATE — whoosh

```javascript
case 'SHIELD_ACTIVATE':
  const saBufferSize = Math.floor(this.ctx.sampleRate * 0.2);
  const saBuffer = this.ctx.createBuffer(1, saBufferSize, this.ctx.sampleRate);
  const saData = saBuffer.getChannelData(0);
  for (let i = 0; i < saBufferSize; i++) {
    saData[i] = (Math.random() * 2 - 1);
  }
  const saNoise = this.ctx.createBufferSource();
  saNoise.buffer = saBuffer;
  
  const saFilter = this.ctx.createBiquadFilter();
  saFilter.type = 'bandpass';
  saFilter.frequency.setValueAtTime(200, now);
  saFilter.frequency.exponentialRampToValueAtTime(2000, now + 0.15);
  saFilter.Q.value = 2;
  
  const saGain = this.ctx.createGain();
  this.createEnvelope(now, saGain, 0.02, 0.0, 0.18, 0.35);
  
  saNoise.connect(saFilter);
  saFilter.connect(saGain);
  saGain.connect(this.sfxGain);
  saNoise.start(now);
  saNoise.stop(now + 0.2);
  break;
```

### g) SHIELD_HIT — metallic ping

```javascript
case 'SHIELD_HIT':
  // Ring modulation: multiply two sine waves
  const shOsc1 = this.ctx.createOscillator();
  shOsc1.type = 'sine';
  shOsc1.frequency.value = 1200;
  
  const shOsc2 = this.ctx.createOscillator(); // modulator
  shOsc2.type = 'sine';
  shOsc2.frequency.value = 180;
  
  const shRingGain = this.ctx.createGain(); // acts as ring mod
  shRingGain.gain.value = 0;
  
  // Route: osc1 → ringGain, osc2 → ringGain.gain → creates amplitude modulation
  shOsc2.connect(shRingGain.gain); // modulate the carrier amplitude
  shOsc1.connect(shRingGain);
  
  // Alternative: true ring modulation via WaveShaper
  // Simpler approach: use two oscillators and a gain node for tremolo/AM effect
  const shGain = this.ctx.createGain();
  this.createEnvelope(now, shGain, 0.001, 0.0, 0.049, 0.4);
  
  // High shelf for metallic sheen
  const shFilter = this.ctx.createBiquadFilter();
  shFilter.type = 'highshelf';
  shFilter.frequency.value = 3000;
  shFilter.gain.value = 10;
  
  shRingGain.connect(shFilter);
  shFilter.connect(shGain);
  shGain.connect(this.sfxGain);
  
  shOsc1.start(now);
  shOsc1.stop(now + 0.05);
  shOsc2.start(now);
  shOsc2.stop(now + 0.05);
  break;
```

### h) COMBO_INCREASE — ascending ding

```javascript
case 'COMBO_INCREASE':
  const comboLevel = params.combo || 1;
  const basePitch = 400 + comboLevel * 50; // pitch rises with combo
  const ciOsc = this.ctx.createOscillator();
  ciOsc.type = 'triangle';
  ciOsc.frequency.setValueAtTime(basePitch, now);
  ciOsc.frequency.linearRampToValueAtTime(basePitch * 1.3, now + 0.08);
  
  // Add harmonic overtone
  const ciHarm = this.ctx.createOscillator();
  ciHarm.type = 'sine';
  ciHarm.frequency.setValueAtTime(basePitch * 2, now);
  ciHarm.frequency.linearRampToValueAtTime(basePitch * 2.6, now + 0.08);
  
  const ciGain = this.ctx.createGain();
  const ciGainH = this.ctx.createGain();
  this.createEnvelope(now, ciGain, 0.003, 0.0, 0.077, 0.35);
  this.createEnvelope(now, ciGainH, 0.003, 0.0, 0.077, 0.12);
  
  ciOsc.connect(ciGain);
  ciGain.connect(this.sfxGain);
  ciHarm.connect(ciGainH);
  ciGainH.connect(this.sfxGain);
  
  ciOsc.start(now);
  ciOsc.stop(now + 0.08);
  ciHarm.start(now);
  ciHarm.stop(now + 0.08);
  break;
```

### i) BOSS_APPEAR — deep rumble

```javascript
case 'BOSS_APPEAR':
  const baOsc = this.ctx.createOscillator();
  baOsc.type = 'sine';
  baOsc.frequency.setValueAtTime(80, now);
  baOsc.frequency.exponentialRampToValueAtTime(55, now + 0.5);
  
  // Filtered noise layer
  const baBufSize = Math.floor(this.ctx.sampleRate * 0.5);
  const baBuf = this.ctx.createBuffer(1, baBufSize, this.ctx.sampleRate);
  const baData = baBuf.getChannelData(0);
  for (let i = 0; i < baBufSize; i++) {
    baData[i] = (Math.random() * 2 - 1);
  }
  const baNoise = this.ctx.createBufferSource();
  baNoise.buffer = baBuf;
  const baNFilter = this.ctx.createBiquadFilter();
  baNFilter.type = 'lowpass';
  baNFilter.frequency.setValueAtTime(200, now);
  baNFilter.frequency.exponentialRampToValueAtTime(60, now + 0.5);
  
  const baGainO = this.ctx.createGain();
  const baGainN = this.ctx.createGain();
  this.createEnvelope(now, baGainO, 0.15, 0.2, 0.15, 0.5);
  this.createEnvelope(now, baGainN, 0.1, 0.2, 0.2, 0.3);
  
  baOsc.connect(baGainO);
  baGainO.connect(this.sfxGain);
  baNoise.connect(baNFilter);
  baNFilter.connect(baGainN);
  baGainN.connect(this.sfxGain);
  
  baOsc.start(now);
  baOsc.stop(now + 0.5);
  baNoise.start(now);
  baNoise.stop(now + 0.5);
  break;
```

### j) BOSS_ATTACK — heavy impact

```javascript
case 'BOSS_ATTACK':
  const bAtkOsc = this.ctx.createOscillator();
  bAtkOsc.type = 'sawtooth';
  bAtkOsc.frequency.value = 80;
  
  // Distortion
  const bAtkDist = this.ctx.createWaveShaper();
  bAtkDist.curve = this.makeDistortionCurve(400);
  bAtkDist.oversample = '4x';
  
  // Noise layer
  const bAtkBufSize = Math.floor(this.ctx.sampleRate * 0.2);
  const bAtkBuf = this.ctx.createBuffer(1, bAtkBufSize, this.ctx.sampleRate);
  const bAtkData = bAtkBuf.getChannelData(0);
  for (let i = 0; i < bAtkBufSize; i++) {
    bAtkData[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / bAtkBufSize, 2);
  }
  const bAtkNoise = this.ctx.createBufferSource();
  bAtkNoise.buffer = bAtkBuf;
  
  const bAtkGainO = this.ctx.createGain();
  const bAtkGainN = this.ctx.createGain();
  this.createEnvelope(now, bAtkGainO, 0.005, 0.0, 0.195, 0.5);
  this.createEnvelope(now, bAtkGainN, 0.002, 0.0, 0.198, 0.35);
  
  const bAtkFilter = this.ctx.createBiquadFilter();
  bAtkFilter.type = 'lowpass';
  bAtkFilter.frequency.value = 400;
  
  bAtkOsc.connect(bAtkDist);
  bAtkDist.connect(bAtkFilter);
  bAtkFilter.connect(bAtkGainO);
  bAtkGainO.connect(this.sfxGain);
  bAtkNoise.connect(bAtkGainN);
  bAtkGainN.connect(this.sfxGain);
  
  bAtkOsc.start(now);
  bAtkOsc.stop(now + 0.2);
  bAtkNoise.start(now);
  bAtkNoise.stop(now + 0.2);
  break;
```

### k) MENU_SELECT — soft blip

```javascript
case 'MENU_SELECT':
  const msOsc = this.ctx.createOscillator();
  msOsc.type = 'triangle';
  msOsc.frequency.value = 600;
  const msGain = this.ctx.createGain();
  this.createEnvelope(now, msGain, 0.002, 0.0, 0.028, 0.25);
  msOsc.connect(msGain);
  msGain.connect(this.sfxGain);
  msOsc.start(now);
  msOsc.stop(now + 0.03);
  break;
```

### l) MENU_CONFIRM — confirmation tone

```javascript
case 'MENU_CONFIRM':
  const mcOsc = this.ctx.createOscillator();
  mcOsc.type = 'sine';
  mcOsc.frequency.value = 800;
  const mcGain = this.ctx.createGain();
  this.createEnvelope(now, mcGain, 0.002, 0.0, 0.048, 0.35);
  mcOsc.connect(mcGain);
  mcGain.connect(this.sfxGain);
  mcOsc.start(now);
  mcOsc.stop(now + 0.05);
  break;
```

### m) NUKE / BULLET_CLEAR — powerful sweep

```javascript
case 'NUKE':
  // Sine sweep
  const nkOsc = this.ctx.createOscillator();
  nkOsc.type = 'sine';
  nkOsc.frequency.setValueAtTime(100, now);
  nkOsc.frequency.exponentialRampToValueAtTime(2000, now + 0.3);
  
  // Noise burst
  const nkBufSize = Math.floor(this.ctx.sampleRate * 0.3);
  const nkBuf = this.ctx.createBuffer(1, nkBufSize, this.ctx.sampleRate);
  const nkData = nkBuf.getChannelData(0);
  for (let i = 0; i < nkBufSize; i++) {
    nkData[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / nkBufSize, 1.5);
  }
  const nkNoise = this.ctx.createBufferSource();
  nkNoise.buffer = nkBuf;
  
  const nkFilter = this.ctx.createBiquadFilter();
  nkFilter.type = 'bandpass';
  nkFilter.frequency.setValueAtTime(200, now);
  nkFilter.frequency.exponentialRampToValueAtTime(3000, now + 0.3);
  nkFilter.Q.value = 0.7;
  
  const nkGainO = this.ctx.createGain();
  const nkGainN = this.ctx.createGain();
  this.createEnvelope(now, nkGainO, 0.05, 0.1, 0.15, 0.5);
  this.createEnvelope(now, nkGainN, 0.03, 0.1, 0.17, 0.4);
  
  // Heavy reverb
  this.reverbGain.gain.setValueAtTime(0.3, now);
  this.reverbGain.gain.exponentialRampToValueAtTime(0.001, now + 0.6);
  
  nkOsc.connect(nkGainO);
  nkGainO.connect(this.sfxGain);
  nkNoise.connect(nkFilter);
  nkFilter.connect(nkGainN);
  nkGainN.connect(this.sfxGain);
  
  nkOsc.start(now);
  nkOsc.stop(now + 0.3);
  nkNoise.start(now);
  nkNoise.stop(now + 0.3);
  break;
```

### n) GAME_OVER — descending sad tones

```javascript
case 'GAME_OVER':
  const goNotes = [466.16, 415.30, 369.99]; // Bb4, Ab4, Gb4
  const goDuration = 0.33; // per note
  
  goNotes.forEach((freq, i) => {
    const osc = this.ctx.createOscillator();
    osc.type = 'sawtooth';
    osc.frequency.value = freq;
    
    const lpf = this.ctx.createBiquadFilter();
    lpf.type = 'lowpass';
    const filterStart = 3000 - i * 800;
    lpf.frequency.setValueAtTime(filterStart, now + i * goDuration);
    lpf.frequency.exponentialRampToValueAtTime(400, now + i * goDuration + goDuration);
    lpf.Q.value = 1;
    
    const gain = this.ctx.createGain();
    const noteStart = now + i * goDuration;
    gain.gain.setValueAtTime(0, noteStart);
    gain.gain.linearRampToValueAtTime(0.35, noteStart + 0.05);
    gain.gain.exponentialRampToValueAtTime(0.001, noteStart + goDuration);
    
    osc.connect(lpf);
    lpf.connect(gain);
    gain.connect(this.sfxGain);
    osc.start(noteStart);
    osc.stop(noteStart + goDuration);
  });
  break;
```

### o) VICTORY — triumphant arpeggio

```javascript
case 'VICTORY':
  const vNotes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
  const vDuration = 0.375; // 1500ms / 4 notes
  
  vNotes.forEach((freq, i) => {
    // Sine base
    const oscS = this.ctx.createOscillator();
    oscS.type = 'sine';
    oscS.frequency.value = freq;
    
    // Square for brightness
    const oscQ = this.ctx.createOscillator();
    oscQ.type = 'square';
    oscQ.frequency.value = freq;
    
    const gainS = this.ctx.createGain();
    const gainQ = this.ctx.createGain();
    const noteStart = now + i * vDuration;
    
    // Soft attack, sustain, gentle release
    gainS.gain.setValueAtTime(0, noteStart);
    gainS.gain.linearRampToValueAtTime(0.35, noteStart + 0.05);
    gainS.gain.setValueAtTime(0.35, noteStart + vDuration - 0.05);
    gainS.gain.exponentialRampToValueAtTime(0.001, noteStart + vDuration);
    
    gainQ.gain.setValueAtTime(0, noteStart);
    gainQ.gain.linearRampToValueAtTime(0.08, noteStart + 0.05);
    gainQ.gain.exponentialRampToValueAtTime(0.001, noteStart + vDuration - 0.1);
    
    oscS.connect(gainS);
    gainS.connect(this.sfxGain);
    oscQ.connect(gainQ);
    gainQ.connect(this.sfxGain);
    
    oscS.start(noteStart);
    oscS.stop(noteStart + vDuration);
    oscQ.start(noteStart);
    oscQ.stop(noteStart + vDuration);
  });
  
  // Optional: low bass note underneath
  const vBassOsc = this.ctx.createOscillator();
  vBassOsc.type = 'sine';
  vBassOsc.frequency.value = 130.81; // C3
  const vBassGain = this.ctx.createGain();
  vBassGain.gain.setValueAtTime(0, now);
  vBassGain.gain.linearRampToValueAtTime(0.15, now + 0.1);
  vBassGain.gain.exponentialRampToValueAtTime(0.001, now + 1.5);
  vBassOsc.connect(vBassGain);
  vBassGain.connect(this.sfxGain);
  vBassOsc.start(now);
  vBassOsc.stop(now + 1.5);
  break;
```

---

# 4. BACKGROUND MUSIC SYSTEM

### Scale: C minor pentatonic
```javascript
const PENTATONIC = [130.81, 155.56, 174.61, 195.99, 233.08, // C3-G3
                     261.63, 311.13, 349.23, 391.99, 466.16, // C4-Bb4
                     523.25, 622.25, 698.46, 783.99, 932.33, // C5-Bb5
                     1046.50, 1244.51, 1396.91, 1567.98, 1864.66]; // C7-Bb7
```

### Music Sequencer

```javascript
  startMusic() {
    if (!this.initialized) this.init();
    if (this.musicPlaying) return;
    this.musicPlaying = true;
    
    // ── Bass Drone ──────────────────────────
    this.bassOsc = this.ctx.createOscillator();
    this.bassOsc.type = 'sawtooth';
    this.bassOsc.frequency.value = 65.41; // C2
    
    this.bassFilter = this.ctx.createBiquadFilter();
    this.bassFilter.type = 'lowpass';
    this.bassFilter.frequency.value = 120;
    this.bassFilter.Q.value = 5;
    
    this.bassGain = this.ctx.createGain();
    this.bassGain.gain.value = 0.05;
    
    this.bassOsc.connect(this.bassFilter);
    this.bassFilter.connect(this.bassGain);
    this.bassGain.connect(this.musicGain);
    this.bassOsc.start();
    
    // ── Arpeggio Sequencer ──────────────────
    this.musicSeqStep = 0;
    this.scheduleMusicTick();
  }
  
  scheduleMusicTick() {
    if (!this.musicPlaying) return;
    
    const bpm = 120 + this.currentLevel * 8; // Level 1: 128, Level 5: 160
    const beatInterval = 60 / bpm; // quarter note
    const eighthInterval = beatInterval / 2;
    
    const now = this.ctx.currentTime;
    const step = this.musicSeqStep % 8;
    
    // Choose random pentatonic note for this step
    const octaveIdx = this.currentLevel <= 2 ? 5 : (this.currentLevel <= 4 ? 10 : 15);
    // Pick from 5 notes within range
    const noteIdx = Math.floor(Math.random() * 5) + octaveIdx;
    const freq = PENTATONIC[Math.min(noteIdx, PENTATONIC.length - 1)];
    
    const arpOsc = this.ctx.createOscillator();
    arpOsc.type = 'triangle';
    arpOsc.frequency.value = freq;
    
    const arpGain = this.ctx.createGain();
    arpGain.gain.setValueAtTime(0, now);
    arpGain.gain.linearRampToValueAtTime(0.12, now + 0.01);
    arpGain.gain.exponentialRampToValueAtTime(0.001, now + eighthInterval * 0.8);
    
    arpOsc.connect(arpGain);
    arpGain.connect(this.musicGain);
    arpOsc.start(now);
    arpOsc.stop(now + eighthInterval);
    
    // ── Drum hits (on beats 0, 2, 4, 6) ────
    if (step % 2 === 0) {
      this.playMusicDrum(now, step === 0 || step === 4 ? 0.06 : 0.04);
    }
    
    this.musicSeqStep++;
    
    // Schedule next tick
    this.musicIntervalId = setTimeout(() => this.scheduleMusicTick(), eighthInterval * 1000);
  }
  
  playMusicDrum(now, volume) {
    const bufSize = Math.floor(this.ctx.sampleRate * 0.03);
    const buf = this.ctx.createBuffer(1, bufSize, this.ctx.sampleRate);
    const data = buf.getChannelData(0);
    for (let i = 0; i < bufSize; i++) {
      data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / bufSize, 3);
    }
    const noise = this.ctx.createBufferSource();
    noise.buffer = buf;
    
    const bpf = this.ctx.createBiquadFilter();
    bpf.type = 'bandpass';
    bpf.frequency.value = 200;
    bpf.Q.value = 0.5;
    
    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(volume, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.03);
    
    noise.connect(bpf);
    bpf.connect(gain);
    gain.connect(this.musicGain);
    noise.start(now);
    noise.stop(now + 0.03);
  }
```

### Boss Music Mode

```javascript
  startBossMusic() {
    this.currentLevel = 99; // max intensity
    // More aggressive drum pattern handled in scheduleMusicTick via level check
    // Bass drone intensifies
    if (this.bassGain) {
      this.bassGain.gain.setValueAtTime(0.10, this.ctx.currentTime);
    }
    // Double-time drums
    this.bossMusicMode = true;
  }
  
  stopBossMusic() {
    this.bossMusicMode = false;
    this.currentLevel = this.savedLevel || 1;
    if (this.bassGain) {
      this.bassGain.gain.setValueAtTime(0.05, this.ctx.currentTime);
    }
  }
```

### Music Stop

```javascript
  stopMusic() {
    this.musicPlaying = false;
    if (this.musicIntervalId) clearTimeout(this.musicIntervalId);
    if (this.bassOsc) {
      try { this.bassOsc.stop(); } catch(e) {}
      this.bassOsc.disconnect();
      this.bassOsc = null;
    }
    if (this.bassFilter) {
      this.bassFilter.disconnect();
      this.bassFilter = null;
    }
    if (this.bassGain) {
      this.bassGain.disconnect();
      this.bassGain = null;
    }
  }
```

---

# 5. VOLUME AND MIXING

### Set Methods

```javascript
  setMasterVolume(value) {
    this._masterVol = Math.max(0, Math.min(1, value));
    if (this.masterGain) {
      this.masterGain.gain.setValueAtTime(this._masterVol, this.ctx.currentTime);
    }
  }
  
  setSFXVolume(value) {
    this._sfxVol = Math.max(0, Math.min(1, value));
    if (this.sfxGain) {
      this.sfxGain.gain.setValueAtTime(this._sfxVol, this.ctx.currentTime);
    }
  }
  
  setMusicVolume(value) {
    this._musicVol = Math.max(0, Math.min(1, value));
    if (this.musicGain) {
      this.musicGain.gain.setValueAtTime(this._musicVol, this.ctx.currentTime);
    }
  }
```

### Ducking System

When many SFX play simultaneously (e.g., during intense combat), the music volume automatically ducks (reduces) to keep audio clear. This is tracked by a counter.

```javascript
  // Called at start of every SFX play:
  _incrementSFXCount() {
    this.sfxCount++;
    if (this.sfxCount > 3 && this.duckingGain) {
      const targetGain = Math.max(0.2, 1.0 - (this.sfxCount - 3) * 0.15);
      this.duckingGain.gain.linearRampToValueAtTime(targetGain, this.ctx.currentTime + 0.05);
    }
    // Reset decay timer
    if (this.sfxDecayTimer) clearTimeout(this.sfxDecayTimer);
    this.sfxDecayTimer = setTimeout(() => this._decrementSFXCount(), 500);
  }
  
  _decrementSFXCount() {
    if (this.sfxCount > 0) this.sfxCount--;
    if (this.duckingGain) {
      if (this.sfxCount <= 3) {
        this.duckingGain.gain.linearRampToValueAtTime(1.0, this.ctx.currentTime + 0.1);
      } else {
        const targetGain = Math.max(0.2, 1.0 - (this.sfxCount - 3) * 0.15);
        this.duckingGain.gain.linearRampToValueAtTime(targetGain, this.ctx.currentTime + 0.1);
      }
    }
  }
```

### Mute/Unmute

```javascript
  mute() {
    if (!this.masterGain) return;
    this._preMuteVolume = this._masterVol;
    this.masterGain.gain.setValueAtTime(0, this.ctx.currentTime);
    this.muted = true;
  }
  
  unmute() {
    if (!this.masterGain) return;
    this.masterGain.gain.setValueAtTime(this._preMuteVolume, this.ctx.currentTime);
    this.muted = false;
  }
```

---

# 6. COMPLETE AudioManager CLASS (pseudo-code)

```javascript
class AudioManager {
  constructor() { /* as shown in §2 */ }
  
  // ── INITIALIZATION ────────────────────────
  init() { /* as shown in §2 */ }
  
  // Ensure AudioContext is running (call on first user gesture)
  resume() {
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }
  
  // ── SOUND PLAYBACK ────────────────────────
  playSound(name, params = {}) {
    if (!this.initialized) this.init();
    if (this.muted) return;
    this.resume(); // ensure context running
    
    const now = this.ctx.currentTime;
    this._incrementSFXCount();
    
    switch (name) {
      case 'PLAYER_SHOOT':    /* §3a */ break;
      case 'PLAYER_HIT':      /* §3b */ break;
      case 'ENEMY_SHOOT':     /* §3c */ break;
      case 'ENEMY_DEATH':     /* §3d */ break;
      case 'POWERUP_COLLECT': /* §3e */ break;
      case 'SHIELD_ACTIVATE': /* §3f */ break;
      case 'SHIELD_HIT':      /* §3g */ break;
      case 'COMBO_INCREASE':  /* §3h */ break;
      case 'BOSS_APPEAR':     /* §3i */ break;
      case 'BOSS_ATTACK':     /* §3j */ break;
      case 'MENU_SELECT':     /* §3k */ break;
      case 'MENU_CONFIRM':    /* §3l */ break;
      case 'NUKE':            /* §3m */ break;
      case 'GAME_OVER':       /* §3n */ break;
      case 'VICTORY':         /* §3o */ break;
    }
  }
  
  // ── MUSIC CONTROL ─────────────────────────
  setMusicIntensity(level) {
    this.savedLevel = level;
    this.currentLevel = level;
    if (this.bassGain) {
      const bassVol = 0.05 + level * 0.006; // 0.05 at lvl 1 → 0.08 at lvl 5
      this.bassGain.gain.setValueAtTime(bassVol, this.ctx.currentTime);
    }
  }
  
  startMusic()           { /* §4 */ }
  stopMusic()            { /* §4 */ }
  startBossMusic()       { /* §4 */ }
  stopBossMusic()        { /* §4 */ }
  
  // ── VOLUME CONTROL ────────────────────────
  setMasterVolume(value) { /* §5 */ }
  setSFXVolume(value)    { /* §5 */ }
  setMusicVolume(value)  { /* §5 */ }
  mute()                 { /* §5 */ }
  unmute()               { /* §5 */ }
  
  // ── HELPERS ───────────────────────────────
  createEnvelope(now, gainNode, attack, hold, decay, peakLevel = 0.5) { /* §3 */ }
  
  makeDistortionCurve(amount = 50) {
    const samples = 256;
    const curve = new Float32Array(samples);
    for (let i = 0; i < samples; i++) {
      const x = (i * 2) / samples - 1;
      curve[i] = ((Math.PI + amount) * x) / (Math.PI + amount * Math.abs(x));
    }
    return curve;
  }
  
  // ── SFX COUNT (for ducking) ───────────────
  _incrementSFXCount()   { /* §5 */ }
  _decrementSFXCount()   { /* §5 */ }
  
  // ── CLEANUP ───────────────────────────────
  dispose() {
    this.stopMusic();
    if (this.ctx) {
      this.ctx.close();
      this.ctx = null;
    }
    this.initialized = false;
  }
}
```

---

# 7. BROWSER AUTOPLAY POLICY HANDLING

```javascript
// In the HTML entry point / main.js:
let audioManager;

document.addEventListener('click', function initAudio() {
  if (!audioManager) audioManager = new AudioManager();
  audioManager.init();
  audioManager.resume();
  document.removeEventListener('click', initAudio);
}, { once: true });

document.addEventListener('keydown', function initAudioKey() {
  if (!audioManager) audioManager = new AudioManager();
  audioManager.init();
  audioManager.resume();
  document.removeEventListener('keydown', initAudioKey);
}, { once: true });
```

---

# 8. SOUND LIST SUMMARY (for game designer / engineers)

| Key              | Duration | Description                  | Category   |
|------------------|----------|------------------------------|------------|
| PLAYER_SHOOT     | 0.05s    | Laser blip, 800→400Hz sweep | Player     |
| PLAYER_HIT       | 0.10s    | Thud + noise burst           | Player     |
| ENEMY_SHOOT      | 0.07s    | Sawtooth 400→200Hz          | Enemy      |
| ENEMY_DEATH      | 0.15s    | Noise explosion + reverb    | Enemy      |
| POWERUP_COLLECT  | 0.09s    | Rising C-E-G arpeggio       | Pickup     |
| SHIELD_ACTIVATE  | 0.20s    | Filtered noise whoosh       | Player     |
| SHIELD_HIT       | 0.05s    | Metallic ping, ring mod     | Player     |
| COMBO_INCREASE   | 0.08s    | Ascending ding              | UI/Score   |
| BOSS_APPEAR      | 0.50s    | Deep rumble, ominous        | Boss       |
| BOSS_ATTACK      | 0.20s    | Heavy distorted impact      | Boss       |
| MENU_SELECT      | 0.03s    | Soft triangle blip          | UI         |
| MENU_CONFIRM     | 0.05s    | Confirmation sine tone      | UI         |
| NUKE             | 0.30s    | Sweep + noise + reverb      | Power-up   |
| GAME_OVER        | 1.00s    | Descending sad tones        | Game State |
| VICTORY          | 1.50s    | Rising triumphant arpeggio  | Game State |

---

# 9. INTEGRATION NOTES FOR OTHER TEAMMATES

- **game-designer**: Reference sounds by the key names above when defining game events.
- **ui-engineer**: `MENU_SELECT` and `MENU_CONFIRM` are the UI sounds. Call `audioManager.playSound('MENU_SELECT')` on hover/select, `audioManager.playSound('MENU_CONFIRM')` on enter/click.
- **physics-engineer**: When collisions are detected, call appropriate sound. Enemy death → `ENEMY_DEATH`, player hit → `PLAYER_HIT`, powerup collect → `POWERUP_COLLECT`, shield hit → `SHIELD_HIT`.
- **ai-engineer**: Boss spawn → `BOSS_APPEAR`, boss attack → `BOSS_ATTACK`, enemy shoot → `ENEMY_SHOOT`. Call `audioManager.setMusicIntensity(level)` on level change, `audioManager.startBossMusic()` / `stopBossMusic()` for boss encounters.
- **rendering-engineer**: No direct dependency, but nuke screen flash could sync with `NUKE` sound timing (0.3s duration).
- All teammates: Call `audioManager.playSound('PLAYER_SHOOT')` with optional `params` for variations.

---

END OF AUDIO SYSTEM SPEC
