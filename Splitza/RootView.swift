//
//  RootView.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var interactor: RootInteractor
    @ObservedObject var groupsInteractor: GroupsInteractor
    @ObservedObject var friendsInteractor: FriendsInteractor
    @ObservedObject var activityInteractor: ActivityInteractor
    @ObservedObject var accountInteractor: AccountInteractor
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    /// Track the last valid tab to revert from the center spacer
    @State private var lastValidTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $interactor.selectedTab) {
                GroupsView(interactor: groupsInteractor)
                    .tabItem {
                        Label("Groups", systemImage: "person.3.fill")
                    }
                    .tag(0)
                
                FriendsView(interactor: friendsInteractor)
                    .tabItem {
                        Label("Friends", systemImage: "person.2.fill")
                    }
                    .tag(1)
                
                // Spacer tab for center button — never navigated to
                Color.clear
                    .tabItem {
                        Label("", systemImage: "")
                    }
                    .tag(99)
                
                ActivityView(interactor: activityInteractor)
                    .tabItem {
                        Label("Activity", systemImage: "clock.fill")
                    }
                    .tag(2)
                
                AccountView(interactor: accountInteractor)
                    .tabItem {
                        Label("Account", systemImage: "person.circle.fill")
                    }
                    .tag(3)
            }
            .tint(AppColors.primary)
            .onChange(of: interactor.selectedTab) { _, newTab in
                if newTab == 99 {
                    // Intercept center tab tap — open Add Expense and revert tab
                    interactor.selectedTab = lastValidTab
                    interactor.router?.routeToAddExpense(groupId: nil, friendId: nil)
                } else {
                    lastValidTab = newTab
                }
            }
            
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
        .sheet(isPresented: $interactor.showAddExpense, onDismiss: {
            interactor.router?.dismissAddExpense()
        }) {
            AddExpenseView(rootInteractor: interactor, expense: interactor.editingExpense)
        }
        .sheet(isPresented: $interactor.showSettleUp, onDismiss: {
            interactor.router?.dismissSettleUp()
        }) {
            SettleUpView(rootInteractor: interactor)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    // MARK: - Add Button
    
    private var addButton: some View {
        Button {
            interactor.router?.routeToAddExpense(groupId: nil, friendId: nil)
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

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootBuilder().build()
    }
}
