let gameState;
let aiThinking = false;

const boardEl = document.getElementById('board');
const statusEl = document.getElementById('status');
const resultOverlay = document.getElementById('result-overlay');
const resultMessage = document.getElementById('result-message');
const modePvpBtn = document.getElementById('mode-pvp');
const modePveBtn = document.getElementById('mode-pve');
const resetBtn = document.getElementById('reset');
const playAgainBtn = document.getElementById('play-again');
const cells = document.querySelectorAll('.cell');

function startGame(mode) {
  gameState = createGame(mode);
  aiThinking = false;
  updateModeButtons(mode);
  renderState();
  resultOverlay.classList.add('hidden');
}

function updateModeButtons(mode) {
  modePvpBtn.classList.toggle('active', mode === 'pvp');
  modePveBtn.classList.toggle('active', mode === 'pve');
}

function onCellClick(index) {
  if (aiThinking) return;
  if (gameState.board[index] !== null) return;
  if (gameState.status !== 'playing') return;

  gameState = makeMove(gameState, index);
  renderState();

  if (gameState.status !== 'playing') {
    showResult();
    return;
  }

  if (gameState.mode === 'pve' && gameState.currentPlayer === 'O') {
    aiThinking = true;
    setTimeout(() => {
      const bestMove = getBestMove(gameState);
      if (bestMove !== null) {
        gameState = makeMove(gameState, bestMove);
        renderState();
        if (gameState.status !== 'playing') {
          showResult();
        }
      }
      aiThinking = false;
    }, 300);
  }
}

function renderState() {
  cells.forEach((cell, i) => {
    const val = gameState.board[i];
    cell.textContent = val || '';
    cell.className = 'cell';
    if (val) {
      cell.classList.add('taken', val);
    }
  });

  if (gameState.winningLine) {
    for (const idx of gameState.winningLine) {
      cells[idx].classList.add('win');
    }
  }

  if (gameState.status === 'playing') {
    statusEl.textContent = gameState.currentPlayer + "'s turn";
  } else if (gameState.status === 'won') {
    statusEl.textContent = gameState.winner + ' wins!';
  } else if (gameState.status === 'draw') {
    statusEl.textContent = "It's a draw!";
  }
}

function showResult() {
  if (gameState.status === 'won') {
    resultMessage.textContent = gameState.winner + ' wins!';
  } else if (gameState.status === 'draw') {
    resultMessage.textContent = "It's a draw!";
  }
  resultOverlay.classList.remove('hidden');
}

function resetGame() {
  startGame(gameState.mode);
}

boardEl.addEventListener('click', function (e) {
  const cell = e.target.closest('.cell');
  if (!cell) return;
  const index = parseInt(cell.getAttribute('data-index'), 10);
  onCellClick(index);
});

modePvpBtn.addEventListener('click', function () {
  startGame('pvp');
});

modePveBtn.addEventListener('click', function () {
  startGame('pve');
});

resetBtn.addEventListener('click', resetGame);

playAgainBtn.addEventListener('click', function () {
  resultOverlay.classList.add('hidden');
  startGame(gameState.mode);
});

startGame('pvp');
