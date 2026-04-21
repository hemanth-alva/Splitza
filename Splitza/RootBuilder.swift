//
//  RootBuilder.swift
//  Splitza
//
//  Created by Antigravity on 21/04/26.
//

import SwiftUI

public protocol RootBuildable: Buildable {
    func build() -> RootView
}

public class RootBuilder: RootBuildable {
    public init() {}
    
    public func build() -> RootView {
        let interactor = RootInteractor()
        let router = RootRouter()
        
        interactor.router = router
        
        let view = RootView(interactor: interactor)
        return view
    }
}
