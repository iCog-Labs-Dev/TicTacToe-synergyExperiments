(= (gpPlayer12 $bs $player)
   (let*
     (
      ($pythonBoard (load_board_python (Board $bs)))
      ($resultBoard (py-call (gp12_x_player.run_policy $pythonBoard $player)))
      ((Board $mettaBoard) (load_board_metta $resultBoard))
     )
     ((getDiffBoard $bs $mettaBoard) $mettaBoard)))
