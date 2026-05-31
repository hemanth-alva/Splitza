//
//  SettleUpInteractor.swift
//  Splitza
//
//  Created by Antigravity on 30/05/26.
//

import Foundation
import Combine

/// Interactor for the Settle Up sheet.
/// Contains all business logic for recording settlements.
class SettleUpInteractor: ObservableObject {
    enum Context {
        case all
        case individual(UUID)
        case group(UUID)
        case nonGroup
    }
    
    let rootInteractor: RootInteractor
    let context: Context
    
    @Published var selectedFriendId: UUID?
    @Published var amountText = ""
    
    init(rootInteractor: RootInteractor) {
        self.rootInteractor = rootInteractor
        
        if let presetFriendId = rootInteractor.settleUpWithUserId {
            self.context = .individual(presetFriendId)
        } else if let groupId = rootInteractor.settleUpGroupId {
            self.context = .group(groupId)
        } else if rootInteractor.settleUpNonGroup {
            self.context = .nonGroup
        } else {
            self.context = .all
        }
        
        // Pre-select friend if set
        if case .individual(let presetFriendId) = context {
            self.selectedFriendId = presetFriendId
            prefillAmount(for: presetFriendId)
        } else if friendsWithDebt.count == 1, let friend = friendsWithDebt.first {
            self.selectedFriendId = friend.id
            prefillAmount(for: friend.id)
        }
    }
    
    // MARK: - Computed State
    
    var currentUser: User { rootInteractor.currentUser }
    
    func user(for id: UUID) -> User? {
        rootInteractor.user(for: id)
    }
    
    /// Friends who have non-zero balances
    var friendsWithDebt: [User] {
        eligibleFriends.filter { friend in
            let balance = balance(with: friend.id)
            return abs(balance) > 0.01
        }
    }
    
    var eligibleFriends: [User] {
        switch context {
        case .all:
            return rootInteractor.friends
        case .individual(let friendId):
            return rootInteractor.user(for: friendId).map { [$0] } ?? []
        case .group(let groupId):
            guard let group = rootInteractor.group(for: groupId) else { return [] }
            return group.memberIds
                .filter { $0 != rootInteractor.currentUser.id }
                .compactMap { rootInteractor.user(for: $0) }
        case .nonGroup:
            return rootInteractor.nonGroupParticipants().filter { $0.id != rootInteractor.currentUser.id }
        }
    }
    
    var isIndividualContext: Bool {
        if case .individual = context {
            return true
        }
        return false
    }
    
    var navigationTitle: String {
        switch context {
        case .individual:
            return "Settle Up"
        case .group(let groupId):
            return rootInteractor.group(for: groupId)?.name ?? "Settle Group"
        case .nonGroup:
            return "Settle Non-group"
        case .all:
            return "Settle Up"
        }
    }
    
    var selectorTitle: String {
        switch context {
        case .group:
            return "Group members"
        case .nonGroup:
            return "Non-group balances"
        default:
            return "Settle with"
        }
    }
    
    var emptyTitle: String {
        switch context {
        case .individual(let friendId):
            let name = rootInteractor.user(for: friendId)?.name ?? "this friend"
            return "All Settled with \(name)"
        case .group:
            return "Group Settled Up!"
        case .nonGroup:
            return "No Non-group Balances"
        case .all:
            return "All Settled Up!"
        }
    }
    
    var emptySubtitle: String {
        switch context {
        case .individual:
            return "There is no outstanding balance with this person"
        case .group:
            return "There are no outstanding balances in this group"
        case .nonGroup:
            return "Non-group expenses and payments are settled"
        case .all:
            return "You have no outstanding balances with any friends"
        }
    }
    
    func balance(with friendId: UUID) -> Double {
        switch context {
        case .all, .individual:
            return rootInteractor.balanceWith(friendId: friendId)
        case .group(let groupId):
            return rootInteractor.balanceWith(friendId: friendId, scopedToGroup: groupId, respectSimplify: true)
        case .nonGroup:
            return rootInteractor.balanceWith(friendId: friendId, scopedToGroup: nil, respectSimplify: true)
        }
    }
    
    // MARK: - Actions
    
    func selectFriend(_ friendId: UUID) {
        selectedFriendId = friendId
        prefillAmount(for: friendId)
    }
    
    /// Record a settlement and clear state
    func recordSettlement() -> Bool {
        guard let friendId = selectedFriendId,
              let amount = Double(amountText), amount > 0 else { return false }
        
        let totalBalance = balance(with: friendId)
        let isIOwe = totalBalance < 0
        
        // If we are settling inside a specific group or non-group context,
        // we just record one settlement scoped to that context.
        switch context {
        case .group(let groupId):
            createSettlement(friendId: friendId, amount: amount, isIOwe: isIOwe, groupId: groupId)
        case .nonGroup:
            createSettlement(friendId: friendId, amount: amount, isIOwe: isIOwe, groupId: nil)
        case .all, .individual:
            // Distribute the payment across all shared groups and non-group debts
            distributeSettlement(amount: amount, friendId: friendId, isIOwe: isIOwe)
        }
        
        rootInteractor.router?.dismissSettleUp()
        return true
    }
    
    private func distributeSettlement(amount: Double, friendId: UUID, isIOwe: Bool) {
        let sharedGroups = rootInteractor.groups.filter {
            $0.memberIds.contains(friendId) && $0.memberIds.contains(rootInteractor.currentUser.id)
        }
        
        // Collect per-context balances (positive = they owe me, negative = I owe them)
        struct ContextDebt {
            let groupId: UUID?
            let balance: Double
        }
        
        var contextDebts: [ContextDebt] = []
        
        // Non-group balance
        let nonGroupBalance = rootInteractor.balanceWith(friendId: friendId, scopedToGroup: nil)
        if abs(nonGroupBalance) > 0.01 {
            contextDebts.append(ContextDebt(groupId: nil, balance: nonGroupBalance))
        }
        
        // Group balances
        for group in sharedGroups {
            let groupBalance = rootInteractor.balanceWith(friendId: friendId, scopedToGroup: group.id)
            if abs(groupBalance) > 0.01 {
                contextDebts.append(ContextDebt(groupId: group.id, balance: groupBalance))
            }
        }
        
        // Check if this is a full settlement (paying the exact global balance)
        let totalGlobalDebt = abs(rootInteractor.balanceWith(friendId: friendId))
        let isFullSettlement = abs(amount - totalGlobalDebt) < 0.01
        
        if isFullSettlement {
            // Full settlement: zero out EVERY context individually, regardless of direction.
            // This ensures each group shows as settled.
            for debt in contextDebts {
                let debtIsIOwe = debt.balance < 0
                createSettlement(
                    friendId: friendId,
                    amount: abs(debt.balance),
                    isIOwe: debtIsIOwe,
                    groupId: debt.groupId
                )
            }
        } else {
            // Partial settlement: greedily apply to debts in the main direction first
            var remainingAmount = amount
            
            // Sort: main-direction debts first, then by amount descending
            let sorted = contextDebts.sorted { a, b in
                let aMainDir = (isIOwe && a.balance < 0) || (!isIOwe && a.balance > 0)
                let bMainDir = (isIOwe && b.balance < 0) || (!isIOwe && b.balance > 0)
                if aMainDir != bMainDir { return aMainDir }
                return abs(a.balance) > abs(b.balance)
            }
            
            for debt in sorted {
                if remainingAmount <= 0.01 { break }
                // Only settle debts flowing in the main direction for partial payments
                let debtFlowsMainDir = (isIOwe && debt.balance < 0) || (!isIOwe && debt.balance > 0)
                guard debtFlowsMainDir else { continue }
                
                let settleAmount = min(remainingAmount, abs(debt.balance))
                createSettlement(friendId: friendId, amount: settleAmount, isIOwe: isIOwe, groupId: debt.groupId)
                remainingAmount -= settleAmount
            }
            
            // If there is still remaining amount (overpayment), put in non-group
            if remainingAmount > 0.01 {
                createSettlement(friendId: friendId, amount: remainingAmount, isIOwe: isIOwe, groupId: nil)
            }
        }
    }
    
    private func createSettlement(friendId: UUID, amount: Double, isIOwe: Bool, groupId: UUID?) {
        let settlement = Settlement(
            fromUserId: isIOwe ? rootInteractor.currentUser.id : friendId,
            toUserId: isIOwe ? friendId : rootInteractor.currentUser.id,
            amount: amount,
            groupId: groupId
        )
        rootInteractor.addSettlement(settlement)
    }
    
    func cancel() {
        rootInteractor.router?.dismissSettleUp()
    }
    
    private var settlementGroupId: UUID? {
        if case .group(let groupId) = context {
            return groupId
        }
        return nil
    }
    
    private func prefillAmount(for friendId: UUID) {
        let balance = balance(with: friendId)
        amountText = String(format: "%.2f", abs(balance))
    }
}
