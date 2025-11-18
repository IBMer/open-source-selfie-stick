# 情侣互动游戏项目文档

## 📚 文档概览

本目录包含了情侣互动游戏项目的完整设计和开发文档。这是一个基于 MultipeerConnectivity 的双人实时互动游戏 App，从开源项目 **Open Source Selfie Stick** 获取灵感并复用部分代码。

---

## 📖 文档列表

### [01-project-overview.md](./01-project-overview.md)
**项目概述与背景**

涵盖内容：
- 原项目分析
- 产品定位与使用场景
- 功能规划（Phase 1-3）
- 与原项目的本质区别
- 项目目标与成功指标

**适合阅读对象：** 所有人，了解项目全貌

---

### [02-technical-architecture.md](./02-technical-architecture.md)
**技术架构方案**

涵盖内容：
- 完整技术栈选型（Swift 6.0, SwiftUI, SwiftData, CloudKit）
- Clean Architecture 分层设计
- 项目文件结构
- 核心模块详细设计（Domain, Data, Presentation）
- @Observable macro 使用
- MultipeerConnectivity 封装
- 编码规范（SOLID, DRY, KISS）
- 安全、性能考虑

**适合阅读对象：** 开发者，技术决策参考

---

### [03-development-plan.md](./03-development-plan.md)
**开发计划与里程碑**

涵盖内容：
- 8 个开发里程碑（项目搭建到测试发布）
- 详细任务清单
- 时间线估算（2-3周完成 MVP）
- 迭代计划（V1.0 - V2.0）
- 开发工具和环境
- 风险识别与应对
- 每日开发流程

**适合阅读对象：** 项目管理者，开发者

---

### [04-code-reuse-guide.md](./04-code-reuse-guide.md)
**原项目代码复用指南**

涵盖内容：
- 原项目代码分析
- 哪些代码可以直接复用
- 哪些代码需要改造
- 哪些代码不需要
- UIKit → SwiftUI 改造示例
- ObservableObject → @Observable 改造
- 完整的 ConnectionManager 实现示例

**适合阅读对象：** 开发者，代码迁移参考

---

## 🚀 快速开始

### 新成员如何使用这些文档

1. **了解项目** → 阅读 [01-project-overview.md](./01-project-overview.md)
2. **理解架构** → 阅读 [02-technical-architecture.md](./02-technical-architecture.md)
3. **查看计划** → 阅读 [03-development-plan.md](./03-development-plan.md)
4. **开始开发** → 参考 [04-code-reuse-guide.md](./04-code-reuse-guide.md)

### 文档阅读顺序建议

```
产品经理 / 项目管理:
01 (必读) → 03 (必读) → 02 (可选)

开发者 (新加入):
01 (必读) → 02 (必读) → 04 (必读) → 03 (参考)

开发者 (熟悉项目):
直接查阅 02, 03, 04 作为参考

设计师:
01 (必读) → 02 的 UI 部分 (可选)
```

---

## 📋 项目关键信息速览

### 产品定位
> "和 TA 一起玩的双人小游戏，让相处更有趣"

### 核心功能（Phase 1 MVP）
- 设备配对
- 画画猜猜游戏
- 历史记录
- 云同步

### 技术栈
- Swift 6.0+, SwiftUI (iOS 17+)
- @Observable macro
- SwiftData + CloudKit
- MultipeerConnectivity
- Clean Architecture

### 开发时间
- MVP: 2周
- 打磨版本: 3周

### 原项目
- 名称: Open Source Selfie Stick
- 技术: UIKit, MultipeerConnectivity, AVFoundation
- 许可证: Mozilla Public License v2.0
- 仓库: https://github.com/RF-Nelson/open-source-selfie-stick

---

## 🔄 文档更新记录

| 日期 | 文档 | 更新内容 |
|------|------|---------|
| 2025-11-18 | 所有文档 | 初始创建 |

---

## 📞 联系方式

如对文档有疑问或建议，请：
- 创建 Issue
- 或直接联系项目负责人

---

## 📜 许可证

本文档与项目代码一致，遵循相应的开源许可证。

原项目 Open Source Selfie Stick 采用 [Mozilla Public License v2.0](http://mozilla.org/MPL/2.0/)。

---

_文档创建日期：2025-11-18_
_最后更新：2025-11-18_

**Happy Coding! 🎉**
