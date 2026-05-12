//
//  GroupDetailView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct GroupDetailView: View {
    @ObservedObject var interactor: RootInteractor
    let group: ExpenseGroup
    
    var groupExpenses: [Expense] {
        interactor.expenses(forGroup: group.id).sorted { $0.date > $1.date }
    }
    
    var members: [User] {
        interactor.members(of: group)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Group header
                groupHeader
                
                // Member balances
                memberBalancesSection
                
                // Actions
                actionButtons
                
                // Expenses
                expensesSection
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.groupedBackground)
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Group Header
    
    private var groupHeader: some View {
        VStack(spacing: AppSpacing.md) {
            Text(group.emoji)
                .font(.system(size: 48))
            
            Text(group.name)
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            
            let balance = interactor.groupBalance(groupId: group.id)
            BalanceLabel(amount: balance, font: AppTypography.headline)
            
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: group.type.icon)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text(group.type.rawValue)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text("•")
                    .foregroundStyle(AppColors.tertiaryText)
                Text("\(members.count) members")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(AppColors.cardBackground)
    }
    
    // MARK: - Member Balances
    
    private var memberBalancesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Members")
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: 0) {
                ForEach(members) { member in
                    HStack(spacing: AppSpacing.md) {
                        AvatarView(user: member, size: 36)
                        
                        Text(member.id == interactor.currentUser.id ? "You" : member.name)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.primaryText)
                        
                        Spacer()
                        
                        if member.id != interactor.currentUser.id {
                            let balance = interactor.balanceWith(friendId: member.id)
                            BalanceLabel(amount: balance, font: AppTypography.footnote)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    
                    if member.id != members.last?.id {
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
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                interactor.settleUpGroupId = group.id
                interactor.showSettleUp = true
            } label: {
                Label("Settle Up", systemImage: "banknote.fill")
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button {
                interactor.addExpenseGroupId = group.id
                interactor.showAddExpense = true
            } label: {
                Label("Add Expense", systemImage: "plus.circle.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Expenses
    
    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Expenses")
                .padding(.horizontal, AppSpacing.lg)
            
            if groupExpenses.isEmpty {
                EmptyStateView(
                    icon: "receipt",
                    title: "No Expenses Yet",
                    subtitle: "Add an expense to start splitting costs"
                )
                .frame(height: 200)
            } else {
                VStack(spacing: 0) {
                    ForEach(groupExpenses) { expense in
                        ExpenseRow(
                            expense: expense,
                            paidByUser: interactor.user(for: expense.paidById),
                            currentUserId: interactor.currentUser.id
                        )
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.xs)
                        
                        if expense.id != groupExpenses.last?.id {
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
