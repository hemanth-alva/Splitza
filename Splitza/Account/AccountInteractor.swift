//
//  AccountInteractor.swift
//  Splitza
//
//  Created by Antigravity on 30/05/26.
//

import Foundation
import Combine

/// Interactor for the Account tab.
/// Contains all business logic for profile, stats, and balance overview.
class AccountInteractor: ObservableObject {
    
    let rootInteractor: RootInteractor
    
    init(rootInteractor: RootInteractor) {
        self.rootInteractor = rootInteractor
    }
    
    // MARK: - Computed State
    
    var currentUser: User { rootInteractor.currentUser }
    var totalOwedToMe: Double { rootInteractor.totalOwedToMe }
    var totalIOwe: Double { rootInteractor.totalIOwe }
    
    var netBalance: Double {
        totalOwedToMe - totalIOwe
    }
    
    var friendsCount: Int { rootInteractor.friends.count }
    var groupsCount: Int { rootInteractor.groups.count }
    var expensesCount: Int { rootInteractor.expenses.count }
}
