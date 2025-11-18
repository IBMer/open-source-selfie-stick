//
//  SwiftDataGameRepository.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation
import SwiftData

/// SwiftData 游戏仓储实现
final class SwiftDataGameRepository: GameRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ session: GameSession) async throws {
        let entity = try GameSessionMapper.toEntity(session)
        modelContext.insert(entity)
        try modelContext.save()
    }

    func fetchAll() async throws -> [GameSession] {
        let descriptor = FetchDescriptor<GameSessionEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let entities = try modelContext.fetch(descriptor)
        return try entities.map(GameSessionMapper.toDomain)
    }

    func fetch(id: UUID) async throws -> GameSession? {
        let predicate = #Predicate<GameSessionEntity> { entity in
            entity.id == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        let entities = try modelContext.fetch(descriptor)
        return try entities.first.map(GameSessionMapper.toDomain)
    }

    func delete(id: UUID) async throws {
        let predicate = #Predicate<GameSessionEntity> { entity in
            entity.id == id
        }
        try modelContext.delete(model: GameSessionEntity.self, where: predicate)
        try modelContext.save()
    }

    func fetchSessions(with partnerName: String) async throws -> [GameSession] {
        let predicate = #Predicate<GameSessionEntity> { entity in
            entity.partnerName == partnerName
        }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let entities = try modelContext.fetch(descriptor)
        return try entities.map(GameSessionMapper.toDomain)
    }

    func fetchRecent(limit: Int) async throws -> [GameSession] {
        var descriptor = FetchDescriptor<GameSessionEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        let entities = try modelContext.fetch(descriptor)
        return try entities.map(GameSessionMapper.toDomain)
    }
}
