//
//  DataProvider.swift
//  Splitza
//
//  Created by Antigravity on 30/05/26.
//

import Foundation
import SwiftUI

// MARK: - DataProvider Protocol

/// Protocol that abstracts the data source for the app.
/// Implement this with an API client to connect to a backend.
protocol DataProvider {
    func loadCurrentUser() -> User
    func loadFriends(for currentUser: User) -> [User]
    func loadGroups(for currentUser: User, friends: [User]) -> [ExpenseGroup]
    func loadExpenses(for groups: [ExpenseGroup], currentUser: User, friends: [User]) -> [Expense]
    func loadSettlements() -> [Settlement]
}

// MARK: - Sample Data Provider

/// In-memory sample data for development and previews.
/// Replace with `APIDataProvider` when connecting to a backend.
class SampleDataProvider: DataProvider {
    
    func loadCurrentUser() -> User {
        User(name: "Hemanth", email: "hemanth@splitza.app", avatarColor: AppColors.avatarColors[0])
    }
    
    func loadFriends(for currentUser: User) -> [User] {
        [
            User(name: "Rahul Sharma", email: "rahul@email.com", avatarColor: AppColors.avatarColors[1]),
            User(name: "Priya Patel", email: "priya@email.com", avatarColor: AppColors.avatarColors[2]),
            User(name: "Amit Kumar", email: "amit@email.com", avatarColor: AppColors.avatarColors[3]),
            User(name: "Sneha Reddy", email: "sneha@email.com", avatarColor: AppColors.avatarColors[4]),
            User(name: "Vikram Singh", email: "vikram@email.com", avatarColor: AppColors.avatarColors[5]),
        ]
    }
    
    func loadGroups(for currentUser: User, friends: [User]) -> [ExpenseGroup] {
        let friend1 = friends[0]
        let friend2 = friends[1]
        let friend3 = friends[2]
        let friend4 = friends[3]
        let friend5 = friends[4]
        
        return [
            ExpenseGroup(
                name: "Goa Trip",
                memberIds: [currentUser.id, friend1.id, friend2.id, friend3.id],
                type: .trip,
                emoji: "🏖️",
                createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
            ),
            ExpenseGroup(
                name: "Flat Expenses",
                memberIds: [currentUser.id, friend1.id, friend4.id],
                type: .home,
                emoji: "🏠",
                createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date())!
            ),
            ExpenseGroup(
                name: "Office Lunch",
                memberIds: [currentUser.id, friend2.id, friend3.id, friend5.id],
                type: .other,
                emoji: "🍕",
                createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
            ),
        ]
    }
    
    func loadExpenses(for groups: [ExpenseGroup], currentUser: User, friends: [User]) -> [Expense] {
        let friend1 = friends[0]
        let friend2 = friends[1]
        let friend3 = friends[2]
        let friend5 = friends[4]
        
        let group1 = groups[0] // Goa Trip
        let group2 = groups[1] // Flat Expenses
        let group3 = groups[2] // Office Lunch
        
        let membersGroup1 = [currentUser.id, friend1.id, friend2.id, friend3.id]
        
        return [
            Expense(
                description: "Pizza Party",
                amount: 1800,
                paidById: friend2.id,
                splitType: .equal,
                splits: [currentUser.id, friend2.id, friend3.id, friend5.id].map { Split(userId: $0, amount: 450) },
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                groupId: group3.id,
                category: .food
            ),
            Expense(
                description: "Electricity Bill",
                amount: 2400,
                paidById: currentUser.id,
                splitType: .equal,
                splits: [currentUser.id, friend1.id, friends[3].id].map { Split(userId: $0, amount: 800) },
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                groupId: group2.id,
                category: .utilities
            ),
            Expense(
                description: "Cab to Airport",
                amount: 1500,
                paidById: friend3.id,
                splitType: .equal,
                splits: membersGroup1.map { Split(userId: $0, amount: 375) },
                date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
                groupId: group1.id,
                category: .transport
            ),
            Expense(
                description: "Dinner at Fisherman's Wharf",
                amount: 3200,
                paidById: friend1.id,
                splitType: .equal,
                splits: membersGroup1.map { Split(userId: $0, amount: 800) },
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                groupId: group1.id,
                category: .food
            ),
            Expense(
                description: "Hotel booking",
                amount: 12000,
                paidById: currentUser.id,
                splitType: .equal,
                splits: membersGroup1.map { Split(userId: $0, amount: 3000) },
                date: Calendar.current.date(byAdding: .day, value: -8, to: Date())!,
                groupId: group1.id,
                category: .travel
            ),
        ]
    }
    
    func loadSettlements() -> [Settlement] {
        // Note: Settlement references are resolved at runtime via user IDs.
        // For sample data, we return an empty array since the friend IDs are
        // generated fresh each launch. The RootInteractor adds a sample
        // settlement after loading friends.
        return []
    }
}
