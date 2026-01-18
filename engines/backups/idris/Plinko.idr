module Plinko

-- Backup reference (not wired).

multiplier : Int -> String -> Int -> Double
multiplier rows risk slot =
  if rows == 12 && risk == "medium" && slot == 0 then 20.0
  else 1.0
