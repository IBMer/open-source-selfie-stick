# 技术架构方案

## 🛠️ 技术栈

### 核心技术

| 层级 | 技术选型 | 版本要求 | 说明 |
|------|---------|---------|------|
| **编程语言** | Swift | 6.0+ | 最新语言特性 |
| **UI 框架** | SwiftUI | iOS 17+ | 声明式 UI |
| **状态管理** | @Observable macro | iOS 17+ | 替代 ObservableObject |
| **架构模式** | Clean Architecture | - | MVVM + 分层 |
| **持久化** | SwiftData | iOS 17+ | 替代 Core Data |
| **云同步** | CloudKit | - | 自动与 SwiftData 集成 |
| **设备通信** | MultipeerConnectivity | iOS 7+ | P2P 连接 |
| **并发** | async/await | Swift 5.5+ | 现代并发模型 |

### 为什么选择这些技术

#### SwiftUI + @Observable
```swift
// ❌ 旧方式（iOS 13-16）
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .waiting
    @Published var countdown: Int = 30
}

// ✅ 新方式（iOS 17+）
@Observable
final class GameViewModel {
    var gameState: GameState = .waiting
    var countdown: Int = 30
    // SwiftUI 自动追踪变化，无需继承和 @Published
}
```

**优势：**
- 更简洁的代码
- 更好的性能（细粒度变化追踪）
- 类型安全
- 自动支持 computed properties

#### SwiftData + CloudKit
```swift
// 配置
let config = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .private("iCloud.com.yourcompany.couplegame")
)
```

**优势：**
- 零配置云同步
- 现代化 API
- 自动冲突解决
- 与 SwiftUI 深度集成

---

## 🏗️ 架构设计

### Clean Architecture 分层

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (SwiftUI Views + ViewModels)         │
│         @Observable                      │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│   (Entities + Use Cases + Protocols)    │
│      纯 Swift，无任何框架依赖              │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (SwiftData Entities + Repositories +   │
│   MultipeerConnectivity)                │
└─────────────────────────────────────────┘
```

### 数据流向

#### 保存游戏会话
```
User Action (完成绘画)
    ↓
GameView
    ↓
GameViewModel (调用 Use Case)
    ↓
SaveGameSessionUseCase
    ↓
GameRepositoryProtocol (协议)
    ↓
SwiftDataGameRepository (实现)
    ↓
GameSessionMapper.toEntity() (Domain → SwiftData)
    ↓
ModelContext.insert() + save()
    ↓
SwiftData Entity 持久化
    ↓
CloudKit 自动同步
```

#### 获取游戏历史
```
ModelContext.fetch()
    ↓
SwiftData Entity
    ↓
GameSessionMapper.toDomain() (SwiftData → Domain)
    ↓
GameRepositoryProtocol
    ↓
FetchGameHistoryUseCase
    ↓
HistoryViewModel
    ↓
HistoryView (显示)
```

### 依赖方向规则

**核心原则：依赖倒置（DIP）**

```
Presentation → Domain ← Data

✅ Presentation 依赖 Domain
✅ Data 依赖 Domain
❌ Domain 不依赖任何层
❌ Presentation 不直接依赖 Data
```

---

## 📁 项目结构

```
CoupleGame/
├── App/
│   ├── CoupleGameApp.swift           # App 入口 + SwiftData 配置
│   └── DependencyContainer.swift      # 依赖注入容器
│
├── Domain/                            # 纯 Swift，无依赖
│   ├── Entities/
│   │   ├── GameSession.swift          # 游戏会话
│   │   ├── Partner.swift              # 配对对象
│   │   ├── DrawingData.swift          # 绘画数据
│   │   └── GameMessage.swift          # 游戏消息
│   ├── UseCases/
│   │   ├── SaveGameSessionUseCase.swift
│   │   ├── FetchGameHistoryUseCase.swift
│   │   ├── ConnectToPartnerUseCase.swift
│   │   └── SendDrawingUseCase.swift
│   └── RepositoryProtocols/
│       ├── GameRepositoryProtocol.swift
│       └── ConnectionRepositoryProtocol.swift
│
├── Data/                              # SwiftData + Network
│   ├── Entities/                      # SwiftData Models
│   │   ├── GameSessionEntity.swift
│   │   └── PartnerEntity.swift
│   ├── Mappers/                       # Domain ↔ SwiftData
│   │   ├── GameSessionMapper.swift
│   │   └── PartnerMapper.swift
│   ├── Repositories/                  # 实现 Domain Protocols
│   │   ├── SwiftDataGameRepository.swift
│   │   └── MultipeerConnectionRepository.swift
│   └── Network/
│       └── ConnectionManager.swift    # MultipeerConnectivity 封装
│
├── Presentation/                      # SwiftUI + ViewModels
│   ├── Screens/
│   │   ├── Pairing/                   # 设备配对
│   │   │   ├── PairingView.swift
│   │   │   └── PairingViewModel.swift
│   │   ├── Game/                      # 游戏主界面
│   │   │   ├── GameView.swift
│   │   │   ├── GameViewModel.swift
│   │   │   └── Components/
│   │   │       ├── DrawingCanvasView.swift
│   │   │       ├── TopicHeaderView.swift
│   │   │       ├── CountdownTimerView.swift
│   │   │       └── GameControlsView.swift
│   │   ├── Result/                    # 结果对比
│   │   │   ├── ResultView.swift
│   │   │   └── ResultViewModel.swift
│   │   └── History/                   # 历史记录
│   │       ├── HistoryView.swift
│   │       └── HistoryViewModel.swift
│   └── Common/
│       ├── Components/
│       │   ├── PrimaryButton.swift
│       │   ├── ConnectionStatusBadge.swift
│       │   └── LoadingView.swift
│       └── Extensions/
│           ├── View+Extensions.swift
│           └── Color+Theme.swift
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Topics.json                    # 题目库
│   └── Localizable.strings
│
└── Tests/
    ├── DomainTests/
    ├── DataTests/
    └── PresentationTests/
```

---

## 🔌 核心模块设计

### 1. Domain Layer

#### Entities（领域实体）

```swift
// Domain/Entities/GameSession.swift
struct GameSession: Identifiable, Sendable {
    let id: UUID
    let createdAt: Date
    let partnerName: String
    let topic: String
    let myDrawing: DrawingData
    let partnerDrawing: DrawingData?
    let matchScore: Int?
}

// Domain/Entities/DrawingData.swift
struct DrawingData: Sendable, Codable {
    let imageData: Data
    let strokes: [DrawingStroke]
}

struct DrawingStroke: Sendable, Codable {
    let points: [CGPoint]
    let color: String
    let width: Double
}
```

#### Repository Protocols（仓储协议）

```swift
// Domain/RepositoryProtocols/GameRepositoryProtocol.swift
protocol GameRepositoryProtocol: Sendable {
    func save(_ session: GameSession) async throws
    func fetchAll() async throws -> [GameSession]
    func fetch(id: UUID) async throws -> GameSession?
    func delete(id: UUID) async throws
}

// Domain/RepositoryProtocols/ConnectionRepositoryProtocol.swift
protocol ConnectionRepositoryProtocol: Sendable {
    var connectionState: ConnectionState { get }
    var connectedPartnerName: String? { get }

    func startSearching() async
    func stopSearching() async
    func sendMessage(_ message: GameMessage) async throws
    func observeMessages() -> AsyncStream<GameMessage>
}
```

#### Use Cases（用例）

```swift
// Domain/UseCases/SaveGameSessionUseCase.swift
struct SaveGameSessionUseCase: Sendable {
    private let repository: GameRepositoryProtocol

    init(repository: GameRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ session: GameSession) async throws {
        try await repository.save(session)
    }
}
```

---

### 2. Data Layer

#### SwiftData Entities

```swift
// Data/Entities/GameSessionEntity.swift
import SwiftData
import Foundation

@Model
final class GameSessionEntity {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var partnerName: String
    var topic: String

    @Attribute(.externalStorage) var myDrawingImageData: Data
    var myDrawingStrokes: Data  // JSON encoded [DrawingStroke]

    @Attribute(.externalStorage) var partnerDrawingImageData: Data?
    var partnerDrawingStrokes: Data?

    var matchScore: Int?

    init(/* ... */) { /* ... */ }
}
```

#### Mappers（映射器）

```swift
// Data/Mappers/GameSessionMapper.swift
enum GameSessionMapper {
    // SwiftData → Domain
    static func toDomain(_ entity: GameSessionEntity) throws -> GameSession {
        // 解码 strokes
        let myStrokes = try JSONDecoder().decode(
            [DrawingStroke].self,
            from: entity.myDrawingStrokes
        )
        let myDrawing = DrawingData(
            imageData: entity.myDrawingImageData,
            strokes: myStrokes
        )

        // 处理 optional partner drawing
        var partnerDrawing: DrawingData?
        if let partnerImageData = entity.partnerDrawingImageData,
           let partnerStrokesData = entity.partnerDrawingStrokes {
            let partnerStrokes = try JSONDecoder().decode(
                [DrawingStroke].self,
                from: partnerStrokesData
            )
            partnerDrawing = DrawingData(
                imageData: partnerImageData,
                strokes: partnerStrokes
            )
        }

        return GameSession(
            id: entity.id,
            createdAt: entity.createdAt,
            partnerName: entity.partnerName,
            topic: entity.topic,
            myDrawing: myDrawing,
            partnerDrawing: partnerDrawing,
            matchScore: entity.matchScore
        )
    }

    // Domain → SwiftData
    static func toEntity(_ domain: GameSession) throws -> GameSessionEntity {
        // 编码 strokes
        let myStrokesData = try JSONEncoder().encode(domain.myDrawing.strokes)

        var partnerImageData: Data?
        var partnerStrokesData: Data?
        if let partnerDrawing = domain.partnerDrawing {
            partnerImageData = partnerDrawing.imageData
            partnerStrokesData = try JSONEncoder().encode(partnerDrawing.strokes)
        }

        return GameSessionEntity(
            id: domain.id,
            createdAt: domain.createdAt,
            partnerName: domain.partnerName,
            topic: domain.topic,
            myDrawingImageData: domain.myDrawing.imageData,
            myDrawingStrokes: myStrokesData,
            partnerDrawingImageData: partnerImageData,
            partnerDrawingStrokes: partnerStrokesData,
            matchScore: domain.matchScore
        )
    }
}
```

#### Repository Implementations

```swift
// Data/Repositories/SwiftDataGameRepository.swift
import SwiftData
import Foundation

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
}
```

---

### 3. MultipeerConnectivity 封装

```swift
// Data/Network/ConnectionManager.swift
import MultipeerConnectivity
import Observation

@Observable
final class ConnectionManager: NSObject {
    // Published state（自动被 SwiftUI 观察）
    var connectionState: ConnectionState = .disconnected
    var connectedPartnerName: String?
    private var messageContinuation: AsyncStream<GameMessage>.Continuation?

    // MultipeerConnectivity
    private let serviceType = "couple-game"
    private let myPeerId: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private lazy var session: MCSession = {
        let session = MCSession(
            peer: myPeerId,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
        return session
    }()

    override init() {
        self.myPeerId = MCPeerID(displayName: UIDevice.current.name)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        self.serviceBrowser = MCNearbyServiceBrowser(
            peer: myPeerId,
            serviceType: serviceType
        )

        super.init()

        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }

    func startSearching() {
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
        connectionState = .searching
    }

    func stopSearching() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }

    func sendMessage(_ message: GameMessage) async throws {
        let data = try JSONEncoder().encode(message)
        try session.send(
            data,
            toPeers: session.connectedPeers,
            with: .reliable
        )
    }

    func observeMessages() -> AsyncStream<GameMessage> {
        AsyncStream { continuation in
            self.messageContinuation = continuation
        }
    }
}

// MARK: - Delegates
extension ConnectionManager: MCSessionDelegate {
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        Task { @MainActor in
            switch state {
            case .connected:
                connectionState = .connected
                connectedPartnerName = peerID.displayName
            case .notConnected:
                connectionState = .disconnected
                connectedPartnerName = nil
            case .connecting:
                connectionState = .connecting
            @unknown default:
                break
            }
        }
    }

    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        Task { @MainActor in
            if let message = try? JSONDecoder().decode(GameMessage.self, from: data) {
                messageContinuation?.yield(message)
            }
        }
    }

    // ... 其他必需的 delegate 方法
}

// 从原项目复制并改造的 delegate 扩展
extension ConnectionManager: MCNearbyServiceAdvertiserDelegate { /* ... */ }
extension ConnectionManager: MCNearbyServiceBrowserDelegate { /* ... */ }
```

---

### 4. Presentation Layer

#### ViewModel（@Observable）

```swift
// Presentation/Screens/Game/GameViewModel.swift
import Foundation
import Observation

@Observable
final class GameViewModel {
    // State
    var gameState: GameState = .waiting
    var currentTopic: String = ""
    var countdown: Int = 30
    var myDrawing: DrawingData?
    var partnerDrawing: DrawingData?
    var partnerName: String = ""

    // Dependencies
    private let saveGameUseCase: SaveGameSessionUseCase
    private let connectionRepository: ConnectionRepositoryProtocol

    init(
        saveGameUseCase: SaveGameSessionUseCase,
        connectionRepository: ConnectionRepositoryProtocol
    ) {
        self.saveGameUseCase = saveGameUseCase
        self.connectionRepository = connectionRepository
        observeIncomingMessages()
    }

    // Actions
    func startGame(topic: String) {
        currentTopic = topic
        gameState = .drawing
        startCountdown()
    }

    func submitDrawing(_ drawing: DrawingData) async {
        myDrawing = drawing
        gameState = .waitingForPartner

        let message = GameMessage.drawingSubmitted(drawing)
        try? await connectionRepository.sendMessage(message)
    }

    func saveSession() async throws {
        guard let myDrawing, let partnerDrawing else { return }

        let session = GameSession(
            partnerName: partnerName,
            topic: currentTopic,
            myDrawing: myDrawing,
            partnerDrawing: partnerDrawing
        )

        try await saveGameUseCase.execute(session)
    }

    private func observeIncomingMessages() {
        Task {
            for await message in connectionRepository.observeMessages() {
                handleMessage(message)
            }
        }
    }

    private func handleMessage(_ message: GameMessage) {
        switch message {
        case .drawingSubmitted(let drawing):
            partnerDrawing = drawing
            if myDrawing != nil {
                gameState = .showingResult
            }
        case .gameStarted(let topic):
            startGame(topic: topic)
        }
    }

    private func startCountdown() {
        Task {
            while countdown > 0 && gameState == .drawing {
                try? await Task.sleep(for: .seconds(1))
                countdown -= 1
            }
            if gameState == .drawing {
                gameState = .timeUp
            }
        }
    }
}

enum GameState: Sendable {
    case waiting
    case drawing
    case timeUp
    case waitingForPartner
    case showingResult
}
```

#### View（SwiftUI + 模块化）

```swift
// Presentation/Screens/Game/GameView.swift
import SwiftUI

struct GameView: View {
    @State private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            topicHeader
            drawingCanvas
            controlsFooter
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Subviews

    private var topicHeader: some View {
        TopicHeaderView(
            topic: viewModel.currentTopic,
            countdown: viewModel.countdown
        )
    }

    private var drawingCanvas: some View {
        DrawingCanvasView(
            isEnabled: viewModel.gameState == .drawing,
            onDrawingComplete: { drawing in
                Task {
                    await viewModel.submitDrawing(drawing)
                }
            }
        )
    }

    private var controlsFooter: some View {
        GameControlsView(
            gameState: viewModel.gameState,
            onExit: { dismiss() }
        )
    }
}
```

---

### 5. 依赖注入

```swift
// App/DependencyContainer.swift
import SwiftData
import Foundation
import Observation

@Observable
final class DependencyContainer {
    // Repositories
    let gameRepository: GameRepositoryProtocol
    let connectionRepository: ConnectionRepositoryProtocol

    // Use Cases
    let saveGameUseCase: SaveGameSessionUseCase
    let fetchGameHistoryUseCase: FetchGameHistoryUseCase

    init(modelContext: ModelContext) {
        // Initialize repositories
        self.gameRepository = SwiftDataGameRepository(modelContext: modelContext)
        self.connectionRepository = MultipeerConnectionRepository()

        // Initialize use cases
        self.saveGameUseCase = SaveGameSessionUseCase(repository: gameRepository)
        self.fetchGameHistoryUseCase = FetchGameHistoryUseCase(repository: gameRepository)
    }

    // Factory methods
    func makeGameViewModel() -> GameViewModel {
        GameViewModel(
            saveGameUseCase: saveGameUseCase,
            connectionRepository: connectionRepository
        )
    }

    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(fetchGameHistoryUseCase: fetchGameHistoryUseCase)
    }
}
```

```swift
// App/CoupleGameApp.swift
import SwiftUI
import SwiftData

@main
struct CoupleGameApp: App {
    let container: ModelContainer
    let dependencyContainer: DependencyContainer

    init() {
        do {
            // SwiftData schema
            let schema = Schema([
                GameSessionEntity.self,
                PartnerEntity.self
            ])

            // CloudKit configuration
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.yourcompany.couplegame")
            )

            container = try ModelContainer(for: schema, configurations: config)

            // Dependency injection
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
```

---

## 📋 编码规范

### SOLID 原则应用

#### 1. Single Responsibility Principle (SRP)
```swift
// ✅ 好的示例
struct SaveGameSessionUseCase {
    // 只负责保存游戏会话
    func execute(_ session: GameSession) async throws { }
}

struct FetchGameHistoryUseCase {
    // 只负责获取历史记录
    func execute() async throws -> [GameSession] { }
}

// ❌ 不好的示例
struct GameUseCase {
    func saveSession() { }
    func fetchHistory() { }
    func connectToPartner() { }
    func sendMessage() { }
    // 职责太多！
}
```

#### 2. Open/Closed Principle (OCP)
```swift
// ✅ 通过协议扩展新功能
protocol GameRepositoryProtocol {
    func save(_ session: GameSession) async throws
}

// 可以轻松添加新的实现，无需修改现有代码
class MockGameRepository: GameRepositoryProtocol { }
class SwiftDataGameRepository: GameRepositoryProtocol { }
class CloudGameRepository: GameRepositoryProtocol { }
```

#### 3. Dependency Inversion Principle (DIP)
```swift
// ✅ 依赖抽象（协议）
class GameViewModel {
    private let repository: GameRepositoryProtocol  // 协议

    init(repository: GameRepositoryProtocol) {
        self.repository = repository
    }
}

// ❌ 依赖具体实现
class GameViewModel {
    private let repository = SwiftDataGameRepository()  // 具体类
}
```

### DRY 原则

```swift
// ✅ 提取公共组件
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

// 在多处使用
PrimaryButton(title: "开始游戏", action: startGame)
PrimaryButton(title: "保存", action: save)
```

### KISS 原则

```swift
// ✅ 简单直接
func isGameFinished() -> Bool {
    return myDrawing != nil && partnerDrawing != nil
}

// ❌ 过度复杂
func isGameFinished() -> Bool {
    guard let _ = myDrawing else { return false }
    guard let _ = partnerDrawing else { return false }
    if myDrawing != nil {
        if partnerDrawing != nil {
            return true
        }
    }
    return false
}
```

### View 模块化原则

```swift
// ✅ 单个 View 文件不超过 150 行
// GameView.swift (80 行)
struct GameView: View {
    var body: some View {
        VStack {
            TopicHeaderView()      // 30 行
            DrawingCanvasView()    // 50 行
            GameControlsView()     // 40 行
        }
    }
}

// ❌ 避免巨大的 View
// GameView.swift (500 行) - 太长！
```

---

## 🔐 安全与隐私

### 数据安全
- ✅ MultipeerConnectivity 强制加密（`.required`）
- ✅ CloudKit 私有数据库（用户数据隔离）
- ✅ 本地 SwiftData 加密存储
- ✅ 不收集用户隐私数据

### 权限管理
- 📷 相机权限（Phase 3 拍照功能需要）
- 📱 本地网络权限（MultipeerConnectivity）
- ☁️ iCloud 权限（数据同步）

---

## 📊 性能考虑

### 绘画数据优化
- 使用 `@Attribute(.externalStorage)` 存储大图片
- 压缩图片数据（JPEG 80% 质量）
- 限制笔触数量（性能保护）

### 网络传输优化
- 发送前压缩数据
- 使用 `.reliable` 模式确保数据完整
- WiFi 优先于蓝牙

### SwiftUI 性能
- 使用 `@Observable` 细粒度更新
- 避免不必要的 View 刷新
- 图片异步加载

---

_文档创建日期：2025-11-18_
_最后更新：2025-11-18_
