//
//  RootRouter.swift
//  Splitza
//
//  Created by Antigravity on 21/04/26.
//

import Foundation

public protocol RootRouting: Routing {
    // Defines methods for routing from the Root RIB to other RIBs
}

public class RootRouter: RootRouting {
    public init() {
        // Initialize routing dependencies
    }
}
