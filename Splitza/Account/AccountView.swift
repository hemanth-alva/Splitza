//
//  AccountView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var interactor: RootInteractor
    @State private var isDarkMode = false
    @State private var notificationsEnabled = true
    
    var netBalance: Double {
        interactor.totalOwedToMe - interactor.totalIOwe
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Profile header
                    profileHeader
                    
                    // Balance overview
                    balanceOverview
                    
                    // Settings
                    settingsSection
                    
                    // App info
                    appInfoSection
                    
                    // Logout
                    logoutButton
                }
                .padding(.bottom, 100)
            }
            .background(AppColors.groupedBackground)
            .navigationTitle("Account")
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: AppSpacing.md) {
            AvatarView(user: interactor.currentUser, size: 80)
            
            Text(interactor.currentUser.name)
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            
            Text(interactor.currentUser.email)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
        .background(AppColors.cardBackground)
    }
    
    // MARK: - Balance Overview
    
    private var balanceOverview: some View {
        VStack(spacing: AppSpacing.lg) {
            SectionHeader(title: "Overall Balance")
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: AppSpacing.md) {
                // Net balance
                VStack(spacing: AppSpacing.xs) {
                    Text("Net Balance")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                    
                    Text(CurrencyFormatter.format(netBalance))
                        .font(AppTypography.amountLarge)
                        .foregroundStyle(netBalance >= 0 ? AppColors.owedToYou : AppColors.youOwe)
                }
                
                Divider()
                
                HStack(spacing: AppSpacing.xxxl) {
                    VStack(spacing: AppSpacing.xs) {
                        Text("You are owed")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                        Text(CurrencyFormatter.format(interactor.totalOwedToMe))
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.owedToYou)
                    }
                    
                    VStack(spacing: AppSpacing.xs) {
                        Text("You owe")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                        Text(CurrencyFormatter.format(interactor.totalIOwe))
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.youOwe)
                    }
                }
                
                Divider()
                
                // Stats
                HStack {
                    StatItem(title: "Friends", value: "\(interactor.friends.count)", icon: "person.2.fill")
                    Spacer()
                    StatItem(title: "Groups", value: "\(interactor.groups.count)", icon: "person.3.fill")
                    Spacer()
                    StatItem(title: "Expenses", value: "\(interactor.expenses.count)", icon: "receipt.fill")
                }
            }
            .padding(AppSpacing.xl)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    // MARK: - Settings
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Settings")
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: 0) {
                SettingsRow(icon: "bell.fill", iconColor: .red, title: "Notifications") {
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(AppColors.primary)
                }
                
                Divider().padding(.leading, 52)
                
                SettingsRow(icon: "moon.fill", iconColor: .indigo, title: "Dark Mode") {
                    Toggle("", isOn: $isDarkMode)
                        .tint(AppColors.primary)
                }
                
                Divider().padding(.leading, 52)
                
                SettingsRow(icon: "indianrupeesign.circle.fill", iconColor: .green, title: "Currency") {
                    Text("INR (₹)")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Divider().padding(.leading, 52)
                
                SettingsRow(icon: "globe", iconColor: .blue, title: "Language") {
                    Text("English")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    // MARK: - App Info
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "About")
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: 0) {
                SettingsRow(icon: "info.circle.fill", iconColor: .blue, title: "Version") {
                    Text("1.0.0")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Divider().padding(.leading, 52)
                
                SettingsRow(icon: "star.fill", iconColor: .yellow, title: "Rate Splitza") {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                }
                
                Divider().padding(.leading, 52)
                
                SettingsRow(icon: "questionmark.circle.fill", iconColor: .orange, title: "Help & Support") {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    // MARK: - Logout Button
    
    private var logoutButton: some View {
        Button {
            // Placeholder
        } label: {
            HStack {
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Log Out")
                    .fontWeight(.semibold)
                Spacer()
            }
            .foregroundStyle(AppColors.youOwe)
            .padding(AppSpacing.md)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppColors.primary)
            Text(value)
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.primaryText)
            Text(title)
                .font(AppTypography.caption2)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    @ViewBuilder let trailing: () -> Trailing
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            trailing()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}
