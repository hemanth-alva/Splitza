//
//  GroupsInteractor.swift
//  Splitza
//
//  Created by Antigravity on 30/05/26.
//

import Foundation
import Combine

/// Interactor for Groups tab and Group Detail screens.
/// Contains all business logic for group operations — views only render.
class GroupsInteractor: Interacting {
    typealias RouterType = GroupsRouting
    
    let rootInteractor: RootInteractor
    var router: GroupsRouting?
    private var cancellables = Set<AnyCancellable>()
    
    // Re-publish root state changes so views update
    @Published var groups: [ExpenseGroup] = []
    @Published var showCreateGroup = false
    
    init(rootInteractor: RootInteractor, router: GroupsRouting? = nil) {
        self.rootInteractor = rootInteractor
        self.router = router
        
        // Sync state from root
        rootInteractor.$groups
            .assign(to: &$groups)
        
        rootInteractor.$showCreateGroup
            .assign(to: &$showCreateGroup)
        
        rootInteractor.$expenses
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed State
    
    var totalOwedToMe: Double { rootInteractor.totalOwedToMe }
    var totalIOwe: Double { rootInteractor.totalIOwe }
    var friends: [User] { rootInteractor.friends }
    var currentUser: User { rootInteractor.currentUser }
    var nonGroupBalance: Double { rootInteractor.nonGroupBalance() }
    var nonGroupParticipants: [User] { rootInteractor.nonGroupParticipants() }
    
    // MARK: - Group Queries
    
    func groupBalance(for groupId: UUID) -> Double {
        rootInteractor.groupBalance(groupId: groupId)
    }
    
    func members(of group: ExpenseGroup) -> [User] {
        rootInteractor.members(of: group)
    }
    
    func expenses(forGroup groupId: UUID) -> [Expense] {
        rootInteractor.expenses(forGroup: groupId).sorted { $0.date > $1.date }
    }
    
    func nonGroupExpenses() -> [Expense] {
        rootInteractor.nonGroupExpenses().sorted { $0.date > $1.date }
    }
    
    func user(for id: UUID) -> User? {
        rootInteractor.user(for: id)
    }
    
    func balanceWith(friendId: UUID) -> Double {
        rootInteractor.balanceWith(friendId: friendId)
    }
    
    func groupBalanceWith(friendId: UUID, groupId: UUID) -> Double {
        rootInteractor.balanceWith(friendId: friendId, scopedToGroup: groupId)
    }
    
    func nonGroupBalanceWith(friendId: UUID) -> Double {
        rootInteractor.balanceWith(friendId: friendId, scopedToGroup: nil)
    }
    
    // MARK: - Simplify Payments
    
    func simplifiedPayments(forGroup groupId: UUID) -> [SimplifiedPayment] {
        rootInteractor.simplifiedPayments(forGroup: groupId)
    }
    
    /// Count of unique debtor-creditor pairs from raw expenses (before simplification)
    func rawPairCount(forGroup groupId: UUID) -> Int {
        let groupExpenses = rootInteractor.expenses(forGroup: groupId)
        var pairs: Set<String> = []
        
        for expense in groupExpenses {
            for split in expense.splits where split.userId != expense.paidById {
                let key = "\(min(split.userId.uuidString, expense.paidById.uuidString))-\(max(split.userId.uuidString, expense.paidById.uuidString))"
                pairs.insert(key)
            }
        }
        return pairs.count
    }
    
    // MARK: - Actions
    
    func createGroup(name: String, emoji: String, type: GroupType, memberIds: [UUID]) {
        var allMemberIds = memberIds
        if !allMemberIds.contains(rootInteractor.currentUser.id) {
            allMemberIds.insert(rootInteractor.currentUser.id, at: 0)
        }
        
        let group = ExpenseGroup(
            name: name,
            memberIds: allMemberIds,
            type: type,
            emoji: emoji
        )
        rootInteractor.addGroup(group)
    }
    
    func requestAddExpense(groupId: UUID) {
        router?.routeToAddExpense(groupId: groupId)
    }
    
    func requestAddNonGroupExpense() {
        router?.routeToAddNonGroupExpense()
    }
    
    func requestEditExpense(_ expense: Expense) {
        router?.routeToEditExpense(expense)
    }
    
    func requestSettleUp(groupId: UUID) {
        router?.routeToSettleUp(groupId: groupId)
    }
    
    func requestSettleUpNonGroup() {
        router?.routeToSettleUpNonGroup()
    }
    
    func requestShowCreateGroup() {
        router?.routeToCreateGroup()
    }
    
    func dismissCreateGroup() {
        router?.dismissCreateGroup()
    }
    
    /// Record all simplified payments as settlements at once
    func settleAllSimplified(forGroup groupId: UUID) {
        let payments = simplifiedPayments(forGroup: groupId)
        for payment in payments {
            let settlement = Settlement(
                fromUserId: payment.fromUserId,
                toUserId: payment.toUserId,
                amount: payment.amount,
                groupId: groupId
            )
            rootInteractor.addSettlement(settlement)
        }
    }
}
