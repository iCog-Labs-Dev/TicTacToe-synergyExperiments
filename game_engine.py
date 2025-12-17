import random
import math

# Constants
X_MARK = "X"
O_MARK = "O"
EMPTY = "E"


class Board:
    def __init__(self, state=None):
        self.state = state if state else [EMPTY] * 9

    def copy(self):
        return Board(self.state.copy())

    def get_valid_moves(self):
        return [i for i, mark in enumerate(self.state) if mark == EMPTY]

    def make_move(self, index, mark):
        self.state[index] = mark

    def is_full(self):
        return EMPTY not in self.state

    def to_string(self):
        s = self.state
        return f"{s[0]} {s[1]} {s[2]}\n{s[3]} {s[4]} {s[5]}\n{s[6]} {s[7]} {s[8]}"


class HammingScorer:
    """Calculates how close a player is to winning."""

    WIN_LINES = [
        (0, 1, 2),
        (3, 4, 5),
        (6, 7, 8),  # Rows
        (0, 3, 6),
        (1, 4, 7),
        (2, 5, 8),  # Cols
        (0, 4, 8),
        (2, 4, 6),  # Diagonals
    ]

    @staticmethod
    def get_distance_to_win(board, player):
        """
        Returns the minimum moves needed to win.
        0 = Already Won
        1 = 2 in a row (open)
        ...
        99 = Blocked / Impossible
        """
        opponent = O_MARK if player == X_MARK else X_MARK
        min_dist = 99

        for line in HammingScorer.WIN_LINES:
            marks = [board.state[i] for i in line]
            if opponent in marks:
                continue  # Blocked line

            # Distance is number of empty spots
            dist = marks.count(EMPTY)
            if dist < min_dist:
                min_dist = dist

        return min_dist

    @staticmethod
    def check_winner(board):
        """Returns X_MARK, O_MARK, or None."""
        for line in HammingScorer.WIN_LINES:
            a, b, c = line
            if (
                board.state[a] != EMPTY
                and board.state[a] == board.state[b] == board.state[c]
            ):
                return board.state[a]
        return None


class GameActions:
    """
    The primitive actions available to the GP.
    Each action returns (Success: bool, ResultingBoard: Board).
    If success is False, the Board is returned unchanged.
    """

    # Toggle to enable/disable smart move selection in play_corners/play_sides
    enable_heuristics = True

    @staticmethod
    def _pick_best_move(board, candidate_indices, player):
        """
        Helper: From a list of indices, pick the ones that result in the
        lowest Hamming Distance to Win for 'player'. Tie-break randomly.
        """
        valid_candidates = [i for i in candidate_indices if board.state[i] == EMPTY]

        if not valid_candidates:
            return None

        scored_moves = []
        for move in valid_candidates:
            # Simulate
            temp_board = board.copy()
            temp_board.make_move(move, player)
            dist = HammingScorer.get_distance_to_win(temp_board, player)
            scored_moves.append((dist, move))

        # Sort by distance (ascending)
        scored_moves.sort(key=lambda x: x[0])

        # Filter for ties (all moves with the best score)
        best_score = scored_moves[0][0]
        best_moves = [m for s, m in scored_moves if s == best_score]

        return random.choice(best_moves)

    @staticmethod
    def play_center(board, player):
        """Try to play center (Index 4)."""
        if board.state[4] == EMPTY:
            new_board = board.copy()
            new_board.make_move(4, player)
            return True, new_board
        return False, board

    @staticmethod
    def play_corners(board, player):
        """Try to play corners (0, 2, 6, 8). Uses heuristics if enabled."""
        corners = [0, 2, 6, 8]

        move = None
        if GameActions.enable_heuristics:
            move = GameActions._pick_best_move(board, corners, player)
        else:
            valid_corners = [i for i in corners if board.state[i] == EMPTY]
            if valid_corners:
                move = random.choice(valid_corners)

        if move is not None:
            new_board = board.copy()
            new_board.make_move(move, player)
            return True, new_board
        return False, board

    @staticmethod
    def play_sides(board, player):
        """Try to play sides (1, 3, 5, 7). Uses heuristics if enabled."""
        sides = [1, 3, 5, 7]

        move = None
        if GameActions.enable_heuristics:
            move = GameActions._pick_best_move(board, sides, player)
        else:
            valid_sides = [i for i in sides if board.state[i] == EMPTY]
            if valid_sides:
                move = random.choice(valid_sides)

        if move is not None:
            new_board = board.copy()
            new_board.make_move(move, player)
            return True, new_board
        return False, board

    @staticmethod
    def play_win(board, player):
        """Only play if it results in an immediate win."""
        # Check all valid moves. If any has dist=0, take it.
        all_moves = board.get_valid_moves()
        for move in all_moves:
            temp_board = board.copy()
            temp_board.make_move(move, player)
            if HammingScorer.check_winner(temp_board) == player:
                return True, temp_board
        return False, board

    @staticmethod
    def play_block(board, player):
        """Only play if it blocks an opponent's immediate win."""
        opponent = O_MARK if player == X_MARK else X_MARK
        all_moves = board.get_valid_moves()

        # Look for a move where, if the opponent played there, they would win.
        blocking_moves = []
        for move in all_moves:
            temp_board = board.copy()
            temp_board.make_move(move, opponent)  # Simulate Opponent move
            if HammingScorer.check_winner(temp_board) == opponent:
                blocking_moves.append(move)

        if blocking_moves:
            # Pick random if multiple blocks exist (though usually 1)
            move = random.choice(blocking_moves)
            new_board = board.copy()
            new_board.make_move(move, player)
            return True, new_board

        return False, board


# Mapping for GP use
ACTION_MAP = {
    "CENTER": GameActions.play_center,
    "CORNERS": GameActions.play_corners,
    "SIDES": GameActions.play_sides,
    "WIN": GameActions.play_win,
    "BLOCK": GameActions.play_block,
}


class Opponent:
    def get_move(self, board, my_mark):
        raise NotImplementedError


class RandomOpponent(Opponent):
    def get_move(self, board, my_mark):
        valid = board.get_valid_moves()
        return random.choice(valid) if valid else None


class MinimaxOpponent(Opponent):
    def __init__(self, depth):
        self.max_depth = depth

    def get_move(self, board, my_mark):
        best_score = -math.inf
        best_move = None
        opponent_mark = O_MARK if my_mark == X_MARK else X_MARK

        valid = board.get_valid_moves()
        if not valid:
            return None

        # Optimization: If only 1 move, take it (skip search)
        if len(valid) == 1:
            return valid[0]

        for move in valid:
            sim_board = board.copy()
            sim_board.make_move(move, my_mark)
            score = self.minimax(sim_board, 0, False, my_mark, opponent_mark)
            if score > best_score:
                best_score = score
                best_move = move
        return best_move

    def minimax(self, board, depth, is_maximizing, player_mark, opp_mark):
        winner = HammingScorer.check_winner(board)
        if winner == player_mark:
            return 10 - depth
        if winner == opp_mark:
            return depth - 10
        if board.is_full() or depth >= self.max_depth:
            return 0

        valid = board.get_valid_moves()

        if is_maximizing:
            max_eval = -math.inf
            for move in valid:
                sim_board = board.copy()
                sim_board.make_move(move, player_mark)
                eval = self.minimax(sim_board, depth + 1, False, player_mark, opp_mark)
                max_eval = max(max_eval, eval)
            return max_eval
        else:
            min_eval = math.inf
            for move in valid:
                sim_board = board.copy()
                sim_board.make_move(move, opp_mark)
                eval = self.minimax(sim_board, depth + 1, True, player_mark, opp_mark)
                min_eval = min(min_eval, eval)
            return min_eval
