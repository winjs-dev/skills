---
name: winjs-hybrid
description: WinJS Hybrid 模板（混合式移动应用）开发指南。包含原生桥接（GmuJSAPI/Light SDK）、WebView 渲染控制、REM/VConsole、离线包。适用于：(1) create-win hybrid 模板创建的项目 (2) 对接 Harmony JSApi/Light SDK (3) 配置 render 钩子与原生就绪 (4) 使用 navigateTo 容器内跳转 (5) 配置 REM/VConsole (6) 鸿蒙/券商混合应用开发。
---

# WinJS Hybrid 模板开发指南

面向混合式移动应用（Vue 3/2.7 + WebView），支持原生桥接（GmuJSAPI、Light SDK）、渲染时序控制、容器内跳转与 REM 适配。

---

## 模板概览

- **技术栈**：Vue 3/2.7 + Vue Router 4，hash 路由，运行在 WebView 中
- **构建**：WinJS + Vite，Less + PostCSS，支持 REM 适配
- **插件**：`@winner-fed/plugin-request`（请求）、`@winner-fed/plugin-wconsole`（VConsole）
- **原生桥接**：Harmony JSApi（`@winner-fed/harmony-jsapi`）、Light SDK（`window.LightSDK`）
- **核心特性**：原生就绪控制（render 钩子）、WebView 容器内跳转（navigateTo）、离线包
- **代码质量**：Biome、StyleLint、F2ELint + Husky

---

## 核心配置（.winrc）

关键配置项：

- **history**: `{ type: 'hash' }` 适合 WebView 部署
- **plugins**: 含 request、wconsole 插件
- **appConfig**: 注入 `window.LOCAL_CONFIG`，常用键：`API_HOME`、`API_UPLOAD`、`IS_OPEN_VCONSOLE`
- **request/wconsole**: 插件配置
- **convertToRem**: 开启 REM 适配
- **lessLoader.modifyVars**: 注入 variable.less 与 magicless
- **targets**: `{ ios: 10, android: 6, chrome: 80 }`
- **publicPath**: 开发 `/`，生产 `./`

完整配置见 [详细用法参考](./references/usage-reference.md) 或 [官方文档](https://winjs-dev.github.io/winjs-docs/config/config)。

---

## 应用入口（src/app.js）

**Hybrid 特有钩子：**

- **render(oldRender)**: ⚠️ 原生环境中先执行 `gmuJSAPI.nativeReady({ complete() { oldRender(); } })`，等待原生就绪；非原生环境直接 `oldRender()`
- **onRouterCreated({ router })**: 注册路由守卫，可通过 `gmuJSAPI.navigateTo` 实现容器内跳转
- **request**: 配置 request 插件，对接 `services/request.js`
- **onAppCreated / onMounted**: 通用钩子，可访问 `window.LightSDK`

**原生桥接说明**：
- **GmuJSAPI**: 鸿蒙/券商桥接（nativeReady、isAppOS、navigateTo）
- **Light SDK**: 挂载到 `window.LightSDK`，按需使用

详见 [详细用法参考](./references/usage-reference.md)。

---

## 目录结构（src）

- **layouts/index.vue**: 全局布局
- **pages/**: 约定式路由
- **assets/**: fonts、img、style（variable.less、app.less、main.less）
- **services/**: 请求封装（request.js、autoMatchBaseUrl.js、constant.js、RESTFULURL.js）
- **constant.js**: 根级常量
- **global.less**: 全局样式

---

## 常用命令

| 命令 | 说明 |
|------|------|
| `win dev` | 开发服务器 |
| `win build` | 生产构建 |
| `win preview` | 预览构建 |
| `npm run lint` / `lint:fix` | Biome 检查/修复 |
| `win cache` | 清缓存 |

---

## 快速排错

常见问题：

- **页面不渲染/白屏**: 检查 `render(oldRender)` 是否正确调用 `nativeReady` 的 `complete` 回调
- **原生 API 报错**: 确认调用前已执行 `nativeReady` 或宿主已注入桥接
- **路由跳转异常**: 检查 `gmuJSAPI.isAppOS()` 与 `navigateTo` 参数是否符合宿主约定
- **请求 base URL 错误**: 检查 `appConfig` 配置与 `autoMatchBaseUrl` 映射
- **VConsole 不显示**: 确认 `IS_OPEN_VCONSOLE: true` 且 wconsole 插件已启用
- **useAppData/getRoute 报错**: 仅在组件生命周期中调用

详见 [常见问题与排错](./references/troubleshooting.md)。

---

## 参考文档

**本技能随模板下发，可独立使用：**

- [Hybrid 模板速查](./references/app-reference.md) — 配置、app.js、GmuJSAPI、navigateTo、离线包速查
- [详细用法参考](./references/usage-reference.md) — 配置、钩子、路由、环境变量、CLI 等
- [常见问题与排错](./references/troubleshooting.md) — AppContext、守卫、preview 404 等排错
- [官方文档索引](./references/docs-index.md) — 快速定位官方文档主题

**在线资源：**

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [Request 插件](https://winjs-dev.github.io/winjs-docs/plugins/request) | [wconsole 插件](https://winjs-dev.github.io/winjs-docs/plugins/wconsole) | [REM 配置](https://winjs-dev.github.io/winjs-docs/config/config#converttorem)
- 项目 README.md — 混合应用特性、鸿蒙/Light SDK 说明
