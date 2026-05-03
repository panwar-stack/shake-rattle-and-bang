function getBestMove(state) {
  let bestScore = -Infinity;
  let bestMove = null;

  const availableMoves = getAvailableMoves(state);
  for (const move of availableMoves) {
    const newState = makeMove(state, move);
    const result = minimax(newState, 0, false);
    if (result.score > bestScore) {
      bestScore = result.score;
      bestMove = move;
    }
  }

  return bestMove;
}

function minimax(state, depth, isMaximizing) {
  if (state.status === 'won') {
    if (state.winner === 'O') return { score: 10 - depth };
    return { score: depth - 10 };
  }
  if (state.status === 'draw') return { score: 0 };

  const availableMoves = getAvailableMoves(state);

  if (isMaximizing) {
    let bestScore = -Infinity;
    for (const move of availableMoves) {
      const newState = makeMove(state, move);
      const result = minimax(newState, depth + 1, false);
      bestScore = Math.max(bestScore, result.score);
    }
    return { score: bestScore };
  } else {
    let bestScore = Infinity;
    for (const move of availableMoves) {
      const newState = makeMove(state, move);
      const result = minimax(newState, depth + 1, true);
      bestScore = Math.min(bestScore, result.score);
    }
    return { score: bestScore };
  }
}
