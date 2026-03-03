
(= (round $x $n) (py-call (builtins.round $x $n)))

;; revision rule for atoms of the same sentence but with different stamps
(= (revision $sentences) 
    (let* ((((Sentence ($goal $stv1st) $ev1st) $rest) (decons-atom  $sentences))
            (((stv $combined-c $combined-s) $evidences) 
                (foldl-atom $rest ($stv1st $ev1st) ($init-stv $ev-acc) 
                (Sentence ($g $stv) $ev) (if (StampDisjoint $ev-acc $ev)
                                             ((Truth_Revision $init-stv $stv) (StampConcat $ev-acc $ev))
                                             ($stv1st $ev1st)))))
        (Sentence ($goal (stv (round $combined-c 3) (round $combined-s 3))) $evidences)))        

(= (getNodeSTV $kb $node)
;; I found this approach to be misleading -- assigning stv values for atoms that are not in the atomspace
;; The reason -- for a series of moves that need to be have been made prio for a goal state to be reached. implementation below meant that we will arrive at the destination
;; even if the moves that need to be there has not happened yet
;    (let $res (collapse (match $kb (Sentence ($node $tv) $_) $tv))
;       (if (== $res ())
;           (stv 0.5 0.0) ;; Complete ignorance default
;           (car-atom $res)))) 
    (match $kb (Sentence ($node $tv) $_) $tv)) 


;; an alternative definition of getNodeSTV, rather than just a straight look up for the goal in the atomspace
;; calls back the main backward chainer inference engine to look fo the goal   
; (= (getNodeSTV $kb $node) 
;     (let $result (collapse (pln-bc $kb $node (S (S (S Z))) ())) ;; look for the atom with depth of 3
;         (if (!= $result ())
;             (getStv (revision $result))
;             (stv 0.5 0))))        

; (= (getStv (Sentence ($atom $stv) $stamp)) $stv) 
(= (getConfidence (Sentence ($atom (stv $s $c)) $stamp)) $c) 

; (= (getStamp (Sentence ($atom $stv) $stamp)) $stamp)  

(= (insert-sorted $x ()) ($x))

;; Recursive Case: Compare x with head of list
(= (insert-sorted $x $expr)
    (let ($h $t) (decons-atom $expr)   
        (if (> (getConfidence $x) (getConfidence $h))
            (cons-atom $x $expr)
            (let $rest (insert-sorted $x $t)
                (cons-atom $h (insert-sorted $x $t))))))

;; ============================================================
;; 3. MAIN SORT FUNCTION
;; ============================================================
;; Recursively sorts a list
(= (sorT ()) ())
(= (sorT $expr)
    (let ($h $t) (decons-atom $expr)
        (insert-sorted $h (sorT $t))))