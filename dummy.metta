!(import! &self ./moses_bridge)
; !(emptyStrategyMetaPop)
!(update-moses-strategy "Random")
!(get-state activeMosesStrategy) 