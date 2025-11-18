# 开发计划

## 🎯 总体目标

**Phase 1 MVP 目标：** 1-2周内完成可玩的画画猜猜游戏原型

**核心验证问题：**
- 设备配对是否稳定？
- 游戏玩法是否有趣？
- 用户是否愿意重复玩？

---

## 📅 开发里程碑

### Milestone 1: 项目搭建（1-2天）

**目标：** 完成基础项目结构和核心框架

#### 任务清单

**1. 项目初始化**
- [ ] 创建 Xcode 项目（iOS 17+ minimum）
- [ ] 配置 SwiftData + CloudKit
  - [ ] 添加 iCloud capability
  - [ ] 配置 CloudKit private database
  - [ ] 创建 SwiftData schema
- [ ] 配置 MultipeerConnectivity
  - [ ] 添加本地网络权限（Info.plist）
  - [ ] NSLocalNetworkUsageDescription
  - [ ] NSBonjourServices

**2. 项目结构**
- [ ] 创建文件夹结构
  - [ ] Domain/
  - [ ] Data/
  - [ ] Presentation/
  - [ ] Resources/
- [ ] 创建基础文件骨架
  - [ ] Domain Models
  - [ ] Repository Protocols
  - [ ] Use Cases
  - [ ] ViewModels
  - [ ] Views

**3. 依赖注入**
- [ ] 实现 `DependencyContainer.swift`
- [ ] 配置 App 入口点
- [ ] 设置 Environment 注入

**验收标准：**
- ✅ 项目可以编译运行
- ✅ SwiftData 可以保存简单数据
- ✅ CloudKit 配置正确（可在多设备间同步）
- ✅ 文件结构清晰，符合 Clean Architecture

---

### Milestone 2: MultipeerConnectivity 核心（2-3天）

**目标：** 从原项目提取并现代化设备通信代码

#### 任务清单

**1. 提取原项目代码**
- [ ] 复制 `CameraServiceManager.swift` 的核心逻辑
  - [ ] MultipeerConnectivity 初始化
  - [ ] 设备发现和广播
  - [ ] 连接建立
  - [ ] 数据传输

**2. 改造为现代 Swift**
- [ ] UIKit → @Observable
- [ ] Completion handlers → async/await
- [ ] 硬编码字符串 → 结构化消息
- [ ] Delegate pattern → AsyncStream

**3. 实现 ConnectionManager**
```swift
@Observable
final class ConnectionManager {
    var connectionState: ConnectionState
    var connectedPartnerName: String?

    func startSearching()
    func stopSearching()
    func sendMessage(_ message: GameMessage) async throws
    func observeMessages() -> AsyncStream<GameMessage>
}
```

**4. 实现 ConnectionRepository**
- [ ] 实现 `ConnectionRepositoryProtocol`
- [ ] 桥接 ConnectionManager 和 Domain

**5. 测试**
- [ ] 两台设备能够发现彼此
- [ ] 配对连接成功
- [ ] 发送简单消息
- [ ] 接收消息触发 UI 更新

**验收标准：**
- ✅ 设备配对成功率 > 95%
- ✅ 消息传输可靠
- ✅ 连接状态正确反映在 UI
- ✅ 支持 WiFi 和蓝牙

---

### Milestone 3: 设备配对界面（1-2天）

**目标：** 完成第一个可用的功能流程

#### 任务清单

**1. PairingView**
- [ ] 设计配对界面
  - [ ] "开始配对"按钮
  - [ ] 连接状态显示
  - [ ] 发现的设备列表
  - [ ] 连接成功提示

**2. PairingViewModel**
- [ ] 管理连接状态
- [ ] 调用 ConnectionRepository
- [ ] 处理配对确认逻辑

**3. 用户体验优化**
- [ ] 加载动画
- [ ] 连接成功动效
- [ ] 错误处理和提示
- [ ] 重连机制

**4. 导航逻辑**
- [ ] 配对成功后跳转到游戏界面
- [ ] 断开连接后返回配对界面

**验收标准：**
- ✅ 用户可以轻松配对两台设备
- ✅ 连接状态清晰可见
- ✅ 连接失败有明确提示
- ✅ 用户体验流畅

---

### Milestone 4: 游戏核心功能（3-4天）

**目标：** 实现完整的画画游戏流程

#### 任务清单

**1. Domain 层**
- [ ] `GameSession` 实体
- [ ] `DrawingData` 和 `DrawingStroke` 模型
- [ ] `GameMessage` 枚举（游戏消息类型）
- [ ] `SaveGameSessionUseCase`
- [ ] `FetchGameHistoryUseCase`

**2. Data 层**
- [ ] `GameSessionEntity` (SwiftData)
- [ ] `GameSessionMapper`
- [ ] `SwiftDataGameRepository` 实现

**3. 题目系统**
- [ ] 创建 `Topics.json` 题目库
- [ ] `TopicGenerator` 随机选择题目
- [ ] 两台设备同步题目

**4. 绘画功能**
- [ ] `DrawingCanvasView` 组件
  - [ ] 使用 PencilKit 或自定义绘画
  - [ ] 支持触摸绘制
  - [ ] 颜色选择（可选）
  - [ ] 清空画布
- [ ] 绘画数据捕获
  - [ ] 笔触记录
  - [ ] 转换为图片
  - [ ] 压缩优化

**5. 游戏流程**
- [ ] 游戏开始
  - [ ] 显示题目
  - [ ] 启动倒计时
- [ ] 绘画阶段
  - [ ] 实时倒计时显示
  - [ ] 时间到自动提交
- [ ] 提交绘画
  - [ ] 发送给对方
  - [ ] 等待对方完成
- [ ] 显示结果
  - [ ] 左右对比两幅画
  - [ ] 显示题目
  - [ ] 保存选项

**6. GameViewModel**
```swift
@Observable
final class GameViewModel {
    var gameState: GameState
    var currentTopic: String
    var countdown: Int
    var myDrawing: DrawingData?
    var partnerDrawing: DrawingData?

    func startGame(topic: String)
    func submitDrawing(_ drawing: DrawingData) async
    func saveSession() async throws
}
```

**7. GameView 组件化**
- [ ] `GameView.swift` (主视图)
- [ ] `TopicHeaderView.swift` (题目+倒计时)
- [ ] `DrawingCanvasView.swift` (画布)
- [ ] `CountdownTimerView.swift` (倒计时)
- [ ] `GameControlsView.swift` (控制按钮)

**验收标准：**
- ✅ 两台设备能同步开始游戏
- ✅ 题目在两边一致
- ✅ 倒计时准确
- ✅ 绘画流畅无卡顿
- ✅ 绘画数据能成功传输
- ✅ 结果正确显示

---

### Milestone 5: 结果展示与保存（1-2天）

**目标：** 完成游戏后的体验闭环

#### 任务清单

**1. ResultView**
- [ ] 左右对比布局
- [ ] 显示题目和时间
- [ ] "再玩一局"按钮
- [ ] "保存"按钮
- [ ] "查看历史"按钮

**2. ResultViewModel**
- [ ] 管理结果状态
- [ ] 保存游戏会话
- [ ] 导航控制

**3. 数据持久化**
- [ ] 保存到 SwiftData
- [ ] 自动同步到 CloudKit
- [ ] 测试多设备同步

**4. 分享功能（可选）**
- [ ] 生成结果截图
- [ ] 分享到社交媒体

**验收标准：**
- ✅ 结果展示清晰美观
- ✅ 数据成功保存
- ✅ CloudKit 同步正常
- ✅ 可以开始新一局

---

### Milestone 6: 历史记录（1天）

**目标：** 用户可以回顾过往游戏

#### 任务清单

**1. HistoryView**
- [ ] 列表展示游戏记录
- [ ] 显示日期、对手、题目
- [ ] 缩略图预览
- [ ] 点击查看详情

**2. HistoryViewModel**
- [ ] 获取所有游戏记录
- [ ] 按日期排序
- [ ] 删除功能

**3. 详情页**
- [ ] 完整显示两幅画
- [ ] 显示游戏信息
- [ ] 分享按钮

**验收标准：**
- ✅ 历史记录正确显示
- ✅ 可以查看详情
- ✅ 删除功能正常

---

### Milestone 7: UI/UX 打磨（2-3天）

**目标：** 提升整体体验，准备发布

#### 任务清单

**1. 视觉设计**
- [ ] 设计色彩主题
- [ ] 统一字体和间距
- [ ] 图标和插图
- [ ] 动画和过渡效果

**2. 交互优化**
- [ ] 按钮点击反馈
- [ ] 页面过渡动画
- [ ] 加载状态优化
- [ ] 手势交互

**3. 错误处理**
- [ ] 网络断开提示
- [ ] 数据保存失败处理
- [ ] 配对失败提示
- [ ] 友好的错误信息

**4. 性能优化**
- [ ] 绘画性能测试
- [ ] 数据传输优化
- [ ] 内存使用优化
- [ ] 启动时间优化

**5. 无障碍**
- [ ] VoiceOver 支持
- [ ] Dynamic Type 支持
- [ ] 颜色对比度检查

**验收标准：**
- ✅ 视觉效果专业美观
- ✅ 交互流畅自然
- ✅ 所有错误情况有处理
- ✅ 性能达标（60fps）

---

### Milestone 8: 测试与修复（2-3天）

**目标：** 确保产品质量

#### 任务清单

**1. 功能测试**
- [ ] 完整流程测试
  - [ ] 配对 → 游戏 → 结果 → 保存
- [ ] 边界情况
  - [ ] 中途断开连接
  - [ ] 同时提交绘画
  - [ ] 快速重复操作
- [ ] 多设备测试
  - [ ] iPhone + iPhone
  - [ ] iPhone + iPad
  - [ ] 不同 iOS 版本

**2. 数据测试**
- [ ] SwiftData 保存/读取
- [ ] CloudKit 同步
- [ ] 数据冲突解决
- [ ] 大量数据性能

**3. 网络测试**
- [ ] WiFi 连接稳定性
- [ ] 蓝牙连接测试
- [ ] 弱网络环境
- [ ] 切换网络

**4. Bug 修复**
- [ ] 记录所有 bug
- [ ] 按优先级修复
- [ ] 回归测试

**验收标准：**
- ✅ 无严重 bug
- ✅ 配对成功率 > 95%
- ✅ 游戏流程顺畅
- ✅ 数据准确无误

---

## 📊 时间线估算

```
Week 1:
├── Day 1-2: Milestone 1 (项目搭建)
├── Day 3-5: Milestone 2 (MultipeerConnectivity)
└── Day 6-7: Milestone 3 (配对界面)

Week 2:
├── Day 8-11: Milestone 4 (游戏核心)
├── Day 12-13: Milestone 5 (结果展示)
└── Day 14: Milestone 6 (历史记录)

Week 3 (可选打磨):
├── Day 15-17: Milestone 7 (UI/UX 打磨)
└── Day 18-20: Milestone 8 (测试修复)
```

**最快完成时间：** 2周（基础可用版本）
**打磨完成时间：** 3周（可发布版本）

---

## 🔄 迭代计划

### V1.0 - MVP（2-3周）
- ✅ 设备配对
- ✅ 画画猜猜游戏
- ✅ 历史记录
- ✅ SwiftData + CloudKit

### V1.1 - 功能扩展（+1周）
- ✅ 真心话大冒险游戏
- ✅ 更多题目
- ✅ 音效

### V1.2 - 体验优化（+1周）
- ✅ 接力画功能
- ✅ 同步涂鸦
- ✅ UI 美化

### V2.0 - 重大更新（+3周）
- ✅ 双人拍照功能
- ✅ AI 自动抓拍
- ✅ 情侣滤镜
- ✅ AR 道具

---

## 🛠️ 开发工具和环境

### 必需工具
- **Xcode:** 15.0+
- **iOS 设备:** 两台 iOS 17+ 设备（用于测试）
- **Apple Developer Account:** 用于 TestFlight 和 CloudKit

### 推荐工具
- **Git:** 版本控制
- **Figma:** UI 设计（可选）
- **SF Symbols:** 系统图标

### 测试设备矩阵
| 设备类型 | iOS 版本 | 用途 |
|---------|---------|------|
| iPhone 15 Pro | iOS 17.x | 主开发设备 |
| iPhone 12 | iOS 17.x | 测试设备 |
| iPad Pro | iOS 17.x | 大屏测试 |

---

## 📋 每日开发流程

### 开发节奏
```
09:00 - 10:00  回顾昨日进度，规划今日任务
10:00 - 12:00  专注开发
12:00 - 13:00  午休
13:00 - 17:00  开发 + 测试
17:00 - 18:00  代码审查，提交代码
18:00 - 18:30  更新文档，规划明日
```

### Git 工作流
```bash
# 每天开始
git checkout main
git pull origin main
git checkout -b feature/milestone-X-task-Y

# 开发过程中
git add .
git commit -m "feat: implement XXX"

# 完成任务
git push origin feature/milestone-X-task-Y
# 创建 PR（如果团队协作）
# 或直接合并到 main（个人项目）
```

### 代码提交规范
```
feat: 新功能
fix: 修复 bug
refactor: 重构
docs: 文档更新
test: 测试
chore: 构建/工具
```

---

## 🎯 优先级原则

### 必须有（Must Have）
- 设备配对
- 画画游戏核心流程
- 数据持久化

### 应该有（Should Have）
- 历史记录
- UI 美化
- 错误处理

### 可以有（Could Have）
- 分享功能
- 音效
- 动画

### 暂不考虑（Won't Have）
- 其他游戏模式（留到 V1.1）
- 拍照功能（留到 V2.0）
- 账号系统

---

## 🚨 风险识别与应对

### 技术风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| MultipeerConnectivity 不稳定 | 高 | 中 | 增加重连机制，提供降级方案 |
| SwiftData 同步问题 | 中 | 低 | 充分测试，准备回退到本地存储 |
| 绘画性能问题 | 中 | 中 | 优化笔触算法，限制数据量 |
| CloudKit 配置错误 | 中 | 低 | 详细文档，测试环境验证 |

### 产品风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| 用户觉得不好玩 | 高 | 中 | 快速迭代，收集反馈 |
| 配对流程太复杂 | 中 | 低 | 简化 UI，提供引导 |
| 题目库不够丰富 | 低 | 中 | 提前准备100+题目 |

### 时间风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| 低估开发时间 | 中 | 高 | 按优先级砍功能，MVP 优先 |
| 测试时间不足 | 中 | 中 | 每日测试，及时发现问题 |

---

## ✅ 完成标准

### MVP 完成标准
- [ ] 两台设备能稳定配对
- [ ] 能完整玩一局游戏
- [ ] 游戏记录能保存和查看
- [ ] 无严重 bug
- [ ] 基本 UI 可用

### 可发布标准
- [ ] 所有核心功能完整
- [ ] UI/UX 专业美观
- [ ] 无已知 bug
- [ ] 性能达标
- [ ] 通过 TestFlight 内测反馈良好

---

## 📝 开发日志模板

```markdown
# 开发日志 - YYYY-MM-DD

## 今日目标
- [ ] 任务 1
- [ ] 任务 2

## 实际完成
- [x] 任务 1
- [ ] 任务 2（进行中）

## 遇到的问题
1. 问题描述
   - 解决方案

## 明日计划
- [ ] 继续任务 2
- [ ] 开始任务 3

## 笔记
- 其他想法和记录
```

---

## 🎓 学习资源

### SwiftUI + SwiftData
- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Observable Macro Guide](https://developer.apple.com/documentation/observation)

### MultipeerConnectivity
- [Apple MultipeerConnectivity Guide](https://developer.apple.com/documentation/multipeerconnectivity)
- [原项目教程](https://gist.github.com/RF-Nelson/8a3e6319b0607cf6b181ae4ee00f6c4c)

### Clean Architecture
- [Clean Architecture in Swift](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3)

---

_文档创建日期：2025-11-18_
_最后更新：2025-11-18_
