;; ============================================================
;; ABDUCTION RULE (Recursive)
;; ============================================================
;; same note as induction.metta: do not pull in main-loop or the
;; file itself from inside the definition. the tests around the
;; library do the importing, so the helper imports here are kept
;; commented to avoid cycles.
; !(import! &self ./utilities/forward-chaining-pln)
; !(import! &self ./utilities/helpers)
; !(import! &self ./main-loop)
; !(import! &self ./induction)
(= (abduction $kb $goal (S $k) $ev)
    (let ($link-type $A $B) $goal
        (if (SyllogisticRuleGuard $link-type)
            (match $kb (Sentence (($link-type $B $C) $tv-bc) $ev-bc)
                (if (StampDisjoint $ev $ev-bc)
                    (let* (($next-ev (StampConcat $ev $ev-bc))
                            ((Sentence (($link-type $A $C) $tv-ac) $ev-final) (pln-bc $kb ($link-type $A $C) $k $next-ev))
                            ($stv-a (getNodeSTV $kb $A))
                            ($stv-b (getNodeSTV $kb $B))
                            ($stv-c (getNodeSTV $kb $C))
                            ($tv-goal (Truth_Abduction $stv-a $stv-b $stv-c $tv-ac $tv-bc)))
                        
                            (Sentence ($goal $tv-goal) $ev-final))
                    (empty)))
                    (empty))))
; !(bind! &kb (new-space))    
; ;; 1. The Facts (Shared Consequent: Flyer)
; !(add-atom &kb (Sentence ((Inheritance Tweety Flyer) (stv 1.0 0.9)) (101)))
; !(add-atom &kb (Sentence ((Inheritance Bird Flyer)   (stv 0.9 0.9)) (102)))

; ;; 2. The Query
; ;; We ask the engine to prove (Inheritance Tweety Bird) with a depth of 2.
; !(abduction &kb (Inheritance Tweety Bird) (S (S Z)) ())                    
