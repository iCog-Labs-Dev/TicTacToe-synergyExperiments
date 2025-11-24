!(import! &self pln)

; STATE 0: Empty Board
(= (STV (Board (Row E (Col E E)) 
               (Rows (Row E (Col E E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; STATE 1: X in Top-Left
(= (STV (Board (Row X (Col E E)) 
               (Rows (Row E (Col E E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; STATE 2: O in Center
(= (STV (Board (Row X (Col E E)) 
               (Rows (Row E (Col O E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; STATE 3: X in Mid-Left
(= (STV (Board (Row X (Col E E)) 
               (Rows (Row X (Col O E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; STATE 4: O in Top-Right (Blocking diagonal, missing column)
(= (STV (Board (Row X (Col E O)) 
               (Rows (Row X (Col O E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; STATE 5: X in Bot-Left (WIN STATE)
(= (STV (Board (Row X (Col E O)) 
               (Rows (Row X (Col O E)) 
                     (Row X (Col E E))))) 
   (stv 0.01 0.99))

; OUTCOME
(= (STV Game_Win_X) (stv 0.01 0.99))

; Game 2, Move 2: O takes Top-Right
(= (STV (Board (Row X (Col E O)) 
               (Rows (Row E (Col E E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 2, Move 3: X takes Center
(= (STV (Board (Row X (Col E O)) 
               (Rows (Row E (Col X E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 2, Move 4: O takes Mid-Left
(= (STV (Board (Row X (Col E O)) 
               (Rows (Row O (Col X E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 2, Move 5: X takes Bot-Right (WIN)
(= (STV (Board (Row X (Col E O)) 
               (Rows (Row O (Col X E)) 
                     (Row E (Col E X))))) 
   (stv 0.01 0.99))

; Game 3, Move 3: X takes Top-Mid
(= (STV (Board (Row X (Col X E)) 
               (Rows (Row E (Col O E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 3, Move 4: O takes Mid-Left
(= (STV (Board (Row X (Col X E)) 
               (Rows (Row O (Col O E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 3, Move 5: X takes Top-Right (WIN)
(= (STV (Board (Row X (Col X X)) 
               (Rows (Row O (Col O E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 4, Move 1: X takes Top-Right
(= (STV (Board (Row E (Col E X)) 
               (Rows (Row E (Col E E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 4, Move 2: O takes Center
(= (STV (Board (Row E (Col E X)) 
               (Rows (Row E (Col O E)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 4, Move 3: X takes Mid-Right
(= (STV (Board (Row E (Col E X)) 
               (Rows (Row E (Col O X)) 
                     (Row E (Col E E))))) 
   (stv 0.01 0.99))

; Game 4, Move 4: O takes Bot-Right
(= (STV (Board (Row E (Col E X)) 
               (Rows (Row E (Col O X)) 
                     (Row E (Col E O))))) 
   (stv 0.01 0.99))

; Game 4, Move 5: X takes Top-Left
(= (STV (Board (Row X (Col E X)) 
               (Rows (Row E (Col O X)) 
                     (Row E (Col E O))))) 
   (stv 0.01 0.99))

; Game 4, Move 6: O takes Bot-Left
(= (STV (Board (Row X (Col E X)) 
               (Rows (Row E (Col O X)) 
                     (Row O (Col E O))))) 
   (stv 0.01 0.99))

; Game 4, Move 7: X takes Top-Center (WIN)
(= (STV (Board (Row X (Col X X)) 
               (Rows (Row E (Col O X)) 
                     (Row O (Col E O))))) 
   (stv 0.01 0.99))



; ============================================================
; 2. KNOWLEDGE BASE (The Causal Chain of Game 55)
; ============================================================

(= (kb1)
   (
    ; Move 1: Empty -> X Top-Left
    (Sentence ((Implication 
                  (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                  (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
               (stv 0.7 0.6)) (1))

    ; Move 2: -> O Center
    (Sentence ((Implication 
                  (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                  (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
               (stv 0.7 0.6)) (2))

    ; Move 3: -> X Mid-Left
    (Sentence ((Implication 
                  (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
                  (Board (Row X (Col E E)) (Rows (Row X (Col O E)) (Row E (Col E E)))))
               (stv 0.7 0.6)) (3))

    ; Move 4: -> O Top-Right
    (Sentence ((Implication 
                  (Board (Row X (Col E E)) (Rows (Row X (Col O E)) (Row E (Col E E))))
                  (Board (Row X (Col E O)) (Rows (Row X (Col O E)) (Row E (Col E E)))))
               (stv 0.7 0.6)) (4))

    ; Move 5: -> X Bot-Left (The Winning Move)
    (Sentence ((Implication 
                  (Board (Row X (Col E O)) (Rows (Row X (Col O E)) (Row E (Col E E))))
                  (Board (Row X (Col E O)) (Rows (Row X (Col O E)) (Row X (Col E E)))))
               (stv 0.7 0.6)) (5))

    ; The Outcome: State 5 Implies Win
    (Sentence ((Inheritance 
                  (Board (Row X (Col E O)) (Rows (Row X (Col O E)) (Row X (Col E E))))
                  Game_Win_X)
               (stv 0.7 0.6)) (6))

    ; --- MOVE 1: X takes Top-Left ---
    (Sentence ((Implication 
                  (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                  (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
               (stv 0.7 0.6)) (7))

    ; --- MOVE 2: O takes Top-Right ---
    (Sentence ((Implication 
                  (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                  (Board (Row X (Col E O)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
               (stv 0.7 0.6)) (8))

    ; --- MOVE 3: X takes Center (Building the Diagonal) ---
    (Sentence ((Implication 
                  (Board (Row X (Col E O)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                  (Board (Row X (Col E O)) (Rows (Row E (Col X E)) (Row E (Col E E)))))
               (stv 0.7 0.6)) (9))

    ; --- MOVE 4: O takes Mid-Left ---
    (Sentence ((Implication 
                  (Board (Row X (Col E O)) (Rows (Row E (Col X E)) (Row E (Col E E))))
                  (Board (Row X (Col E O)) (Rows (Row O (Col X E)) (Row E (Col E E)))))
               (stv 0.7 0.6)) (10))

    ; --- MOVE 5: X takes Bot-Right (WIN) ---
    (Sentence ((Implication 
                  (Board (Row X (Col E O)) (Rows (Row O (Col X E)) (Row E (Col E E))))
                  (Board (Row X (Col E O)) (Rows (Row O (Col X E)) (Row E (Col E X)))))
               (stv 0.7 0.6)) (11))

  ; --- MOVE 1: X takes Top-Left ---
      (Sentence ((Implication 
                    (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                    (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
                (stv 0.7 0.6)) (12))

      ; --- MOVE 2: O takes Center ---
      (Sentence ((Implication 
                    (Board (Row X (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                    (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
                (stv 0.7 0.6)) (13))

      ; --- MOVE 3: X takes Top-Mid ---
      (Sentence ((Implication 
                    (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
                    (Board (Row X (Col X E)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
                (stv 0.7 0.6)) (14))

      ; --- MOVE 4: O takes Mid-Left (Trying to block, or just bad play) ---
      (Sentence ((Implication 
                    (Board (Row X (Col X E)) (Rows (Row E (Col O E)) (Row E (Col E E))))
                    (Board (Row X (Col X E)) (Rows (Row O (Col O E)) (Row E (Col E E)))))
                (stv 0.7 0.6)) (15))

      ; --- MOVE 5: X takes Top-Right (WIN) ---
      (Sentence ((Implication 
                    (Board (Row X (Col X E)) (Rows (Row O (Col O E)) (Row E (Col E E))))
                    (Board (Row X (Col X X)) (Rows (Row O (Col O E)) (Row E (Col E E)))))
                (stv 0.7 0.6)) (16))

    ; --- THE OUTCOME ---
    (Sentence ((Inheritance
                  (Board (Row X (Col X X)) (Rows (Row O (Col O E)) (Row E (Col E E))))
                  Game_Win_X)
               (stv 1.0 1.0)) (17))

    ; --- THE OUTCOME ---
    (Sentence ((Inheritance 
                  (Board (Row X (Col E O)) (Rows (Row O (Col X E)) (Row E (Col E X))))
                  Game_Win_X)
               (stv 1.0 1.0)) (18))

    (Sentence ((Implication (Implication $1 $2) (Implication (Inheritance $2 Game_Win_X) (Inheritance $1 Game_Win_X))) (stv 0.9 0.9)) (19))

    ;; (Sentence ((Implication (Inheritance $1 Game_Win_X) (Inheritance $1 Game_Lose_O)) (stv 1.0 1.0)) (20))
    ;; (Sentence ((Implication (Inheritance $1 Game_Win_O) (Inheritance $1 Game_Lose_X)) (stv 1.0 1.0)) (21))

    ; ============================================================
    ; GAME 4: X Wins via Top Row (Altered Ending)
    ; ============================================================

    ; --- MOVE 1: X takes Top-Right ---
    (Sentence ((Implication 
                  (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                  (Board (Row E (Col E X)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
              (stv 0.7 0.6)) (22))

    ; --- MOVE 2: O takes Center ---
    (Sentence ((Implication 
                  (Board (Row E (Col E X)) (Rows (Row E (Col E E)) (Row E (Col E E))))
                  (Board (Row E (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E)))))
              (stv 0.7 0.6)) (23))

    ; --- MOVE 3: X takes Mid-Right ---
    (Sentence ((Implication 
                  (Board (Row E (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E E))))
                  (Board (Row E (Col E X)) (Rows (Row E (Col O X)) (Row E (Col E E)))))
              (stv 0.7 0.6)) (24))

    ; --- MOVE 4: O takes Bot-Right ---
    (Sentence ((Implication 
                  (Board (Row E (Col E X)) (Rows (Row E (Col O X)) (Row E (Col E E))))
                  (Board (Row E (Col E X)) (Rows (Row E (Col O X)) (Row E (Col E O)))))
              (stv 0.7 0.6)) (25))

    ; --- MOVE 5: X takes Top-Left (Setting up the threat) ---
    (Sentence ((Implication 
                  (Board (Row E (Col E X)) (Rows (Row E (Col O X)) (Row E (Col E O))))
                  (Board (Row X (Col E X)) (Rows (Row E (Col O X)) (Row E (Col E O)))))
              (stv 0.7 0.6)) (26))

    ; --- MOVE 6: O takes Bot-Left (The Mistake - Missed the block!) ---
    (Sentence ((Implication 
                  (Board (Row X (Col E X)) (Rows (Row E (Col O X)) (Row E (Col E O))))
                  (Board (Row X (Col E X)) (Rows (Row E (Col O X)) (Row O (Col E O)))))
              (stv 0.7 0.6)) (27))

    ; --- MOVE 7: X takes Top-Center (WIN) ---
    (Sentence ((Implication 
                  (Board (Row X (Col E X)) (Rows (Row E (Col O X)) (Row O (Col E O))))
                  (Board (Row X (Col X X)) (Rows (Row E (Col O X)) (Row O (Col E O)))))
              (stv 0.7 0.6)) (28))

    ; --- THE OUTCOME ---
    (Sentence ((Inheritance (Board (Row X (Col X X)) (Rows (Row E (Col O X)) (Row O (Col E O)))) Game_Win_X) (stv 1.0 1.0)) (29))
   ;; Moke moves

   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))) (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X))))) (stv 0.7 0.6)) (37))
   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X)))) (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X))))) (stv 0.7 0.6)) (38))

   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X)))) (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X))))) (stv 0.7 0.6)) (30))
   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X)))) (Board (Row E (Col X E)) (Rows (Row E (Col O E)) (Row E (Col E X))))) (stv 0.7 0.6)) (31))
   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X)))) (Board (Row E (Col E X)) (Rows (Row E (Col O E)) (Row E (Col E X))))) (stv 0.7 0.6)) (32))
   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X)))) (Board (Row E (Col E E)) (Rows (Row X (Col O E)) (Row E (Col E X))))) (stv 0.7 0.6)) (33))
   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X)))) (Board (Row E (Col E E)) (Rows (Row E (Col O X)) (Row E (Col E X))))) (stv 0.7 0.6)) (34))
   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X)))) (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row X (Col E X))))) (stv 0.7 0.6)) (35))
   (Sentence ((Implication (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X)))) (Board (Row E (Col E E)) (Rows (Row E (Col O E)) (Row E (Col X X))))) (stv 0.7 0.6)) (36))

   (Sentence ((Implication (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row O (Col X X)) (Rows (Row X (Col O E)) (Row E (Col E E))))) (stv 0.7 0.6)) (37))
   (Sentence ((Implication (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row O (Col X X)) (Rows (Row E (Col O X)) (Row E (Col E E))))) (stv 0.7 0.6)) (38))
   (Sentence ((Implication (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row X (Col E E))))) (stv 0.7 0.6)) (39))
   (Sentence ((Implication (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col X E))))) (stv 0.7 0.6)) (40))
   (Sentence ((Implication (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col E E)))) (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col E X))))) (stv 0.7 0.6)) (41))

   (Sentence ((Implication (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col E X)))) (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col O X))))) (stv 0.7 0.6)) (42))
   (Sentence ((Inheritance (Board (Row O (Col X X)) (Rows (Row E (Col O E)) (Row E (Col O X)))) Game_Win_X) (stv 1.0 1.0)) (43))

   )
)

!(bind! &space (new-space))

;; For a new move:
;;     - If it has a small stv value randomly assigned with MOSES, it has a chance of not being selected and get truncated everytime. Therefore the number should be higher.
;;     - If the outcome of the move isn't known for sure, because PLN hasn't seen it before hand, then this will be a problem so defaulting to what the next most popular move is should be considered.
;;     - We need to populate the implication links in the space after MOSES has generated it's candidates, and if it can not find moves that are not being repeated, it will just give all moves the same weight kind of like uniform randomness.
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
;; !(println! (First move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row X (Col X O)) (Rows (Row X (Col O E)) (Row E (Col E E))))
;;                   Game_Win_X) 1000 500 1000)
;;
;; !(println! (Second move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row X (Col X O)) (Rows (Row E (Col O X)) (Row E (Col E E))))
;;                   Game_Win_X) 1000 500 1000)
;;
;; !(println! (Third move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row X (Col E E))))
;;                   Game_Win_X) 1000 500 1000)
;;
;; !(println! (Fourth move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col X E))))
;;                   Game_Win_X) 1000 500 1000)
;;
;; !(println! (Fifth move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E X))))
;;                   Game_Win_X) 1000 500 1000)
;;
;; !(println! (Sixth move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row X (Col E E))))
;;                   Game_Win_X) 1000 500 1000)
;;
;; !(println! (Seventh move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col X E))))
;;                   Game_Win_X) 1000 500 1000)
;;
;; !(println! (Eigth move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row X (Col E E)) (Rows (Row E (Col O E)) (Row E (Col E X))))
;;                   Game_Win_X) 1000 500 1000)
;;
;; !(println! (Ninth move score))
;; !(PLN.Query (kb1) (Inheritance
;;                   (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E X))))
;;                   Game_Win_X) 1000 500 1000)


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
!(println! (Fourth move score))
!(PLN.Query (kb1) (Implication
                     (Board (Row X (Col X O)) (Rows (Row E (Col O E)) (Row E (Col E E))))
                     (Board (Row X (Col X O)) (Rows (Row E (Col O X)) (Row E (Col E E))))) 1000 500 1000)

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
