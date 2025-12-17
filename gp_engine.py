import random
import copy
from game_engine import (
    ACTION_MAP,
    Board,
    HammingScorer,
    X_MARK,
    O_MARK,
    RandomOpponent,
    MinimaxOpponent,
)


class PolicyGenome:
    """
    Represents a strategy as a prioritized list of Action Keys.
    Example: ["WIN", "BLOCK", "CORNERS"]
    Execution: Try WIN. If fail, Try BLOCK. If fail, Try CORNERS.
    """

    def __init__(self, actions=None):
        if actions:
            self.actions = actions
        else:
            # Random initialization
            keys = list(ACTION_MAP.keys())
            # Random length between 1 and 5
            length = random.randint(1, 5)
            self.actions = [random.choice(keys) for _ in range(length)]

        self.fitness = 0.0

    def execute(self, board, player_mark):
        """
        Runs the decision list. Returns the new board state if a move is made.
        If NO action succeeds (e.g. policy is empty or inapplicable), returns None.
        """
        for action_key in self.actions:
            func = ACTION_MAP[action_key]
            success, new_board = func(board, player_mark)
            if success:
                return new_board
        return None

    def __str__(self):
        return " -> ".join(self.actions)


class GPEngine:
    def __init__(
        self, target_player, pop_size=20, mutation_rate=0.2, crossover_rate=0.7
    ):
        self.target_player = target_player
        self.pop_size = pop_size
        self.mutation_rate = mutation_rate
        self.crossover_rate = crossover_rate
        self.population = [PolicyGenome() for _ in range(pop_size)]
        self.available_genes = list(ACTION_MAP.keys())

    def evaluate_fitness(self, policy):
        """
        Score against:
        1. Random Opponent (5 games)
        2. Minimax Depth 1 (2 games)
        3. Minimax Depth 2 (2 games)
        4. Minimax Depth 3 (2 games)
        5. Minimax Depth 4 (2 games)

        Metric: Distance Advantage.
        """
        opponents = [
            (RandomOpponent(), 5),
            (MinimaxOpponent(1), 2),
            (MinimaxOpponent(2), 2),
            (MinimaxOpponent(3), 2),
            (MinimaxOpponent(4), 2),
        ]

        total_score = 0
        total_games = 0

        for opp, rounds in opponents:
            for _ in range(rounds):
                score = self.play_single_game(policy, opp)
                total_score += score
                total_games += 1

        # Normalize (Higher is better)
        policy.fitness = total_score

    def play_single_game(self, policy, opponent):
        board = Board()
        current_turn = X_MARK  # X always starts

        opponent_mark = O_MARK if self.target_player == X_MARK else X_MARK

        while not board.is_full() and HammingScorer.check_winner(board) is None:
            if current_turn == self.target_player:
                # My Policy Turn
                new_board = policy.execute(board, self.target_player)
                if new_board is None:
                    # Policy failed to return a move (e.g. empty list or no applicable actions)
                    # This is a critical failure (Forfeit)
                    # Return huge penalty
                    return -10
                board = new_board
            else:
                # Opponent Turn
                move = opponent.get_move(board, opponent_mark)
                if move is not None:
                    board.make_move(move, opponent_mark)

            # Switch turn
            current_turn = O_MARK if current_turn == X_MARK else X_MARK

        # Game Over - Calculate Distance Score
        dist_me = HammingScorer.get_distance_to_win(board, self.target_player)
        dist_opp = HammingScorer.get_distance_to_win(board, opponent_mark)

        # Scoring Logic
        # Closer to 0 is better.
        if dist_me < dist_opp:
            return 1.0  # Win (Distance Advantage)
        elif dist_me > dist_opp:
            return -1.0  # Loss
        else:
            return 0.0  # Draw

    def select_parent(self):
        # Tournament Selection
        k = 3
        tournament = random.sample(self.population, k)
        return max(tournament, key=lambda p: p.fitness)

    def crossover(self, parent1, parent2):
        if random.random() > self.crossover_rate:
            return PolicyGenome(parent1.actions.copy())

        # Single Point Crossover
        # Ensure we don't create empty policies if possible
        pt1 = random.randint(0, len(parent1.actions))
        pt2 = random.randint(0, len(parent2.actions))

        # Child takes head of P1 and tail of P2
        new_actions = parent1.actions[:pt1] + parent2.actions[pt2:]

        # Safety: If empty, fill with random
        if not new_actions:
            new_actions = [random.choice(self.available_genes)]

        return PolicyGenome(new_actions)

    def mutate(self, policy):
        if random.random() > self.mutation_rate:
            return

        # 3 Types of Mutation
        mut_type = random.choice(["ADD", "REMOVE", "SWAP", "CHANGE"])
        actions = policy.actions

        if mut_type == "ADD":
            idx = random.randint(0, len(actions))
            gene = random.choice(self.available_genes)
            actions.insert(idx, gene)

        elif mut_type == "REMOVE" and len(actions) > 1:
            idx = random.randint(0, len(actions) - 1)
            actions.pop(idx)

        elif mut_type == "SWAP" and len(actions) > 1:
            idx1, idx2 = random.sample(range(len(actions)), 2)
            actions[idx1], actions[idx2] = actions[idx2], actions[idx1]

        elif mut_type == "CHANGE":
            idx = random.randint(0, len(actions) - 1)
            actions[idx] = random.choice(self.available_genes)

    def step_generation(self):
        # 1. Evaluate
        for p in self.population:
            self.evaluate_fitness(p)

        # 2. Sort
        self.population.sort(key=lambda p: p.fitness, reverse=True)

        # 3. Elitism (Keep top 2)
        next_gen = [
            copy.deepcopy(self.population[0]),
            copy.deepcopy(self.population[1]),
        ]

        # 4. Breed
        while len(next_gen) < self.pop_size:
            p1 = self.select_parent()
            p2 = self.select_parent()
            child = self.crossover(p1, p2)
            self.mutate(child)
            next_gen.append(child)

        self.population = next_gen
        return self.population[0]  # Return best
