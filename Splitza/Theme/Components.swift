//
//  Components.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

// MARK: - Avatar View

struct AvatarView: View {
    let user: User
    var size: CGFloat = 40
    
    var body: some View {
        ZStack {
            Circle()
                .fill(user.avatarColor.gradient)
                .frame(width: size, height: size)
            
            Text(user.initials)
                .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Avatar Stack (overlapping)

struct AvatarStackView: View {
    let users: [User]
    var size: CGFloat = 28
    var maxDisplay: Int = 4
    
    var body: some View {
        HStack(spacing: -(size * 0.25)) {
            ForEach(Array(users.prefix(maxDisplay).enumerated()), id: \.element.id) { index, user in
                AvatarView(user: user, size: size)
                    .overlay(
                        Circle()
                            .stroke(AppColors.background, lineWidth: 2)
                    )
                    .zIndex(Double(maxDisplay - index))
            }
            
            if users.count > maxDisplay {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: size, height: size)
                    Text("+\(users.count - maxDisplay)")
                        .font(.system(size: size * 0.32, weight: .semibold))
                        .foregroundStyle(AppColors.secondaryText)
                }
                .overlay(
                    Circle()
                        .stroke(AppColors.background, lineWidth: 2)
                )
            }
        }
    }
}

// MARK: - Balance Label

struct BalanceLabel: View {
    let amount: Double
    var font: Font = AppTypography.amountSmall
    var showSign: Bool = true
    
    var body: some View {
        if amount > 0.005 {
            Text(showSign ? "you are owed \(CurrencyFormatter.format(amount))" : CurrencyFormatter.format(amount))
                .font(font)
                .foregroundStyle(AppColors.owedToYou)
        } else if amount < -0.005 {
            Text(showSign ? "you owe \(CurrencyFormatter.format(amount))" : CurrencyFormatter.format(amount))
                .font(font)
                .foregroundStyle(AppColors.youOwe)
        } else {
            Text("settled up")
                .font(font)
                .foregroundStyle(AppColors.settled)
        }
    }
}

// MARK: - Expense Row

struct ExpenseRow: View {
    let expense: Expense
    let paidByUser: User?
    let currentUserId: UUID
    var showsEditIndicator: Bool = false
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(expense.category.color.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: expense.category.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(expense.category.color)
            }
            
            // Description and who paid
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.description)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                
                Text(paidByUser?.id == currentUserId ? "You paid" : "\(paidByUser?.name ?? "Someone") paid")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
            
            // Amount and your share
            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.format(expense.amount))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                let yourSplit = expense.splits.first(where: { $0.userId == currentUserId })?.amount ?? 0
                let paidByYou = expense.paidById == currentUserId
                
                if paidByYou {
                    Text("you lent \(CurrencyFormatter.format(expense.amount - yourSplit))")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.owedToYou)
                } else {
                    Text("you owe \(CurrencyFormatter.format(yourSplit))")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.youOwe)
                }
            }
            
            if showsEditIndicator {
                Image(systemName: "pencil")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.tertiaryText)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

// MARK: - Settlement Row

struct SettlementRow: View {
    let settlement: Settlement
    let fromUser: User?
    let toUser: User?
    let currentUserId: UUID
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: "banknote.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if settlement.fromUserId == currentUserId {
                    Text("You paid \(toUser?.name ?? "someone")")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                } else {
                    Text("\(fromUser?.name ?? "Someone") paid you")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                }
                
                Text("Settlement")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
            
            Text(CurrencyFormatter.format(settlement.amount))
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primary)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

// MARK: - Category Icon

struct CategoryIconView: View {
    let category: ExpenseCategory
    var size: CGFloat = 42
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.sm)
                .fill(category.color.opacity(0.15))
                .frame(width: size, height: size)
            Image(systemName: category.icon)
                .font(.system(size: size * 0.42))
                .foregroundStyle(category.color)
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(AppColors.primary.opacity(0.5))
                .padding(.bottom, AppSpacing.sm)
            
            Text(title)
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.primaryText)
            
            Text(subtitle)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xxxl)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 60)
                .padding(.top, AppSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(AppTypography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.secondaryText)
            .tracking(0.8)
    }
}

// MARK: - Total Balance Card

struct TotalBalanceCard: View {
    let totalOwed: Double
    let totalOwe: Double
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.xxxl) {
                VStack(spacing: AppSpacing.xs) {
                    Text("you are owed")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                    Text(CurrencyFormatter.format(totalOwed))
                        .font(AppTypography.amountMedium)
                        .foregroundStyle(AppColors.owedToYou)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: AppSpacing.xs) {
                    Text("you owe")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                    Text(CurrencyFormatter.format(totalOwe))
                        .font(AppTypography.amountMedium)
                        .foregroundStyle(AppColors.youOwe)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
        .padding(.horizontal, AppSpacing.lg)
    }
}
