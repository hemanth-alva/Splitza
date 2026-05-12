//
//  RootRouter.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import Foundation

public protocol RootRouting: Routing {
    func routeToAddExpense()
    func routeToCreateGroup()
    func routeToSettleUp()
}

public class RootRouter: RootRouting {
    public init() {}
    
    public func routeToAddExpense() {
        // Handled via sheet presentation in RootView
    }
    
    public func routeToCreateGroup() {
        // Handled via sheet presentation in GroupsView
    }
    
    public func routeToSettleUp() {
        // Handled via sheet presentation in RootView
    }
}
