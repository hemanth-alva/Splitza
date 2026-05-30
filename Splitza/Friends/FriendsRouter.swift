//
//  FriendsRouter.swift
//  Splitza
//
//  Created by Codex on 30/05/26.
//

import Foundation

protocol FriendsRouting: Routing {
    func routeToAddExpense(friendId: UUID)
    func routeToEditExpense(_ expense: Expense)
    func routeToSettleUp(friendId: UUID)
}

class FriendsRouter: FriendsRouting {
    private let rootRouter: RootRouting
    
    init(rootRouter: RootRouting) {
        self.rootRouter = rootRouter
    }
    
    func routeToAddExpense(friendId: UUID) {
        rootRouter.routeToAddExpense(groupId: nil, friendId: friendId)
    }
    
    func routeToEditExpense(_ expense: Expense) {
        rootRouter.routeToEditExpense(expense)
    }
    
    func routeToSettleUp(friendId: UUID) {
        rootRouter.routeToSettleUp(friendId: friendId, groupId: nil, isNonGroup: false)
    }
}
