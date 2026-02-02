# WinJS Skills

WinJS 框架的 Cursor Agent Skills 集合，为不同的项目模板提供专门的开发指导、配置说明和最佳实践。

## 📦 包含的技能

| 技能                         | 模板类型   | 技术栈                 | 核心功能                            |
| ---------------------------- | ---------- | ---------------------- | ----------------------------------- |
| [winjs-app](./winjs-app/)       | 移动端 H5  | Vue 3 + Vite           | REM 适配、VConsole、请求封装        |
| [winjs-huipro](./winjs-huipro/) | 企业级 Web | Vue 2 + Webpack + HUI  | 自定义 Router、TabsManagement、权限 |
| [winjs-hybrid](./winjs-hybrid/) | 混合应用   | Vue 3 + Vite + WebView | 原生桥接、GmuJSAPI、容器跳转        |
| [winjs-pc](./winjs-pc/)         | PC 端 Web  | Vue 3 + Vite           | PC 浏览器、无移动端适配             |

## 🚀 快速开始

### 识别项目模板

根据项目特征快速判断使用哪个技能：

```
你的项目是?
├─ 配置在 config/config.ts → 使用 winjs-huipro
└─ 配置在 .winrc.ts
   ├─ 有 convertToRem + wconsole → 使用 winjs-app
   ├─ 有 render 钩子 + GmuJSAPI → 使用 winjs-hybrid
   └─ 无 REM/VConsole → 使用 winjs-pc
```

### 查阅文档

每个技能包含以下文档：

```
skill-name/
├── SKILL.md                    # 核心指南（<120行，快速浏览）
└── references/                 # 详细参考文档
    ├── app-reference.md        # 模板配置速查
    ├── usage-reference.md      # 详细用法与规范
    ├── troubleshooting.md      # 常见问题排错
    └── docs-index.md           # 官方文档索引
```

**推荐阅读顺序**：

1. `SKILL.md` - 获取核心概念和快速参考
2. `app-reference.md` - 查看配置项和目录结构
3. `usage-reference.md` - 深入了解详细用法
4. `troubleshooting.md` - 遇到问题时查阅

## 📖 技能详情

### winjs-app（移动端 H5）

**适用场景**：

- `create-win app` 模板创建的项目
- 需要 REM 适配的移动端 H5 应用
- 需要 VConsole 调试工具
- 使用 Vue 3 + Vue Router 4 + Vite

**核心配置**：

```typescript
// .winrc.ts
export default defineConfig({
  convertToRem: { enabled: true },
  plugins: ['@winner-fed/plugin-request', '@winner-fed/plugin-wconsole'],
  appConfig: {
    API_HOME: 'https://api.example.com',
    IS_OPEN_VCONSOLE: true
  }
})
```

[查看详细文档 →](./skills/winjs-app/SKILL.md)

### winjs-huipro（企业级 Web）

**适用场景**：

- `create-win huipro` 模板创建的项目
- 企业级后台管理系统
- 需要自定义 Router、Vuex 状态管理
- 使用 TabsManagement 页签管理
- 主子系统架构

**核心特点**：

- 配置在 `config/config.ts`（非 `.winrc`）
- Vue 2.6 + Vue Router 3.x + Vuex
- 自定义 Router 实例（`src/router/`）
- HUI 企业级组件库

[查看详细文档 →](./skills/winjs-huipro/SKILL.md)

### winjs-hybrid（混合应用）

**适用场景**：

- `create-win hybrid` 模板创建的项目
- 运行在 WebView 中的混合应用
- 需要对接原生 API（鸿蒙/券商）
- 使用 Harmony JSApi 或 Light SDK

**核心特点**：

- 原生桥接（GmuJSAPI、Light SDK）
- `render(oldRender)` 钩子控制渲染时序
- 支持 WebView 容器内跳转（navigateTo）
- 支持离线包配置

[查看详细文档 →](./skills/winjs-hybrid/SKILL.md)

### winjs-pc（PC 端 Web）

**适用场景**：

- `create-win pc` 模板创建的项目
- PC 桌面浏览器应用
- 不需要移动端适配功能

**核心特点**：

- 无 REM 适配、无 VConsole
- 专注 PC 浏览器（Chrome、Firefox、Safari、Edge）
- 使用 Vite 构建，性能优化

[查看详细文档 →](./skills/winjs-pc/SKILL.md)

## 🔍 功能对比

| 功能特性       | app           | huipro               | hybrid        | pc            |
| -------------- | ------------- | -------------------- | ------------- | ------------- |
| 配置文件       | `.winrc.ts` | `config/config.ts` | `.winrc.ts` | `.winrc.ts` |
| Vue 版本       | 3             | 2.6                  | 3/2.7         | 3/2.7         |
| 构建工具       | Vite          | Webpack              | Vite          | Vite          |
| Router         | 约定式        | 自定义               | 约定式        | 约定式        |
| REM 适配       | ✅            | ❌                   | ✅            | ❌            |
| VConsole       | ✅            | ❌                   | ✅            | ❌            |
| 原生桥接       | ❌            | ❌                   | ✅            | ❌            |
| TabsManagement | ❌            | ✅                   | ❌            | ❌            |
| 主子系统       | ❌            | ✅                   | ❌            | ❌            |

## 📚 AI 使用指南

如果你是 AI 编码助手，请查阅：

- **[AGENT.md](./AGENT.md)** - AI 代理快速参考指南（135行）
- **[CLAUDE.md](./CLAUDE.md)** - Claude AI 详细使用教程（282行）

这些文档包含：

- 自动触发场景识别
- 文档查阅优先级
- 常见任务处理流程
- 示例对话和最佳实践

## 🛠️ 常用命令

所有模板通用：

```bash
win dev          # 启动开发服务器
win build        # 生产构建
win preview      # 预览构建结果
win cache        # 清理缓存
npm run lint     # 代码检查
npm run format   # 代码格式化
```

HuiPro 特有命令：

```bash
win huipro       # 子系统构建
win see          # 构建SEE包
```

## 📝 常见问题

### 如何选择合适的模板？

| 需求                     | 推荐模板     |
| ------------------------ | ------------ |
| 移动端 H5，需要 REM 适配 | winjs-app    |
| 企业后台，需要权限管理   | winjs-huipro |
| 混合应用，对接原生 API   | winjs-hybrid |
| PC 端网站，桌面浏览器    | winjs-pc     |

### 配置文件在哪里？

- **winjs-app / hybrid / pc**: `.winrc.ts` 或 `.winrc.js`
- **winjs-huipro**: `config/config.ts`

### 如何区分 Vue 2 和 Vue 3 项目？

- **Vue 2.6**: winjs-huipro（使用 Router 3.x API）
- **Vue 3**: winjs-app / hybrid / pc（使用 Router 4.x API）

### 遇到问题怎么办？

1. 确定项目使用的模板类型
2. 查阅对应技能的 `troubleshooting.md`
3. 参考 `docs-index.md` 定位官方文档
4. 查看 `usage-reference.md` 的详细说明

## 🔗 相关资源

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [WinJS GitHub](https://github.com/winjs-dev)
- [create-win 脚手架](https://www.npmjs.com/package/create-win)

## 📂 项目结构

```
skills/
├── README.md                   # 本文件
├── AGENT.md                    # AI 代理快速参考
├── CLAUDE.md                   # Claude 使用教程
├── DOCS_INDEX.md               # 完整文档索引
├── .claude-plugin.md           # 插件配置说明
├── .claude-plugin/             # 插件配置目录
│   └── marketplace.json       # Marketplace 配置
└── skills/                     # 技能目录
    ├── winjs-app/              # App 模板技能
    │   ├── SKILL.md
    │   └── references/
    ├── winjs-huipro/           # HuiPro 模板技能
    │   ├── SKILL.md
    │   └── references/
    ├── winjs-hybrid/           # Hybrid 模板技能
    │   ├── SKILL.md
    │   └── references/
    └── winjs-pc/               # PC 模板技能
        ├── SKILL.md
        └── references/
```

## 📄 许可证

MIT License

Copyright (c) 2026 winjs-dev

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这些技能文档。

### 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 文档规范

- 保持 SKILL.md 文件在 500 行以内
- 使用中文编写文档
- 遵循现有的文档结构和格式
- 提供实际的代码示例

## 📮 联系方式

- GitHub Issues: [winjs-dev/skills/issues](https://github.com/winjs-dev/skills/issues)
- 官方文档: [winjs-docs](https://winjs-dev.github.io/winjs-docs/)

---

**提示**: 这些技能随 WinJS 框架更新而更新，建议定期检查是否有新版本。
