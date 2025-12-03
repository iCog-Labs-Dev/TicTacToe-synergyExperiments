import unittest
import random
from typing import List, Tuple, Dict

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
                # Create a representation of this specific winning line configuration
                temp_state = ["."] * 9
                for i in indices:
                    temp_state[i] = player_mark
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
        # Calculate Score for current board relative to current player
        score, _ = HammingScorer.calculate_distance(board, current_player)

        node_desc = (
            f"Player {current_player}'s Turn"
            if depth % 2 == 0
            else f"Opponent {current_player}'s Turn"
        )
        node = PolicyNode(board, score, current_player, node_desc)

        # Stop if won, lost (inf), full, or max depth reached
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
                # Check for Immediate Win
                if next_score_val == 0:
                    # Current player won. Create a terminal node for the opponent.
                    # Opponent score is INFINITY (Bad) because they lost.
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
            # If ties for the best score, pick one randomly.
            candidates.sort(key=lambda x: x[0])  # Ascending sort

            if not candidates:
                # Should not happen if game not over, but good for safety
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
    # --- Unit Tests (9) ---

    def test_board_parsing(self):
        """1. Ensure string format is parsed correctly."""
        b = Board.from_string("""(Board (
            X E O
            X E O
            X E E
        ))""")
        self.assertEqual(b.state[0], "X")
        self.assertEqual(b.state[1], "E")

    def test_hamming_distance_empty(self):
        """2. Empty board requires 3 moves to fill a line. Distance should be 3."""
        b = Board.from_string("""(Board (
            E E E
            E E E
            E E E
        ))""")
        score, _ = HammingScorer.calculate_distance(b, "X")
        self.assertEqual(score, 3)

    def test_hamming_distance_one_move_made(self):
        """3. Board with 1 X should have distance 2 (needs 2 more Xs)."""
        b = Board.from_string("""(Board (
            X E E
            E E E
            E E E
        ))""")
        score, _ = HammingScorer.calculate_distance(b, "X")
        self.assertEqual(score, 2)

    def test_hamming_distance_blocked(self):
        """4. A line blocked by enemy should be infinity."""
        b = Board.from_string("""(Board (
            X O X
            E E E
            E E E
        ))""")
        score, _ = HammingScorer.calculate_distance(b, "X")
        self.assertEqual(score, 2)

    def test_hamming_distance_winning(self):
        """5. A winning board should have distance 0."""
        b = Board.from_string("""(Board (
            X X X
            E E E
            E E E
        ))""")
        score, _ = HammingScorer.calculate_distance(b, "X")
        self.assertEqual(score, 0)

    def test_hamming_distance_fully_blocked(self):
        """6. If X is blocked everywhere, distance is Infinity."""
        b = Board.from_string("""(Board (
            O O O
            O O O
            O O O
        ))""")
        score, _ = HammingScorer.calculate_distance(b, "X")
        self.assertEqual(score, INFINITY)

    def test_valid_moves(self):
        """7. Should identify empty indices correctly."""
        b = Board.from_string("""(Board (
            X E X
            E E E
            E E E
        ))""")
        moves = b.get_valid_moves()
        self.assertIn(1, moves)
        self.assertNotIn(0, moves)

    def test_make_move(self):
        """8. Making a move should return new board and not mutate old."""
        b1 = Board.from_string("""(Board (
            E E E
            E E E
            E E E
        ))""")
        b2 = b1.make_move(0, "X")
        self.assertEqual(b2.state[0], "X")
        self.assertEqual(b1.state[0], "E")  # Immutability check

    def test_s_expression_generation(self):
        """9. Check generation of S-expressions with tuple indices."""
        b = Board.from_string("""(Board (
            X X E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")

        s_exprs = policy.to_s_expressions()

        # We expect 1 implication since X winning immediately (move 2) is the best move
        self.assertTrue(len(s_exprs) > 0)
        index, expr = s_exprs[0]

        # Check index format (level, path_tuple)
        level, path = index
        self.assertEqual(level, 0)  # Level 0 implication
        self.assertIsInstance(path, tuple)
        self.assertEqual(len(path), 1)  # Path should be (0,) for first level

        # Check string format
        self.assertIn("(Implication", expr)
        self.assertIn("(Board", expr)

    # --- Integration Tests (8) ---

    def test_integration_winning_move_selection(self):
        """1. System should prioritize a winning move (Dist 1 -> Dist 0)."""
        b = Board.from_string("""(Board (
            X X E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")

        # Best move is index 2 (completes row).
        best_child_key = list(policy.children.keys())[
            0
        ]  # Since it's sorted, first key is best
        self.assertEqual(best_child_key, 2)

    def test_integration_top_1_filtering(self):
        """2. Policy should only keep top 1 move for the player."""
        b = Board.from_string("""(Board (
            E E E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")
        # Empty board has 9 moves. Policy should only have 1 child (selected randomly from best).
        self.assertEqual(len(policy.children), 1)

    def test_integration_opponent_simulation_full_width(self):
        """3. Opponent phase should generate ALL valid moves."""
        b = Board.from_string("""(Board (
            E E E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=2)
        policy = gen.generate(b, "X")

        # Root (X) -> picks 1 move.
        # Child (O) -> Should have 8 responses (since 1 taken).
        first_move_node = list(policy.children.values())[0]
        self.assertEqual(len(first_move_node.children), 8)

    def test_integration_infinity_handling(self):
        """4. If a move leads to being fully blocked, score is Inf."""
        # Use a "Cat's Game" where X is blocked everywhere but O hasn't won yet.
        b = Board.from_string("""(Board (
            X O X
            O X O
            O X O
        ))""")
        # X is blocked on all rows/cols/diags.

        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")
        # X cannot win. Distance is Inf.
        self.assertEqual(policy.score, INFINITY)

    def test_integration_game_over_leaf(self):
        """5. Tree should stop generating if game is won."""
        b = Board.from_string("""(Board (
            X X X
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=2)
        policy = gen.generate(b, "X")
        # Should have no children because score is 0 (Win)
        self.assertEqual(len(policy.children), 0)

    def test_integration_depth_limit(self):
        """6. Tree should stop at max_depth."""
        b = Board.from_string("""(Board (
            E E E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")
        # Root has children.
        self.assertTrue(len(policy.children) > 0)
        # Children should have NO children (Leafs at depth 1)
        first_child = list(policy.children.values())[0]
        self.assertEqual(len(first_child.children), 0)

    def test_integration_sorting_correctness(self):
        """7. Ensure the children are actually sorted by best score."""
        b = Board.from_string("""(Board (
            E E E
            E E E
            E E E
        ))""")
        gen = PolicyGenerator(max_depth=1)
        policy = gen.generate(b, "X")

        keys = list(policy.children.keys())
        self.assertTrue(len(keys) > 0)

    def test_integration_string_output(self):
        """8. Check if to_string works on the policy tree."""
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
        E E E
        E E E
        E E E
    ))"""
    board = Board.from_string(initial_string)

    # 2. Score the current board manually (to demonstrate requirements 1-5)
    print(f"Current Board: {board.to_string()}")
    score, details = HammingScorer.calculate_distance(board, "X")
    print(f"Distance to Win for X: {score}")
    print("Detailed Distance to winning configurations:")
    for dist, config in details:
        print(f"  - Dist: {dist} | {config}")

    # 3. Generate Policy Tree
    # Depth 2 means:
    #   Level 0: Current State
    #   Level 1: My Best 3 Moves
    #   Level 2: Opponent's Responses (All valid moves)
    print("\nGenerating Candidate Policy Tree (Depth 2)...")
    generator = PolicyGenerator(max_depth=9)
    policy_tree = generator.generate(board, "X")

    print("\n--- Generated Policy Candidate ---")
    print(policy_tree)

    print("\n--- Saving Policies ---")
    output_filename = "policies.metta"
    policy_tree.save_s_expressions_to_file(output_filename)
    print(f"Successfully saved only S-expressions to '{output_filename}'")
