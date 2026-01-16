!(import! &self helpers)
!(import! &self minimax-player)
!(import! &self random-player)
!(import! &self "../gp12_x_player.py")
!(import! &self "../gp6_o_player.py")
!(import! &self ../utils)
!(import! &self gp-12-x-player)
!(import! &self gp-6-o-player)

!(test (minimax-player (E E E E E E E E E) X) (0 (X E E E E E E E E)))
!(test (minimax-player (X O X E O E X E E) O) (7 (X O X E O E X O E)))

!(py-call (random.seed 42))
!(test (random-player (X O X E O E X E E) O) (3 (X O X O O E X E E)))

!(test (gpPlayer6 (X O X E O E X E E) O) (3 (X O X O O E X E E)))
!(test (gpPlayer6 (X O X E O E X E E) X) (7 (X O X E O E X X E)))

!(test (gpPlayer12 (X O X E O E X E E) O) (3 (X O X O O E X E E)))
!(test (gpPlayer12 (X O X E O E X E E) X) (7 (X O X E O E X X E)))
