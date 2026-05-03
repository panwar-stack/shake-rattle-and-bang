const WIN_LINES = [
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  [0, 3, 6],
  [1, 4, 7],
  [2, 5, 8],
  [0, 4, 8],
  [2, 4, 6],
];

function createGame(mode) {
  return {
    board: [null, null, null, null, null, null, null, null, null],
    currentPlayer: 'X',
    status: 'playing',
    winner: null,
    winningLine: null,
    mode: mode,
    moves: 0,
  };
}

function makeMove(state, index) {
  if (state.status !== 'playing') return state;
  if (state.board[index] !== null) return state;

  const newBoard = state.board.slice();
  newBoard[index] = state.currentPlayer;

  const newState = {
    board: newBoard,
    currentPlayer: state.currentPlayer,
    status: 'playing',
    winner: null,
    winningLine: null,
    mode: state.mode,
    moves: state.moves + 1,
  };

  for (const line of WIN_LINES) {
    const [a, b, c] = line;
    if (
      newBoard[a] !== null &&
      newBoard[a] === newBoard[b] &&
      newBoard[a] === newBoard[c]
    ) {
      newState.status = 'won';
      newState.winner = newBoard[a];
      newState.winningLine = line;
      return newState;
    }
  }

  if (newState.moves === 9) {
    newState.status = 'draw';
  } else {
    newState.currentPlayer = state.currentPlayer === 'X' ? 'O' : 'X';
  }

  return newState;
}

function getAvailableMoves(state) {
  const moves = [];
  for (let i = 0; i < state.board.length; i++) {
    if (state.board[i] === null) moves.push(i);
  }
  return moves;
}

function getCurrentPlayer(state) {
  return state.currentPlayer;
}

function getGameStatus(state) {
  return state.status;
}

function checkWinner(state) {
  return state.winner;
}

function getWinningLine(state) {
  return state.winningLine;
}

function isDraw(state) {
  return state.moves === 9 && state.winner === null;
}
