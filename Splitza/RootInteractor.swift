//
//  RootInteractor.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import Foundation
import Combine

class RootInteractor: Interacting {
    typealias RouterType = RootRouting
    var router: RootRouting?
    
    // MARK: - Published State
    
    @Published var selectedTab: Int = 0
    @Published var currentUser: User
    @Published var friends: [User] = []
    @Published var groups: [ExpenseGroup] = []
    @Published var expenses: [Expense] = []
    @Published var settlements: [Settlement] = []
    
    // Sheet presentation
    @Published var showAddExpense = false
    @Published var showCreateGroup = false
    @Published var showSettleUp = false
    @Published var settleUpWithUserId: UUID? = nil
    @Published var settleUpGroupId: UUID? = nil
    @Published var settleUpNonGroup = false
    @Published var addExpenseGroupId: UUID? = nil
    @Published var addExpenseFriendId: UUID? = nil
    @Published var editingExpense: Expense? = nil
    
    // MARK: - Dependencies
    
    private let dataProvider: DataProvider
    
    // MARK: - Init
    
    init(dataProvider: DataProvider = SampleDataProvider()) {
        self.dataProvider = dataProvider
        self.currentUser = dataProvider.loadCurrentUser()
        loadData()
    }
    
    // MARK: - Lifecycle
    
    func didBecomeActive() {}
    func willResignActive() {}
    
    // MARK: - Data Loading
    
    private func loadData() {
        friends = dataProvider.loadFriends(for: currentUser)
        groups = dataProvider.loadGroups(for: currentUser, friends: friends)
        expenses = dataProvider.loadExpenses(for: groups, currentUser: currentUser, friends: friends)
        settlements = dataProvider.loadSettlements()
        
        // Add a sample settlement if using sample data and we have friends
        if dataProvider is SampleDataProvider, friends.count > 0 {
            let sampleSettlement = Settlement(
                fromUserId: friends[0].id,
                toUserId: currentUser.id,
                amount: 1000,
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                groupId: groups.first?.id
            )
            settlements = [sampleSettlement]
        }
    }
    
    // MARK: - Lookups
    
    var allUsers: [User] {
        [currentUser] + friends
    }
    
    func user(for id: UUID) -> User? {
        allUsers.first(where: { $0.id == id })
    }
    
    func group(for id: UUID) -> ExpenseGroup? {
        groups.first(where: { $0.id == id })
    }
    
    // MARK: - Expense Queries
    
    func expenses(forGroup groupId: UUID) -> [Expense] {
        expenses.filter { $0.groupId == groupId }
    }
    
    func nonGroupExpenses() -> [Expense] {
        expenses.filter { $0.groupId == nil }
    }
    
    func expenses(withFriend friendId: UUID) -> [Expense] {
        expenses.filter { expense in
            let involvesFriend = expense.paidById == friendId || expense.splits.contains(where: { $0.userId == friendId })
            let involvesMe = expense.paidById == currentUser.id || expense.splits.contains(where: { $0.userId == currentUser.id })
            return involvesFriend && involvesMe
        }
    }
    
    func members(of group: ExpenseGroup) -> [User] {
        group.memberIds.compactMap { user(for: $0) }
    }
    
    // MARK: - Balance Computation
    
    func balanceWith(friendId: UUID) -> Double {
        var balance: Double = 0
        
        for expense in expenses {
            let involvesMe = expense.paidById == currentUser.id || expense.splits.contains(where: { $0.userId == currentUser.id })
            let involvesFriend = expense.paidById == friendId || expense.splits.contains(where: { $0.userId == friendId })
            
            guard involvesMe && involvesFriend else { continue }
            
            if expense.paidById == currentUser.id {
                if let friendSplit = expense.splits.first(where: { $0.userId == friendId }) {
                    balance += friendSplit.amount
                }
            } else if expense.paidById == friendId {
                if let mySplit = expense.splits.first(where: { $0.userId == currentUser.id }) {
                    balance -= mySplit.amount
                }
            }
        }
        
        for settlement in settlements {
            if settlement.fromUserId == currentUser.id && settlement.toUserId == friendId {
                balance += settlement.amount
            } else if settlement.fromUserId == friendId && settlement.toUserId == currentUser.id {
                balance -= settlement.amount
            }
        }
        
        return balance
    }
    
    var totalOwedToMe: Double {
        friends.reduce(0) { sum, friend in
            let b = balanceWith(friendId: friend.id)
            return sum + (b > 0 ? b : 0)
        }
    }
    
    var totalIOwe: Double {
        friends.reduce(0) { sum, friend in
            let b = balanceWith(friendId: friend.id)
            return sum + (b < 0 ? abs(b) : 0)
        }
    }
    
    func groupBalance(groupId: UUID) -> Double {
        let groupExpenses = expenses(forGroup: groupId)
        var balance: Double = 0
        
        for expense in groupExpenses {
            if expense.paidById == currentUser.id {
                let othersShare = expense.splits.filter { $0.userId != currentUser.id }.reduce(0) { $0 + $1.amount }
                balance += othersShare
            } else if let mySplit = expense.splits.first(where: { $0.userId == currentUser.id }) {
                balance -= mySplit.amount
            }
        }
        
        for settlement in settlements.filter({ $0.groupId == groupId }) {
            if settlement.fromUserId == currentUser.id {
                balance += settlement.amount
            } else if settlement.toUserId == currentUser.id {
                balance -= settlement.amount
            }
        }
        
        return balance
    }
    
    func nonGroupBalance() -> Double {
        let nonGroupExpenses = nonGroupExpenses()
        var balance: Double = 0
        
        for expense in nonGroupExpenses {
            if expense.paidById == currentUser.id {
                let othersShare = expense.splits.filter { $0.userId != currentUser.id }.reduce(0) { $0 + $1.amount }
                balance += othersShare
            } else if let mySplit = expense.splits.first(where: { $0.userId == currentUser.id }) {
                balance -= mySplit.amount
            }
        }
        
        for settlement in settlements.filter({ $0.groupId == nil }) {
            if settlement.fromUserId == currentUser.id {
                balance += settlement.amount
            } else if settlement.toUserId == currentUser.id {
                balance -= settlement.amount
            }
        }
        
        return balance
    }
    
    func balanceWith(friendId: UUID, scopedToGroup groupId: UUID?) -> Double {
        let scopedExpenses = expenses.filter { $0.groupId == groupId }
        var balance: Double = 0
        
        for expense in scopedExpenses {
            let involvesMe = expense.paidById == currentUser.id || expense.splits.contains(where: { $0.userId == currentUser.id })
            let involvesFriend = expense.paidById == friendId || expense.splits.contains(where: { $0.userId == friendId })
            
            guard involvesMe && involvesFriend else { continue }
            
            if expense.paidById == currentUser.id {
                if let friendSplit = expense.splits.first(where: { $0.userId == friendId }) {
                    balance += friendSplit.amount
                }
            } else if expense.paidById == friendId {
                if let mySplit = expense.splits.first(where: { $0.userId == currentUser.id }) {
                    balance -= mySplit.amount
                }
            }
        }
        
        for settlement in settlements where settlement.groupId == groupId {
            if settlement.fromUserId == currentUser.id && settlement.toUserId == friendId {
                balance += settlement.amount
            } else if settlement.fromUserId == friendId && settlement.toUserId == currentUser.id {
                balance -= settlement.amount
            }
        }
        
        return balance
    }
    
    func nonGroupParticipants() -> [User] {
        let expenses = nonGroupExpenses()
        let expenseUserIds = expenses.reduce(into: Set<UUID>()) { ids, expense in
            ids.insert(expense.paidById)
            expense.splits.forEach { ids.insert($0.userId) }
        }
        let settlementUserIds = settlements.filter { $0.groupId == nil }.reduce(into: Set<UUID>()) { ids, settlement in
            ids.insert(settlement.fromUserId)
            ids.insert(settlement.toUserId)
        }
        let userIds = expenseUserIds.union(settlementUserIds).union([currentUser.id])
        return allUsers.filter { userIds.contains($0.id) }
    }
    
    // MARK: - Simplify Payments
    
    func simplifiedPayments(forGroup groupId: UUID) -> [SimplifiedPayment] {
        guard let group = group(for: groupId) else { return [] }
        let groupExpenses = expenses(forGroup: groupId)
        let groupSettlements = settlements.filter { $0.groupId == groupId }
        
        return DebtSimplifier.simplify(
            expenses: groupExpenses,
            settlements: groupSettlements,
            memberIds: group.memberIds
        )
    }
    
    // MARK: - CRUD Actions
    
    func addExpense(_ expense: Expense) {
        expenses.insert(expense, at: 0)
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
        } else {
            addExpense(expense)
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
    }
    
    func addGroup(_ group: ExpenseGroup) {
        groups.append(group)
    }
    
    func addSettlement(_ settlement: Settlement) {
        settlements.insert(settlement, at: 0)
    }
    
    func addFriend(_ friend: User) {
        friends.append(friend)
    }
    
    // MARK: - Activity Feed
    
    var activityFeed: [ActivityItem] {
        let expenseItems = expenses.map { ActivityItem.expense($0) }
        let settlementItems = settlements.map { ActivityItem.settlement($0) }
        return (expenseItems + settlementItems).sorted { $0.date > $1.date }
    }
}
