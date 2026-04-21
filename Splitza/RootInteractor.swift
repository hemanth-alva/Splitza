//
//  RootInteractor.swift
//  Splitza
//
//  Created by Antigravity on 21/04/26.
//

import Foundation
import Combine

public class RootInteractor: Interacting {
    public typealias RouterType = RootRouting
    public var router: RootRouting?
    
    // State exposed to the View
    @Published public var items: [String] = []
    
    public init() {}
    
    public func didBecomeActive() {
        // Initialize with some data
        items = ["Item 1", "Item 2", "Item 3"]
    }
    
    public func addItem() {
        let newItem = "Item \(items.count + 1)"
        items.append(newItem)
    }
    
    public func willResignActive() {
        // Cleanup resources
    }
}
