//
//  GroupsRouter.swift
//  Splitza
//
//  Created by Codex on 30/05/26.
//

import Foundation

protocol GroupsRouting: Routing {
    func routeToAddExpense(groupId: UUID)
    func routeToAddNonGroupExpense()
    func routeToEditExpense(_ expense: Expense)
    func routeToSettleUp(groupId: UUID)
    func routeToSettleUpNonGroup()
    func routeToCreateGroup()
    func dismissCreateGroup()
}

class GroupsRouter: GroupsRouting {
    private let rootRouter: RootRouting
    
    init(rootRouter: RootRouting) {
        self.rootRouter = rootRouter
    }
    
    func routeToAddExpense(groupId: UUID) {
        rootRouter.routeToAddExpense(groupId: groupId, friendId: nil)
    }
    
    func routeToAddNonGroupExpense() {
        rootRouter.routeToAddExpense(groupId: nil, friendId: nil)
    }
    
    func routeToEditExpense(_ expense: Expense) {
        rootRouter.routeToEditExpense(expense)
    }
    
    func routeToSettleUp(groupId: UUID) {
        rootRouter.routeToSettleUp(friendId: nil, groupId: groupId, isNonGroup: false)
    }
    
    func routeToSettleUpNonGroup() {
        rootRouter.routeToSettleUp(friendId: nil, groupId: nil, isNonGroup: true)
    }
    
    func routeToCreateGroup() {
        rootRouter.routeToCreateGroup()
    }
    
    func dismissCreateGroup() {
        rootRouter.dismissCreateGroup()
    }
}
