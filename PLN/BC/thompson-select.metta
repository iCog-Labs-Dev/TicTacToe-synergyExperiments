;; have seen values as small as e-14 so using this as scaling factor 
(= (min-stv) 1.0e-14)

;; reduandant def in pln.metta
; (= (clamp $v $lo $hi)
;    (min $hi (max $lo $v)))

;; log-scale small values of confidence and strength for betta distribution to enable exploration
(= (scale01 $x)
   (let* (($xx (max $x (min-stv)))
          ($lg (py-call (math.log10 $xx))))      ; in [-10, 0]
         (clamp (/ (+ $lg 10.0) 10.0) 0.0 1.0)))

;; conversion from stv values into bivariate factors ⍺ and β for the bivariate dist used 
(= (stv-beta $k (stv $s $c))
   (let* (($ss (scale01 $s))
          ($cc (scale01 $c))
          ($m1 (* $ss $cc))
          ($m2 (* $m1 $k))
          ($n1 (* (- 1.0 $ss) $cc))
          ($n2 (* $n1 $k))
          ($a (+ 1.0 $m2))
          ($b (+ 1.0 $n2)))
         ($a $b)))

;; k = 10 very exploratory
;; k = 50 balanced
;; k = 80 fairly exploitative
;; k = 200 mostly deterministic

(= (sample-sentence (Sentence ($entity $stv) $stamp))
    (let* ((($a $b) (stv-beta 80 $stv))
        ($x (py-call (random.betavariate $a $b))))
    ((Sentence ($entity $stv) $stamp) $x)))

; !(sample-sentence (Sentence (A (stv 0.60 0.20)) (503)))
(= (ts-select $sentences)
   (let* (($scored (map-atom $sentences (|-> ($s) (sample-sentence $s))))
          ($best (foldl-atom $scored
                             (() -1.0)
                             $acc $item
                             (let* ((($best-s $best-v) $acc)
                                    (($s $v) $item))
                               ; random tie-break avoids first-item bias
                               (if (or (> $v $best-v)
                                       (and (== $v $best-v)
                                            (> (py-call (random.random)) 0.5)))
                                   ($s $v)
                                   ($best-s $best-v))))))
     (car-atom $best)))
