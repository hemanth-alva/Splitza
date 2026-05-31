//
//  SimplifyPaymentsView.swift
//  Splitza
//
//  Created by Antigravity on 30/05/26.
//

import SwiftUI

/// Displays the simplified payment plan for a group.
/// Shows the minimal set of transactions needed to settle all debts.
struct SimplifyPaymentsView: View {
    @ObservedObject var interactor: GroupsInteractor
    let groupId: UUID
    let payments: [SimplifiedPayment]
    
    @State private var showConfirmSettleAll = false
    
    var isSimplified: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            if isSimplified {
                HStack {
                    Spacer()
                    savingsTag
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            
            // Payment list
            VStack(spacing: 0) {
                ForEach(payments) { payment in
                    paymentRow(payment)
                    
                    if payment.id != payments.last?.id {
                        Divider()
                            .padding(.leading, 64)
                    }
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .padding(.horizontal, AppSpacing.lg)
            
            // Settle All button
            Button {
                showConfirmSettleAll = true
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Settle All (\(payments.count) payments)")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, AppSpacing.lg)
            .alert("Settle All Debts?", isPresented: $showConfirmSettleAll) {
                Button("Cancel", role: .cancel) {}
                Button("Settle All") {
                    withAnimation(.spring(response: 0.3)) {
                        interactor.settleAllSimplified(forGroup: groupId)
                    }
                }
            } message: {
                Text("This will record \(payments.count) settlement(s) to clear all group debts.")
            }
        }
    }
    
    // MARK: - Savings Tag
    
    private var savingsTag: some View {
        let rawCount = interactor.rawPairCount(forGroup: groupId)
        let saved = DebtSimplifier.transactionsSaved(
            originalPairCount: rawCount,
            simplifiedPayments: payments
        )
        
        return Group {
            if saved > 0 {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "arrow.triangle.merge")
                        .font(.system(size: 10))
                    Text("\(saved) fewer payment\(saved == 1 ? "" : "s")")
                        .font(AppTypography.caption2)
                }
                .foregroundStyle(AppColors.owedToYou)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColors.owedToYou.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            }
        }
    }
    
    // MARK: - Payment Row
    
    private func paymentRow(_ payment: SimplifiedPayment) -> some View {
        let fromUser = interactor.user(for: payment.fromUserId)
        let toUser = interactor.user(for: payment.toUserId)
        
        return HStack(spacing: AppSpacing.md) {
            // From avatar
            if let from = fromUser {
                AvatarView(user: from, size: 36)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xs) {
                    Text(fromUser?.id == interactor.currentUser.id ? "You" : fromUser?.name ?? "?")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                    
                    Text(toUser?.id == interactor.currentUser.id ? "You" : toUser?.name ?? "?")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                }
                
                Text("pays")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
            
            Text(CurrencyFormatter.format(payment.amount))
                .font(AppTypography.amountSmall)
                .foregroundStyle(AppColors.primary)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}
