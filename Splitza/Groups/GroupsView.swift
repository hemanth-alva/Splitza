//
//  GroupsView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct GroupsView: View {
    @ObservedObject var interactor: RootInteractor
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Balance summary
                    TotalBalanceCard(
                        totalOwed: interactor.totalOwedToMe,
                        totalOwe: interactor.totalIOwe
                    )
                    .padding(.top, AppSpacing.sm)
                    
                    // Groups list
                    VStack(spacing: AppSpacing.sm) {
                        HStack {
                            SectionHeader(title: "Your Groups")
                            Spacer()
                            Button {
                                interactor.showCreateGroup = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        if interactor.groups.isEmpty {
                            EmptyStateView(
                                icon: "person.3.fill",
                                title: "No Groups Yet",
                                subtitle: "Create a group to start splitting expenses with friends",
                                actionTitle: "Create Group"
                            ) {
                                interactor.showCreateGroup = true
                            }
                            .frame(height: 300)
                        } else {
                            LazyVStack(spacing: AppSpacing.sm) {
                                ForEach(interactor.groups) { group in
                                    NavigationLink {
                                        GroupDetailView(interactor: interactor, group: group)
                                    } label: {
                                        GroupCard(
                                            group: group,
                                            members: interactor.members(of: group),
                                            balance: interactor.groupBalance(groupId: group.id)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
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
            // Emoji icon
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
