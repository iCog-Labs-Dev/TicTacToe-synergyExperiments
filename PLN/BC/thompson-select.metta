(= (min-stv) 1.0e-12)
; (= (clamp $v $lo $hi)
;    (min $hi (max $lo $v)))

;; log-scale small values of confidence and strength for betta distribution to enable exploration
(= (scale01 $x)
   (let* (($xx (max $x (min-stv)))
          ($lg (py-call (math.log10 $xx))))      ; in [-10, 0]
         (clamp (/ (+ $lg 10.0) 10.0) 0.0 1.0)))

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

; !(ts-select ((Sentence ((GameWin X) (stv 1.0800000000000005e-06 3.21952430645594e-06)) (504 507 508 511 512 515 516 2))
;              (Sentence ((GameWin X) (stv 2.7000000000000006e-05 0.00011585652778703793)) (519 531 532 535 536 46))
;              (Sentence ((GameWin X) (stv 1.8000000000000007e-05 0.00011585652778703793)) (539 551 552 555 556 130))
;              (Sentence ((GameWin X) (stv 2.7000000000000006e-05 0.00011585652778703793)) (504 567 568 571 572 250))
;              (Sentence ((GameWin X) (stv 1.0800000000000004e-08 8.946700680443039e-08)) (504 507 508 587 588 591 592 595 596 406))))

; !(ts-select ((Sentence ((GameWin X) (stv 0.02000000000419978 0.08651361650255185)) (46760 46761 46764 47009 47137 47138 47141 47142 29737)) (Sentence ((GameWin X) (stv 0.02000000004031789 0.08651361650255185)) (46760 46761 46878 46879 46882 46883 47162 47163 30521)) (Sentence ((GameWin X) (stv 0.02000000001259934 0.08651361650255185)) (46760 46761 46764 47009 47159 47160 47162 47163 30521)) (Sentence ((GameWin X) (stv 0.020000183165159825 0.1553724370053188)) (46760 46761 47041 47042 47171 47172 31338)) (Sentence ((GameWin X) (stv 0.020000041500829253 0.08651361650255185)) (46760 46761 47041 47042 47045 47046 47049 47050 31753)) (Sentence ((GameWin X) (stv 0.02000054495419452 0.1553724370053188)) (46760 46761 46764 47009 47159 47175 32998)) (Sentence ((GameWin X) (stv 0.02000000867282636 0.08651361650255185)) (46760 46761 46824 46825 46980 46981 47005 47006 33415)) (Sentence ((GameWin X) (stv 0.02000152587174465 0.1553724370053188)) (46760 46761 46764 46765 46768 46988 33832)) (Sentence ((GameWin X) (stv 0.020000007622601294 0.08651361650255185)) (46760 46761 47041 47042 47045 47046 47126 47127 34249)) (Sentence ((GameWin X) (stv 0.020000025198681954 0.08651361650255185)) (46760 46761 46878 46879 46898 46899 47023 47024 35500)) (Sentence ((GameWin X) (stv 0.02000000867282636 0.08651361650255185)) (46760 46761 46824 46825 46980 46981 46984 46985 38002))))