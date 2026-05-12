//
//  RootInteractor.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import Foundation
import Combine
import SwiftUI

public class RootInteractor: Interacting {
    public typealias RouterType = RootRouting
    public var router: RootRouting?
    
    // MARK: - Published State
    
    @Published var selectedTab: Int = 0
    @Published var currentUser: User
    @Published var friends: [User] = []
    @Published var groups: [ExpenseGroup] = []
    @Published var expenses: [Expense] = []
    @Published var settlements: [Settlement] = []
    
    // Sheet presentation
    @Published public var showAddExpense = false
    @Published public var showCreateGroup = false
    @Published public var showSettleUp = false
    @Published public var settleUpWithUserId: UUID? = nil
    @Published public var settleUpGroupId: UUID? = nil
    @Published public var addExpenseGroupId: UUID? = nil
    @Published public var addExpenseFriendId: UUID? = nil
    
    // MARK: - Init
    
    public init() {
        self.currentUser = User(name: "Hemanth", email: "hemanth@splitza.app", avatarColor: AppColors.avatarColors[0])
        loadSampleData()
    }
    
    // MARK: - Lifecycle
    
    public func didBecomeActive() {}
    public func willResignActive() {}
    
    // MARK: - Computed Helpers
    
    /// All users (current + friends)
    var allUsers: [User] {
        [currentUser] + friends
    }
    
    func user(for id: UUID) -> User? {
        allUsers.first(where: { $0.id == id })
    }
    
    func group(for id: UUID) -> ExpenseGroup? {
        groups.first(where: { $0.id == id })
    }
    
    /// Expenses for a specific group
    func expenses(forGroup groupId: UUID) -> [Expense] {
        expenses.filter { $0.groupId == groupId }
    }
    
    /// Expenses between current user and a specific friend (non-group)
    func expenses(withFriend friendId: UUID) -> [Expense] {
        expenses.filter { expense in
            let involvesFriend = expense.paidById == friendId || expense.splits.contains(where: { $0.userId == friendId })
            let involvesMe = expense.paidById == currentUser.id || expense.splits.contains(where: { $0.userId == currentUser.id })
            return involvesFriend && involvesMe
        }
    }
    
    /// Members of a group as User objects
    func members(of group: ExpenseGroup) -> [User] {
        group.memberIds.compactMap { user(for: $0) }
    }
    
    // MARK: - Balance Computation
    
    /// Compute net balance for each friend (positive = they owe you)
    func balanceWith(friendId: UUID) -> Double {
        var balance: Double = 0
        
        for expense in expenses {
            let involvesMe = expense.paidById == currentUser.id || expense.splits.contains(where: { $0.userId == currentUser.id })
            let involvesFriend = expense.paidById == friendId || expense.splits.contains(where: { $0.userId == friendId })
            
            guard involvesMe && involvesFriend else { continue }
            
            if expense.paidById == currentUser.id {
                // I paid — friend owes me their split
                if let friendSplit = expense.splits.first(where: { $0.userId == friendId }) {
                    balance += friendSplit.amount
                }
            } else if expense.paidById == friendId {
                // Friend paid — I owe them my split
                if let mySplit = expense.splits.first(where: { $0.userId == currentUser.id }) {
                    balance -= mySplit.amount
                }
            }
        }
        
        // Settlements
        for settlement in settlements {
            if settlement.fromUserId == currentUser.id && settlement.toUserId == friendId {
                balance += settlement.amount // I paid them, reduces what I owe
            } else if settlement.fromUserId == friendId && settlement.toUserId == currentUser.id {
                balance -= settlement.amount // They paid me, reduces what they owe
            }
        }
        
        return balance
    }
    
    /// Total owed to me across all friends
    var totalOwedToMe: Double {
        friends.reduce(0) { sum, friend in
            let b = balanceWith(friendId: friend.id)
            return sum + (b > 0 ? b : 0)
        }
    }
    
    /// Total I owe across all friends
    var totalIOwe: Double {
        friends.reduce(0) { sum, friend in
            let b = balanceWith(friendId: friend.id)
            return sum + (b < 0 ? abs(b) : 0)
        }
    }
    
    /// Balance for a specific group
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
        
        // Group settlements
        for settlement in settlements.filter({ $0.groupId == groupId }) {
            if settlement.fromUserId == currentUser.id {
                balance += settlement.amount
            } else if settlement.toUserId == currentUser.id {
                balance -= settlement.amount
            }
        }
        
        return balance
    }
    
    // MARK: - Actions
    
    func addExpense(_ expense: Expense) {
        withAnimation(.spring(response: 0.3)) {
            expenses.insert(expense, at: 0)
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        withAnimation(.spring(response: 0.3)) {
            expenses.removeAll { $0.id == expense.id }
        }
    }
    
    func addGroup(_ group: ExpenseGroup) {
        withAnimation(.spring(response: 0.3)) {
            groups.append(group)
        }
    }
    
    func addSettlement(_ settlement: Settlement) {
        withAnimation(.spring(response: 0.3)) {
            settlements.insert(settlement, at: 0)
        }
    }
    
    func addFriend(_ friend: User) {
        withAnimation(.spring(response: 0.3)) {
            friends.append(friend)
        }
    }
    
    // MARK: - Activity Feed
    
    var activityFeed: [ActivityItem] {
        let expenseItems = expenses.map { ActivityItem.expense($0) }
        let settlementItems = settlements.map { ActivityItem.settlement($0) }
        return (expenseItems + settlementItems).sorted { $0.date > $1.date }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        let friend1 = User(name: "Rahul Sharma", email: "rahul@email.com", avatarColor: AppColors.avatarColors[1])
        let friend2 = User(name: "Priya Patel", email: "priya@email.com", avatarColor: AppColors.avatarColors[2])
        let friend3 = User(name: "Amit Kumar", email: "amit@email.com", avatarColor: AppColors.avatarColors[3])
        let friend4 = User(name: "Sneha Reddy", email: "sneha@email.com", avatarColor: AppColors.avatarColors[4])
        let friend5 = User(name: "Vikram Singh", email: "vikram@email.com", avatarColor: AppColors.avatarColors[5])
        
        friends = [friend1, friend2, friend3, friend4, friend5]
        
        // Groups
        let group1 = ExpenseGroup(
            name: "Goa Trip",
            memberIds: [currentUser.id, friend1.id, friend2.id, friend3.id],
            type: .trip,
            emoji: "🏖️",
            createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        )
        
        let group2 = ExpenseGroup(
            name: "Flat Expenses",
            memberIds: [currentUser.id, friend1.id, friend4.id],
            type: .home,
            emoji: "🏠",
            createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        )
        
        let group3 = ExpenseGroup(
            name: "Office Lunch",
            memberIds: [currentUser.id, friend2.id, friend3.id, friend5.id],
            type: .other,
            emoji: "🍕",
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        )
        
        groups = [group1, group2, group3]
        
        // Expenses
        let membersGroup1 = [currentUser.id, friend1.id, friend2.id, friend3.id]
        let splitEqual4 = membersGroup1.map { Split(userId: $0, amount: 3000.0 / 4.0) }
        
        let expense1 = Expense(
            description: "Hotel booking",
            amount: 12000,
            paidById: currentUser.id,
            splitType: .equal,
            splits: membersGroup1.map { Split(userId: $0, amount: 3000) },
            date: Calendar.current.date(byAdding: .day, value: -8, to: Date())!,
            groupId: group1.id,
            category: .travel
        )
        
        let expense2 = Expense(
            description: "Dinner at Fisherman's Wharf",
            amount: 3200,
            paidById: friend1.id,
            splitType: .equal,
            splits: membersGroup1.map { Split(userId: $0, amount: 800) },
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            groupId: group1.id,
            category: .food
        )
        
        let expense3 = Expense(
            description: "Electricity Bill",
            amount: 2400,
            paidById: currentUser.id,
            splitType: .equal,
            splits: [currentUser.id, friend1.id, friend4.id].map { Split(userId: $0, amount: 800) },
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            groupId: group2.id,
            category: .utilities
        )
        
        let expense4 = Expense(
            description: "Pizza Party",
            amount: 1800,
            paidById: friend2.id,
            splitType: .equal,
            splits: [currentUser.id, friend2.id, friend3.id, friend5.id].map { Split(userId: $0, amount: 450) },
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            groupId: group3.id,
            category: .food
        )
        
        let expense5 = Expense(
            description: "Cab to Airport",
            amount: 1500,
            paidById: friend3.id,
            splitType: .equal,
            splits: membersGroup1.map { Split(userId: $0, amount: 375) },
            date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
            groupId: group1.id,
            category: .transport
        )
        
        expenses = [expense4, expense3, expense5, expense2, expense1]
        
        // A settlement
        let settlement1 = Settlement(
            fromUserId: friend1.id,
            toUserId: currentUser.id,
            amount: 1000,
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            groupId: group1.id
        )
        
        settlements = [settlement1]
    }
}
