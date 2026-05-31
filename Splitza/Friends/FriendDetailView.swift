//
//  FriendDetailView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct FriendDetailView: View {
    @ObservedObject var interactor: FriendsInteractor
    let friend: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                friendHeader
                actionButtons
                sharedGroupsSection
                expenseHistorySection
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.groupedBackground)
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Friend Header
    
    private var friendHeader: some View {
        VStack(spacing: AppSpacing.md) {
            AvatarView(user: friend, size: 72)
            
            Text(friend.name)
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            
            BalanceLabel(amount: interactor.balance(with: friend.id), font: AppTypography.headline)
            
            Text(friend.email)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(AppColors.cardBackground)
    }
    
    // MARK: - Actions
    
    private var actionButtons: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                interactor.requestSettleUp(friendId: friend.id)
            } label: {
                Label("Settle Up", systemImage: "banknote.fill")
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button {
                interactor.requestAddExpense(friendId: friend.id)
            } label: {
                Label("Add Expense", systemImage: "plus.circle.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Shared Groups
    
    private var sharedGroupsSection: some View {
        let sharedGroups = interactor.sharedGroups(with: friend.id)
        
        return Group {
            if !sharedGroups.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(title: "Shared Groups")
                        .padding(.horizontal, AppSpacing.lg)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.md) {
                            ForEach(sharedGroups) { group in
                                VStack(spacing: AppSpacing.xs) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: AppRadius.md)
                                            .fill(AppColors.primary.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        Text(group.emoji)
                                            .font(.system(size: 24))
                                    }
                                    Text(group.name)
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColors.secondaryText)
                                        .lineLimit(1)
                                }
                                .frame(width: 70)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
        }
    }
    
    // MARK: - Activity History
    
    private var expenseHistorySection: some View {
        let activities = interactor.friendActivity(withFriend: friend.id)
        
        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "History")
                .padding(.horizontal, AppSpacing.lg)
            
            if activities.isEmpty {
                EmptyStateView(
                    icon: "receipt",
                    title: "No Activity",
                    subtitle: "No shared activity with \(friend.name) yet"
                )
                .frame(height: 200)
            } else {
                VStack(spacing: 0) {
                    ForEach(activities) { item in
                        activityRow(for: item)
                        
                        if item.id != activities.last?.id {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }
    
    @ViewBuilder
    private func activityRow(for item: ActivityItem) -> some View {
        switch item {
        case .expense(let expense):
            Button {
                interactor.requestEditExpense(expense)
            } label: {
                ExpenseRow(
                    expense: expense,
                    paidByUser: interactor.user(for: expense.paidById),
                    currentUserId: interactor.currentUser.id,
                    showsEditIndicator: true
                )
            }
            .buttonStyle(.plain)
            .accessibilityHint("Edit expense")
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xs)
            
        case .settlement(let settlement):
            SettlementRow(
                settlement: settlement,
                fromUser: interactor.user(for: settlement.fromUserId),
                toUser: interactor.user(for: settlement.toUserId),
                currentUserId: interactor.currentUser.id
            )
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xs)
        }
    }
}
