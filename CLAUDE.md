# WinJS Skills - Claude 使用指南

本文档为 Claude AI 提供 WinJS 技能的使用说明，帮助你快速理解和应用这些技能。

## 技能概述

本项目包含 4 个 WinJS 框架相关的技能，每个对应不同的项目模板：

| 技能 | 模板类型 | 核心场景 |
|------|---------|---------|
| **winjs-app** | 移动端 H5 | REM 适配、VConsole、移动端开发 |
| **winjs-huipro** | 企业级 Web | 自定义 Router、Vuex、权限管理 |
| **winjs-hybrid** | 混合应用 | 原生桥接、WebView、鸿蒙开发 |
| **winjs-pc** | PC 端 Web | 桌面浏览器、无移动端适配 |

## 何时使用这些技能

### 自动触发场景

当用户提及以下关键词时，你应该主动应用对应技能：

**winjs-app**:
- `create-win app`
- 移动端 H5 + REM 适配
- VConsole 调试
- `.winrc` 配置 + Vue 3

**winjs-huipro**:
- `create-win huipro`
- `config/config.ts` 配置
- 自定义 Router + Vuex
- HUI 组件库
- TabsManagement 页签
- 主子系统

**winjs-hybrid**:
- `create-win hybrid`
- WebView + 原生桥接
- GmuJSAPI / Light SDK
- `render(oldRender)` 钩子
- 鸿蒙/券商应用

**winjs-pc**:
- `create-win pc`
- PC 浏览器项目
- 无 REM/VConsole
- Vue 3 + Vite

## 快速识别模板

通过项目特征快速判断：

```
配置文件在 config/config.ts → winjs-huipro
配置文件在 .winrc.ts:
  ├─ 有 convertToRem + wconsole → winjs-app
  ├─ 有 render 钩子 + GmuJSAPI → winjs-hybrid
  └─ 无 REM/VConsole → winjs-pc
```

## 使用流程

### 1. 识别模板类型

```
用户问题 → 提取关键词 → 判断模板类型 → 应用对应技能
```

### 2. 查阅文档顺序

```
SKILL.md (核心指南，<120行)
  ↓ 需要详细配置
app-reference.md (配置速查)
  ↓ 需要深入理解
usage-reference.md (详细用法)
  ↓ 遇到问题
troubleshooting.md (排错清单)
```

### 3. 回答用户问题

1. **先读 SKILL.md**：获取核心概念和快速参考
2. **按需读 references**：根据具体问题查阅详细文档
3. **引用文档**：回答时引用相关章节，方便用户自查

## 常见任务处理

### 配置相关问题

**用户**: "如何配置 REM 适配？"

**处理流程**:
1. 识别为 winjs-app 或 winjs-hybrid（支持 REM）
2. 读取 `SKILL.md` → 核心配置章节
3. 查看 `app-reference.md` → convertToRem 详细配置
4. 提供配置示例和说明

### 排错相关问题

**用户**: "路由守卫不生效"

**处理流程**:
1. 识别模板类型（huipro 特别注意 Vue 2）
2. 读取 `troubleshooting.md` → 路由相关章节
3. 检查常见问题（onRouterCreated、Vue.use 顺序等）
4. 提供解决方案

### 开发相关问题

**用户**: "如何对接原生 API？"

**处理流程**:
1. 识别为 winjs-hybrid
2. 读取 `SKILL.md` → 应用入口章节
3. 查看 GmuJSAPI 和 render 钩子说明
4. 提供代码示例

## 关键差异速记

### 配置文件

- `config/config.ts` → **huipro**
- `.winrc.ts` → **app / hybrid / pc**

### Vue 版本

- **Vue 2.6** → huipro（注意 Router 3.x API）
- **Vue 3** → app / hybrid / pc

### 构建工具

- **Webpack** → huipro
- **Vite** → app / hybrid / pc

### 特色功能

| 功能 | app | huipro | hybrid | pc |
|------|-----|--------|--------|-----|
| REM 适配 | ✅ | ❌ | ✅ | ❌ |
| VConsole | ✅ | ❌ | ✅ | ❌ |
| 自定义 Router | ❌ | ✅ | ❌ | ❌ |
| TabsManagement | ❌ | ✅ | ❌ | ❌ |
| 原生桥接 | ❌ | ❌ | ✅ | ❌ |
| 主子系统 | ❌ | ✅ | ❌ | ❌ |

## 最佳实践

### 1. 主动识别，快速应用

看到 WinJS 相关问题，立即识别模板类型并应用技能，无需等待用户明确说明。

### 2. 渐进式阅读

不要一次性读取所有文档：
- 先读 SKILL.md 获取全局认知
- 根据具体问题按需读取 references
- 只在遇到问题时查阅 troubleshooting

### 3. 精准引用

回答时引用具体章节：
- ✅ "根据 winjs-app/SKILL.md 的核心配置章节..."
- ✅ "详见 app-reference.md 的 services 章节"
- ❌ "根据文档..." （太模糊）

### 4. 注意版本差异

- **huipro** 使用 Vue 2，注意 API 差异：
  - `router.addRoutes([...])` 非 `addRoute()`
  - `router.options.routes` 非 `getRoutes()`
  - 必须先 `Vue.use(Router)` 再 `new Router()`

### 5. 强调关键注意点

使用 ⚠️ 标记重要事项：
- ⚠️ huipro 的 `modifyClientRenderOpts` 必须返回新对象
- ⚠️ hybrid 的 `render(oldRender)` 在原生环境需等待 `nativeReady`
- ⚠️ 所有模板的 `useAppData/getRoute` 只能在组件生命周期中调用

## 示例对话

### 示例 1：配置问题

**用户**: "我用 create-win app 创建了项目，怎么开启 REM 适配？"

**你的处理**:
1. 识别为 winjs-app
2. 读取 `winjs-app/SKILL.md`
3. 定位到核心配置 → convertToRem
4. 回答：

```typescript
// .winrc.ts 中配置
export default defineConfig({
  convertToRem: {
    enabled: true,
    rootFontSize: 50, // 根据设计稿调整
  }
})
```

详见 [winjs-app/SKILL.md 核心配置章节](./winjs-app/SKILL.md)。

### 示例 2：排错问题

**用户**: "HuiPro 项目的路由守卫不触发"

**你的处理**:
1. 识别为 winjs-huipro
2. 读取 `winjs-huipro/troubleshooting.md`
3. 检查常见问题清单
4. 回答：

确认以下两点：
1. `src/router/index.js` 中先 `Vue.use(Router)` 再 `new Router()`
2. 守卫在 `src/app.js` 的 `onRouterCreated` 中注册，非 `router.interceptor.js` 顶层

⚠️ Vue 2 + Router 3 必须遵循此顺序。

详见 [winjs-huipro/troubleshooting.md](./winjs-huipro/references/troubleshooting.md)。

### 示例 3：开发问题

**用户**: "Hybrid 项目白屏，原生 API 报错"

**你的处理**:
1. 识别为 winjs-hybrid
2. 读取 `winjs-hybrid/SKILL.md` → 应用入口
3. 检查 render 钩子
4. 回答：

检查 `src/app.js` 的 `render` 钩子：

```javascript
export function render(oldRender) {
  if (gmuJSAPI.isAppOS()) {
    // 原生环境，等待就绪
    gmuJSAPI.nativeReady({
      complete() {
        oldRender(); // 就绪后渲染
      }
    });
  } else {
    // 非原生环境，直接渲染
    oldRender();
  }
}
```

⚠️ 原生环境必须在 `nativeReady` 后调用 `oldRender()`。

详见 [winjs-hybrid/SKILL.md 应用入口章节](./winjs-hybrid/SKILL.md)。

## 相关资源

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [AGENT.md](./AGENT.md) - 完整的代理使用指南
- 各技能的 references 目录 - 详细参考文档

## 快速命令参考

所有模板通用命令：

```bash
win dev          # 开发服务器
win build        # 生产构建
win preview      # 预览构建
win cache        # 清缓存
npm run lint     # 代码检查
```

HuiPro 特有：

```bash
win huipro       # 子系统构建
win see          # 构建并预览
```

---

**记住**: 你的目标是帮助用户快速解决 WinJS 项目中的问题。通过快速识别模板类型、精准查阅文档、提供可操作的解决方案，让用户高效完成开发任务。
