//
//  SplitOptionsView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct SplitOptionsView: View {
    @ObservedObject var interactor: AddExpenseInteractor
    @ObservedObject var rootInteractor: RootInteractor
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Split type tabs
            splitTypePicker
            
            // Participants & split details
            participantsList
            
            // Validation indicator
            validationBar
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    
    // MARK: - Split Type Picker
    
    private var splitTypePicker: some View {
        HStack(spacing: 0) {
            ForEach(SplitType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        interactor.splitType = type
                    }
                } label: {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: type.icon)
                            .font(.system(size: 16))
                        Text(type.rawValue)
                            .font(AppTypography.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(interactor.splitType == type ? AppColors.primary.opacity(0.15) : Color.clear)
                    )
                    .foregroundStyle(interactor.splitType == type ? AppColors.primary : AppColors.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.xs)
        .background(AppColors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    
    // MARK: - Participants List
    
    private var participantsList: some View {
        VStack(spacing: 0) {
            ForEach(interactor.availableParticipants) { user in
                HStack(spacing: AppSpacing.md) {
                    // Checkbox (for equal split)
                    if interactor.splitType == .equal {
                        Button {
                            if interactor.participantIds.contains(user.id) {
                                if interactor.participantIds.count > 2 {
                                    interactor.participantIds.remove(user.id)
                                }
                            } else {
                                interactor.participantIds.insert(user.id)
                            }
                        } label: {
                            Image(systemName: interactor.participantIds.contains(user.id)
                                  ? "checkmark.circle.fill"
                                  : "circle")
                                .foregroundStyle(interactor.participantIds.contains(user.id) ? AppColors.primary : AppColors.tertiaryText)
                                .font(.system(size: 20))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    AvatarView(user: user, size: 32)
                    
                    Text(user.id == rootInteractor.currentUser.id ? "You" : user.name)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    // Input based on split type
                    splitInput(for: user)
                }
                .padding(.vertical, AppSpacing.sm)
                
                if user.id != interactor.availableParticipants.last?.id {
                    Divider()
                }
            }
        }
    }
    
    // MARK: - Split Input per Type
    
    @ViewBuilder
    private func splitInput(for user: User) -> some View {
        switch interactor.splitType {
        case .equal:
            if interactor.participantIds.contains(user.id) && interactor.amount > 0 {
                let share = interactor.amount / Double(interactor.participantIds.count)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyFormatter.format(share))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                    Text(formatPercentage(interactor.computedPercentage(for: user.id)))
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }
            
        case .exact:
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text("₹")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                    TextField("0", text: Binding(
                        get: { interactor.exactAmounts[user.id] ?? "" },
                        set: { interactor.exactAmounts[user.id] = $0 }
                    ))
                    .font(AppTypography.body)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                }
                
                if interactor.amount > 0 {
                    Text(formatPercentage(interactor.computedPercentage(for: user.id)))
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }
            
        case .percentage:
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    TextField("0", text: Binding(
                        get: { interactor.percentages[user.id] ?? "" },
                        set: { interactor.percentages[user.id] = $0 }
                    ))
                    .font(AppTypography.body)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    Text("%")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                if interactor.amount > 0 {
                    Text(CurrencyFormatter.format(interactor.computedAmount(for: user.id)))
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }
            
        case .shares:
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: AppSpacing.sm) {
                    Button {
                        let current = Int(interactor.shares[user.id] ?? "0") ?? 0
                        if current > 0 {
                            interactor.shares[user.id] = "\(current - 1)"
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(AppColors.secondaryText)
                            .font(.system(size: 22))
                    }
                    .buttonStyle(.plain)
                    
                    Text(interactor.shares[user.id] ?? "0")
                        .font(AppTypography.headline)
                        .frame(width: 28, alignment: .center)
                    
                    Button {
                        let current = Int(interactor.shares[user.id] ?? "0") ?? 0
                        interactor.shares[user.id] = "\(current + 1)"
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppColors.primary)
                            .font(.system(size: 22))
                    }
                    .buttonStyle(.plain)
                }
                
                if interactor.amount > 0 {
                    Text("\(formatPercentage(interactor.computedPercentage(for: user.id))) • \(CurrencyFormatter.format(interactor.computedAmount(for: user.id)))")
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }
        }
    }
    
    // MARK: - Validation Bar
    
    private var validationBar: some View {
        Group {
            switch interactor.splitType {
            case .equal:
                if interactor.amount > 0 {
                    let share = interactor.amount / Double(interactor.participantIds.count)
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.owedToYou)
                        Text("\(CurrencyFormatter.format(share))/person")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
                
            case .exact:
                let remaining = interactor.exactRemaining
                HStack {
                    Image(systemName: abs(remaining) < 0.01 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(abs(remaining) < 0.01 ? AppColors.owedToYou : AppColors.youOwe)
                    Text(abs(remaining) < 0.01 ? "Fully allocated" : "\(CurrencyFormatter.format(remaining)) remaining")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
            case .percentage:
                let remaining = interactor.percentageRemaining
                HStack {
                    Image(systemName: abs(remaining) < 0.01 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(abs(remaining) < 0.01 ? AppColors.owedToYou : AppColors.youOwe)
                    Text(abs(remaining) < 0.01 ? "100% allocated" : "\(String(format: "%.1f", remaining))% remaining")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
            case .shares:
                let totalShares = interactor.participantIds.reduce(0.0) { $0 + (Double(interactor.shares[$1] ?? "0") ?? 0) }
                if totalShares > 0 && interactor.amount > 0 {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.owedToYou)
                        Text("\(CurrencyFormatter.format(interactor.amount / totalShares))/share")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
    }
    
    private func formatPercentage(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))%"
        }
        return String(format: "%.1f%%", value)
    }
}
