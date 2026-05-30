//
//  GroupDetailView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct GroupDetailView: View {
    @ObservedObject var interactor: GroupsInteractor
    let group: ExpenseGroup
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                groupHeader
                memberBalancesSection
                actionButtons
                simplifyDebtsSection
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
            
            BalanceLabel(
                amount: interactor.groupBalance(for: group.id),
                font: AppTypography.headline
            )
            
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: group.type.icon)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text(group.type.rawValue)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text("•")
                    .foregroundStyle(AppColors.tertiaryText)
                Text("\(interactor.members(of: group).count) members")
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
        let members = interactor.members(of: group)
        
        return VStack(alignment: .leading, spacing: AppSpacing.md) {
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
                            BalanceLabel(
                                amount: interactor.groupBalanceWith(friendId: member.id, groupId: group.id),
                                font: AppTypography.footnote
                            )
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
                interactor.requestSettleUp(groupId: group.id)
            } label: {
                Label("Settle Up", systemImage: "banknote.fill")
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button {
                interactor.requestAddExpense(groupId: group.id)
            } label: {
                Label("Add Expense", systemImage: "plus.circle.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Simplify Debts
    
    private var simplifyDebtsSection: some View {
        let payments = interactor.simplifiedPayments(forGroup: group.id)
        
        return Group {
            if !payments.isEmpty {
                SimplifyPaymentsView(
                    interactor: interactor,
                    groupId: group.id,
                    payments: payments
                )
            }
        }
    }
    
    // MARK: - Expenses
    
    private var expensesSection: some View {
        let groupExpenses = interactor.expenses(forGroup: group.id)
        
        return VStack(alignment: .leading, spacing: AppSpacing.md) {
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
