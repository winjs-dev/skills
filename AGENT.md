# WinJS Skills - Agent Guide

本文档为 AI 编码代理提供 WinJS 相关技能的使用指南，帮助快速定位和应用正确的技能。

## 项目概述

本项目包含 4 个 WinJS 框架的 Cursor Agent Skills，每个针对不同的项目模板，提供配置、开发、排错指导。

## 可用技能

### 1. winjs-app（移动端 H5）
- **路径**: `winjs-app/SKILL.md`
- **技术栈**: Vue 3 + Vue Router 4 + Vite
- **核心功能**: REM 适配、VConsole 调试、请求封装
- **适用场景**: 
  - `create-win app` 模板项目
  - 修改 `.winrc` 配置
  - 配置 REM/VConsole
  - 移动端 H5 开发与排错

### 2. winjs-huipro（企业级 Web）
- **路径**: `winjs-huipro/SKILL.md`
- **技术栈**: Vue 2.6 + Vue Router 3.x + Vuex + HUI + Webpack
- **核心功能**: 自定义 Router、TabsManagement、主子系统、权限控制
- **适用场景**:
  - `create-win huipro` 模板项目
  - 修改 `config/` 配置
  - 维护 `src/router` 自定义路由
  - 企业级后台开发

### 3. winjs-hybrid（混合应用）
- **路径**: `winjs-hybrid/SKILL.md`
- **技术栈**: Vue 3/2.7 + Vue Router 4 + Vite + WebView
- **核心功能**: 原生桥接（GmuJSAPI/Light SDK）、WebView 渲染控制、容器内跳转
- **适用场景**:
  - `create-win hybrid` 模板项目
  - 对接 Harmony JSApi/Light SDK
  - 鸿蒙/券商混合应用开发
  - 配置 render 钩子与原生就绪

### 4. winjs-pc（PC 端 Web）
- **路径**: `winjs-pc/SKILL.md`
- **技术栈**: Vue 3/2.7 + Vue Router 4 + Vite
- **核心功能**: 请求封装、路由配置（无 REM/VConsole）
- **适用场景**:
  - `create-win pc` 模板项目
  - PC 浏览器项目
  - 无需移动端适配的 Web 应用

## 技能结构

每个技能包含：

```
skill-name/
├── SKILL.md                    # 核心指南（<120行）
└── references/                 # 详细参考文档
    ├── app-reference.md        # 模板配置速查
    ├── usage-reference.md      # 详细用法与规范
    ├── troubleshooting.md      # 常见问题排错
    └── docs-index.md           # 官方文档索引
```

**SKILL.md 内容**：模板概览、核心配置、应用入口、目录结构、常用命令、快速排错、参考文档链接。

## 使用指南

### 快速识别模板类型

识别用户项目使用的模板：

| 特征 | 模板类型 |
|------|---------|
| 移动端 H5 + REM + VConsole | **winjs-app** |
| Vue 2 + 自定义 Router + Vuex + HUI | **winjs-huipro** |
| WebView + 原生桥接 + GmuJSAPI | **winjs-hybrid** |
| PC 浏览器 + 无 REM/VConsole | **winjs-pc** |
| 配置在 `config/config.ts` | **winjs-huipro** |
| 配置在 `.winrc.ts` | **app/hybrid/pc** |

### 应用流程

1. **识别模板** → 根据上表判断项目类型
2. **读取 SKILL.md** → 获取核心指导（<120行，快速浏览）
3. **按需查阅 references** → 详细配置、排错等信息

### 常见任务映射

| 任务 | 参考文档 |
|------|---------|
| 修改配置（.winrc/config） | `app-reference.md` |
| 扩展 src/app.js | `SKILL.md` → 应用入口章节 |
| 编写请求接口 | `app-reference.md` → services 章节 |
| 路由配置 | `usage-reference.md` → 路由章节 |
| 排查问题 | `troubleshooting.md` |
| 查找官方文档 | `docs-index.md` |

## 关键差异速查

### 配置差异

| 配置项 | app | huipro | hybrid | pc |
|--------|-----|---------|--------|-----|
| 配置文件 | `.winrc.ts` | `config/config.ts` | `.winrc.ts` | `.winrc.ts` |
| Vue 版本 | 3 | 2.6 | 3/2.7 | 3/2.7 |
| 构建工具 | Vite | Webpack | Vite | Vite |
| Router | 约定式 | 自定义 | 约定式 | 约定式 |
| REM 适配 | ✅ | ❌ | ✅ | ❌ |
| VConsole | ✅ | ❌ | ✅ | ❌ |
| 原生桥接 | ❌ | ❌ | ✅ | ❌ |

### 特有功能

- **winjs-app**: `convertToRem`、`wconsole` 插件
- **winjs-huipro**: 自定义 router、TabsManagement、`index.pro.js` 子系统入口
- **winjs-hybrid**: `render(oldRender)` 钩子、`gmuJSAPI.nativeReady()`、`navigateTo`
- **winjs-pc**: 专注 PC 端，targets 为桌面浏览器

## 最佳实践

1. **模板识别优先**: 先看配置文件位置和技术栈特征
2. **渐进式查阅**: SKILL.md → app-reference.md → usage-reference.md → troubleshooting.md
3. **保持一致性**: 遵循模板约定的目录结构和命名规范
4. **善用索引**: `docs-index.md` 快速定位官方文档主题

## 相关资源

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [WinJS GitHub](https://github.com/winjs-dev)
- 各模板项目根目录的 README.md

---

**使用提示**: 当用户提及 WinJS 项目时，通过关键词（create-win、.winrc、config/、REM、VConsole、GmuJSAPI、HUI 等）快速判断模板类型，然后应用对应技能。
