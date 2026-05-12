//
//  FriendsView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct FriendsView: View {
    @ObservedObject var interactor: RootInteractor
    @State private var showAddFriend = false
    @State private var newFriendName = ""
    @State private var newFriendEmail = ""
    
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
                    
                    // Friends list
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
                            VStack(spacing: 0) {
                                ForEach(interactor.friends) { friend in
                                    NavigationLink {
                                        FriendDetailView(interactor: interactor, friend: friend)
                                    } label: {
                                        FriendRow(
                                            friend: friend,
                                            balance: interactor.balanceWith(friendId: friend.id)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if friend.id != interactor.friends.last?.id {
                                        Divider()
                                            .padding(.leading, 72)
                                    }
                                }
                            }
                            .background(AppColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            .padding(.horizontal, AppSpacing.lg)
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
                        let friend = User(
                            name: newFriendName,
                            email: newFriendEmail.isEmpty ? "\(newFriendName.lowercased().replacingOccurrences(of: " ", with: "."))@email.com" : newFriendEmail,
                            avatarColor: AppColors.avatarColor(for: interactor.friends.count + 1)
                        )
                        interactor.addFriend(friend)
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
