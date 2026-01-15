import unittest
import shutil
import random
from gp_engine import GPEngine, PolicyGenome
from game_engine import (
    Board,
    GameActions,
    to_string,
    to_linear_string,
    make_move,
    save_board,
    remove_file,
    X_MARK,
    check_winner,
    get_diff_index,
    is_valid,
    is_full,
    save_policy_to_file,
    simulate_game_dynamics,
)

# ==========================================
# UNIT TESTS
# ==========================================


class TestGameLogic(unittest.TestCase):
    def test_actions_validity(self):
        """Ensure actions return (Success, Board) correctly."""
        b = Board(["E"] * 9)
        success, new_b = GameActions.play_center(b, "X")
        self.assertTrue(success)
        self.assertEqual(new_b.state[4], "X")

        # Try playing center again
        success, final_b = GameActions.play_center(new_b, "O")
        self.assertFalse(success)  # Occupied

    def test_policy_execution(self):
        """Test a manual policy stack."""
        # Priority: Win -> Center -> Corners
        p = PolicyGenome(["WIN", "CENTER", "CORNERS"])
        b = Board(["E"] * 9)

        # Empty board -> Should trigger Center (Win fails)
        new_b = p.execute(b, "X")
        self.assertEqual(new_b.state[4], "X")


class TestEvolutionLogic(unittest.TestCase):
    def test_population_growth(self):
        engine = GPEngine(target_player="X", pop_size=10)
        best = engine.step_generation()
        self.assertEqual(len(engine.population), 10)
        self.assertIsNotNone(best)


# ==========================================
# MAIN EXECUTION
# ==========================================


def run_optimization(player, generations=20, minimax_max_depth=4):
    # print(f"\n--- Evolving Policy for Player {player} ---")
    random.seed(42)

    # Init GP Engine with configurable depth
    engine = GPEngine(
        target_player=player,
        pop_size=30,
        mutation_rate=0.3,
        crossover_rate=0.8,
        minimax_depth=minimax_max_depth,
    )

    # Calculate Theoretical Max Fitness
    # Random(5) + Minimax(1..Depth * 2)
    max_possible_score = 5.0 + (2.0 * minimax_max_depth)
    # print(f"Target Max Fitness: {max_possible_score:.1f}")

    for g in range(generations):
        best_policy = engine.step_generation()
        # print(
        #     f"Gen {g + 1}: Best Fitness = {best_policy.fitness:.2f} | Rule: {best_policy}"
        # )

        # Check if we found a very strong policy (Allowing for slight imperfection, e.g. 1 draw)
        if best_policy.fitness >= (max_possible_score - 1.0):
            # print(
            #     f"Found Strong Policy (Score {best_policy.fitness}/{max_possible_score})!"
            # )
            break

    # print(f"\nWinner for {player}: {engine.population[0]}")

    best_policy = engine.population[0]
    # save_policy_to_file(best_policy.actions, generations, best_policy.fitness, player)
    return best_policy


def run_moses(board, player, depth=1, game_id=1):
    best_x = run_optimization(player, generations=15, minimax_max_depth=4)
    simulate_game_dynamics(board, best_x.actions, depth, player, game_id=game_id)
    return True


def clean_file(filename):
    backup_filename = filename + ".bak"
    shutil.copyfile(filename, backup_filename)
    with open(filename, "w") as f:
        f.write("")
    return True


def restore_file(filename):
    import os

    backup_filename = filename + ".bak"
    if not os.path.exists(backup_filename):
        print(f"Backup file for {filename} does not exist. No changes made.")
        return False

    with open(backup_filename, "r") as f:
        data = f.read()

    shutil.copyfile(filename, backup_filename)

    with open(filename, "w") as f:
        f.write(data)
    return True


# if __name__ == "__main__":
#     # # 1. Run Unit Tests
#     # print("Running Tests...")
#     # suite = unittest.TestLoader().loadTestsFromTestCase(TestGameLogic)
#     # unittest.TextTestRunner(verbosity=1).run(suite)
#
#     # 2. Run Evolution for X (Depth 4)
#     best_x = run_optimization("X", generations=15, minimax_max_depth=4)
#     simulate_game_dynamics("(Board (X E E E O E E E E))", best_x.actions, 3, X_MARK)
#
#     # 3. Run Evolution for O (Depth 4)
#     # best_o = run_optimization("O", generations=15, minimax_max_depth=4)
