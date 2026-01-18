(defun resolve-roulette (bet-type color amount)
  "Backup reference (not wired)."
  (cond ((or (string= bet-type "red") (string= bet-type "black"))
         (if (string= bet-type color) (* amount 2) 0))
        ((string= bet-type "green")
         (if (string= color "green") (* amount 14) 0))
        (t 0)))
