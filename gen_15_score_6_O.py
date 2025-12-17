from game_engine import GameActions, Board, X_MARK, O_MARK

# Generation: 15
# Fitness: 6.0
# Player: O

def run_policy(board, player_mark):
    # Try BLOCK
    success, new_board = GameActions.play_block(board, player_mark)
    if success:
        return new_board

    # Try CORNERS
    success, new_board = GameActions.play_corners(board, player_mark)
    if success:
        return new_board

    # Try SIDES
    success, new_board = GameActions.play_sides(board, player_mark)
    if success:
        return new_board

    # Try BLOCK
    success, new_board = GameActions.play_block(board, player_mark)
    if success:
        return new_board

    # Try CORNERS
    success, new_board = GameActions.play_corners(board, player_mark)
    if success:
        return new_board

    return None
