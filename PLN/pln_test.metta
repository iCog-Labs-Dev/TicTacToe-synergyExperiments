!(import! &self pln)

!(bind! &perception (new-space))
!(bind! &belief (new-space))
!(bind! &count (new-state 39))


(= (K) 50)

!(let $perception
      (superpose
        (
          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))))
          (Inheritance (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))) Game_Win_X)

          (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X))))

          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E)))))
          (Inheritance (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E)))) Game_Win_O)

          (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E))))
          (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E))))
          (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E))))

          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E O)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col X E)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E O)) (Rows (Row E (Col X E)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))))
          (Implication (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X)))))
          (Inheritance (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X)))) Game_Win_X)

          (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E O)) (Rows (Row E (Col E E)) (Row E (Col E E))))
          (Board (Row X (Col E O)) (Rows (Row E (Col X E)) (Row E (Col E E))))
          (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E))))
          (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X))))


          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X)))))
          (Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X)))) (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X)))))

        ) ;; Manually inputed space content. It should be updated to be persistent.
      )
      (add-atom &perception $perception))



!(let $belief
      (superpose
        (
           (Sentence ((Implication (Implication $1 $2) (Implication (Inheritance $2 Game_Win_X) (Inheritance $1 Game_Win_X))) (stv 1.0 1.0)) (0))
           (Sentence ((Implication (Implication $1 $2) (Implication (Inheritance $2 Game_Win_O) (Inheritance $1 Game_Win_O))) (stv 1.0 1.0)) (1))
           (Sentence ((Implication (Inheritance $1 Game_Win_X) (Inheritance $1 Game_Lose_O)) (stv 1.0 1.0)) (2))
           (Sentence ((Implication (Inheritance $1 Game_Win_O) (Inheritance $1 Game_Lose_X)) (stv 1.0 1.0)) (3))
           (Sentence ((Equivalence (Board (Row $TL (Col $TC $TR)) (Rows (Row $ML (Col $MC $MR)) (Row $BL (Col $BC $BR)))) (Board (Row $TR (Col $TC $TL)) (Rows (Row $MR (Col $MC $ML)) (Row $BR (Col $BC $BL))))) (stv 1.0 1.0)) (4))
           (Sentence ((Equivalence (Board $TopRow (Rows $MidRow $BotRow)) (Board $BotRow (Rows $MidRow $TopRow))) (stv 1.0 1.0)) (5))
           ;; (Sentence ((Equivalence (Board (Row $00 (Col $01 $02)) (Rows (Row $10 (Col $11 $12)) (Row $20 (Col $21 $22)))) (Board (Row $20 (Col $10 $00)) (Rows (Row $21 (Col $11 $01)) (Row $22 (Col $12 $02))))) (stv 1.0 1.0)) (72))
           ;; (Sentence ((Equivalence (Board (Row $00 (Col $01 $02)) (Rows (Row $10 (Col $11 $12)) (Row $20 (Col $21 $22)))) (Board (Row $22 (Col $12 $02)) (Rows (Row $21 (Col $11 $01)) (Row $20 (Col $10 $00))))) (stv 1.0 1.0)) (73))
           ;; (Sentence ((Equivalence (Board (Row $00 (Col $01 $02)) (Rows (Row $10 (Col $11 $12)) (Row $20 (Col $21 $22)))) (Board (Row $00 (Col $10 $20)) (Rows (Row $01 (Col $11 $21)) (Row $02 (Col $12 $22))))) (stv 1.0 1.0)) (74))

           (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))) (stv 0.08334166666666666 0.1935483870967742)) (6))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E))))) (stv 0.08334166666666666 0.1935483870967742)) (7))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E))))) (stv 0.08334166666666666 0.1935483870967742)) (8))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E))))) (stv 0.08334166666666666 0.1935483870967742)) (9))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X))))) (stv 0.08334166666666666 0.1935483870967742)) (10))
           (Sentence ((Inheritance (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))) Game_Win_X) (stv 1.0 1.0)) (11))
           (Sentence ((Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.08334166666666666 0.1935483870967742)) (12))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.08334166666666666 0.1935483870967742)) (13))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E)))) (stv 0.08334166666666666 0.1935483870967742)) (14))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E)))) (stv 0.08334166666666666 0.1935483870967742)) (15))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E)))) (stv 0.08334166666666666 0.1935483870967742)) (16))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))) (stv 0.08334166666666666 0.1935483870967742)) (17))

           (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))) (stv 0.07692692307692309 0.34210526315789475)) (18))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E))))) (stv 0.03846538461538462 0.34210526315789475)) (19))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E))))) (stv 0.03846538461538462 0.34210526315789475)) (20))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E))))) (stv 0.03846538461538462 0.34210526315789475)) (21))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X))))) (stv 0.03846538461538462 0.34210526315789475)) (22))
           (Sentence ((Inheritance (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))) Game_Win_X) (stv 1.0 1.0)) (23))
           (Sentence ((Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.07692692307692309 0.34210526315789475)) (24))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.07692692307692309 0.34210526315789475)) (25))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E)))) (stv 0.03846538461538462 0.34210526315789475)) (26))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E)))) (stv 0.03846538461538462 0.34210526315789475)) (27))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E)))) (stv 0.03846538461538462 0.34210526315789475)) (28))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))) (stv 0.03846538461538462 0.34210526315789475)) (29))

           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))) (stv 0.03846538461538462 0.34210526315789475)) (30))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))) (stv 0.03846538461538462 0.34210526315789475)) (31))
           (Sentence ((Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E))))) (stv 0.03846538461538462 0.34210526315789475)) (32))
           (Sentence ((Implication (Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E))))) (stv 0.03846538461538462 0.34210526315789475)) (33))
           (Sentence ((Implication (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E))))) (stv 0.03846538461538462 0.34210526315789475)) (34))
           (Sentence ((Inheritance (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E)))) Game_Win_O) (stv 1.0 1.0)) (34))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (stv 0.03846538461538462 0.34210526315789475)) (35))
           (Sentence ((Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (stv 0.03846538461538462 0.34210526315789475)) (36))
           (Sentence ((Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (stv 0.03846538461538462 0.34210526315789475)) (37))
           (Sentence ((Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E)))) (stv 0.03846538461538462 0.34210526315789475)) (38))
           (Sentence ((Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E)))) (stv 0.03846538461538462 0.34210526315789475)) (39))

           (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))) (stv 0.07895 0.4318181818181818)) (40))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (41))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (42))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E))))) (stv 0.026318421052631578 0.4318181818181818)) (43))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E)))) (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X))))) (stv 0.026318421052631578 0.4318181818181818)) (44))
           (Sentence ((Inheritance (Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))) Game_Win_X) (stv 1.0 1.0)) (45))
           (Sentence ((Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.07895 0.4318181818181818)) (46))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.07895 0.4318181818181818)) (47))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row O (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (48))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (49))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O E)))) (stv 0.026318421052631578 0.4318181818181818)) (50))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col X E)) (Row O (Col O X)))) (stv 0.026318421052631578 0.4318181818181818)) (51))

           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (52))
           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (53))
           (Sentence ((Implication (Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (54))
           (Sentence ((Implication (Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (55))
           (Sentence ((Implication (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E)))) (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E))))) (stv 0.026318421052631578 0.4318181818181818)) (56))
           (Sentence ((Inheritance (Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E)))) Game_Win_O) (stv 1.0 1.0)) (57))
           (Sentence ((Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (58))
           (Sentence ((Board (Row X (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (59))
           (Sentence ((Board (Row X (Col O X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (60))
           (Sentence ((Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (61))
           (Sentence ((Board (Row X (Col O X)) (Rows (Row E (Col O X)) (Row E (Col O E)))) (stv 0.026318421052631578 0.4318181818181818)) (62))

           (Sentence ((Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col E E)) (Row E (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (63))
           (Sentence ((Implication (Board (Row X (Col E O)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col X E)) (Row E (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (64))
           (Sentence ((Implication (Board (Row X (Col E O)) (Rows (Row E (Col X E)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E))))) (stv 0.026318421052631578 0.4318181818181818)) (65))
           (Sentence ((Implication (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))) (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X))))) (stv 0.026318421052631578 0.4318181818181818)) (66))
           (Sentence ((Inheritance (Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X)))) Game_Win_X) (stv 1.0 1.0)) (67))
           (Sentence ((Board (Row X (Col E O)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (68))
           (Sentence ((Board (Row X (Col E O)) (Rows (Row E (Col X E)) (Row E (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (69))
           (Sentence ((Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E E)))) (stv 0.026318421052631578 0.4318181818181818)) (70))
           (Sentence ((Board (Row X (Col E O)) (Rows (Row E (Col X O)) (Row E (Col E X)))) (stv 0.026318421052631578 0.4318181818181818)) (71))

           ;; Moked moves
        ) ;; Manually inputed space content. It should be updated to be persistent.
      )
      (add-atom &belief $belief))

(= (STV $fact)
          (let*
            (
              ($m (foldl-atom (if (= $fact ($link $a $b)) (collapse (match &perception $fact 1)) (collapse (match &perception ($link $a $fact) 1))) 0 +)) ;; Positive count
              ($N (foldl-atom (collapse (match &perception $x 1)) 0 +)) ;; Total count
            )
            (stv (/ (+ $m 0.0001) $N) (/ $N (+ $N (K)))))
          )

(= (increment $state) (let $n (get-state $state) (let $_ (change-state! $state (+ $n 1)) (get-state $state))))
(= (update-atom $space $old $new) (match $space $old (let $_ (remove-atom $space $old) (add-atom $space $new))))

(= (populate-belief $atoms)
   (let*
      (
        ($updatedPercept' (collapse (let $percept (superpose $atoms) ($percept (STV $percept)))))
        ($updatedPercept (unique-atom $updatedPercept'))
        ($revisedPercepts (collapse (let*
               (
                 (($percept $stvN) (superpose $updatedPercept))
                 ((Sentence ($percept $stv) $Ev) (get-atoms &belief))
                 ((Sentence ($percept $stvU) $Ev) (BestCandidate PriorityRank () (collapse (|- ($percept $stv) ($percept $stvN)))))
                 ($_ (update-atom &belief (Sentence ($percept $stv) $Ev) (Sentence ($percept $stvU) $Ev)))
               )
               $percept)))
        ($revisedPercepts' (unique-atom $revisedPercepts))
        ($newBeliefs (subtraction-atom $updatedPercept $revisedPercepts'))
        ($_ (collapse (let*
                         (
                           (($percept $stvN) (superpose $newBeliefs))
                           ($i (increment &count))
                         )
                         (add-atom &belief (Sentence ($percept $stvN) ($i))))))
      )
      (get-atoms &belief))
)

;; !(populate-belief (get-atoms &perception))
;; !(STV Game_Win_O)


;; INFO: For a new move:
;;     - If it has a small stv value randomly assigned with MOSES, it has a chance of not being selected and get truncated everytime. Therefore the number should be higher. 
;;     - Not both the strength and the confidence have to be higher, the confidence is the most determining factor here. For some reason if the confidence is too low, it will be truncated. We can mitigate this by increasing the step size but it is not reliable. For comparison, with iteration 500 and task size of 500, it can't find reliable results when K > 66 but for 1000 step size keeping task size the same, it can support all the way upto 700.
;;     - If the outcome of the move isn't known for sure, because PLN hasn't seen it before hand, then this will be a problem so defaulting to what the next most popular move is should be considered.
;;     - We need to populate the implication links in the space after MOSES has generated it's candidates, and if it can not find moves that are not being repeated, it will just give all moves the same weight kind of like uniform randomness.
;;     - Adding single board state moves will also be needed for computing STV values for a single game.
;;     - If you change the pln to check with unification instead of equality, can query for the next best move but with the risk of generating an invalid move. Not that it matters a lot though. Because the invalid move will most likely have a lower stv value so you can filter it out. But it can still turn up if the exact generalized rule can be matched. Unless there's a way to deal with that, it is best to stick with the concrete query, or atleast as concrete as possible. (This is happening by matching the move on its self and succeeding the unification hence being returned)
;;
; !(let* (
;          ($query (Inheritance (Board (Row X (Col E E))
;                                (Rows (Row E (Col E E))
;                                      (Row E (Col E E)))) Game_Win_X))
;          ($Nothing (collapse (let $result  (PLN.Query (kb1) $query 700 100 700) (add-atom &space $result))))
;       )
;       (println! (match &space (Sentence ($query $stv) $proof) (Sentence ($query $stv) $proof)))
; )

;; Winning move
;; !(println! (First move score)) ;; 1 2 4
;; !(let*
;;    (
;;       (($bestCandidate $belief) (PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row X (Col E X)))) Game_Win_X) 400 200 300))
;;       ;; (($bestCandidate $belief) (PLN.Query (collapse (get-atoms &belief)) (Implication (Board (Row E (ColE E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X))))) 400 200 300))
;;       ;; ($_ (println! (Best Candidate STV: $bestCandidate)))
;;       ;; ($beliefs (collapse (populate-belief $belief)))
;;    )
;;    $bestCandidate)
;; !(println! (First move score)) ;; 1 2 4
;; !(println! "Hello")
!(PLN.Query (collapse (get-atoms &belief)) (Implication (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row X (Col $b $c)) (Rows (Row $d (Col $a $e)) (Row $f (Col $g $h))))) 2000 500 2000)

;; !(PLN.Query (collapse (get-atoms &belief)) (Implication (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))) 200 100 200)

; !(println! (Second move score))
!(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col X E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Third move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E X)) (Rows (Row E (Col E E)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Fourth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row X (Col E E)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Fifth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col X E)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Sixth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col E X)) (Row E (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Seventh move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row X (Col E E)))) Game_Win_X) 200 100 200)

; !(println! (Eigth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col X E)))) Game_Win_X) 200 100 200)

; !(println! (Ninth move score))
; !(PLN.Query (collapse (get-atoms &belief)) (Inheritance (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X)))) Game_Win_X) 200 100 200)


;; Most common move
;; !(println! (First move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E X))))) 1000 500 1000)
;;
;; !(println! (Second move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col X E))))) 1000 500 1000)
;;
;; !(println! (Third move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row X (Col E E))))) 1000 500 1000)
;;
;; !(println! (Fourth move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O X)) (Row E (Col E E))))) 1000 500 1000)
;;
;; !(println! (Fifth move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row X (Col O E)) (Row E (Col E E))))) 1000 500 1000)
;;
;; !(println! (Sixth move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))) 1000 500 1000)
;;
;; !(println! (Seventh move score))
;; !(PLN.Query (kb1) (Implication
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
;;                      (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E #))))) 1000 500 1000)


