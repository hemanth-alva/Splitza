//
//  SplitzaApp.swift
//  Splitza
//
//  Created by Hemanth Alva R on 21/04/26.
//

import SwiftUI

@main
struct SplitzaApp: App {
    let rootBuilder = RootBuilder()

    var body: some Scene {
        WindowGroup {
            rootBuilder.build()
        }
    }
}
