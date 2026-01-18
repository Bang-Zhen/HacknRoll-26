# Backup reference (not wired).
function apply_ledger(balance::Int, amount::Int)
    next = balance + amount
    if next < 0
        error("Insufficient credits")
    end
    return next
end
