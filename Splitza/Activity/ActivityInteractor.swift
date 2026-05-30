//
//  ActivityInteractor.swift
//  Splitza
//
//  Created by Antigravity on 30/05/26.
//

import Foundation
import Combine

/// Interactor for the Activity tab.
/// Contains all business logic for grouping and sorting the activity feed.
class ActivityInteractor: Interacting {
    typealias RouterType = ActivityRouting
    
    let rootInteractor: RootInteractor
    var router: ActivityRouting?
    private var cancellables = Set<AnyCancellable>()
    
    init(rootInteractor: RootInteractor, router: ActivityRouting? = nil) {
        self.rootInteractor = rootInteractor
        self.router = router
        
        rootInteractor.$expenses
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        rootInteractor.$settlements
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed State
    
    var currentUser: User { rootInteractor.currentUser }
    
    func user(for id: UUID) -> User? {
        rootInteractor.user(for: id)
    }
    
    func requestEditExpense(_ expense: Expense) {
        router?.routeToEditExpense(expense)
    }
    
    var activityFeed: [ActivityItem] {
        rootInteractor.activityFeed
    }
    
    /// Group activity items by date string for section headers
    var groupedActivity: [(String, [ActivityItem])] {
        let feed = activityFeed
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        var result: [(String, [ActivityItem])] = []
        var currentDate = ""
        var currentItems: [ActivityItem] = []
        
        for item in feed {
            let dateStr = formatter.string(from: item.date)
            if dateStr != currentDate {
                if !currentItems.isEmpty {
                    result.append((currentDate, currentItems))
                }
                currentDate = dateStr
                currentItems = [item]
            } else {
                currentItems.append(item)
            }
        }
        if !currentItems.isEmpty {
            result.append((currentDate, currentItems))
        }
        
        return result
    }
}
