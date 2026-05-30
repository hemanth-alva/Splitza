//
//  ActivityView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject var interactor: ActivityInteractor
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if interactor.activityFeed.isEmpty {
                    EmptyStateView(
                        icon: "clock.fill",
                        title: "No Activity",
                        subtitle: "Your expense and payment activity will appear here"
                    )
                    .frame(minHeight: 400)
                } else {
                    LazyVStack(spacing: AppSpacing.lg, pinnedViews: .sectionHeaders) {
                        ForEach(interactor.groupedActivity, id: \.0) { dateString, items in
                            Section {
                                VStack(spacing: 0) {
                                    ForEach(items) { item in
                                        activityRow(for: item)
                                        
                                        if item.id != items.last?.id {
                                            Divider()
                                                .padding(.leading, 64)
                                        }
                                    }
                                }
                                .background(AppColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                .padding(.horizontal, AppSpacing.lg)
                            } header: {
                                HStack {
                                    Text(dateString)
                                        .font(AppTypography.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(AppColors.secondaryText)
                                    Spacer()
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.xs)
                                .background(AppColors.groupedBackground)
                            }
                        }
                    }
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, 100)
                }
            }
            .background(AppColors.groupedBackground)
            .navigationTitle("Activity")
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
