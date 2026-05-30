//
//  RootRouter.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import Foundation

protocol RootRouting: Routing {
    func routeToAddExpense(groupId: UUID?, friendId: UUID?)
    func routeToEditExpense(_ expense: Expense)
    func dismissAddExpense()
    func routeToCreateGroup()
    func dismissCreateGroup()
    func routeToSettleUp(friendId: UUID?, groupId: UUID?, isNonGroup: Bool)
    func dismissSettleUp()
}

class RootRouter: RootRouting {
    private weak var rootInteractor: RootInteractor?
    
    init(rootInteractor: RootInteractor) {
        self.rootInteractor = rootInteractor
    }
    
    func routeToAddExpense(groupId: UUID? = nil, friendId: UUID? = nil) {
        rootInteractor?.editingExpense = nil
        rootInteractor?.addExpenseGroupId = groupId
        rootInteractor?.addExpenseFriendId = friendId
        rootInteractor?.showAddExpense = true
    }
    
    func routeToEditExpense(_ expense: Expense) {
        rootInteractor?.editingExpense = expense
        rootInteractor?.addExpenseGroupId = nil
        rootInteractor?.addExpenseFriendId = nil
        rootInteractor?.showAddExpense = true
    }
    
    func dismissAddExpense() {
        rootInteractor?.editingExpense = nil
        rootInteractor?.addExpenseGroupId = nil
        rootInteractor?.addExpenseFriendId = nil
    }
    
    func routeToCreateGroup() {
        rootInteractor?.showCreateGroup = true
    }
    
    func dismissCreateGroup() {
        rootInteractor?.showCreateGroup = false
    }
    
    func routeToSettleUp(friendId: UUID? = nil, groupId: UUID? = nil, isNonGroup: Bool = false) {
        rootInteractor?.settleUpWithUserId = friendId
        rootInteractor?.settleUpGroupId = groupId
        rootInteractor?.settleUpNonGroup = isNonGroup
        rootInteractor?.showSettleUp = true
    }
    
    func dismissSettleUp() {
        rootInteractor?.settleUpWithUserId = nil
        rootInteractor?.settleUpGroupId = nil
        rootInteractor?.settleUpNonGroup = false
    }
}
