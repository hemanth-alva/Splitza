//
//  SplitzaTests.swift
//  SplitzaTests
//
//  Created by Hemanth Alva R on 21/04/26.
//

import Testing
import Foundation
@testable import Splitza

struct SplitzaTests {

    @Test func testSimplifiedSettlementDistribution() async throws {
        // 1. Initialize RootInteractor (uses SampleDataProvider by default)
        let root = RootInteractor()
        
        // 2. Locate Goa Trip group
        guard let goaTrip = root.groups.first(where: { $0.name == "Goa Trip" }) else {
            Issue.record("Goa Trip group not found")
            return
        }
        
        // 3. Locate Priya Patel
        guard let priya = root.friends.first(where: { $0.name == "Priya Patel" }) else {
            Issue.record("Priya Patel not found")
            return
        }
        
        // Ensure simplifyDebts is toggled ON for Goa Trip
        #expect(goaTrip.simplifyDebts == true)
        
        // 4. Check global balance for Priya Patel
        // According to verify_logic and SampleDataProvider:
        // - In Goa Trip: Priya owes Hemanth 4175.0.
        // - In Office Lunch: Hemanth owes Priya 450.0 (from Pizza Party: 1800 split among 4).
        // Global balance = 4175.0 - 450.0 = 3725.0.
        let globalBalance = root.balanceWith(friendId: priya.id)
        #expect(globalBalance == 3725.0)
        
        // 5. Setup SettleUpInteractor in all/global context
        root.settleUpWithUserId = priya.id
        root.settleUpGroupId = nil
        root.settleUpNonGroup = false
        
        let settleUpInteractor = SettleUpInteractor(rootInteractor: root)
        
        // Check prefilled details
        #expect(settleUpInteractor.selectedFriendId == priya.id)
        #expect(settleUpInteractor.amountText == "3725.00")
        
        // 6. Record settlement of 3725
        let success = settleUpInteractor.recordSettlement()
        #expect(success == true)
        
        // 7. Verify Goa Trip group has the settlement of 4175.0 (Priya -> Hemanth)
        let goaSettlements = root.settlements.filter { $0.groupId == goaTrip.id }
        // Goa Trip has 2 settlements: 1 pre-existing sample (Rahul -> Hemanth 1000) and 1 new (Priya -> Hemanth 4175)
        #expect(goaSettlements.count == 2)
        
        let priyaGoaSettlement = goaSettlements.first(where: { $0.fromUserId == priya.id })
        #expect(priyaGoaSettlement != nil)
        #expect(priyaGoaSettlement?.amount == 4175.0)
        #expect(priyaGoaSettlement?.toUserId == root.currentUser.id)
        
        // 8. Verify Office Lunch group has the settlement of 450.0 (Hemanth -> Priya)
        guard let officeLunch = root.groups.first(where: { $0.name == "Office Lunch" }) else {
            Issue.record("Office Lunch group not found")
            return
        }
        let officeLunchSettlements = root.settlements.filter { $0.groupId == officeLunch.id }
        #expect(officeLunchSettlements.count == 1)
        #expect(officeLunchSettlements.first?.fromUserId == root.currentUser.id)
        #expect(officeLunchSettlements.first?.toUserId == priya.id)
        #expect(officeLunchSettlements.first?.amount == 450.0)
        
        // 9. Verify global balance is now 0
        let newGlobalBalance = root.balanceWith(friendId: priya.id)
        #expect(abs(newGlobalBalance) < 0.01)
    }

    @Test func testDebtSimplificationAlgorithm() {
        let u1 = UUID() // Alice
        let u2 = UUID() // Bob
        let u3 = UUID() // Charlie
        
        // Scenario 1: Alice pays 300 for a dinner split equally between Alice, Bob, and Charlie.
        // Bob owes Alice 100. Charlie owes Alice 100.
        let expenses = [
            Expense(
                description: "Dinner",
                amount: 300,
                paidById: u1,
                splitType: .equal,
                splits: [u1, u2, u3].map { Split(userId: $0, amount: 100) }
            )
        ]
        
        let payments = DebtSimplifier.simplify(expenses: expenses, settlements: [], memberIds: [u1, u2, u3])
        #expect(payments.count == 2)
        #expect(payments.contains(where: { $0.fromUserId == u2 && $0.toUserId == u1 && $0.amount == 100.0 }))
        #expect(payments.contains(where: { $0.fromUserId == u3 && $0.toUserId == u1 && $0.amount == 100.0 }))
        
        // Scenario 2: Bob pays 150 for a cab split equally between Alice, Bob, and Charlie (50 each).
        // Cumulative net balances:
        // Alice: +200 - 50 = +150 (Creditor)
        // Bob: -100 + 100 = 0
        // Charlie: -100 - 50 = -150 (Debtor)
        // Simplified should result in: Charlie pays Alice 150. Bob is cleared.
        let expenses2 = expenses + [
            Expense(
                description: "Cab",
                amount: 150,
                paidById: u2,
                splitType: .equal,
                splits: [u1, u2, u3].map { Split(userId: $0, amount: 50) }
            )
        ]
        
        let payments2 = DebtSimplifier.simplify(expenses: expenses2, settlements: [], memberIds: [u1, u2, u3])
        #expect(payments2.count == 1)
        #expect(payments2.first?.fromUserId == u3)
        #expect(payments2.first?.toUserId == u1)
        #expect(payments2.first?.amount == 150.0)
    }

    @Test func testPartialSettlementDistribution() async throws {
        let root = RootInteractor()
        
        // Find Priya Patel
        guard let priya = root.friends.first(where: { $0.name == "Priya Patel" }) else {
            Issue.record("Priya Patel not found")
            return
        }
        
        // Setup SettleUpInteractor
        root.settleUpWithUserId = priya.id
        root.settleUpGroupId = nil
        root.settleUpNonGroup = false
        
        let settleUpInteractor = SettleUpInteractor(rootInteractor: root)
        
        // Priya owes Hemanth 3725.0 globally.
        // Goa Trip group balance: Priya owes Hemanth 4175.0 (positive)
        // Office Lunch group balance: Hemanth owes Priya 450.0 (negative)
        // Perform a partial payment of Priya paying Hemanth 2000.0
        settleUpInteractor.amountText = "2000.00"
        let success = settleUpInteractor.recordSettlement()
        #expect(success == true)
        
        // The partial payment should only flow towards debts in the main direction.
        // So the ₹2,000 should be applied entirely to the Goa Trip group (where Priya owes Hemanth).
        // Office Lunch should remain untouched.
        let goaSettlements = root.settlements.filter { $0.groupId == root.groups.first(where: { $0.name == "Goa Trip" })?.id }
        let priyaGoaSettlements = goaSettlements.filter { $0.fromUserId == priya.id && $0.amount == 2000.0 }
        #expect(priyaGoaSettlements.count == 1)
        
        let officeLunch = root.groups.first(where: { $0.name == "Office Lunch" })!
        let officeLunchSettlements = root.settlements.filter { $0.groupId == officeLunch.id }
        #expect(officeLunchSettlements.isEmpty)
    }

    @Test func testAddExpenseRecalculatesBalances() async throws {
        let root = RootInteractor()
        
        guard let rahul = root.friends.first(where: { $0.name == "Rahul Sharma" }) else {
            Issue.record("Rahul Sharma not found")
            return
        }
        
        let initialBalance = root.balanceWith(friendId: rahul.id)
        
        // Hemanth paid 1000 for a movie split equally between Hemanth and Rahul (500 each)
        let newExpense = Expense(
            description: "Movie tickets",
            amount: 1000,
            paidById: root.currentUser.id,
            splits: [
                Split(userId: root.currentUser.id, amount: 500),
                Split(userId: rahul.id, amount: 500)
            ],
            groupId: nil
        )
        
        root.addExpense(newExpense)
        
        let finalBalance = root.balanceWith(friendId: rahul.id)
        // Since Hemanth paid and Rahul's share is 500, Rahul now owes Hemanth 500 more.
        #expect(finalBalance == initialBalance + 500.0)
    }
}

