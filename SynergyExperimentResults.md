# Synergy Experiment Results: Tic-Tac-Toe Learning Analysis

## Executive Summary

This report summarizes the results of the Tic-Tac-Toe experiment using the **Synergy** framework (PLN + GP). The experiments evaluated the learning progress and reasoning capabilities of the agent against various adversaries of increasing complexity: **Random**, **GP6O** (Evolved GP O player), **GP12X** (Advanced evolved X player), and **MiniMax** (Perfect player).

The experiments were conducted under different configurations:

- **Standard/Sequential**: Baseline learning progression.
- **Advanced**: Integration of reasoning rules (symmetry) from `WM/permanent-belief.metta`.
- **Interleaved**: Testing resilience by interleaving different adversaries with MiniMax.

---

## 1. Experiment Configurations & Reasoning Rules

### 1.1 Reasoning Rules (Advanced Configuration)

In the "Advanced" runs, the agent utilized permanent beliefs related to board symmetry and game logic, as defined in `WM/permanent-belief.metta`:

- **Rules 0-1**: Board state to game outcome implications.
- **Rules 2-3**: Win/Loss duality (Win X implies Loss O).
- **Rule 4 (Horizontal Symmetry)**: Equivalence between board states when columns 1 and 3 are swapped.
- **Rule 5 (Vertical Symmetry)**: Equivalence between board states when top and bottom rows are swapped.

### 1.2 Learning Starting Points

The "Start" value in the results reflects the point in the training process where the test batch was executed (e.g., after 0, 37, 323, 435 games).

---

## 2. Results Tables

### 2.1 Standard & Sequential Runs (Baseline)

These runs show the baseline performance of the agent as it gains experience.

| Configuration | Start | Adversary | Total Games | Wins | Losses | Draws | Win % | PLN Move % |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Sequential | 0 | Random | 5 | 2 | 3 | 0 | 40.0% | 11.1% |
| Sequential | 0 | GP6O | 7 | 0 | 6 | 1 | 0.0% | 47.6% |
| Sequential | 0 | GP12X | 10 | 0 | 10 | 0 | 0.0% | 27.6% |
| Sequential | 0 | MiniMax | 15 | 0 | 11 | 4 | 0.0% | 47.1% |
| Sequential | 37 | Random | 5 | 4 | 0 | 1 | 80.0% | 40.0% |
| Sequential | 37 | GP6O | 7 | 3 | 4 | 0 | 42.9% | 62.5% |
| Sequential | 37 | GP12X | 10 | 2 | 7 | 1 | 20.0% | 66.7% |
| Sequential | 37 | MiniMax | 15 | 0 | 8 | 7 | 0.0% | 63.6% |
| Standard | 323 | Random | 5 | 1 | 3 | 1 | 20.0% | 50.0% |
| Standard | 323 | GP6O | 7 | 4 | 2 | 1 | 57.1% | 84.0% |
| Standard | 323 | GP12X | 10 | 5 | 4 | 1 | 50.0% | 85.7% |
| Standard | 323 | MiniMax | 15 | 0 | 7 | 8 | 0.0% | 62.3% |
| Standard | 435 | Random | 5 | 3 | 2 | 0 | 60.0% | 73.3% |
| Standard | 435 | GP6O | 7 | 4 | 2 | 1 | 57.1% | 96.3% |
| Standard | 435 | GP12X | 10 | 5 | 5 | 0 | 50.0% | 87.5% |
| Standard | 435 | MiniMax | 15 | 0 | 8 | 7 | 0.0% | 64.3% |

### 2.2 Advanced Runs (Symmetry Rules Enabled)

The integration of symmetry rules significantly boosts the agent's ability to generalize from fewer games.

| Configuration | Start | Adversary | Total Games | Wins | Losses | Draws | Win % | PLN Move % |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Advanced | 0 | Random | 5 | 5 | 0 | 0 | 100.0% | 15.0% |
| Advanced | 0 | GP6O | 7 | 2 | 4 | 1 | 28.6% | 38.5% |
| Advanced | 0 | GP12X | 10 | 4 | 5 | 1 | 40.0% | 56.4% |
| Advanced | 0 | MiniMax | 15 | 0 | 9 | 6 | 0.0% | 55.4% |
| Advanced | 47 | Random | 5 | 5 | 0 | 0 | 100.0% | 52.6% |
| Advanced | 47 | GP6O | 7 | 3 | 2 | 2 | 42.9% | 84.0% |
| Advanced | 47 | GP12X | 10 | 3 | 6 | 1 | 30.0% | 51.4% |
| Advanced | 47 | MiniMax | 15 | 0 | 8 | 7 | 0.0% | 61.8% |
| Advanced | 84 | Random | 5 | 3 | 2 | 0 | 60.0% | 35.0% |
| Advanced | 84 | GP6O | 7 | 4 | 1 | 2 | 57.1% | 92.3% |
| Advanced | 84 | GP12X | 10 | 4 | 3 | 3 | 40.0% | 69.2% |
| Advanced | 84 | MiniMax | 15 | 0 | 3 | 12 | 0.0% | 70.3% |

### 2.3 Interleaved Runs

Interleaving adversaries tests the agent's stability and ability to adapt to varying playstyles within a single session.

| Configuration | Start | Adversary | Total Games | Wins | Losses | Draws | Win % | PLN Move % |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Interleaved | 0 | Random | 5 | 4 | 0 | 1 | 80.0% | 15.8% |
| Interleaved | 0 | GP6O | 5 | 0 | 5 | 0 | 0.0% | 30.8% |
| Interleaved | 0 | GP12X | 5 | 0 | 5 | 0 | 0.0% | 31.3% |
| Interleaved | 0 | MiniMax | 15 | 0 | 4 | 11 | 0.0% | 47.6% |
| Interleaved | 68 | Random | 5 | 3 | 2 | 0 | 60.0% | 35.3% |
| Interleaved | 68 | GP6O | 5 | 0 | 5 | 0 | 0.0% | 40.0% |
| Interleaved | 68 | GP12X | 5 | 1 | 4 | 0 | 20.0% | 52.6% |
| Interleaved | 68 | MiniMax | 15 | 0 | 5 | 10 | 0.0% | 71.0% |

---

## 3. Key Observations & Analysis

### 3.1 Impact of Advanced Reasoning

The "Advanced" configuration shows a clear advantage in early-stage learning. At **Start 0**, the Advanced agent won **100%** of games against Random, compared to only **40%** in the Sequential baseline. By **Start 84**, the Advanced agent achieved a high draw rate (**12 out of 15**) against MiniMax, indicating it has learned to block winning moves effectively.

### 3.2 Performance Against MiniMax

Against the perfect MiniMax adversary, the goal is typically to achieve a draw.

- **Baseline (Start 0)**: 4 Draws / 11 Losses.
- **Advanced (Start 84)**: 12 Draws / 3 Losses.
- **Standard (Start 323)**: 8 Draws / 7 Losses.

The increase in draws and decrease in losses over time demonstrates successful learning of defensive patterns.

### 3.3 PLN Usage Growth

As the agent gains experience (higher Start numbers), the percentage of moves generated by PLN increases:

- **Sequential 0**: 11.1%
- **Standard 435**: 73.3% - 96.3%

This suggests that the agent is successfully transferring knowledge from its GP-driven exploration into its PLN-driven reasoning system.
