import math
import unittest
import random
from typing import List, Tuple, Optional, Dict

# Constants for readability
X_MARK = "X"
O_MARK = "O"
EMPTY = "E"
INFINITY = float("inf")


class Board:
    """
    Represents the Tic-Tac-Toe board state.
    Format:
    (Board (
      X E E
      E E E
      E E E
    ))
    where indices are 0-8.
    """

    def __init__(self, state: List[str]):
        self.state = state

    @classmethod
    def from_string(cls, board_str: str):
        """
        Parses string like:
        (Board (
          X E E
          ...
        ))
        into a Board object.
        """
        # Clean string: remove '(Board (', '))', and split by spaces/newlines
        cleaned = board_str.replace("(Board (", "").replace("))", "")
        elements = cleaned.split()
        if len(elements) != 9:
            raise ValueError("Invalid board string format. Must have 9 elements.")
        return cls(elements)

    def to_string(self) -> str:
        """Returns the specific Lisp-like string format requested, in a 3x3 grid."""
        s = self.state
        return (
            f"(Board (\n"
            f"  {s[0]} {s[1]} {s[2]}\n"
            f"  {s[3]} {s[4]} {s[5]}\n"
            f"  {s[6]} {s[7]} {s[8]}\n"
            f"))"
        )

    def to_linear_string(self) -> str:
        """Returns the board representation as a single line string."""
        return f"(Board ({' '.join(self.state)}))"

    def __str__(self):
        return self.to_string()

    def get_valid_moves(self) -> List[int]:
        """Returns a list of indices (0-8) that are EMPTY."""
        return [i for i, mark in enumerate(self.state) if mark == EMPTY]

    def make_move(self, index: int, mark: str) -> "Board":
        """Returns a NEW Board instance with the move applied."""
        new_state = self.state.copy()
        new_state[index] = mark
        return Board(new_state)

    def is_full(self) -> bool:
        return EMPTY not in self.state


class HammingScorer:
    """
    Evaluates board states based on their Hamming Distance to a winning configuration.
    """

    WINNING_INDICES = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],  # Rows
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],  # Cols
        [0, 4, 8],
        [2, 4, 6],  # Diagonals
    ]

    @staticmethod
    def get_winning_configs(player_mark: str) -> List[Tuple[List[str], List[int]]]:
        """
        Returns a list of (winning_state_list, indices) for the given player.
        This represents the 8 ideal winning states.
        """
        configs = []
        for indices in HammingScorer.WINNING_INDICES:
            # Create a theoretical board that is just this winning line
            configs.append((player_mark, indices))
        return configs

    @staticmethod
    def get_winner(board: Board) -> Optional[str]:
        """
        Checks if there is a winner on the board.
        Returns X_MARK, O_MARK, or None.
        """
        for indices in HammingScorer.WINNING_INDICES:
            marks = [board.state[i] for i in indices]
            # Check if all marks in this line are the same and not EMPTY
            if marks[0] != EMPTY and all(m == marks[0] for m in marks):
                return marks[0]
        return None

    @staticmethod
    def calculate_distance(
        board: Board, player_mark: str
    ) -> Tuple[float, List[Tuple[float, str]]]:
        """
        Steps 1-5 of the requirements:
        Calculates distance to all 8 winning states.
        Returns: (best_score, sorted_list_of_configs)
        """
        opponent = O_MARK if player_mark == X_MARK else X_MARK
        results = []

        for indices in HammingScorer.WINNING_INDICES:
            current_dist = 0
            is_blocked = False

            # Construct what this winning line looks like
            for idx in indices:
                cell = board.state[idx]
                if cell == opponent:
                    # If opponent is in the line, we can NEVER reach this winning state
                    # without breaking rules. Distance is Infinite.
                    is_blocked = True
                    break
                elif cell == EMPTY:
                    # We need to change this E to X. That is 1 unit of "Change" (Distance)
                    current_dist += 1
                elif cell == player_mark:
                    # Already matches. Distance is 0 for this cell.
                    pass

            if is_blocked:
                dist = INFINITY
                config_str = "BLOCKED"
            else:
                dist = current_dist
                config_str = f"Win on line {indices}"

            results.append((dist, config_str))

        # Sort by distance (ascending)
        results.sort(key=lambda x: x[0])

        # The score is the distance of the BEST config (Top of list)
        best_score = results[0][0]

        return best_score, results


class PolicyNode:
    """
    Represents a node in the Policy Tree.
    Contains the board state, score, and children (next possible moves).
    """

    def __init__(
        self, board: Board, score: float, player: str, description: str = "Root"
    ):
        self.board = board
        self.score = score
        self.player = player
        self.description = description
        self.children: Dict[int, "PolicyNode"] = {}  # Maps move_index -> PolicyNode

    def add_child(self, move_index: int, node: "PolicyNode"):
        self.children[move_index] = node

    def to_s_expressions(
        self, level: int = 0, parent_path: Tuple[int, ...] = ()
    ) -> List[Tuple[Tuple[int, Tuple[int, ...]], str]]:
        """
        Helper function to convert the policy tree into a list of S-expressions.
        Format: "(Implication (Board precondition) (Board postcondition))"

        Returns a list of tuples: ((level, path_tuple), s_expression_string)
        where path_tuple identifies the unique branch taken to reach this node.
        """
        expressions = []

        # Sort children by move index to ensure consistent ordering for option_index
        sorted_moves = sorted(self.children.keys())

        # Pass 1: Generate all immediate implications for this node (Grouped together)
        for option_idx, move in enumerate(sorted_moves):
            child = self.children[move]

            # Construct the S-expression using LINEAR string (unformatted)
            precondition = self.board.to_linear_string()
            postcondition = child.board.to_linear_string()

            expression = f"(Implication {precondition} {postcondition})"

            # Create a path tuple that accumulates choices
            current_path = parent_path + (option_idx,)

            # Assign index (level, current_path)
            index_tuple = (level, current_path)

            expressions.append((index_tuple, expression))

        # Pass 2: Recurse into children
        for option_idx, move in enumerate(sorted_moves):
            child = self.children[move]
            current_path = parent_path + (option_idx,)
            expressions.extend(child.to_s_expressions(level + 1, current_path))

        return expressions

    def save_s_expressions_to_file(self, filename: str, candidate_id: int = 1):
        """
        Saves S-expressions formatted as:
        (Sentence (Implication PRE POST) (Candidate Level (OptionPath)))

        Where:
        - Implication PRE POST: The raw logic rule.
        - Candidate: The ID of this candidate policy (default 1).
        - Level: The turn count (1-based index).
        - OptionPath: A tuple indicating the path of choices from the root (e.g. (0 1)).
        """
        s_exprs = self.to_s_expressions()
        previous_level = None

        with open(filename, "w") as f:
            for (level, path), expr in s_exprs:
                # Level + 1 because the internal level starts at 0, but turns start at 1.
                turn_level = level + 1

                # Add a blank line if the level group changes
                if previous_level is not None and turn_level != previous_level:
                    f.write("\n")

                previous_level = turn_level

                # Format path tuple as a space-separated list for S-expr: (0 1 2)
                path_str = " ".join(map(str, path))

                formatted = (
                    f"(Sentence {expr} ({candidate_id} {turn_level} ({path_str})))"
                )
                f.write(f"{formatted}\n")

    def __str__(self, level=0):
        indent = "  " * level
        # We need to indent the multiline board string correctly
        board_str = self.board.to_string().replace("\n", f"\n{indent}")
        ret = f"{indent}{self.description} | Score (Dist to Win): {self.score} | {board_str}\n"
        for move, child in self.children.items():
            ret += f"{indent}  -> Move {move}:\n"
            ret += child.__str__(level + 2)
        return ret


class PolicyGenerator:
    """
    Generates the game play policy.
    """

    def __init__(self, max_depth=2):
        self.max_depth = max_depth

    def generate(self, board: Board, current_player: str, depth=0) -> PolicyNode:
        # 1. Global Game Over Check (Fix for generating moves after game ends)
        winner = HammingScorer.get_winner(board)
        if winner:
            # If there is a winner, the game is over. No valid moves.
            # Score logic:
            # If I (current_player) won: Score is 0 (Good).
            # If Opponent won: Score is INFINITY (Bad).

            score = 0 if winner == current_player else INFINITY
            node_desc = f"Game Over - {winner} Won"

            node = PolicyNode(board, score, current_player, node_desc)
            node.description += " [Leaf]"
            return node

        # 2. Standard Scoring and Generation
        score, _ = HammingScorer.calculate_distance(board, current_player)

        node_desc = (
            f"Player {current_player}'s Turn"
            if depth % 2 == 0
            else f"Opponent {current_player}'s Turn"
        )
        node = PolicyNode(board, score, current_player, node_desc)

        # Stop if score is 0 (I won on this board state, captured by get_winner mostly, but safe to keep)
        # or full or depth limit
        if score == 0 or board.is_full() or depth >= self.max_depth:
            node.description += " [Leaf]"
            return node

        valid_moves = board.get_valid_moves()
        candidates = []

        # Analyze all potential next moves
        for move in valid_moves:
            next_board = board.make_move(move, current_player)
            # We score the next board based on the PLAYER who made the move
            # (How much closer did this move get me to winning?)
            next_score, _ = HammingScorer.calculate_distance(next_board, current_player)
            candidates.append((next_score, move, next_board))

        next_player = O_MARK if current_player == X_MARK else X_MARK

        # Helper to process move selection and recursion
        def process_moves(move_list):
            for next_score_val, move_idx, next_b in move_list:
                # Check for Immediate Win in the candidate analysis
                # (This is an optimization to label nodes early)
                if next_score_val == 0:
                    term_node = PolicyNode(
                        next_b,
                        INFINITY,
                        next_player,
                        f"Game Over - {current_player} Won",
                    )
                    node.add_child(move_idx, term_node)
                else:
                    # Recurse normally
                    child_node = self.generate(next_b, next_player, depth + 1)
                    node.add_child(move_idx, child_node)

        # STRATEGY SELECTION
        if depth % 2 == 0:
            # === MY TURN (The Candidate Policy) ===
            # Pick the Top 1 best move (Lowest Hamming Distance)
            candidates.sort(key=lambda x: x[0])  # Ascending sort

            if not candidates:
                return node

            best_score = candidates[0][0]
            best_moves = [c for c in candidates if c[0] == best_score]

            # Select strictly one randomly from the best options
            chosen_candidate = random.choice(best_moves)
            process_moves([chosen_candidate])

        else:
            # === OPPONENT'S TURN (Simulation) ===
            # We don't assume they are smart. We generate ALL valid moves.
            process_moves(candidates)

        return node


# ==========================================
# TESTS
# ==========================================


class TestTicTacToePolicy(unittest.TestCase):
    # --- Unit Tests ---

    def test_board_parsing(self):
        """1. Ensure string format is parsed correctly."""
        b = Board.from_string("""(Board (
            X E O
            X E O
            X E E
        ))""")
        self.assertEqual(b.state[0], "X")
        self.assertEqual(b.state[1], "E")

    def test_winner_detection(self):
        """2. Check if get_winner identifies winning lines."""
        b = Board.from_string("""(Board (
            X X X
            E O E
            E O E
        ))""")
        self.assertEqual(HammingScorer.get_winner(b), "X")

        b2 = Board.from_string("""(Board (
            E X E
            O O O
            X E X
        ))""")
        self.assertEqual(HammingScorer.get_winner(b2), "O")

    def test_game_over_generation(self):
        """3. Ensure generate() returns a Leaf if opponent already won."""
        # Board where O has already won. It is X's turn to move.
        b = Board.from_string("""(Board (
            O O O
            X E X
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=2)
        # X shouldn't move. Score should be INFINITY (Loss for X).
        node = gen.generate(b, "X")

        self.assertEqual(node.score, INFINITY)
        self.assertEqual(len(node.children), 0)  # No children generated
        self.assertIn("Game Over", node.description)

    def test_integration_winning_move_selection(self):
        """4. System should prioritize a winning move."""
        b = Board.from_string("""(Board (
            X X E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")

        # Best move is index 2 (completes row).
        best_child_key = list(policy.children.keys())[0]
        self.assertEqual(best_child_key, 2)

    def test_integration_top_1_filtering(self):
        """5. Policy should only keep top 1 move for the player."""
        b = Board.from_string("""(Board (
            E E E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")
        self.assertEqual(len(policy.children), 1)

    def test_integration_string_output(self):
        """6. Check if to_string works on the policy tree."""
        b = Board.from_string("""(Board (
            X X E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")
        output = str(policy)
        self.assertIn("Score", output)
        self.assertIn("Move", output)
        self.assertIn("(Board", output)


if __name__ == "__main__":
    # Run tests if executed as script
    unittest.main(argv=["first-arg-is-ignored"], exit=False)

    # --- DEMONSTRATION ---
    print("\n" + "=" * 40)
    print(" DEMONSTRATION OF CANDIDATE POLICY")
    print("=" * 40)

    # 1. Create a board
    initial_string = """(Board (
        X E E
        O E E
        X O E
    ))"""
    board = Board.from_string(initial_string)

    # 2. Score the current board manually
    print(f"Current Board: {board.to_string()}")
    score, details = HammingScorer.calculate_distance(board, "X")
    print(f"Distance to Win for X: {score}")
    print("Detailed Distance to winning configurations:")
    for dist, config in details:
        print(f"  - Dist: {dist} | {config}")

    # 3. Generate Policy Tree
    print("\nGenerating Candidate Policy Tree (Depth 2)...")
    generator = PolicyGenerator(max_depth=2)
    policy_tree = generator.generate(board, "X")

    print("\n--- Generated Policy Candidate ---")
    print(policy_tree)

    print("\n--- Saving Policies ---")
    output_filename = "policies.metta"
    policy_tree.save_s_expressions_to_file(output_filename)
    print(f"Successfully saved only S-expressions to '{output_filename}'")
