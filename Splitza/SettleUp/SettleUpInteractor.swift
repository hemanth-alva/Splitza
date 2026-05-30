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
            return rootInteractor.balanceWith(friendId: friendId, scopedToGroup: groupId)
        case .nonGroup:
            return rootInteractor.balanceWith(friendId: friendId, scopedToGroup: nil)
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
        
        let balance = balance(with: friendId)
        
        let settlement: Settlement
        if balance < 0 {
            // I owe them
            settlement = Settlement(
                fromUserId: rootInteractor.currentUser.id,
                toUserId: friendId,
                amount: amount,
                groupId: settlementGroupId
            )
        } else {
            // They owe me
            settlement = Settlement(
                fromUserId: friendId,
                toUserId: rootInteractor.currentUser.id,
                amount: amount,
                groupId: settlementGroupId
            )
        }
        
        rootInteractor.addSettlement(settlement)
        rootInteractor.router?.dismissSettleUp()
        return true
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
