//
//  AddExpenseView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI
import UIKit

struct AddExpenseView: View {
    @ObservedObject var rootInteractor: RootInteractor
    @StateObject private var interactor: AddExpenseInteractor
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: ExpenseField?
    
    init(rootInteractor: RootInteractor, expense: Expense? = nil) {
        self._rootInteractor = ObservedObject(wrappedValue: rootInteractor)
        self._interactor = StateObject(wrappedValue: AddExpenseInteractor(rootInteractor: rootInteractor, expense: expense))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Amount input
                    amountSection
                    
                    // Description
                    descriptionSection
                    
                    // Category
                    categorySection
                    
                    // Group selector
                    groupSection
                    
                    // Paid by
                    paidBySection
                    
                    // Split options
                    splitSection
                }
                .padding(AppSpacing.lg)
                .padding(.bottom, 40)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppColors.groupedBackground)
            .navigationTitle(interactor.isEditing ? "Edit Expense" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        rootInteractor.router?.dismissAddExpense()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        interactor.save()
                        dismiss()
                    }
                    .disabled(!interactor.isValid)
                    .fontWeight(.semibold)
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
    
    // MARK: - Amount
    
    private var amountSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("₹")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(AppColors.secondaryText)
            
            TextField("0.00", text: $interactor.amountText)
                .font(AppTypography.amountLarge)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.primaryText)
                .focused($focusedField, equals: .amount)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
    
    // MARK: - Description
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Description")
            
            TextField("What was this for?", text: $interactor.description)
                .font(AppTypography.body)
                .padding(AppSpacing.md)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .focused($focusedField, equals: .description)
        }
    }
    
    // MARK: - Category
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Category")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        Button {
                            interactor.selectedCategory = category
                        } label: {
                            VStack(spacing: AppSpacing.xs) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: AppRadius.sm)
                                        .fill(interactor.selectedCategory == category
                                              ? category.color.opacity(0.2)
                                              : AppColors.cardBackground)
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppRadius.sm)
                                                .stroke(interactor.selectedCategory == category
                                                        ? category.color
                                                        : Color.clear, lineWidth: 2)
                                        )
                                    Image(systemName: category.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(category.color)
                                }
                                Text(category.rawValue)
                                    .font(AppTypography.caption2)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .lineLimit(1)
                            }
                            .frame(width: 64)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Group Selector
    
    private var groupSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Group (Optional)")
            
            Menu {
                Button("No Group") {
                    interactor.selectedGroupId = nil
                    interactor.participantIds = [rootInteractor.currentUser.id]
                    interactor.paidById = rootInteractor.currentUser.id
                }
                ForEach(rootInteractor.groups) { group in
                    Button {
                        interactor.selectedGroupId = group.id
                        interactor.participantIds = Set(group.memberIds)
                        if !interactor.participantIds.contains(interactor.paidById) {
                            interactor.paidById = rootInteractor.currentUser.id
                        }
                    } label: {
                        Label(group.name, systemImage: group.type.icon)
                    }
                }
            } label: {
                HStack {
                    if let groupId = interactor.selectedGroupId,
                       let group = rootInteractor.group(for: groupId) {
                        Text(group.emoji)
                        Text(group.name)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.primaryText)
                    } else {
                        Image(systemName: "person.3")
                            .foregroundStyle(AppColors.secondaryText)
                        Text("Select a group")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                }
                .padding(AppSpacing.md)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            }
        }
    }
    
    // MARK: - Paid By
    
    private var paidBySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Paid By")
            
            Menu {
                ForEach(interactor.availableParticipants) { user in
                    Button {
                        interactor.paidById = user.id
                    } label: {
                        Label(
                            user.id == rootInteractor.currentUser.id ? "You" : user.name,
                            systemImage: interactor.paidById == user.id ? "checkmark" : ""
                        )
                    }
                }
            } label: {
                HStack {
                    if let payer = rootInteractor.user(for: interactor.paidById) {
                        AvatarView(user: payer, size: 28)
                        Text(payer.id == rootInteractor.currentUser.id ? "You" : payer.name)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                }
                .padding(AppSpacing.md)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            }
        }
    }
    
    // MARK: - Split Options
    
    private var splitSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Split")
            
            SplitOptionsView(interactor: interactor, rootInteractor: rootInteractor)
        }
    }
    
    private enum ExpenseField: Hashable {
        case amount
        case description
    }
    
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
