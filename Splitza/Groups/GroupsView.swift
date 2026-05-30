//
//  GroupsView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct GroupsView: View {
    @ObservedObject var interactor: GroupsInteractor
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    TotalBalanceCard(
                        totalOwed: interactor.totalOwedToMe,
                        totalOwe: interactor.totalIOwe
                    )
                    .padding(.top, AppSpacing.sm)
                    
                    VStack(spacing: AppSpacing.sm) {
                        HStack {
                            SectionHeader(title: "Your Groups")
                            Spacer()
                            Button {
                                interactor.requestShowCreateGroup()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        LazyVStack(spacing: AppSpacing.sm) {
                            NavigationLink {
                                NonGroupDetailView(interactor: interactor)
                            } label: {
                                NonGroupCard(
                                    members: interactor.nonGroupParticipants,
                                    balance: interactor.nonGroupBalance
                                )
                            }
                            .buttonStyle(.plain)
                            
                            ForEach(interactor.groups) { group in
                                NavigationLink {
                                    GroupDetailView(interactor: interactor, group: group)
                                } label: {
                                    GroupCard(
                                        group: group,
                                        members: interactor.members(of: group),
                                        balance: interactor.groupBalance(for: group.id)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        if interactor.groups.isEmpty {
                            EmptyStateView(
                                icon: "person.3.fill",
                                title: "No Groups Yet",
                                subtitle: "Create a group to start splitting group expenses",
                                actionTitle: "Create Group"
                            ) {
                                interactor.requestShowCreateGroup()
                            }
                            .frame(height: 220)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .background(AppColors.groupedBackground)
            .navigationTitle("Groups")
            .sheet(isPresented: $interactor.showCreateGroup) {
                CreateGroupView(interactor: interactor)
            }
        }
    }
}

// MARK: - Group Card

struct GroupCard: View {
    let group: ExpenseGroup
    let members: [User]
    let balance: Double
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 50, height: 50)
                Text(group.emoji)
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(group.name)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                AvatarStackView(users: members, size: 22)
            }
            
            Spacer()
            
            BalanceLabel(amount: balance, font: AppTypography.footnote, showSign: true)
        }
        .cardStyle()
    }
}

struct NonGroupCard: View {
    let members: [User]
    let balance: Double
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 50, height: 50)
                Text("🧾")
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Non-group expenses")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                if members.count > 1 {
                    AvatarStackView(users: members, size: 22)
                } else {
                    Text("Expenses outside groups")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            
            Spacer()
            
            BalanceLabel(amount: balance, font: AppTypography.footnote, showSign: true)
        }
        .cardStyle()
    }
}
