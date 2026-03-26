# Tic-Tac-Toe Experiment: PLN, Pattern Miner, and MOSES Integration

This experiment explores the synergy between **PLN**, **Pattern Miner**, and **MOSES** using Tic-Tac-Toe as a proof-of-concept for integrated learning.

## Key Components

### 1. Multi-Tiered Memory System
- **Perception Memory**: Stores raw game histories and move sequences.
- **Beliefs Memory**: Active learning layer using **STV (Strength and Trust Value)** and a **Skepticism (K)** hyperparameter for unique, non-redundant knowledge.
- **Permanent Beliefs**: Initial background knowledge and storage for Pattern Miner results.

### 2. PLN (Game Driver)
- **Search Strategy**: Prioritizes winning moves, then draws, then frequent moves.
- **Enhancements**: Implemented **Priority-Based Querying**, **Thompson Sampling** (exploration vs. exploitation), and an **Adapted Backward Chainer** for significant performance gains.

### 3. MOSES (GP Strategy Evolution)
- **Fallback Mechanism**: Generates move strategies when PLN lacks sufficient experience.
- **Evolved Policies**: Actions include prioritized checks for corners, sides, centers, wins, and blocks.
- **Fitness**: Evaluated against random and minimax players to evolve robust strategies.

### 4. Pattern Miner
- **Logics Discovery**: Successfully identified frequent patterns (e.g., adjacent move logic) from mock datasets.
- **Integration**: Ongoing work to scale history data for deeper integration with the reasoning layer.

## Future Direction
The integration enables a self-improving system where STVs converge over time to favor winning strategies and discard sub-optimal moves, demonstrating a functional pipeline for cross-component AI learning.
