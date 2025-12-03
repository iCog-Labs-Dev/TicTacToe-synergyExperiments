import random
import copy
import logging
import unittest
from typing import List, Dict, Optional, Tuple

# We import the core logic from the previous file
# (Assumes representation.py is in the same directory)
from representation import (
    Board,
    PolicyNode,
    PolicyGenerator,
    HammingScorer,
    X_MARK,
    O_MARK,
    EMPTY,
    INFINITY,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# ==========================================
# 1. HELPER: Stochastic Generator
# ==========================================


class StochasticPolicyGenerator(PolicyGenerator):
    """
    Extends PolicyGenerator to introduce randomness during tree construction.
    This allows us to generate a diverse initial population rather than
    identical deterministic trees.
    """

    def __init__(self, max_depth=2, randomness_factor=0.3):
        super().__init__(max_depth)
        self.randomness = randomness_factor

    def generate(self, board: Board, current_player: str, depth=0) -> PolicyNode:
        # Re-implementing generate to inject probabilistic selection
        score, _ = HammingScorer.calculate_distance(board, current_player)

        node_desc = f"{current_player}'s Turn"
        node = PolicyNode(board, score, current_player, node_desc)

        if score == 0 or board.is_full() or depth >= self.max_depth:
            node.description += " [Leaf]"
            return node

        valid_moves = board.get_valid_moves()
        candidates = []

        for move in valid_moves:
            next_board = board.make_move(move, current_player)
            next_score, _ = HammingScorer.calculate_distance(next_board, current_player)
            candidates.append((next_score, move, next_board))

        next_player = O_MARK if current_player == X_MARK else X_MARK

        def process_moves(move_list):
            for next_score_val, move_idx, next_b in move_list:
                if next_score_val == 0:
                    term_node = PolicyNode(next_b, INFINITY, next_player, "Game Over")
                    node.add_child(move_idx, term_node)
                else:
                    child_node = self.generate(next_b, next_player, depth + 1)
                    node.add_child(move_idx, child_node)

        if depth % 2 == 0:
            # === MY TURN (Stochastic Selection) ===
            # Instead of strict Top 1, we pick probabilistically based on score
            candidates.sort(key=lambda x: x[0])

            if not candidates:
                return node

            # If randomness check passes, pick a random sub-optimal move
            # Otherwise, pick from the best scores
            if random.random() < self.randomness and len(candidates) > 1:
                # Pick from the top 3 (if available) to avoid total stupidity
                subset = candidates[: min(3, len(candidates))]
                chosen = random.choice(subset)
            else:
                # Strict best (like original)
                best_score = candidates[0][0]
                best_moves = [c for c in candidates if c[0] == best_score]
                chosen = random.choice(best_moves)

            process_moves([chosen])
        else:
            # === OPPONENT'S TURN ===
            # Standard simulation of all valid moves
            process_moves(candidates)

        return node


# ==========================================
# 2. CANDIDATE REPRESENTATION
# ==========================================


class Candidate:
    """
    Represents an individual in the population.
    """

    def __init__(self, player_mark: str):
        self.player_mark = player_mark
        self.fitness = 0.0  # Loss rate (Lower is better)
        self.wins = 0
        self.losses = 0
        self.games_played = 0

        # Policy Storage
        # X starts empty: Single Tree
        # O starts after X: Forest of Trees (Dict[start_move_index] -> Tree)
        self.policy_root: Optional[PolicyNode] = None
        self.policy_forest: Dict[int, PolicyNode] = {}

    def get_next_move(self, board: Board, move_history: List[int]) -> int:
        """
        Traverses the internal policy tree to find the next move.
        If the state is unknown (not in tree), returns a random valid move.
        """
        current_node = None

        if self.player_mark == X_MARK:
            current_node = self.policy_root
        else:
            # For O, we pick the correct tree based on X's first move
            if len(move_history) > 0:
                first_move = move_history[0]
                current_node = self.policy_forest.get(first_move)

        # Traverse history to find current state in tree
        # Skip the moves that have already happened to get to current node state
        # Note: This simple traversal assumes the tree structure mirrors the game exact sequence
        if current_node:
            # We are at the root of our policy.
            # We need to traverse down based on the moves played SO FAR since the root.

            # Identify moves to replay
            moves_to_replay = []
            if self.player_mark == X_MARK:
                moves_to_replay = move_history  # X's root is empty board
            else:
                moves_to_replay = move_history[1:]  # O's root is after X's first move

            # Walk the tree
            for m in moves_to_replay:
                if m in current_node.children:
                    current_node = current_node.children[m]
                else:
                    # Off-policy!
                    current_node = None
                    break

        # If we have a valid node and it's our turn in the tree (it has children)
        if current_node and current_node.children:
            # The children keys are the valid moves this policy suggests
            # Since our policy stores exactly 1 choice for "My Turn",
            # there should be only 1 key.
            return list(current_node.children.keys())[0]

        # Fallback: Random valid move
        valid = board.get_valid_moves()
        return random.choice(valid) if valid else -1

    def to_string(self):
        return (
            f"Candidate({self.player_mark}) | Fitness (Loss Rate): {self.fitness:.3f}"
        )


# ==========================================
# 3. GAME ARENA (SCORING)
# ==========================================


class GameArena:
    @staticmethod
    def play_game(cand_x: Candidate, cand_o: Candidate) -> str:
        """Plays one game. Returns 'X', 'O', or 'Draw'."""
        board = Board(["E"] * 9)
        history = []
        turn = 0

        while not board.is_full():
            current_cand = cand_x if turn % 2 == 0 else cand_o

            # Get move from candidate
            move = current_cand.get_next_move(board, history)

            if move == -1 or move not in board.get_valid_moves():
                # Invalid move results in immediate loss
                return O_MARK if current_cand == cand_x else X_MARK

            board = board.make_move(move, current_cand.player_mark)
            history.append(move)

            # Check win using HammingScorer (Distance 0 = Win)
            dist, _ = HammingScorer.calculate_distance(board, current_cand.player_mark)
            if dist == 0:
                return current_cand.player_mark

            turn += 1

        return "Draw"

    @staticmethod
    def score_candidates(cand_x: Candidate, cand_o: Candidate, rounds=200):
        """
        Plays N rounds. Updates stats in place.
        """
        for _ in range(rounds):
            result = GameArena.play_game(cand_x, cand_o)

            cand_x.games_played += 1
            cand_o.games_played += 1

            if result == O_MARK:
                cand_x.losses += 1
                cand_o.wins += 1
            elif result == X_MARK:
                cand_o.losses += 1
                cand_x.wins += 1
            # Draws don't count as losses

        # Calculate Scores
        cand_x.fitness = cand_x.losses / max(1, cand_x.games_played)
        cand_o.fitness = cand_o.losses / max(1, cand_o.games_played)


# ==========================================
# 4. EVOLUTIONARY ENGINE
# ==========================================


class EvolutionaryEngine:
    def __init__(
        self,
        pop_size=10,
        generations=5,
        max_depth=4,
        elitism_rate=0.2,
        mutation_rate_base=0.1,
    ):
        self.pop_size = pop_size
        self.generations = generations
        self.max_depth = max_depth
        self.elitism_rate = elitism_rate
        self.mutation_rate_base = mutation_rate_base
        self.generator = StochasticPolicyGenerator(
            max_depth=max_depth, randomness_factor=0.4
        )

        self.population_x: List[Candidate] = []
        self.population_o: List[Candidate] = []

    def initialize_populations(self):
        logger.info("Initializing X Population...")
        empty_board = Board(["E"] * 9)

        for _ in range(self.pop_size):
            c = Candidate(X_MARK)
            # Generate random policy tree
            c.policy_root = self.generator.generate(empty_board, X_MARK)
            self.population_x.append(c)

        logger.info("Initializing O Population...")
        for _ in range(self.pop_size):
            c = Candidate(O_MARK)
            # Generate forest for O (responses to all 9 openings)
            for i in range(9):
                # X moves at i
                board = empty_board.make_move(i, X_MARK)
                # Generate O's response tree
                c.policy_forest[i] = self.generator.generate(board, O_MARK)
            self.population_o.append(c)

    def crossover_trees(
        self, tree_a: PolicyNode, tree_b: PolicyNode, current_player: str
    ) -> PolicyNode:
        """
        Multipoint crossover.
        Traverses two trees. If they share a valid path, potentially swap subtrees.
        """
        # Base copy
        new_tree = copy.deepcopy(tree_a)

        # Valid Crossover points: Nodes where both parents agree on the board state
        # Since our trees are generated from the same start, the structures align
        # heavily on the Opponent's levels (where all options are listed).

        def recurse_swap(node_a, node_b, target_node):
            if not node_a or not node_b:
                return

            # If it's the player's turn to choose (Candidate Level),
            # we can swap the decision
            if node_a.player == current_player:
                if random.random() < 0.5:
                    # Swap logic: Take B's decision
                    target_node.children = copy.deepcopy(node_b.children)

            # Recurse down common paths
            common_moves = set(node_a.children.keys()) & set(node_b.children.keys())
            for m in common_moves:
                if m in target_node.children:
                    recurse_swap(
                        node_a.children[m], node_b.children[m], target_node.children[m]
                    )

        recurse_swap(tree_a, tree_b, new_tree)
        return new_tree

    def mutate_tree(self, tree: PolicyNode, mutation_rate: float, current_player: str):
        """
        Traverses tree and mutates 'My Move' nodes with probability 'mutation_rate'.
        Ensures valid moves.
        """
        if not tree:
            return

        if tree.player == current_player:
            if random.random() < mutation_rate:
                # Mutation: Pick a different valid move based on Hamming
                # We essentially re-run the generator for this node with high randomness
                valid_moves = tree.board.get_valid_moves()
                if valid_moves:
                    # Pick a new random move
                    new_move = random.choice(valid_moves)
                    # Generate the new branch
                    next_board = tree.board.make_move(new_move, current_player)
                    # FIX: Pass depth=1 so the generator knows the child node
                    # represents an Opponent's turn (Odd Depth) and generates
                    # all valid branches, not just one.
                    new_child = self.generator.generate(
                        next_board,
                        O_MARK if current_player == X_MARK else X_MARK,
                        depth=1,
                    )
                    tree.children = {new_move: new_child}

        for child in tree.children.values():
            self.mutate_tree(child, mutation_rate, current_player)

    def evolve_population(
        self,
        population: List[Candidate],
        opponent_pool: List[Candidate],
        player_mark: str,
    ):
        # 1. Scoring
        for cand in population:
            # Reset stats
            cand.games_played = 0
            cand.losses = 0
            # Play against random rival
            rival = random.choice(opponent_pool)
            if player_mark == X_MARK:
                GameArena.score_candidates(cand, rival)
            else:
                GameArena.score_candidates(rival, cand)

        # 2. Sort by Fitness (Ascending, 0 loss is best)
        population.sort(key=lambda x: x.fitness)

        # Elitism: Keep top percentage
        num_elites = max(1, int(self.pop_size * self.elitism_rate))
        next_gen = population[:num_elites]

        # 3. Breeding
        while len(next_gen) < self.pop_size:
            # Select parents from the top half of population for better genetics
            selection_pool_size = max(2, self.pop_size // 2)
            parent_a = random.choice(population[:selection_pool_size])
            parent_b = random.choice(population[:selection_pool_size])

            child = Candidate(player_mark)

            if player_mark == X_MARK:
                child.policy_root = self.crossover_trees(
                    parent_a.policy_root, parent_b.policy_root, X_MARK
                )
            else:
                # Crossover for O: Crossover each tree in the forest
                for start_move in range(9):
                    if (
                        start_move in parent_a.policy_forest
                        and start_move in parent_b.policy_forest
                    ):
                        child.policy_forest[start_move] = self.crossover_trees(
                            parent_a.policy_forest[start_move],
                            parent_b.policy_forest[start_move],
                            O_MARK,
                        )

            # 4. Mutation
            # Rate inversely proportional to fitness of parent (Better parent = Lower mutation)
            # parent fitness is 0..1.
            mut_rate = self.mutation_rate_base + (parent_a.fitness * 0.5)

            if player_mark == X_MARK:
                self.mutate_tree(child.policy_root, mut_rate, X_MARK)
            else:
                for tree in child.policy_forest.values():
                    self.mutate_tree(tree, mut_rate, O_MARK)

            next_gen.append(child)

        return next_gen

    def save_candidate_policy(
        self,
        candidate: Candidate,
        generation: int,
        filename_prefix: str = "policies_gen",
    ):
        """
        Saves the S-expressions of a candidate to a file.
        Handles both X (Single Tree) and O (Forest).
        """
        filename = (
            f"{filename_prefix}_{candidate.player_mark.lower()}_gen{generation}.metta"
        )
        logger.info(f"Saving No Loss policy for {candidate.player_mark} to {filename}")

        with open(filename, "w") as f:
            if candidate.player_mark == X_MARK and candidate.policy_root:
                # Direct save for X (Level 0)
                s_exprs = candidate.policy_root.to_s_expressions(
                    level=0, parent_path=()
                )
                self._write_expressions(f, s_exprs, generation)

            elif candidate.player_mark == O_MARK:
                # Forest save for O
                # Iterate through all opening moves (0-8)
                for start_move, tree in candidate.policy_forest.items():
                    # O starts at Level 1 (Turn 2 effectively), parent path is the X move
                    s_exprs = tree.to_s_expressions(level=1, parent_path=(start_move,))
                    self._write_expressions(f, s_exprs, generation)

    def _write_expressions(self, f, s_exprs, candidate_id):
        """Helper to write formatted expressions to file with newlines between groups."""
        previous_level = None
        for (level, path), expr in s_exprs:
            turn_level = level + 1

            # Visual separator for different levels/branches
            if previous_level is not None and turn_level != previous_level:
                f.write("\n")

            previous_level = turn_level

            path_str = " ".join(map(str, path))
            formatted = f"(Sentence {expr} ({candidate_id} {turn_level} ({path_str})))"
            f.write(f"{formatted}\n")

    def run(self):
        self.initialize_populations()

        for g in range(self.generations):
            logger.info(f"--- Generation {g + 1} ---")

            # Evolve X (Playing against current O)
            self.population_x = self.evolve_population(
                self.population_x, self.population_o, X_MARK
            )
            best_x = self.population_x[0]
            logger.info(f"Best X: {best_x.to_string()}")

            # Evolve O (Playing against current X)
            self.population_o = self.evolve_population(
                self.population_o, self.population_x, O_MARK
            )
            best_o = self.population_o[0]
            logger.info(f"Best O: {best_o.to_string()}")

        # After evolution finishes, SORT and check the survivors
        # We re-sort to ensure we are looking at the absolute best from the final generation
        self.population_x.sort(key=lambda x: x.fitness)
        self.population_o.sort(key=lambda o: o.fitness)

        # Check Top 3 X Policies
        for i, candidate in enumerate(self.population_x[:3]):
            if candidate.fitness == 0.0:
                rank_name = f"final_no_loss_rank{i + 1}"
                self.save_candidate_policy(candidate, self.generations, rank_name)

        # Check Top 3 O Policies
        for i, candidate in enumerate(self.population_o[:3]):
            if candidate.fitness == 0.0:
                rank_name = f"final_no_loss_rank{i + 1}"
                self.save_candidate_policy(candidate, self.generations, rank_name)

        return self.population_x[:3], self.population_o[:3]


# ==========================================
# 5. TESTS
# ==========================================


class TestEvolution(unittest.TestCase):
    def setUp(self):
        random.seed(42)  # Replicability

    def test_stochastic_generator(self):
        """Test that generator creates valid PolicyNodes."""
        gen = StochasticPolicyGenerator(max_depth=2)
        board = Board(["E"] * 9)
        node = gen.generate(board, X_MARK)
        self.assertIsInstance(node, PolicyNode)
        # Should have 1 child (since it's X's turn and policy picks 1)
        self.assertEqual(len(node.children), 1)

    def test_candidate_x_play(self):
        """Test that X candidate can make a move from empty."""
        cand = Candidate(X_MARK)
        gen = StochasticPolicyGenerator(max_depth=2)
        cand.policy_root = gen.generate(Board(["E"] * 9), X_MARK)

        move = cand.get_next_move(Board(["E"] * 9), [])
        self.assertIn(move, range(9))

    def test_candidate_o_forest(self):
        """Test that O candidate handles specific openings."""
        cand = Candidate(O_MARK)
        gen = StochasticPolicyGenerator(max_depth=2)
        # Simulate X playing 0
        board_after_x = Board(["E"] * 9).make_move(0, X_MARK)
        cand.policy_forest[0] = gen.generate(board_after_x, O_MARK)

        # Ask for move given history [0]
        move = cand.get_next_move(board_after_x, [0])
        self.assertIn(move, range(9))
        self.assertNotEqual(move, 0)  # 0 is taken

    def test_game_arena_scoring(self):
        """Test game loop execution."""
        c_x = Candidate(X_MARK)
        c_o = Candidate(O_MARK)

        # Minimal initialization
        gen = StochasticPolicyGenerator(max_depth=1)
        c_x.policy_root = gen.generate(Board(["E"] * 9), X_MARK)
        for i in range(9):
            if i != 0:  # minimal valid setup
                b = Board(["E"] * 9).make_move(i, X_MARK)
                c_o.policy_forest[i] = gen.generate(b, O_MARK)

        GameArena.play_game(c_x, c_o)
        # Just ensure no crash
        self.assertTrue(True)

    def test_integration_full_run(self):
        """Run a tiny evolution to check pipeline integrity."""
        engine = EvolutionaryEngine(
            pop_size=4, generations=2, max_depth=2, elitism_rate=0.5
        )
        top_x, top_o = engine.run()
        self.assertEqual(len(top_x), 3)
        self.assertEqual(len(top_o), 3)

    def test_logging_mechanism(self):
        """Ensure logging helper runs without error for both X and O."""
        engine = EvolutionaryEngine(pop_size=2, generations=1, max_depth=1)
        engine.initialize_populations()

        cand_x = engine.population_x[0]
        cand_o = engine.population_o[0]

        # Should create file without error (we use a test prefix to keep it clean)
        engine.save_candidate_policy(cand_x, 999, "test_log")
        engine.save_candidate_policy(cand_o, 999, "test_log")

        # In a real scenario we'd check file existence, but here we check execution flow
        self.assertTrue(True)


if __name__ == "__main__":
    # 1. Run Tests (Disabled as per user request to avoid log clutter)
    # print("Running Tests...")
    # suite = unittest.TestLoader().loadTestsFromTestCase(TestEvolution)
    # unittest.TextTestRunner(verbosity=2).run(suite)

    # 2. Example Run
    print("\nStarting Example Evolution Run...")
    # random.seed(101)

    # Using small parameters for the demo execution
    # Elitism: 20% of 50 = 10 survivors per gen.
    engine = EvolutionaryEngine(
        pop_size=50,
        generations=20,
        max_depth=9,
        elitism_rate=0.2,
        mutation_rate_base=0.1,
    )
    best_x_policies, best_o_policies = engine.run()

    print("\n=== Final Results ===")
    print("Top 3 X Policies:")
    for i, p in enumerate(best_x_policies):
        print(f"#{i + 1}: {p.to_string()}")

    print("\nTop 3 O Policies:")
    for i, p in enumerate(best_o_policies):
        print(f"#{i + 1}: {p.to_string()}")
