//
//  HelpSupportView.swift
//  Splitza
//
//  Created by Codex on 30/05/26.
//

import SwiftUI

struct HelpSupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                introCard
                helpSection(
                    title: "How Splitza Works",
                    items: [
                        HelpItem(icon: "plus.circle.fill", title: "Add expenses", text: "Record what was paid, who paid it, and who should share the cost."),
                        HelpItem(icon: "person.3.fill", title: "Use groups", text: "Create groups for trips, flat expenses, office lunches, or any shared context."),
                        HelpItem(icon: "person.2.fill", title: "Track friends", text: "Open a friend to see all shared expenses and the current balance with only that person."),
                        HelpItem(icon: "banknote.fill", title: "Settle up", text: "Record a payment when someone pays back what they owe.")
                    ]
                )
                helpSection(
                    title: "Splitting Options",
                    items: [
                        HelpItem(icon: "equal.circle.fill", title: "Equal", text: "Everyone selected contributes the same amount."),
                        HelpItem(icon: "number.circle.fill", title: "Exact", text: "Enter the exact amount each person should pay."),
                        HelpItem(icon: "percent", title: "Percentage", text: "Assign each person a percentage of the total."),
                        HelpItem(icon: "chart.pie.fill", title: "Shares", text: "Use share counts when some people should pay more than others.")
                    ]
                )
                helpSection(
                    title: "Tips",
                    items: [
                        HelpItem(icon: "pencil", title: "Edit expenses", text: "Tap an expense row to update its amount, payer, category, or split."),
                        HelpItem(icon: "tray.full.fill", title: "Non-group expenses", text: "Use the Non-group card in Groups for expenses that do not belong to a specific group."),
                        HelpItem(icon: "moon.fill", title: "Dark mode", text: "Turn on Dark Mode from Account settings to switch the whole app.")
                    ]
                )
                contactCard
            }
            .padding(AppSpacing.lg)
            .padding(.bottom, 40)
        }
        .background(AppColors.groupedBackground)
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var introCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundStyle(AppColors.primary)
            
            Text("Splitza helps you track shared expenses, see who owes whom, and settle balances without mental math.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
        }
        .cardStyle()
    }
    
    private func helpSection(title: String, items: [HelpItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: title)
            
            VStack(spacing: 0) {
                ForEach(items) { item in
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppColors.primary.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: item.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(item.title)
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)
                            Text(item.text)
                                .font(AppTypography.subheadline)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .padding(AppSpacing.md)
                    
                    if item.id != items.last?.id {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }
    
    private var contactCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Need more help?")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            Text("This is a UI-only support page for now. Add your support email, FAQ links, or feedback flow here when the backend is ready.")
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardStyle()
    }
}

struct HelpItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let text: String
}
