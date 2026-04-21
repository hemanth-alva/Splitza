//
//  RIBArchitecture.swift
//  Splitza
//
//  Created by Antigravity on 21/04/26.
//

import SwiftUI
import Combine

/// Base protocol for all Routers
public protocol Routing: AnyObject {
    // Defines basic routing capabilities. Can be expanded as needed.
}

/// Base protocol for all Interactors
public protocol Interacting: AnyObject, ObservableObject {
    associatedtype RouterType
    var router: RouterType? { get set }
    
    func didBecomeActive()
    func willResignActive()
}

public extension Interacting {
    func didBecomeActive() {}
    func willResignActive() {}
}

/// Base protocol for all Builders
public protocol Buildable {
    associatedtype ViewType: View
    func build() -> ViewType
}
