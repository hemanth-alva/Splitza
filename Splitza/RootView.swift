//
//  RootView.swift
//  Splitza
//
//  Created by Antigravity on 21/04/26.
//

import SwiftUI

public struct RootView: View {
    @ObservedObject public var interactor: RootInteractor
    
    public init(interactor: RootInteractor) {
        self.interactor = interactor
    }
    
    public var body: some View {
        NavigationStack {
            List(interactor.items, id: \.self) { item in
                Text(item)
            }
            .navigationTitle("RIBs List")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        interactor.addItem()
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .onAppear {
            interactor.didBecomeActive()
        }
        .onDisappear {
            interactor.willResignActive()
        }
    }
}

#Preview {
    let interactor = RootInteractor()
    interactor.items = ["Preview Item 1", "Preview Item 2"]
    return RootView(interactor: interactor)
}
