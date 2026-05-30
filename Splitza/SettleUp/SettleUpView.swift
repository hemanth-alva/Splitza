//
//  SettleUpView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI
import UIKit

struct SettleUpView: View {
    @StateObject private var interactor: SettleUpInteractor
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAmountFocused: Bool
    
    init(rootInteractor: RootInteractor) {
        self._interactor = StateObject(wrappedValue: SettleUpInteractor(rootInteractor: rootInteractor))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xl) {
                if interactor.friendsWithDebt.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle.fill",
                        title: interactor.emptyTitle,
                        subtitle: interactor.emptySubtitle
                    )
                } else {
                    if interactor.isIndividualContext {
                        selectedFriendSummary
                    } else {
                        friendSelector
                    }
                    
                    if interactor.selectedFriendId != nil {
                        amountInput
                        directionInfo
                    }
                    
                    Spacer()
                    
                    if interactor.selectedFriendId != nil {
                        Button {
                            if interactor.recordSettlement() {
                                dismiss()
                            }
                        } label: {
                            Text("Record Payment")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(interactor.amountText.isEmpty || (Double(interactor.amountText) ?? 0) <= 0)
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
            .contentShape(Rectangle())
            .onTapGesture {
                dismissKeyboard()
            }
            .background(AppColors.groupedBackground)
            .navigationTitle(interactor.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        interactor.cancel()
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        dismissKeyboard()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Friend Selector
    
    private var friendSelector: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: interactor.selectorTitle)
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: 0) {
                ForEach(interactor.friendsWithDebt) { friend in
                    let balance = interactor.balance(with: friend.id)
                    
                    Button {
                        withAnimation {
                            interactor.selectFriend(friend.id)
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
                            
                            if interactor.selectedFriendId == friend.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.primary)
                                    .font(.system(size: 22))
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                    }
                    .buttonStyle(.plain)
                    
                    if friend.id != interactor.friendsWithDebt.last?.id {
                        Divider().padding(.leading, 72)
                    }
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    private var selectedFriendSummary: some View {
        Group {
            if let friendId = interactor.selectedFriendId,
               let friend = interactor.user(for: friendId) {
                let balance = interactor.balance(with: friendId)
                
                VStack(spacing: AppSpacing.md) {
                    AvatarView(user: friend, size: 64)
                    
                    VStack(spacing: AppSpacing.xs) {
                        Text(friend.name)
                            .font(AppTypography.title3)
                            .foregroundStyle(AppColors.primaryText)
                        
                        BalanceLabel(amount: balance, font: AppTypography.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.xl)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }
    
    // MARK: - Amount Input
    
    private var amountInput: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("₹")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppColors.secondaryText)
            
            TextField("0.00", text: $interactor.amountText)
                .font(AppTypography.amountLarge)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.primaryText)
                .focused($isAmountFocused)
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
            if let friendId = interactor.selectedFriendId,
               let friend = interactor.user(for: friendId) {
                let balance = interactor.balance(with: friendId)
                
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
    
    private func dismissKeyboard() {
        isAmountFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
