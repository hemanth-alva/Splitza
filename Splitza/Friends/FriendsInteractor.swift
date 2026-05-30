//
//  FriendsInteractor.swift
//  Splitza
//
//  Created by Antigravity on 30/05/26.
//

import Foundation
import Combine
import SwiftUI

/// Interactor for Friends tab and Friend Detail screens.
/// Contains all business logic for friend operations — views only render.
class FriendsInteractor: Interacting {
    typealias RouterType = FriendsRouting
    
    let rootInteractor: RootInteractor
    var router: FriendsRouting?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var friends: [User] = []
    
    init(rootInteractor: RootInteractor, router: FriendsRouting? = nil) {
        self.rootInteractor = rootInteractor
        self.router = router
        
        rootInteractor.$friends
            .assign(to: &$friends)
        
        rootInteractor.$expenses
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed State
    
    var currentUser: User { rootInteractor.currentUser }
    var totalOwedToMe: Double { rootInteractor.totalOwedToMe }
    var totalIOwe: Double { rootInteractor.totalIOwe }
    
    // MARK: - Friend Queries
    
    func balance(with friendId: UUID) -> Double {
        rootInteractor.balanceWith(friendId: friendId)
    }
    
    func expenses(withFriend friendId: UUID) -> [Expense] {
        rootInteractor.expenses(withFriend: friendId).sorted { $0.date > $1.date }
    }
    
    func sharedGroups(with friendId: UUID) -> [ExpenseGroup] {
        rootInteractor.groups.filter { $0.memberIds.contains(friendId) }
    }
    
    func user(for id: UUID) -> User? {
        rootInteractor.user(for: id)
    }
    
    // MARK: - Actions
    
    func addFriend(name: String, email: String) {
        let resolvedEmail = email.isEmpty
            ? "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@email.com"
            : email
        
        let friend = User(
            name: name,
            email: resolvedEmail,
            avatarColor: AppColors.avatarColor(for: rootInteractor.friends.count + 1)
        )
        rootInteractor.addFriend(friend)
    }
    
    func requestSettleUp(friendId: UUID) {
        router?.routeToSettleUp(friendId: friendId)
    }
    
    func requestAddExpense(friendId: UUID) {
        router?.routeToAddExpense(friendId: friendId)
    }
    
    func requestEditExpense(_ expense: Expense) {
        router?.routeToEditExpense(expense)
    }
}
