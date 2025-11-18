# 原项目代码复用指南

## 📚 概述

本文档详细说明如何从 **Open Source Selfie Stick** 项目中提取和改造代码，用于新的情侣游戏项目。

---

## 🎯 复用策略

### 复用原则
- ✅ **直接复用：** MultipeerConnectivity 核心逻辑
- 🔧 **改造复用：** UIKit → SwiftUI，ObservableObject → @Observable
- ❌ **不复用：** 所有相机相关代码

### 技术栈对比

| 层面 | 原项目 | 新项目 |
|------|--------|--------|
| UI 框架 | UIKit | SwiftUI |
| 状态管理 | ObservableObject + @Published | @Observable macro |
| 并发模型 | GCD + Completion handlers | async/await |
| 数据持久化 | 无 | SwiftData + CloudKit |
| 架构 | MVC | Clean Architecture (MVVM) |

---

## 📂 文件复用清单

### CameraServiceManager.swift

**原始位置：** `Open Source Selfie Stick/Open Source Selfie Stick/CameraServiceManager.swift`

**复用程度：** 🟢 70% 可直接复用，30% 需要改造

#### 🟢 可直接复用的部分

##### 1. MultipeerConnectivity 初始化（18-47行）

```swift
// ✅ 直接复用（仅修改 serviceType）
private let ServiceType = "couple-game"  // 原: "camera-service"
private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)

let serviceAdvertiser: MCNearbyServiceAdvertiser
let serviceBrowser: MCNearbyServiceBrowser

lazy var session: MCSession = {
    let session = MCSession(
        peer: self.myPeerId,
        securityIdentity: nil,
        encryptionPreference: .required  // ✅ 保持加密
    )
    session.delegate = self
    return session
}()
```

**改造要点：**
- 修改 `serviceType` 为 `"couple-game"`
- `UIDevice.currentDevice()` → `UIDevice.current` (Swift 3+)

---

##### 2. 搜索控制方法（49-57行）

```swift
// ✅ 直接复用
func startSearching() {
    self.serviceAdvertiser.startAdvertisingPeer()
    self.serviceBrowser.startBrowsingForPeers()
}

func stopSearching() {
    self.serviceAdvertiser.stopAdvertisingPeer()
    self.serviceBrowser.stopBrowsingForPeers()
}
```

**改造要点：** 无，直接使用

---

##### 3. MCNearbyServiceAdvertiserDelegate（108-118行）

```swift
// ✅ 基本可复用
extension CameraServiceManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: NSError
    ) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: NSData?,
        invitationHandler: (Bool, MCSession) -> Void
    ) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)  // 自动接受
    }
}
```

**改造要点：**
- `NSLog` → `print` 或使用 `os.log`
- `NSData` → `Data`
- 可以添加用户确认逻辑（不自动接受）

---

##### 4. MCNearbyServiceBrowserDelegate（120-135行）

```swift
// ✅ 基本可复用
extension CameraServiceManager: MCNearbyServiceBrowserDelegate {
    func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: NSError
    ) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        NSLog("%@", "foundPeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}
```

**改造要点：**
- `NSLog` → `print`
- `NSError` → `Error`
- 考虑增加发现设备列表（让用户选择）

---

##### 5. MCSessionState 扩展（137-145行）

```swift
// ✅ 直接复用
extension MCSessionState {
    func stringValue() -> String {
        switch self {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        @unknown default: return "Unknown"
        }
    }
}
```

**改造要点：**
- 添加 `@unknown default` 处理未来新增状态
- 可以扩展为 `CustomStringConvertible`

---

#### 🔧 需要改造的部分

##### 1. 发送消息方法（59-96行）

**原代码（硬编码字符串）：**
```swift
// ❌ 需要改造
func takePhoto(sendPhoto: Bool) {
    var boolString = ""
    if sendPhoto {
        boolString = "true"
    } else {
        boolString = "false"
    }
    try self.session.sendData(
        boolString.data(using: .utf8)!,
        toPeers: self.session.connectedPeers,
        withMode: .reliable
    )
}

func toggleFlash() {
    let dataString = "toggleFlash"
    try self.session.sendData(
        dataString.data(using: .utf8)!,
        toPeers: self.session.connectedPeers,
        withMode: .reliable
    )
}
```

**改造为通用消息系统：**
```swift
// ✅ 新代码（结构化消息）
enum GameMessage: Codable, Sendable {
    case gameStarted(topic: String)
    case drawingSubmitted(DrawingData)
    case requestNewGame
    case partnerReady
}

func sendMessage(_ message: GameMessage) async throws {
    let data = try JSONEncoder().encode(message)
    try session.send(
        data,
        toPeers: session.connectedPeers,
        with: .reliable
    )
}
```

**改造步骤：**
1. 定义 `GameMessage` 枚举
2. 使用 `Codable` 序列化
3. 改为 `async throws` 函数
4. 移除硬编码字符串

---

##### 2. 接收消息处理（166-188行）

**原代码（硬编码判断）：**
```swift
// ❌ 需要改造
func session(
    _ session: MCSession,
    didReceive data: Data,
    fromPeer peerID: MCPeerID
) {
    let dataString = String(data: data, encoding: .utf8)

    if dataString == "toggleFlash" {
        delegate?.toggleFlash(self)
    } else if dataString == "acceptInvitation" {
        delegate?.acceptInvitation(self)
    } else if dataString == "true" || dataString == "false" {
        let sendPhoto = (dataString == "true")
        delegate?.shutterButtonTapped(self, sendPhoto)
    }
}
```

**改造为：**
```swift
// ✅ 新代码（结构化处理）
func session(
    _ session: MCSession,
    didReceive data: Data,
    fromPeer peerID: MCPeerID
) {
    Task { @MainActor in
        do {
            let message = try JSONDecoder().decode(GameMessage.self, from: data)
            messageContinuation?.yield(message)  // AsyncStream
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
}
```

**改造步骤：**
1. 使用 `JSONDecoder` 解码
2. 通过 `AsyncStream` 发送消息
3. 在 `@MainActor` 上下文处理
4. 添加错误处理

---

##### 3. MCSessionDelegate 状态变化（197-201行）

**原代码（使用 delegate）：**
```swift
// 🔧 需要适配
func session(
    _ session: MCSession,
    peer peerID: MCPeerID,
    didChange state: MCSessionState
) {
    NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
    delegate?.connectedDevicesChanged(
        self,
        state: state,
        connectedDevices: session.connectedPeers.map { $0.displayName }
    )
}
```

**改造为 @Observable：**
```swift
// ✅ 新代码（直接更新状态）
@Observable
final class ConnectionManager: NSObject {
    var connectionState: ConnectionState = .disconnected
    var connectedPartnerName: String?

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
            case .connecting:
                connectionState = .connecting
            case .notConnected:
                connectionState = .disconnected
                connectedPartnerName = nil
            @unknown default:
                break
            }
        }
    }
}
```

**改造步骤：**
1. 移除 delegate pattern
2. 使用 `@Observable` 直接更新状态
3. SwiftUI View 自动响应变化
4. 在 `@MainActor` 更新 UI 状态

---

##### 4. 文件传输（98-105行，149-164行）

**原代码：**
```swift
// 🔧 Phase 1 不需要，Phase 3 拍照功能时再复用
func transferFile(file: NSURL) {
    session.sendResourceAtURL(
        file,
        withName: "photo.jpg",
        toPeer: id,
        withCompletionHandler: nil
    )
}

func session(
    _ session: MCSession,
    didFinishReceivingResourceWithName resourceName: String,
    fromPeer peerID: MCPeerID,
    at localURL: NSURL,
    withError error: NSError?
) {
    // 保存文件到相册
    let data = try NSFileHandle(forReadingFrom: localURL).readDataToEndOfFile()
    let image = UIImage(data: data)
    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
}
```

**使用建议：**
- Phase 1 画画游戏：不需要文件传输，绘画数据用 `sendData` 发送
- Phase 3 拍照功能：参考原代码实现文件传输
- 改造要点：`NSURL` → `URL`, `NSFileHandle` → `FileHandle`

---

#### ❌ 不复用的部分

##### CameraViewController.swift
- **原因：** 完全是相机相关逻辑
- **替代：** Phase 3 如需拍照功能，重新实现或参考

##### AVCamPreviewController.swift
- **原因：** AVFoundation 预览层
- **替代：** Phase 3 使用 SwiftUI + AVFoundation 重写

##### InitialViewController.swift
- **原因：** 仅是基础 UIViewController
- **替代：** 无需替代

---

## 🔄 完整改造示例

### 原项目 CameraServiceManager

```swift
// 原项目代码（简化版）
import MultipeerConnectivity

class CameraServiceManager: NSObject {
    private let ServiceType = "camera-service"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    let serviceBrowser: MCNearbyServiceBrowser
    var delegate: CameraServiceManagerDelegate?

    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()

    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }

    func takePhoto(sendPhoto: Bool) {
        let boolString = sendPhoto ? "true" : "false"
        try? session.sendData(boolString.data(using: .utf8)!, toPeers: session.connectedPeers, withMode: .reliable)
    }
}

extension CameraServiceManager: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dataString = String(data: data, encoding: .utf8)
        if dataString == "true" {
            delegate?.shutterButtonTapped(self, true)
        }
    }
    // ... 其他 delegate 方法
}

protocol CameraServiceManagerDelegate {
    func shutterButtonTapped(_ manager: CameraServiceManager, _ sendPhoto: Bool)
}
```

---

### 新项目 ConnectionManager（改造后）

```swift
// 新项目代码（完整版）
import MultipeerConnectivity
import Observation

@Observable
final class ConnectionManager: NSObject {
    // MARK: - Published State
    var connectionState: ConnectionState = .disconnected
    var connectedPartnerName: String?

    // MARK: - Private Properties
    private let serviceType = "couple-game"
    private let myPeerId: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private var messageContinuation: AsyncStream<GameMessage>.Continuation?

    private lazy var session: MCSession = {
        let session = MCSession(
            peer: myPeerId,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
        return session
    }()

    // MARK: - Initialization
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

    // MARK: - Public Methods
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
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    func observeMessages() -> AsyncStream<GameMessage> {
        AsyncStream { continuation in
            self.messageContinuation = continuation
        }
    }

    deinit {
        stopSearching()
        messageContinuation?.finish()
    }
}

// MARK: - MCSessionDelegate
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
            case .connecting:
                connectionState = .connecting
            case .notConnected:
                connectionState = .disconnected
                connectedPartnerName = nil
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
            do {
                let message = try JSONDecoder().decode(GameMessage.self, from: data)
                messageContinuation?.yield(message)
            } catch {
                print("Failed to decode message: \(error)")
            }
        }
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // 暂不实现
    }

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        // Phase 3 文件传输时实现
    }

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        // Phase 3 文件传输时实现
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        print("didNotStartAdvertisingPeer: \(error)")
        Task { @MainActor in
            connectionState = .error(error.localizedDescription)
        }
    }

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        print("didReceiveInvitationFromPeer: \(peerID)")
        // 可以添加用户确认逻辑
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension ConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
        print("didNotStartBrowsingForPeers: \(error)")
        Task { @MainActor in
            connectionState = .error(error.localizedDescription)
        }
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        print("foundPeer: \(peerID)")
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 10)
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        print("lostPeer: \(peerID)")
    }
}

// MARK: - Supporting Types
enum ConnectionState: Sendable {
    case disconnected
    case searching
    case connecting
    case connected
    case error(String)
}

enum GameMessage: Codable, Sendable {
    case gameStarted(topic: String)
    case drawingSubmitted(DrawingData)
    case requestNewGame
    case partnerReady
}
```

---

## 📊 改造对比总结

| 方面 | 原项目 | 新项目 | 改造难度 |
|------|--------|--------|---------|
| **类定义** | `class` | `@Observable final class` | 🟢 简单 |
| **状态管理** | Delegate pattern | @Observable properties | 🟡 中等 |
| **消息格式** | 硬编码字符串 | Codable enum | 🟡 中等 |
| **并发模型** | GCD | async/await | 🟢 简单 |
| **错误处理** | try? / print | async throws | 🟢 简单 |
| **数据传输** | sendData | async sendMessage | 🟢 简单 |
| **消息接收** | Delegate callback | AsyncStream | 🟡 中等 |

---

## ✅ 改造检查清单

### 代码层面
- [ ] 移除所有 UIKit 依赖
- [ ] `NSObject` 改为继承需要（MC delegates 需要）
- [ ] 所有 `NS` 前缀类型改为 Swift 原生类型
- [ ] Completion handlers → async/await
- [ ] Delegate pattern → @Observable 或 AsyncStream
- [ ] 硬编码字符串 → 结构化消息

### 功能层面
- [ ] 设备发现工作正常
- [ ] 配对连接稳定
- [ ] 消息发送/接收准确
- [ ] 状态变化正确反映在 UI
- [ ] 错误处理完善

### 架构层面
- [ ] 符合 Clean Architecture
- [ ] 依赖协议而非具体实现
- [ ] 可测试性良好
- [ ] 代码模块化

---

## 🎓 学习要点

### MultipeerConnectivity 核心概念

1. **MCPeerID**: 设备标识
2. **MCSession**: 连接会话
3. **MCNearbyServiceAdvertiser**: 广播自己
4. **MCNearbyServiceBrowser**: 发现其他设备
5. **MCSessionDelegate**: 处理连接状态和数据

### Swift 现代化要点

1. **@Observable**: 替代 ObservableObject，自动追踪变化
2. **async/await**: 现代并发，替代 completion handlers
3. **AsyncStream**: 异步事件流，替代 delegate 回调
4. **Sendable**: 线程安全类型
5. **@MainActor**: 确保 UI 更新在主线程

---

## 📝 参考资源

### 原项目
- 代码仓库: https://github.com/RF-Nelson/open-source-selfie-stick
- 教程: https://gist.github.com/RF-Nelson/8a3e6319b0607cf6b181ae4ee00f6c4c

### Apple 官方文档
- [MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity)
- [Observable Macro](https://developer.apple.com/documentation/observation)
- [Swift Concurrency](https://developer.apple.com/documentation/swift/concurrency)

---

_文档创建日期：2025-11-18_
_最后更新：2025-11-18_
