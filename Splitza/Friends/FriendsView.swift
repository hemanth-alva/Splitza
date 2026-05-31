//
//  FriendsView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct FriendsView: View {
    @ObservedObject var interactor: FriendsInteractor
    @State private var showAddFriend = false
    @State private var newFriendName = ""
    @State private var newFriendEmail = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    TotalBalanceCard(
                        totalOwed: interactor.totalOwedToMe,
                        totalOwe: interactor.totalIOwe
                    )
                    .padding(.top, AppSpacing.sm)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack {
                            SectionHeader(title: "Friends")
                            Spacer()
                            Button {
                                showAddFriend = true
                            } label: {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18))
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        if interactor.friends.isEmpty {
                            EmptyStateView(
                                icon: "person.2.fill",
                                title: "No Friends Yet",
                                subtitle: "Add friends to start splitting expenses",
                                actionTitle: "Add a Friend"
                            ) {
                                showAddFriend = true
                            }
                            .frame(height: 300)
                        } else {
                            let unsettled = interactor.friends.filter { abs(interactor.balance(with: $0.id)) > 0.01 }
                            let settled = interactor.friends.filter { abs(interactor.balance(with: $0.id)) <= 0.01 }
                            
                            // Unsettled friends
                            if !unsettled.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(unsettled) { friend in
                                        NavigationLink {
                                            FriendDetailView(interactor: interactor, friend: friend)
                                        } label: {
                                            FriendRow(
                                                friend: friend,
                                                balance: interactor.balance(with: friend.id)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        
                                        if friend.id != unsettled.last?.id {
                                            Divider()
                                                .padding(.leading, 72)
                                        }
                                    }
                                }
                                .background(AppColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                .padding(.horizontal, AppSpacing.lg)
                            }
                            
                            // Settled friends
                            if !settled.isEmpty {
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    HStack(spacing: AppSpacing.xs) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(AppColors.owedToYou)
                                        Text("Settled Up")
                                            .font(AppTypography.footnote)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(AppColors.secondaryText)
                                    }
                                    .padding(.horizontal, AppSpacing.lg)
                                    .padding(.top, AppSpacing.sm)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(settled) { friend in
                                            NavigationLink {
                                                FriendDetailView(interactor: interactor, friend: friend)
                                            } label: {
                                                FriendRow(
                                                    friend: friend,
                                                    balance: interactor.balance(with: friend.id)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                            
                                            if friend.id != settled.last?.id {
                                                Divider()
                                                    .padding(.leading, 72)
                                            }
                                        }
                                    }
                                    .background(AppColors.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                    .padding(.horizontal, AppSpacing.lg)
                                    .opacity(0.7)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .background(AppColors.groupedBackground)
            .navigationTitle("Friends")
            .alert("Add Friend", isPresented: $showAddFriend) {
                TextField("Name", text: $newFriendName)
                TextField("Email", text: $newFriendEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                Button("Cancel", role: .cancel) {
                    newFriendName = ""
                    newFriendEmail = ""
                }
                Button("Add") {
                    if !newFriendName.isEmpty {
                        interactor.addFriend(name: newFriendName, email: newFriendEmail)
                        newFriendName = ""
                        newFriendEmail = ""
                    }
                }
            } message: {
                Text("Enter your friend's details")
            }
        }
    }
}

// MARK: - Friend Row

struct FriendRow: View {
    let friend: User
    let balance: Double
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AvatarView(user: friend, size: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(friend.name)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text(friend.email)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
            
            BalanceLabel(amount: balance, font: AppTypography.footnote)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}
