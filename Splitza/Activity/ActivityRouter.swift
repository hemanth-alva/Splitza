//
//  ActivityRouter.swift
//  Splitza
//
//  Created by Codex on 30/05/26.
//

protocol ActivityRouting: Routing {
    func routeToEditExpense(_ expense: Expense)
}

class ActivityRouter: ActivityRouting {
    private let rootRouter: RootRouting
    
    init(rootRouter: RootRouting) {
        self.rootRouter = rootRouter
    }
    
    func routeToEditExpense(_ expense: Expense) {
        rootRouter.routeToEditExpense(expense)
    }
}
