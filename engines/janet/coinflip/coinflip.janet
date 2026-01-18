#!/usr/bin/env janet

(def input (slurp))
(def data (json/decode input))
(def choice (get data "choice"))
(def betMinor (get data "betMinor"))

(def flip (if (= (math/random 2) 0) "heads" "tails"))
(def won (= flip choice))
(def payoutMinor (if won (* betMinor 2) 0))

(print (json/encode {:result flip :won won :payoutMinor payoutMinor}))
