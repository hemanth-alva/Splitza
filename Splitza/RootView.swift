//
//  RootView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

public struct RootView: View {
    @ObservedObject public var interactor: RootInteractor
    
    public init(interactor: RootInteractor) {
        self.interactor = interactor
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $interactor.selectedTab) {
                GroupsView(interactor: interactor)
                    .tabItem {
                        Label("Groups", systemImage: "person.3.fill")
                    }
                    .tag(0)
                
                FriendsView(interactor: interactor)
                    .tabItem {
                        Label("Friends", systemImage: "person.2.fill")
                    }
                    .tag(1)
                
                // Spacer tab for center button
                Color.clear
                    .tabItem {
                        Label("", systemImage: "")
                    }
                    .tag(99)
                
                ActivityView(interactor: interactor)
                    .tabItem {
                        Label("Activity", systemImage: "clock.fill")
                    }
                    .tag(2)
                
                AccountView(interactor: interactor)
                    .tabItem {
                        Label("Account", systemImage: "person.circle.fill")
                    }
                    .tag(3)
            }
            .tint(AppColors.primary)
            
            // Floating add button
            addButton
        }
        .onAppear {
            interactor.didBecomeActive()
            configureTabBarAppearance()
        }
        .onDisappear {
            interactor.willResignActive()
        }
        .sheet(isPresented: $interactor.showAddExpense) {
            AddExpenseView(rootInteractor: interactor)
        }
        .sheet(isPresented: $interactor.showSettleUp) {
            SettleUpView(interactor: interactor)
        }
    }
    
    // MARK: - Add Button
    
    private var addButton: some View {
        Button {
            interactor.showAddExpense = true
        } label: {
            ZStack {
                Circle()
                    .fill(AppColors.primary.gradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: AppColors.primary.opacity(0.4), radius: 8, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .offset(y: -26)
    }
    
    // MARK: - Tab Bar Appearance
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    RootView(interactor: RootInteractor())
}
