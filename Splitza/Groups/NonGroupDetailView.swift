//
//  NonGroupDetailView.swift
//  Splitza
//
//  Created by Codex on 30/05/26.
//

import SwiftUI

struct NonGroupDetailView: View {
    @ObservedObject var interactor: GroupsInteractor
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                header
                participantsSection
                actionButtons
                expensesSection
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.groupedBackground)
        .navigationTitle("Non-group")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: AppSpacing.md) {
            Text("🧾")
                .font(.system(size: 48))
            
            Text("Non-group expenses")
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            
            BalanceLabel(
                amount: interactor.nonGroupBalance,
                font: AppTypography.headline
            )
            
            Text("Expenses that are not attached to any group")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(AppColors.cardBackground)
    }
    
    private var participantsSection: some View {
        let participants = interactor.nonGroupParticipants
        
        return Group {
            if participants.count > 1 {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(title: "People")
                        .padding(.horizontal, AppSpacing.lg)
                    
                    VStack(spacing: 0) {
                        ForEach(participants) { participant in
                            HStack(spacing: AppSpacing.md) {
                                AvatarView(user: participant, size: 36)
                                
                                Text(participant.id == interactor.currentUser.id ? "You" : participant.name)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.primaryText)
                                
                                Spacer()
                                
                                if participant.id != interactor.currentUser.id {
                                    BalanceLabel(
                                        amount: interactor.nonGroupBalanceWith(friendId: participant.id),
                                        font: AppTypography.footnote
                                    )
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            
                            if participant.id != participants.last?.id {
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
    
    private var actionButtons: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                interactor.requestSettleUpNonGroup()
            } label: {
                Label("Settle Up", systemImage: "banknote.fill")
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button {
                interactor.requestAddNonGroupExpense()
            } label: {
                Label("Add Expense", systemImage: "plus.circle.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    private var expensesSection: some View {
        let expenses = interactor.nonGroupExpenses()
        
        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Expenses")
                .padding(.horizontal, AppSpacing.lg)
            
            if expenses.isEmpty {
                EmptyStateView(
                    icon: "receipt",
                    title: "No Non-group Expenses",
                    subtitle: "Add expenses here when they do not belong to a group"
                )
                .frame(height: 200)
            } else {
                VStack(spacing: 0) {
                    ForEach(expenses) { expense in
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
                        
                        if expense.id != expenses.last?.id {
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
