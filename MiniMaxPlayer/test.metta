!(import! &self helpers)
!(import! &self minimax-player)

!(test (minimax-player (E E E E E E E E E) X) (0 (X E E E E E E E E)))
!(test (minimax-player (X O X E O E X E E) O) (7 (X O X E O E X O E)))
