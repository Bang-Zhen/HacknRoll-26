library(jsonlite)

input <- fromJSON(file("stdin"))
txs <- input$txs
start <- input$startCreditsMinor

if (is.null(txs) || length(txs) == 0) {
  txs <- data.frame(amountMinor=numeric(), type=character(), meta=I(list()))
}

amounts <- txs$amountMinor
types <- txs$type

totalBetMinor <- sum(abs(amounts[types == "BET"]), na.rm = TRUE)
totalWonMinor <- sum(amounts[amounts > 0], na.rm = TRUE)
transferCount <- sum(types == "TRANSFER", na.rm = TRUE)

gameTypes <- c()
if (!is.null(txs$meta)) {
  for (m in txs$meta) {
    if (!is.null(m$gameType)) {
      gameTypes <- unique(c(gameTypes, m$gameType))
    }
  }
}

meanVal <- if (length(amounts) > 0) mean(amounts) else 0
variance <- if (length(amounts) > 1) var(amounts) else 0
stddev <- sqrt(variance)

clamp01 <- function(n) {
  if (!is.finite(n)) return(0)
  return(max(0, min(1, n)))
}

aggression <- clamp01(totalBetMinor / (start * 3))
luck <- clamp01(min(2, totalWonMinor / max(1, totalBetMinor)) / 2)
variety <- clamp01(length(gameTypes) / 6)
social <- clamp01(transferCount / 10)
volatility <- clamp01(stddev / (start / 2))

output <- list(
  axes = list(
    list(key="aggression", label="Aggression", value=aggression),
    list(key="luck", label="Luck", value=luck),
    list(key="variety", label="Variety", value=variety),
    list(key="social", label="Social", value=social),
    list(key="volatility", label="Volatility", value=volatility)
  ),
  raw = list(
    totalBetMinor=totalBetMinor,
    totalWonMinor=totalWonMinor,
    transferCount=transferCount,
    uniqueGameTypes=gameTypes,
    txCount=length(amounts)
  )
)

cat(toJSON(output, auto_unbox = TRUE))
