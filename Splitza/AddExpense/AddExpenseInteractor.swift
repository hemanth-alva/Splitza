//
//  AddExpenseInteractor.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import Foundation
import SwiftUI
import Combine

class AddExpenseInteractor: ObservableObject {
    @Published var description = ""
    @Published var amountText = ""
    @Published var selectedCategory: ExpenseCategory = .general
    @Published var splitType: SplitType = .equal
    @Published var paidById: UUID
    @Published var selectedGroupId: UUID?
    @Published var participantIds: Set<UUID> = []
    
    // Unequal split inputs
    @Published var exactAmounts: [UUID: String] = [:]
    @Published var percentages: [UUID: String] = [:]
    @Published var shares: [UUID: String] = [:]
    
    let rootInteractor: RootInteractor
    
    var amount: Double {
        Double(amountText) ?? 0
    }
    
    init(rootInteractor: RootInteractor) {
        self.rootInteractor = rootInteractor
        self.paidById = rootInteractor.currentUser.id
        
        // Pre-select group if set
        if let groupId = rootInteractor.addExpenseGroupId {
            self.selectedGroupId = groupId
            if let group = rootInteractor.group(for: groupId) {
                self.participantIds = Set(group.memberIds)
            }
        } else if let friendId = rootInteractor.addExpenseFriendId {
            self.participantIds = [rootInteractor.currentUser.id, friendId]
        } else {
            self.participantIds = [rootInteractor.currentUser.id]
        }
    }
    
    // MARK: - Available participants
    
    var availableParticipants: [User] {
        if let groupId = selectedGroupId, let group = rootInteractor.group(for: groupId) {
            return group.memberIds.compactMap { rootInteractor.user(for: $0) }
        }
        return rootInteractor.allUsers
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        guard !description.isEmpty, amount > 0, participantIds.count >= 2 else { return false }
        
        switch splitType {
        case .equal:
            return true
        case .exact:
            let total = participantIds.reduce(0.0) { $0 + (Double(exactAmounts[$1] ?? "0") ?? 0) }
            return abs(total - amount) < 0.01
        case .percentage:
            let total = participantIds.reduce(0.0) { $0 + (Double(percentages[$1] ?? "0") ?? 0) }
            return abs(total - 100) < 0.01
        case .shares:
            let totalShares = participantIds.reduce(0.0) { $0 + (Double(shares[$1] ?? "0") ?? 0) }
            return totalShares > 0
        }
    }
    
    // MARK: - Compute splits
    
    func computeSplits() -> [Split] {
        let ids = Array(participantIds)
        
        switch splitType {
        case .equal:
            let share = amount / Double(ids.count)
            return ids.map { Split(userId: $0, amount: share) }
            
        case .exact:
            return ids.map { id in
                Split(userId: id, amount: Double(exactAmounts[id] ?? "0") ?? 0)
            }
            
        case .percentage:
            return ids.map { id in
                let pct = Double(percentages[id] ?? "0") ?? 0
                return Split(userId: id, amount: amount * pct / 100.0)
            }
            
        case .shares:
            let totalShares = ids.reduce(0.0) { $0 + (Double(shares[$1] ?? "0") ?? 0) }
            guard totalShares > 0 else { return [] }
            return ids.map { id in
                let share = Double(shares[id] ?? "0") ?? 0
                return Split(userId: id, amount: amount * share / totalShares)
            }
        }
    }
    
    // MARK: - Remaining (for exact amounts)
    
    var exactRemaining: Double {
        let total = participantIds.reduce(0.0) { $0 + (Double(exactAmounts[$1] ?? "0") ?? 0) }
        return amount - total
    }
    
    var percentageRemaining: Double {
        let total = participantIds.reduce(0.0) { $0 + (Double(percentages[$1] ?? "0") ?? 0) }
        return 100 - total
    }
    
    // MARK: - Save
    
    func save() {
        let expense = Expense(
            description: description,
            amount: amount,
            paidById: paidById,
            splitType: splitType,
            splits: computeSplits(),
            groupId: selectedGroupId,
            category: selectedCategory
        )
        rootInteractor.addExpense(expense)
        
        // Clear pre-selections
        rootInteractor.addExpenseGroupId = nil
        rootInteractor.addExpenseFriendId = nil
    }
}
