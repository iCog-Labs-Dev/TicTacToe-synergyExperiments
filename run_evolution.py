import unittest
import random
from gp_engine import GPEngine, PolicyGenome
from game_engine import Board, GameActions

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


def run_optimization(player, generations=20):
    print(f"\n--- Evolving Policy for Player {player} ---")
    random.seed(42)

    # Init GP Engine
    engine = GPEngine(
        target_player=player, pop_size=30, mutation_rate=0.3, crossover_rate=0.8
    )

    for g in range(generations):
        best_policy = engine.step_generation()
        print(
            f"Gen {g + 1}: Best Fitness = {best_policy.fitness:.2f} | Rule: {best_policy}"
        )

        # Check if we found a very strong policy
        # Max score calculation: 13 games. Max score 1.0 each. Total 13.0.
        if best_policy.fitness >= 12.0:
            print("Found Near-Perfect Policy!")
            break

    print(f"\nWinner for {player}: {engine.population[0]}")
    return engine.population[0]


if __name__ == "__main__":
    # 1. Run Unit Tests
    # print("Running Tests...")
    # suite = unittest.TestLoader().loadTestsFromTestCase(TestGameLogic)
    # unittest.TextTestRunner(verbosity=1).run(suite)

    # 2. Run Evolution for X
    best_x = run_optimization("X", generations=15)

    # 3. Run Evolution for O
    # best_o = run_optimization("O", generations=15)
