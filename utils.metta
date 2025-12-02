(= (foldl' $f $expression $acc)
   (if (== $expression ())
       $acc
       (let*
          (
            (($h $t) (decons-atom $expression))
            ($hNew ($f $h $acc))
            )
          (foldl' $f $t $hNew)
          )))

(= (max $f $a $b) (if ($f $a $b) $a $b))

(= (max-atom $list $f) (foldl' $f (cdr-atom $list) (car-atom $list)))

;; (= (selectionSort $list) (selectionSort $list (size-atom $list)))
;; (= (selectionSort $list $n) (selectionSort $list $n <))
(= (selectionSort $list $n $op)
    (if (or (== $n 0) (== $list ()))
        $list
        (let* (
            ($initial (car-atom $list))
            ($cur (max-atom $list $op))
            ($_ (println! (Curr: $cur)))
            ($newList (subtraction-atom $list ($cur))) ;since the subtractionAtom (the custom one) isn't working now but this subtraction-atom does same thing.
            ($rest (selectionSort $newList (- $n 1) $op))
        )
        (cons-atom $cur $rest))))

(= (comp $op $x $y) (if ($op $x $y) $x $y))

(= (zipWith $f $a $b)
    (if (or (== $a ()) (== $b ()))
        ()
        (let*
          (
            (($x $xs) (decons-atom $a))
            (($y $ys) (decons-atom $b))
            ($z ($f $x $y))
            ($zs (zipWith $f $xs $ys))
          )
          (cons-atom $z $zs))))

(= (tuple $a $b) ($a $b))

(= (zip $a $b) (zipWith tuple $a $b))

(= (range $a $b)
   (if (== $a $b)
       ()
       (cons-atom $a (range (+ $a 1) $b) )))

(= (compose $f $g $x) ($f ($g $x)))
