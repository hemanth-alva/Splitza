//
//  CreateGroupView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct CreateGroupView: View {
    @ObservedObject var interactor: GroupsInteractor
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var selectedType: GroupType = .other
    @State private var selectedEmoji = "👥"
    @State private var selectedFriendIds: Set<UUID> = []
    
    private let emojiOptions = ["👥", "🏠", "🏖️", "🍕", "✈️", "🎉", "💼", "🎓", "🏋️", "🚗", "🎬", "☕"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Menu {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button(emoji) { selectedEmoji = emoji }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .fill(AppColors.primary.opacity(0.1))
                                    .frame(width: 56, height: 56)
                                Text(selectedEmoji)
                                    .font(.system(size: 28))
                            }
                        }
                        
                        TextField("Group name", text: $groupName)
                            .font(AppTypography.title3)
                    }
                }
                
                Section("Group Type") {
                    ForEach(GroupType.allCases, id: \.self) { type in
                        Button {
                            selectedType = type
                        } label: {
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundStyle(AppColors.primary)
                                    .frame(width: 28)
                                Text(type.rawValue)
                                    .foregroundStyle(AppColors.primaryText)
                                Spacer()
                                if selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColors.primary)
                                }
                            }
                        }
                    }
                }
                
                Section("Add Members") {
                    ForEach(interactor.friends) { friend in
                        Button {
                            if selectedFriendIds.contains(friend.id) {
                                selectedFriendIds.remove(friend.id)
                            } else {
                                selectedFriendIds.insert(friend.id)
                            }
                        } label: {
                            HStack(spacing: AppSpacing.md) {
                                AvatarView(user: friend, size: 36)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(friend.name)
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppColors.primaryText)
                                    Text(friend.email)
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColors.secondaryText)
                                }
                                
                                Spacer()
                                
                                if selectedFriendIds.contains(friend.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppColors.primary)
                                        .font(.system(size: 22))
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(AppColors.tertiaryText)
                                        .font(.system(size: 22))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        withAnimation(.spring(response: 0.3)) {
                            interactor.createGroup(
                                name: groupName,
                                emoji: selectedEmoji,
                                type: selectedType,
                                memberIds: Array(selectedFriendIds)
                            )
                        }
                        dismiss()
                    }
                    .disabled(groupName.isEmpty || selectedFriendIds.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
