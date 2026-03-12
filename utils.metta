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
            ($__1 (println! (Curr: $cur)))
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

(= (sum $a) (foldl + $a 0))

(= (flattenBoard (Board (Row $1 (Col $2 $3)) (Rows (Row $4 (Col $5 $6)) (Row $7 (Col $8 $9))))) (Board ($1 $2 $3 $4 $5 $6 $7 $8 $9)))
(= (bloatBoard (Board ($1 $2 $3 $4 $5 $6 $7 $8 $9))) (Board (Row $1 (Col $2 $3)) (Rows (Row $4 (Col $5 $6)) (Row $7 (Col $8 $9)))))

(= (load_to_metta $x)
   (let*
      (
        ($__2 (import! &self $x))
        ($content (match &self (Loadable $content) $content))
        ($__3 (remove-atom &self (Loadable $content)))
        ($__4 (py-call (run_evolution.remove_file $x)))
      )
      $content))

(= (load_board_python $board) (py-call (run_evolution.Board $board)))
(= (load_board_metta $board) (let $x (py-call (run_evolution.save_board $board)) (load_to_metta $x)))

(= (saveExpressions $fileName $mettaExpressions)
   (let*
     (
       ($stringExpressions (collapse (let $expression (superpose $mettaExpressions) (py-call (utils.to_metta_str $expression)))))
       ($newStrExpressions (py-call (utils.join_metta_strs $stringExpressions)))
       ($__5 (py-call (utils.add_to_file $fileName $newStrExpressions)))
     )
     true))

(= (saveExpression $fileName $mettaExpression)
   (let $strExpression (py-call (utils.to_metta_str $mettaExpression))
   (let $__6 (py-call (utils.add_to_file $fileName $strExpression)) true)))

(= (clearSpace $space) (let $result (collapse (match $space $x (remove-atom $space $x))) true))

(= (genIdx $u) (genIdx 0 $u))
(= (genIdx $l $u)
    (if (< $u $l)
        ()
        (let $res (genIdx $l (- $u 1))
            (union-atom $res ($u)))))

(= (getDiffBoard $board1 $board2)
   (let*
     (
      ($boards (zipWith != $board1 $board2))
      ($idxs (genIdx (length $boards)))
      ($boardIdxs (zip $boards $idxs))
      ((($__7 $idx)) (filter-atom $boardIdxs (first-from-pair)))
     )
     $idx
   ))
