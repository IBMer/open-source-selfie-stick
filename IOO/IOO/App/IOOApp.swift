//
//  IOOApp.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import SwiftUI
import SwiftData

@main
struct IOOApp: App {
    let container: ModelContainer
    let dependencyContainer: DependencyContainer

    init() {
        do {
            // Configure SwiftData schema
            let schema = Schema([
                GameSessionEntity.self
            ])

            // Configure CloudKit sync
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.yourcompany.ioo")
            )

            // Create ModelContainer
            container = try ModelContainer(for: schema, configurations: config)

            // Create dependency injection container
            dependencyContainer = DependencyContainer(
                modelContext: container.mainContext
            )

        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencyContainer)
        }
        .modelContainer(container)
    }
}
