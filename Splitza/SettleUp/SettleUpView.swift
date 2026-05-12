//
//  SettleUpView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct SettleUpView: View {
    @ObservedObject var interactor: RootInteractor
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFriendId: UUID?
    @State private var amountText = ""
    
    var friendsWithDebt: [User] {
        interactor.friends.filter { friend in
            let balance = interactor.balanceWith(friendId: friend.id)
            return abs(balance) > 0.01
        }
    }
    
    init(interactor: RootInteractor) {
        self._interactor = ObservedObject(wrappedValue: interactor)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xl) {
                if friendsWithDebt.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle.fill",
                        title: "All Settled Up!",
                        subtitle: "You have no outstanding balances with any friends"
                    )
                } else {
                    // Select friend
                    friendSelector
                    
                    // Amount
                    if selectedFriendId != nil {
                        amountInput
                        directionInfo
                    }
                    
                    Spacer()
                    
                    // Record button
                    if selectedFriendId != nil {
                        Button {
                            recordSettlement()
                        } label: {
                            Text("Record Payment")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(amountText.isEmpty || (Double(amountText) ?? 0) <= 0)
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
            .background(AppColors.groupedBackground)
            .navigationTitle("Settle Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        interactor.settleUpWithUserId = nil
                        interactor.settleUpGroupId = nil
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let presetFriendId = interactor.settleUpWithUserId {
                    selectedFriendId = presetFriendId
                    let balance = interactor.balanceWith(friendId: presetFriendId)
                    amountText = String(format: "%.2f", abs(balance))
                }
            }
        }
    }
    
    // MARK: - Friend Selector
    
    private var friendSelector: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Settle with")
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: 0) {
                ForEach(friendsWithDebt) { friend in
                    let balance = interactor.balanceWith(friendId: friend.id)
                    
                    Button {
                        withAnimation {
                            selectedFriendId = friend.id
                            amountText = String(format: "%.2f", abs(balance))
                        }
                    } label: {
                        HStack(spacing: AppSpacing.md) {
                            AvatarView(user: friend, size: 40)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friend.name)
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)
                                
                                BalanceLabel(amount: balance, font: AppTypography.caption)
                            }
                            
                            Spacer()
                            
                            if selectedFriendId == friend.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.primary)
                                    .font(.system(size: 22))
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                    }
                    .buttonStyle(.plain)
                    
                    if friend.id != friendsWithDebt.last?.id {
                        Divider().padding(.leading, 72)
                    }
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    // MARK: - Amount Input
    
    private var amountInput: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("₹")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppColors.secondaryText)
            
            TextField("0.00", text: $amountText)
                .font(AppTypography.amountLarge)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Direction Info
    
    private var directionInfo: some View {
        Group {
            if let friendId = selectedFriendId, let friend = interactor.user(for: friendId) {
                let balance = interactor.balanceWith(friendId: friendId)
                
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(AppColors.primary)
                    
                    if balance < 0 {
                        Text("You pay \(friend.name)")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    } else {
                        Text("\(friend.name) pays you")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
                .padding(AppSpacing.md)
                .background(AppColors.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }
    
    // MARK: - Record Settlement
    
    private func recordSettlement() {
        guard let friendId = selectedFriendId,
              let amount = Double(amountText), amount > 0 else { return }
        
        let balance = interactor.balanceWith(friendId: friendId)
        
        let settlement: Settlement
        if balance < 0 {
            // I owe them
            settlement = Settlement(
                fromUserId: interactor.currentUser.id,
                toUserId: friendId,
                amount: amount,
                groupId: interactor.settleUpGroupId
            )
        } else {
            // They owe me
            settlement = Settlement(
                fromUserId: friendId,
                toUserId: interactor.currentUser.id,
                amount: amount,
                groupId: interactor.settleUpGroupId
            )
        }
        
        interactor.addSettlement(settlement)
        interactor.settleUpWithUserId = nil
        interactor.settleUpGroupId = nil
        dismiss()
    }
}
