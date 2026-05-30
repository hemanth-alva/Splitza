//
//  DebtSimplifier.swift
//  Splitza
//
//  Created by Antigravity on 30/05/26.
//

import Foundation

/// Pure algorithm class for simplifying debts within a group.
/// Uses a greedy approach to minimize the number of transactions.
///
/// Algorithm:
/// 1. Compute net balance for each member (what they paid - their share)
/// 2. Separate into creditors (positive balance) and debtors (negative balance)
/// 3. Greedily match largest debtor with largest creditor
/// 4. Settle the minimum of the two amounts
/// 5. Repeat until all debts are zero
struct DebtSimplifier {
    
    /// Compute simplified payments for a group given its expenses and settlements.
    ///
    /// - Parameters:
    ///   - expenses: All expenses in the group
    ///   - settlements: All existing settlements in the group
    ///   - memberIds: All member IDs in the group
    /// - Returns: Minimal set of payments to settle all debts
    static func simplify(
        expenses: [Expense],
        settlements: [Settlement],
        memberIds: [UUID]
    ) -> [SimplifiedPayment] {
        // Step 1: Compute net balance for each member
        // Positive = they are owed money (creditor)
        // Negative = they owe money (debtor)
        var netBalances: [UUID: Double] = [:]
        for memberId in memberIds {
            netBalances[memberId] = 0
        }
        
        // Process expenses
        for expense in expenses {
            // The payer gets credit for the full amount
            netBalances[expense.paidById, default: 0] += expense.amount
            
            // Each participant's share is deducted
            for split in expense.splits {
                netBalances[split.userId, default: 0] -= split.amount
            }
        }
        
        // Process existing settlements
        for settlement in settlements {
            // fromUser paid toUser, so fromUser gets credit
            netBalances[settlement.fromUserId, default: 0] += settlement.amount
            // toUser received money, so deduct
            netBalances[settlement.toUserId, default: 0] -= settlement.amount
        }
        
        // Step 2: Separate into creditors and debtors
        // Filter out near-zero balances
        var creditors: [(userId: UUID, amount: Double)] = []
        var debtors: [(userId: UUID, amount: Double)] = []
        
        for (userId, balance) in netBalances {
            if balance > 0.01 {
                creditors.append((userId, balance))
            } else if balance < -0.01 {
                debtors.append((userId, abs(balance)))
            }
        }
        
        // Step 3: Greedy matching — sort descending by amount
        creditors.sort { $0.amount > $1.amount }
        debtors.sort { $0.amount > $1.amount }
        
        var payments: [SimplifiedPayment] = []
        var ci = 0
        var di = 0
        
        while ci < creditors.count && di < debtors.count {
            let settleAmount = min(creditors[ci].amount, debtors[di].amount)
            
            if settleAmount > 0.01 {
                payments.append(SimplifiedPayment(
                    fromUserId: debtors[di].userId,
                    toUserId: creditors[ci].userId,
                    amount: round(settleAmount * 100) / 100
                ))
            }
            
            creditors[ci].amount -= settleAmount
            debtors[di].amount -= settleAmount
            
            if creditors[ci].amount < 0.01 {
                ci += 1
            }
            if debtors[di].amount < 0.01 {
                di += 1
            }
        }
        
        return payments
    }
    
    /// Calculate how many transactions were saved by simplification.
    ///
    /// The naive approach would have one transaction per unique debtor-creditor pair
    /// from the raw expenses. This returns the difference.
    static func transactionsSaved(
        originalPairCount: Int,
        simplifiedPayments: [SimplifiedPayment]
    ) -> Int {
        return max(0, originalPairCount - simplifiedPayments.count)
    }
}
