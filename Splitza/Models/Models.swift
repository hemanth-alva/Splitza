//
//  Models.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import Foundation
import SwiftUI

// MARK: - User

struct User: Identifiable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var avatarColor: Color
    
    init(id: UUID = UUID(), name: String, email: String, avatarColor: Color = .teal) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarColor = avatarColor
    }
    
    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Group

struct ExpenseGroup: Identifiable, Hashable {
    let id: UUID
    var name: String
    var memberIds: [UUID]
    var type: GroupType
    var emoji: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, memberIds: [UUID], type: GroupType = .other, emoji: String = "👥", createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.memberIds = memberIds
        self.type = type
        self.emoji = emoji
        self.createdAt = createdAt
    }
}

enum GroupType: String, CaseIterable, Hashable {
    case trip = "Trip"
    case home = "Home"
    case couple = "Couple"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .trip: return "airplane"
        case .home: return "house.fill"
        case .couple: return "heart.fill"
        case .other: return "person.3.fill"
        }
    }
}

// MARK: - Expense

struct Expense: Identifiable, Hashable {
    let id: UUID
    var description: String
    var amount: Double
    var paidById: UUID
    var splitType: SplitType
    var splits: [Split]
    var date: Date
    var groupId: UUID?
    var category: ExpenseCategory
    
    init(
        id: UUID = UUID(),
        description: String,
        amount: Double,
        paidById: UUID,
        splitType: SplitType = .equal,
        splits: [Split] = [],
        date: Date = Date(),
        groupId: UUID? = nil,
        category: ExpenseCategory = .general
    ) {
        self.id = id
        self.description = description
        self.amount = amount
        self.paidById = paidById
        self.splitType = splitType
        self.splits = splits
        self.date = date
        self.groupId = groupId
        self.category = category
    }
}

enum SplitType: String, CaseIterable, Hashable {
    case equal = "Equal"
    case exact = "Exact"
    case percentage = "Percentage"
    case shares = "Shares"
    
    var icon: String {
        switch self {
        case .equal: return "equal.circle.fill"
        case .exact: return "number.circle.fill"
        case .percentage: return "percent"
        case .shares: return "chart.pie.fill"
        }
    }
}

struct Split: Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var amount: Double
    
    init(id: UUID = UUID(), userId: UUID, amount: Double) {
        self.id = id
        self.userId = userId
        self.amount = amount
    }
}

// MARK: - Settlement

struct Settlement: Identifiable, Hashable {
    let id: UUID
    var fromUserId: UUID
    var toUserId: UUID
    var amount: Double
    var date: Date
    var groupId: UUID?
    
    init(id: UUID = UUID(), fromUserId: UUID, toUserId: UUID, amount: Double, date: Date = Date(), groupId: UUID? = nil) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.amount = amount
        self.date = date
        self.groupId = groupId
    }
}

// MARK: - Expense Category

enum ExpenseCategory: String, CaseIterable, Hashable {
    case general = "General"
    case food = "Food & Drink"
    case transport = "Transport"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case utilities = "Utilities"
    case rent = "Rent"
    case travel = "Travel"
    case health = "Health"
    case education = "Education"
    
    var icon: String {
        switch self {
        case .general: return "tag.fill"
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "film.fill"
        case .shopping: return "bag.fill"
        case .utilities: return "bolt.fill"
        case .rent: return "house.fill"
        case .travel: return "airplane"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .general: return .gray
        case .food: return .orange
        case .transport: return .blue
        case .entertainment: return .purple
        case .shopping: return .pink
        case .utilities: return .yellow
        case .rent: return .brown
        case .travel: return .teal
        case .health: return .red
        case .education: return .indigo
        }
    }
}

// MARK: - Balance

struct Balance: Identifiable, Hashable {
    var id: UUID { userId }
    var userId: UUID
    var amount: Double // Positive = owed to you, Negative = you owe
}

// MARK: - Activity Item (for the feed)

enum ActivityItem: Identifiable {
    case expense(Expense)
    case settlement(Settlement)
    
    var id: UUID {
        switch self {
        case .expense(let e): return e.id
        case .settlement(let s): return s.id
        }
    }
    
    var date: Date {
        switch self {
        case .expense(let e): return e.date
        case .settlement(let s): return s.date
        }
    }
}

// MARK: - Simplified Payment (for debt simplification)

struct SimplifiedPayment: Identifiable, Hashable {
    let id: UUID
    let fromUserId: UUID
    let toUserId: UUID
    let amount: Double
    
    init(id: UUID = UUID(), fromUserId: UUID, toUserId: UUID, amount: Double) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.amount = amount
    }
}

