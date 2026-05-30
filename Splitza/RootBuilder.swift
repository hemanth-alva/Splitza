//
//  RootBuilder.swift
//  Splitza
//
//  Created by Antigravity on 13/05/26.
//

import SwiftUI

protocol RootBuildable: Buildable {
    func build() -> RootView
}

class RootBuilder: RootBuildable {
    private let dataProvider: DataProvider
    
    init(dataProvider: DataProvider = SampleDataProvider()) {
        self.dataProvider = dataProvider
    }
    
    func build() -> RootView {
        let interactor = RootInteractor(dataProvider: dataProvider)
        let router = RootRouter(rootInteractor: interactor)
        interactor.router = router
        
        let groupsRouter = GroupsRouter(rootRouter: router)
        let friendsRouter = FriendsRouter(rootRouter: router)
        let activityRouter = ActivityRouter(rootRouter: router)
        
        let groupsInteractor = GroupsInteractor(rootInteractor: interactor, router: groupsRouter)
        let friendsInteractor = FriendsInteractor(rootInteractor: interactor, router: friendsRouter)
        let activityInteractor = ActivityInteractor(rootInteractor: interactor, router: activityRouter)
        let accountInteractor = AccountInteractor(rootInteractor: interactor)
        
        let view = RootView(
            interactor: interactor,
            groupsInteractor: groupsInteractor,
            friendsInteractor: friendsInteractor,
            activityInteractor: activityInteractor,
            accountInteractor: accountInteractor
        )
        return view
    }
}
