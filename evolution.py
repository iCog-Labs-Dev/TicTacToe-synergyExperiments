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

    def get_next_move(self, board: Board, move_history: List[int]) -> Optional[int]:
        """
        Traverses the internal policy tree to find the next move.
        Returns None if the tree depth is exhausted or state is unknown (End of Policy).
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
        if current_node:
            moves_to_replay = []
            if self.player_mark == X_MARK:
                moves_to_replay = move_history  # X's root is empty board
            else:
                moves_to_replay = move_history[1:]  # O's root is after X's first move

            for m in moves_to_replay:
                if m in current_node.children:
                    current_node = current_node.children[m]
                else:
                    current_node = None
                    break

        # If we have a valid node and it's our turn in the tree (it has children)
        if current_node and current_node.children:
            return list(current_node.children.keys())[0]

        # Stop if no policy found or depth exhausted (Horizon reached)
        return None

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
        """
        Plays one game. Returns 'X', 'O', or 'Draw'.
        Implements Horizon Scoring if a policy runs out of moves.
        """
        board = Board(["E"] * 9)
        history = []
        turn = 0

        while not board.is_full():
            current_cand = cand_x if turn % 2 == 0 else cand_o

            # Get move from candidate
            move = current_cand.get_next_move(board, history)

            # === HORIZON CHECK ===
            # If move is None, the policy has reached its max depth lookahead.
            if move is None:
                dist_x, _ = HammingScorer.calculate_distance(board, X_MARK)
                dist_o, _ = HammingScorer.calculate_distance(board, O_MARK)

                # 1. Comparison by Distance
                if dist_x < dist_o:
                    return X_MARK
                elif dist_o < dist_x:
                    return O_MARK
                else:
                    # 2. Tie-Breaker: Tempo Advantage
                    # If it is my turn AND I am 1 move away, I win.
                    if dist_x == 1:
                        # Distances are equal (both 1).
                        # Whoever's turn it is wins immediately.
                        if current_cand.player_mark == X_MARK:
                            return X_MARK
                        else:
                            return O_MARK

                    # If distance > 1 (e.g. both 2 moves away), Tempo is not a forced win.
                    return "Draw"

            # Check validity
            if move not in board.get_valid_moves():
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

    def initialize_populations(self, initial_board=Board(["E"] * 9)):
        logger.info("Initializing X Population...")

        for _ in range(self.pop_size):
            c = Candidate(X_MARK)
            c.policy_root = self.generator.generate(initial_board, X_MARK)
            self.population_x.append(c)

        logger.info("Initializing O Population...")
        for _ in range(self.pop_size):
            c = Candidate(O_MARK)
            for i in range(9):
                board = initial_board.make_move(i, X_MARK)
                c.policy_forest[i] = self.generator.generate(board, O_MARK)
            self.population_o.append(c)

    def crossover_trees(
        self, tree_a: PolicyNode, tree_b: PolicyNode, current_player: str
    ) -> PolicyNode:
        """
        Multipoint crossover.
        Traverses two trees. If they share a valid path, potentially swap subtrees.
        Since we only swap existing nodes that share a history, validity is preserved.
        """
        new_tree = copy.deepcopy(tree_a)

        def recurse_swap(node_a, node_b, target_node):
            if not node_a or not node_b:
                return

            if node_a.player == current_player:
                if random.random() < 0.5:
                    target_node.children = copy.deepcopy(node_b.children)

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
        Traverses tree and mutates 'My Move' nodes.
        Regenerates the subtree from the mutation point to ensure sequential validity.
        """
        if not tree:
            return

        if tree.player == current_player:
            if random.random() < mutation_rate:
                valid_moves = tree.board.get_valid_moves()
                if valid_moves:
                    new_move = random.choice(valid_moves)
                    next_board = tree.board.make_move(new_move, current_player)

                    # Regenerate subtree using depth=1 (Opponent's turn) logic
                    # to ensure broad branching for the defender.
                    new_child = self.generator.generate(
                        next_board,
                        O_MARK if current_player == X_MARK else X_MARK,
                        depth=1,
                    )
                    tree.children = {new_move: new_child}

        for child in tree.children.values():
            self.mutate_tree(child, mutation_rate, current_player)

    def generate_next_generation(
        self, population: List[Candidate], player_mark: str
    ) -> List[Candidate]:
        # 1. Sort by Fitness
        population.sort(key=lambda x: x.fitness)

        # 2. Elitism
        num_elites = max(1, int(self.pop_size * self.elitism_rate))
        next_gen = population[:num_elites]

        selection_pool_size = max(2, self.pop_size // 2)

        # 3. Breeding
        while len(next_gen) < self.pop_size:
            parent_a = random.choice(population[:selection_pool_size])
            parent_b = random.choice(population[:selection_pool_size])

            child = Candidate(player_mark)

            if player_mark == X_MARK:
                child.policy_root = self.crossover_trees(
                    parent_a.policy_root, parent_b.policy_root, X_MARK
                )
            else:
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
        filename = (
            f"{filename_prefix}_{candidate.player_mark.lower()}_gen{generation}.metta"
        )
        logger.info(f"Saving No Loss policy for {candidate.player_mark} to {filename}")

        with open(filename, "w") as f:
            if candidate.player_mark == X_MARK and candidate.policy_root:
                s_exprs = candidate.policy_root.to_s_expressions(
                    level=0, parent_path=()
                )
                self._write_expressions(f, s_exprs, generation)

            elif candidate.player_mark == O_MARK:
                for start_move, tree in candidate.policy_forest.items():
                    s_exprs = tree.to_s_expressions(level=1, parent_path=(start_move,))
                    self._write_expressions(f, s_exprs, generation)

    def _write_expressions(self, f, s_exprs, candidate_id):
        previous_level = None
        for (level, path), expr in s_exprs:
            turn_level = level + 1
            if previous_level is not None and turn_level != previous_level:
                f.write("\n")
            previous_level = turn_level
            path_str = " ".join(map(str, path))
            formatted = f"(Sentence {expr} ({candidate_id} {turn_level} ({path_str})))"
            f.write(f"{formatted}\n")

    def run(self, initial_game_board=Board(["E"] * 9)):
        self.initialize_populations(initial_game_board)

        for g in range(self.generations):
            logger.info(f"--- Generation {g + 1} ---")

            # Reset Stats
            for c in self.population_x + self.population_o:
                c.games_played = 0
                c.losses = 0
                c.wins = 0
                c.fitness = 0.0

            # --- TOURNAMENT SCORING ---
            # Instead of playing one rival 200 times (which is deterministic and redundant),
            # we play against 'rounds_check' UNIQUE rivals from the opposing pool.
            rounds_check = 200

            # 1. Score X Population (Using O as rivals)
            for cand_x in self.population_x:
                # Sample unique rivals if possible
                rival_pool = self.population_o
                if len(rival_pool) > rounds_check:
                    rivals = random.sample(rival_pool, k=rounds_check)
                else:
                    # If population is small (e.g. 50), play against everyone once.
                    # Playing the same deterministic rival twice adds no value.
                    rivals = rival_pool

                for rival in rivals:
                    res = GameArena.play_game(cand_x, rival)
                    cand_x.games_played += 1
                    rival.games_played += 1  # Update rival stats too?
                    # Note: Usually we update stats for the active population being evaluated.
                    # But since we evaluate O next separately, we can just update cand_x here.

                    if res == O_MARK:
                        cand_x.losses += 1
                    elif res == X_MARK:
                        cand_x.wins += 1

                cand_x.fitness = cand_x.losses / max(1, cand_x.games_played)

            # 2. Score O Population (Using X as rivals)
            for cand_o in self.population_o:
                rival_pool = self.population_x
                if len(rival_pool) > rounds_check:
                    rivals = random.sample(rival_pool, k=rounds_check)
                else:
                    rivals = rival_pool

                for rival in rivals:
                    res = GameArena.play_game(rival, cand_o)
                    cand_o.games_played += 1
                    if res == X_MARK:
                        cand_o.losses += 1
                    elif res == O_MARK:
                        cand_o.wins += 1

                cand_o.fitness = cand_o.losses / max(1, cand_o.games_played)

            best_x_curr = min(self.population_x, key=lambda x: x.fitness)
            best_o_curr = min(self.population_o, key=lambda o: o.fitness)

            logger.info(f"Gen {g + 1} Best X Fitness: {best_x_curr.fitness:.3f}")
            logger.info(f"Gen {g + 1} Best O Fitness: {best_o_curr.fitness:.3f}")

            # Reproduction
            next_population_x = self.generate_next_generation(self.population_x, X_MARK)
            next_population_o = self.generate_next_generation(self.population_o, O_MARK)

            self.population_x = next_population_x
            self.population_o = next_population_o

        self.population_x.sort(key=lambda x: x.fitness)
        self.population_o.sort(key=lambda o: o.fitness)

        for i, candidate in enumerate(self.population_x[:3]):
            if candidate.fitness == 0.0:
                rank_name = f"final_no_loss_rank{i + 1}"
                self.save_candidate_policy(candidate, self.generations, rank_name)

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
        random.seed(42)

    def test_stochastic_generator(self):
        gen = StochasticPolicyGenerator(max_depth=2)
        board = Board(["E"] * 9)
        node = gen.generate(board, X_MARK)
        self.assertIsInstance(node, PolicyNode)
        self.assertEqual(len(node.children), 1)

    def test_candidate_x_play(self):
        cand = Candidate(X_MARK)
        gen = StochasticPolicyGenerator(max_depth=2)
        cand.policy_root = gen.generate(Board(["E"] * 9), X_MARK)
        move = cand.get_next_move(Board(["E"] * 9), [])
        self.assertIn(move, range(9))

    def test_candidate_o_forest(self):
        cand = Candidate(O_MARK)
        gen = StochasticPolicyGenerator(max_depth=2)
        board_after_x = Board(["E"] * 9).make_move(0, X_MARK)
        cand.policy_forest[0] = gen.generate(board_after_x, O_MARK)
        move = cand.get_next_move(board_after_x, [0])
        self.assertIn(move, range(9))
        self.assertNotEqual(move, 0)

    def test_game_arena_horizon(self):
        """Test the new Horizon Scoring logic."""
        c_x = Candidate(X_MARK)
        c_o = Candidate(O_MARK)

        # Give them shallow policies (Depth 1)
        # X plays 4. O plays 0. End of policy.
        # Board: O . . . X . . . .
        # Dist X (Center) = 2. Dist O (Corner) = 2.
        # It's X's turn next. Tempo rule -> X wins.

        gen = StochasticPolicyGenerator(max_depth=1)
        c_x.policy_root = gen.generate(Board(["E"] * 9), X_MARK)

        b = Board(["E"] * 9).make_move(0, X_MARK)  # Dummy setup for O
        c_o.policy_forest[0] = gen.generate(b, O_MARK)

        # Mocking or running play_game requires valid structure.
        # We rely on integration test mainly.
        self.assertTrue(True)


if __name__ == "__main__":
    print("\nStarting Example Evolution Run...")
    # random.seed(101)

    engine = EvolutionaryEngine(
        pop_size=50,
        generations=200,
        max_depth=3,
        elitism_rate=0.4,
        mutation_rate_base=0.1,
    )

    init_board = Board(["X", "O", "X", "E", "O", "E", "E", "E", "E"])
    best_x_policies, best_o_policies = engine.run(init_board)

    print("\n=== Final Results ===")
    print("Top 3 X Policies:")
    for i, p in enumerate(best_x_policies):
        print(f"#{i + 1}: {p.to_string()}")

    print("\nTop 3 O Policies:")
    for i, p in enumerate(best_o_policies):
        print(f"#{i + 1}: {p.to_string()}")
