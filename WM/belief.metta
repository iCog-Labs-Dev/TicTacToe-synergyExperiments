(Sentence ((Implication (Implication (Board $1 $1s) (Board $2 $2s)) (Implication (Inheritance (Board $2 $2s) Game_Win_X) (Inheritance (Board $1 $1s) Game_Win_X))) (stv 0.9 0.9)) (0))
(Sentence ((Implication (Implication (Board $1 $1s) (Board $2 $2s)) (Implication (Inheritance (Board $2 $2s) Game_Win_O) (Inheritance (Board $1 $1s) Game_Win_O))) (stv 0.9 0.9)) (1))
(Sentence ((Implication (Inheritance $1 Game_Win_X) (Inheritance $1 Game_Lose_O)) (stv 0.9 0.9)) (2))
(Sentence ((Implication (Inheritance $1 Game_Win_O) (Inheritance $1 Game_Lose_X)) (stv 0.9 0.9)) (3))
(Sentence ((Equivalence (Board (Row $TL (Col $TC $TR)) (Rows (Row $ML (Col $MC $MR)) (Row $BL (Col $BC $BR)))) (Board (Row $TR (Col $TC $TL)) (Rows (Row $MR (Col $MC $ML)) (Row $BR (Col $BC $BL))))) (stv 0.9 0.9)) (4))
(Sentence ((Equivalence (Board $TopRow (Rows $MidRow $BotRow)) (Board $BotRow (Rows $MidRow $TopRow))) (stv 0.9 0.9)) (5))





