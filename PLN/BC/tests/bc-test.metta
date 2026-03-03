!(import! &self ../utilities/helpers)
!(import! &self ../forward-chaining-pln)

!(import! &self ../syllogisitic-deduction)
!(import! &self ../modus-ponens)
!(import! &self ../inversion)
!(import! &self ../induction)
!(import! &self ../abduction)

!(import! &self ../lookup)
!(import! &self ./game-data)
!(import! &self ../main-loop)

; !(bc-drive &self 
;       (GameWin X)
;     ())

; !(pln-bc &self 
;       (GameWin X)
;       (S (S Z)) ())   

; !(match &self (Sentence ((Inheritance $x  (GameWin X)) $stv) $stamp) $stamp)
; !(match &self (= (pln-bc $x $y $z $a) $body) $body)
; !(match &self (= (step-lookup $kb $goal) $body) $body)


; !(bind! &kb (new-space))
; ; !(add-atom &kb (Sentence ((Inheritance rain fall) (stv 0.4 0.52))  (1)))                        
; ; !(add-atom &kb (Sentence ((Inheritance rain fall) (stv 0.4 0.52))  (1)))                        
; !(add-atom &kb (Sentence ((Inheritance slippery fall) (stv 0.45 0.752))  (2)))         
; !(add-atom &kb (Sentence (rain (stv 0.9 0.8)) (3)))               
; !(add-atom &kb (Sentence (slippery (stv 0.7 0.8)) (4)))               
; !(add-atom &kb (Sentence (fall (stv 0.6 0.6)) (5)))               

; !(step-lookup &kb rain)
; !(syllo-deduction (Inheritance rain fall) &kb (S (S Z)) ())

; !(Truth_Deduction (stv 0.6 0.78)
;                     (stv 0.6 0.7)
;                     (stv 0.6 0.7)
;                     (stv 0.6 0.7)
;                     (stv 0.6 0.7))
; !(getNodeSTV &kb rain)

; !(add-atom &kb (Sentence ((Inheritance animal cat) (stv 0.6 0.7)) (1)))

; !(add-atom &kb (Sentence (cat (stv 0.7 0.8)) (2)))


; !(inversion &kb (Inheritance cat animal) (S (S Z)) ())  

; !(bind! &kb (new-space))

; !(add-atom &kb (Sentence ((Implication dog bite) (stv 0.6 0.6)) (1)))
; !(add-atom &kb (Sentence ((Implication cat bite) (stv 0.7 0.7)) (3)))

; !(add-atom &kb (Sentence (dog (stv 0.7 0.98)) (32)))
; !(add-atom &kb (Sentence (cat (stv 0.6 0.99)) (33)))
; !(add-atom &kb (Sentence (animal (stv 0.7 0.7)) (3345)))

; !(pln-bc &kb  bite (S (S Z)) ())

; !(bind! &kb (new-space))

; !(add-atom &kb (Sentence ((Implication dog bite) (stv 0.6 0.6)) (1)))
; !(add-atom &kb (Sentence ((Implication cat bite) (stv 0.7 0.7)) (3)))

; !(add-atom &kb (Sentence (dog (stv 0.7 0.98)) (32)))
; !(add-atom &kb (Sentence (cat (stv 0.6 0.99)) (33)))

; !(modus-ponens &kb bite (S (S Z)) ())

; ; !(match &self (= (modus-ponens $x $xy $y $z) $body) $body)

; ; !(add 2 3)

; !(stamp disjoint (StampDisjoint (1 2) (3 4)))
; !(syllogisitic rule guard (SyllogisticRuleGuard Inheritance))

; !(step-lookup &self (Board (Row E (Col E E)) (Rows (Row E (Col E E)) (Row E (Col E E)))))
;; straight lookup works

;; Testing inversion rules
; !(bind! &kb (new-space))
; !(add-atom &kb (Sentence ((Inheritance animal cat) (stv 0.6 0.7)) (1)))

; !(add-atom &kb (Sentence (cat (stv 0.7 0.8)) (2)))


; !(inversion &kb (Inheritance cat animal) (S (S Z)) ())           
;; Inversion also works with 


; !(sylo (SyllogisticRuleGuard Inheritance))
; !(sylo (StampDisjoint (1 2) (1 3)))
; !(truth (Truth_ModusPonens (stv 0.4 0.6) (stv 0.4 0.6)))
; !(concated (StampConcat (1 2) (3 4)))
; !(getNodeSTV &kb dog)

