# IOO - 情侣互动游戏 App

## 📱 项目简介

IOO 是一个基于 MultipeerConnectivity 的双人实时互动游戏应用，让情侣和朋友通过画画、游戏等方式增进感情。

### 核心功能（Phase 1 MVP）
- 🔗 设备配对（WiFi/蓝牙）
- 🎨 画画猜猜游戏
- 📊 游戏历史记录
- ☁️ iCloud 云同步

## 🏗️ 架构

项目采用 **Clean Architecture** 设计，分为三层：

```
IOO/
├── Domain/              # 领域层（纯 Swift，无框架依赖）
│   ├── Entities/        # 领域实体
│   ├── UseCases/        # 业务用例
│   └── RepositoryProtocols/  # 仓储协议
│
├── Data/                # 数据层
│   ├── Entities/        # SwiftData 实体
│   ├── Mappers/         # Domain ↔ SwiftData 映射
│   ├── Repositories/    # 仓储实现
│   └── Network/         # MultipeerConnectivity
│
├── Presentation/        # 表现层
│   ├── Screens/         # 界面和 ViewModel
│   └── Common/          # 公共组件
│
├── App/                 # 应用层
│   ├── IOOApp.swift     # App 入口
│   └── DependencyContainer.swift  # 依赖注入
│
└── Resources/           # 资源文件
```

## 🛠️ 技术栈

| 技术 | 用途 |
|------|------|
| **Swift 6.0+** | 编程语言 |
| **SwiftUI** | UI 框架 |
| **@Observable** | 状态管理（iOS 17+） |
| **SwiftData** | 数据持久化 |
| **CloudKit** | 云同步 |
| **MultipeerConnectivity** | P2P 设备通信 |

## 📋 编码规范

### SOLID 原则
- **S**ingle Responsibility Principle
- **O**pen/Closed Principle
- **L**iskov Substitution Principle
- **I**nterface Segregation Principle
- **D**ependency Inversion Principle

### 其他原则
- **DRY**: Don't Repeat Yourself
- **KISS**: Keep It Simple, Stupid

### View 模块化
- 单个 View 文件不超过 **150 行**
- 超过 3 层嵌套立即拆分子组件
- 组件化，可复用

## 🚀 开发进度

### ✅ 已完成
- [x] 项目架构设计
- [x] Domain 层实现
- [x] Data 层实现
- [x] MultipeerConnectivity 集成
- [x] 基础 ViewModel 和 View 骨架

### 🚧 进行中
- [ ] 完整 UI 实现
- [ ] 绘画功能
- [ ] 游戏流程

### 📅 计划中
- [ ] 历史记录详情页
- [ ] 题目库
- [ ] 单元测试
- [ ] UI 测试

## 📖 相关文档

详细文档位于 `docs/couple-game-project/`：
- [项目概述](../docs/couple-game-project/01-project-overview.md)
- [技术架构](../docs/couple-game-project/02-technical-architecture.md)
- [开发计划](../docs/couple-game-project/03-development-plan.md)
- [代码复用指南](../docs/couple-game-project/04-code-reuse-guide.md)

## 🔧 如何构建

### 前置要求
- Xcode 15.0+
- iOS 17.0+ 设备（两台用于测试）
- Apple Developer Account（CloudKit 需要）

### 步骤
1. 在 Xcode 中创建新项目
2. 将 `IOO/` 目录下的所有文件添加到项目
3. 配置 CloudKit entitlement
4. 配置 Info.plist（MultipeerConnectivity 权限）
5. 构建并运行

## 📜 许可证

本项目基于 Open Source Selfie Stick 项目启发，复用了部分 MultipeerConnectivity 代码。

原项目许可证：[Mozilla Public License v2.0](http://mozilla.org/MPL/2.0/)

## 🙏 致谢

- [Open Source Selfie Stick](https://github.com/RF-Nelson/open-source-selfie-stick)
- Apple MultipeerConnectivity Framework
- SwiftUI & SwiftData

---

**创建日期**: 2025-11-18
**最后更新**: 2025-11-18
