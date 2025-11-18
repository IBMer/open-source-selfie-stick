//
//  ContentView.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

struct ContentView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        NavigationStack {
            PairingView(viewModel: container.makePairingViewModel())
        }
    }
}
