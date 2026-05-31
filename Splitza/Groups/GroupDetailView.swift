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
        let isEnabled = interactor.isSimplifyEnabled(for: group.id)
        
        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                SectionHeader(title: "Debts")
                Spacer()
                
                HStack(spacing: AppSpacing.xs) {
                    Text("Simplify")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                    
                    Toggle("", isOn: Binding(
                        get: { isEnabled },
                        set: { _ in interactor.toggleSimplifyDebts(for: group.id) }
                    ))
                    .labelsHidden()
                    .tint(AppColors.primary)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            
            let payments = isEnabled ? interactor.simplifiedPayments(forGroup: group.id) : interactor.rawDebts(forGroup: group.id)
            
            if !payments.isEmpty {
                SimplifyPaymentsView(
                    interactor: interactor,
                    groupId: group.id,
                    payments: payments,
                    isSimplified: isEnabled
                )
                .padding(.top, AppSpacing.xs)
            } else {
                Text(isEnabled ? "No debts to simplify right now." : "No outstanding debts in this group.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .padding(.horizontal, AppSpacing.lg)
            }
        }
    }
    
    // MARK: - Activity History
    
    private var expensesSection: some View {
        let activities = interactor.groupActivity(forGroup: group.id)
        
        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "History")
                .padding(.horizontal, AppSpacing.lg)
            
            if activities.isEmpty {
                EmptyStateView(
                    icon: "receipt",
                    title: "No Activity Yet",
                    subtitle: "Add an expense to start splitting costs"
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
