import random
import math, os
import atexit
from datetime import datetime


# Constants
X_MARK = "X"
O_MARK = "O"
EMPTY = "E"


class Board:
    def __init__(self, state=None):
        if isinstance(state, str):
            # Parse string format: "(Board (X E ...))" or just raw string
            cleaned = state.replace("(Board (", "").replace("))", "")
            self.state = cleaned.split()
            if len(self.state) != 9:
                raise ValueError("Invalid board string format. Must have 9 elements.")
        elif isinstance(state, list):
            # Check for nested format ['Board', [...]]
            if len(state) == 2 and state[0] == "Board" and isinstance(state[1], list):
                self.state = state[1]
            else:
                # Assume flat list ['X', 'E', ...]
                self.state = state
        elif state is None:
            self.state = [EMPTY] * 9
        else:
            raise ValueError("State must be a list or a string representation.")

    @classmethod
    def from_string(cls, board_str: str):
        """
        Parses string like:
        (Board (
          X E E
          ...
        ))
        into a Board object. Kept for backward compatibility.
        """
        return cls(board_str)

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

        # formatting for display
        def fmt(x):
            return " " if x == EMPTY else x

        return f" {fmt(s[0])} | {fmt(s[1])} | {fmt(s[2])} \n---+---+---\n {fmt(s[3])} | {fmt(s[4])} | {fmt(s[5])} \n---+---+---\n {fmt(s[6])} | {fmt(s[7])} | {fmt(s[8])} "

    def to_linear_string(self):
        """Returns the board in (Board (X E ...)) format for S-Expressions."""
        return f"(Board ({' '.join(self.state)}))"
    def __str__(self):
        return f"(Loadable {self.to_linear_string()})"

def to_string(board: Board):
    return board.to_string()


def to_linear_string(board: Board):
    return board.to_linear_string()


def make_move(board: Board, index, mark):
    board.make_move(int(index), mark)
    return board


def get_diff_index(board_a, board_b):
    """
    Returns the zero-based index where two boards differ.
    Useful for identifying which move was made.
    Returns None if boards are identical.
    """
    # Normalize inputs to ensure we have access to .state
    b1 = board_a if isinstance(board_a, Board) else Board(board_a)
    b2 = board_b if isinstance(board_b, Board) else Board(board_b)

    for i in range(9):
        if b1.state[i] != b2.state[i]:
            return i


def is_valid(board, move):
    if int(move) in board.get_valid_moves():
        return move
    return None


def save_board(board: Board):
    filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}.metta"
    with open(filename, "w") as f:
        f.write(f"(Loadable {board.to_linear_string()})")
    return filename


def remove_file(filename: str):
    import os

    if os.path.isfile(filename):
        os.remove(filename)
    else:
        print(f"{filename} does not exist")


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


def check_winner(board):
    return HammingScorer.check_winner(board)


def is_full(board):
    return 1 if board.is_full() else 0


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

        # --- HEURISTIC TOGGLE ---
        if not GameActions.enable_heuristics:
            return random.choice(valid_candidates)

        # --- SMART LOGIC ---
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
        move = GameActions._pick_best_move(board, [4], player)
        if move is not None:
            new_board = board.copy()
            new_board.make_move(move, player)
            return True, new_board
        return False, board

    @staticmethod
    def play_corners(board, player):
        """Try to play corners (0, 2, 6, 8). Uses heuristics if enabled."""
        corners = [0, 2, 6, 8]
        move = GameActions._pick_best_move(board, corners, player)
        if move is not None:
            new_board = board.copy()
            new_board.make_move(move, player)
            return True, new_board
        return False, board

    @staticmethod
    def play_sides(board, player):
        """Try to play sides (1, 3, 5, 7). Uses heuristics if enabled."""
        sides = [1, 3, 5, 7]
        move = GameActions._pick_best_move(board, sides, player)
        if move is not None:
            new_board = board.copy()
            new_board.make_move(move, player)
            return True, new_board
        return False, board

    @staticmethod
    def play_win(board, player):
        """
        Only play if it results in an immediate win.
        Respects heuristic toggle: if disabled, it cannot 'see' the win.
        """
        if not GameActions.enable_heuristics:
            return False, board

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
        """
        Only play if it blocks an opponent's immediate win.
        """
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

    @staticmethod
    def play_random(board, player):
        """
        Only used when no other move is generated
        """
        all_moves = board.get_valid_moves()

        # Pick random if multiple blocks exist (though usually 1)
        move = random.choice(all_moves)
        new_board = board.copy()
        new_board.make_move(move, player)
        return True, new_board


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


def save_policy_to_file(policy_actions, generation, fitness, player_mark):
    """
    Generates a Python file representing the policy logic.
    filename format: gen_{generation}_score_{fitness:.2f}_{player_mark}.py
    """
    # Create a safe filename with score formatted to 2 decimals
    filename = f"gen_{generation}_score_{fitness:.2f}_{player_mark}.py"

    with open(filename, "w") as f:
        f.write("from game_engine import GameActions, Board, X_MARK, O_MARK\n\n")
        f.write(f"# Generation: {generation}\n")
        f.write(f"# Fitness: {fitness}\n")
        f.write(f"# Player: {player_mark}\n\n")

        f.write("def run_policy(board, player_mark):\n")

        for action_key in policy_actions:
            if action_key in ACTION_MAP:
                # Use the function name from the action mapping to generate code
                func_name = ACTION_MAP[action_key].__name__
                f.write(f"    # Try {action_key}\n")
                f.write(
                    f"    success, new_board = GameActions.{func_name}(board, player_mark)\n"
                )
                f.write(f"    if success:\n")
                f.write(f"        return new_board\n\n")

        f.write("    return None\n")

    # print(f"Policy code saved to {filename}")


def play_terminal_game(opponent_policy_func):
    """
    Runs a terminal-based game loop against a provided policy function.
    opponent_policy_func: function(board, player_mark) -> new_board (or None)
    """
    print("\n--- Tic-Tac-Toe Terminal Arena ---")
    human_mark = input("Choose your mark (X/O): ").upper()
    while human_mark not in [X_MARK, O_MARK]:
        human_mark = input("Invalid. Choose X or O: ").upper()

    ai_mark = O_MARK if human_mark == X_MARK else X_MARK
    print(f"You are {human_mark}. AI is {ai_mark}.")
    print("Board positions are 0-8:")
    print(" 0 | 1 | 2 \n---+---+---\n 3 | 4 | 5 \n---+---+---\n 6 | 7 | 8 ")

    board = Board()
    current_turn = X_MARK

    while True:
        print(f"\nCurrent Board:\n{board.to_string()}")
        winner = HammingScorer.check_winner(board)
        if winner:
            print(f"Game Over! Winner: {winner}")
            break
        if board.is_full():
            print("Game Over! It's a Draw.")
            break

        if current_turn == human_mark:
            while True:
                try:
                    move_input = input(f"Your move ({human_mark}) [0-8]: ")
                    if not move_input.strip():
                        continue  # handle empty enter
                    move = int(move_input)
                    if move in board.get_valid_moves():
                        board.make_move(move, human_mark)
                        break
                    else:
                        print("Invalid move. Try again.")
                except ValueError:
                    print("Please enter a number 0-8.")
        else:
            print(f"AI ({ai_mark}) is thinking...")
            new_board = opponent_policy_func(board, ai_mark)
            if new_board:
                board = new_board
            else:
                print("AI resigned (No move found). You win!")
                break

        current_turn = O_MARK if current_turn == X_MARK else X_MARK


def simulate_game_dynamics(
    board,
    policy_actions,
    depth,
    player,
    filename="policies.metta",
    _current_depth=0,
    game_id=1,
    _path=(),
):
    """
    Simulates game dynamics for a given policy and depth, saving transitions to a file.

    Args:
        board (Board or str or list): Current board state.
        policy_actions (list): List of action strings (e.g. ['WIN', 'CENTER']).
        depth (int): Max number of plies (turns) to simulate.
        player (str): Current player to move.
        filename (str): Output file.
        _current_depth (int): Internal recursion tracker.
        game_id (int): ID for the simulation set.
        _path (tuple): Tuple of indices for the current branch.
    """

    # Ensure board is a Board object (Check for Board class, not just str)
    if not isinstance(board, Board):
        board = Board(board)

    # Stop conditions
    winner = HammingScorer.check_winner(board)
    if winner or board.is_full() or _current_depth >= depth:
        return

    prev_state_str = board.to_linear_string()

    # 1. Execute Move Logic
    next_boards = []  # List of (board, move_desc)

    # Check whose turn it actually is on the board
    x_count = board.state.count(X_MARK)
    o_count = board.state.count(O_MARK)
    current_turn_mark = X_MARK if x_count == o_count else O_MARK

    if current_turn_mark == player:
        # --- POLICY TURN ---
        # Execute policy to get ONE deterministic move
        moved = False
        for action in policy_actions:
            if action in ACTION_MAP:
                success, new_board = ACTION_MAP[action](board, player)
                if success:
                    next_boards.append(new_board)
                    moved = True
                    break  # Policy picks first success

        if not moved:
            success, new_board = GameActions.play_random(board, player)
            next_boards.append(new_board)
            moved = True

    else:
        # --- OPPONENT TURN ---
        # Exhaustive simulation of all valid moves
        valid_moves = board.get_valid_moves()
        for move in valid_moves:
            new_board = board.copy()
            new_board.make_move(move, current_turn_mark)
            next_boards.append(new_board)

    # 2. Save Transitions and Recurse
    with open(filename, "a") as f:
        for i, nb in enumerate(next_boards):
            next_state_str = nb.to_linear_string()

            # Construct Unique ID: (GameID Turn PathTuple)
            new_path = _path + (i,)
            path_str = "".join(map(str, new_path))
            id_str = f"({game_id}{_current_depth + 1}{path_str})"

            # Requested Format: (Sentence ((Implication PRE POST) (stv ...)) ID)
            line = f"(Sentence ((Implication {prev_state_str} {next_state_str}) (stv 0.5 0.3)) {id_str})\n"
            f.write(line)

            # Recurse
            simulate_game_dynamics(
                nb,
                policy_actions,
                depth,
                player,
                filename,
                _current_depth + 1,
                game_id,
                new_path,
            )
