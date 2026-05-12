//
//  FriendDetailView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct FriendDetailView: View {
    @ObservedObject var interactor: RootInteractor
    let friend: User
    
    var friendExpenses: [Expense] {
        interactor.expenses(withFriend: friend.id).sorted { $0.date > $1.date }
    }
    
    var balance: Double {
        interactor.balanceWith(friendId: friend.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Friend header
                friendHeader
                
                // Actions
                actionButtons
                
                // Shared groups
                sharedGroupsSection
                
                // Expense history
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
            
            BalanceLabel(amount: balance, font: AppTypography.headline)
            
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
                interactor.settleUpWithUserId = friend.id
                interactor.showSettleUp = true
            } label: {
                Label("Settle Up", systemImage: "banknote.fill")
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button {
                interactor.addExpenseFriendId = friend.id
                interactor.showAddExpense = true
            } label: {
                Label("Add Expense", systemImage: "plus.circle.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Shared Groups
    
    private var sharedGroupsSection: some View {
        let sharedGroups = interactor.groups.filter { $0.memberIds.contains(friend.id) }
        
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
    
    // MARK: - Expense History
    
    private var expenseHistorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Expense History")
                .padding(.horizontal, AppSpacing.lg)
            
            if friendExpenses.isEmpty {
                EmptyStateView(
                    icon: "receipt",
                    title: "No Expenses",
                    subtitle: "No shared expenses with \(friend.name) yet"
                )
                .frame(height: 200)
            } else {
                VStack(spacing: 0) {
                    ForEach(friendExpenses) { expense in
                        ExpenseRow(
                            expense: expense,
                            paidByUser: interactor.user(for: expense.paidById),
                            currentUserId: interactor.currentUser.id
                        )
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.xs)
                        
                        if expense.id != friendExpenses.last?.id {
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
}
