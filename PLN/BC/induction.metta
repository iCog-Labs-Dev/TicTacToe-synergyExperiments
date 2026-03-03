; ;; ============================================================
; ;; INDUCTION RULE (Recursive)
; ;; ============================================================
(= (induction $kb $goal $depth $ev)
    (let ($link-type $A $B) $goal
         (if (SyllogisticRuleGuard $link-type)
            (match $kb (Sentence (($link-type $C $B) $tv-cb) $ev-cb)
                (if (StampDisjoint $ev $ev-cb)
                    (let* (($next-ev (StampConcat $ev $ev-cb))
                          ((Sentence (($link-type $C $A) $tv-ca) $ev-final) (pln-bc $kb ($link-type $C $A) $depth $next-ev))
                          ($stv-a (getNodeSTV $kb $A))
                          ($stv-b (getNodeSTV $kb $B))
                          ($stv-c (getNodeSTV $kb $C))
                          ($tv-goal (Truth_Induction $stv-a $stv-b $stv-c $tv-ca $tv-cb)))
                        (Sentence ($goal $tv-goal) $ev-final))
                    (empty)))
                    (empty))))

; ; ;; Define which links are allowed to be used in Deductive/Abductive/Inductive chaining
; ; (= (IsDeductionLink $link)
; ;     (is-member $link (Inheritance Implication IntensionalInheritance)))
; ; ; (= (IsDeductionLink Inheritance) True)
; ; (= (IsDeductionLink Implication) True)
; ; (= (IsDeductionLink IntensionalInheritance) True)
; ; (= (IsDeductionLink $_) False) ;; Everything else returns False

; ;; 1. The Facts (Shared Antecedent: Swan)
; !(bind! &kb (new-space))
; !(add-atom &kb (Sentence ((Inheritance Swan WhiteThing) (stv 1.0 0.7)) (201)))
; !(add-atom &kb (Sentence ((Inheritance Swan Bird)       (stv 1.0 0.5)) (202)))
; !(add-atom &kb (Sentence (Swan (stv 0.5 0.8)) (203)))
; !(add-atom &kb (Sentence (WhiteThing (stv 0.5 0.8)) (203)))
; !(add-atom &kb (Sentence (Bird (stv 0.5 0.8)) (203)))
; ; ;; 2. The Query
;; !(induction &kb (Inheritance WhiteThing Bird) (S (S Z)) ())