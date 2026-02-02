---
name: winjs-pc
description: WinJS PC 模板（PC 端 Web）开发指南。包含 Vue 3 配置、Vite 构建、请求封装、路由。适用于：(1) create-win pc 模板创建的项目 (2) 修改 .winrc 配置 (3) 扩展 src/app.js (4) 编写 services 请求 (5) 配置路由与构建 (6) PC 浏览器项目（无 REM/VConsole）。
---

# WinJS PC 模板开发指南

面向 PC 端 Web 应用（Vue 3 + Vue Router 4 + Vite），提供配置、请求、路由与构建优化，无移动端适配功能。

---

## 模板概览

- **技术栈**：Vue 3/2.7 + Vue Router 4，面向 PC 浏览器
- **构建**：WinJS + Vite，Less，支持模块联邦与代码分割
- **插件**：`@winner-fed/plugin-request`（请求）
- **特点**：无 REM 适配、无 VConsole，专注 PC 端
- **代码质量**：Biome、StyleLint、F2ELint + Husky
- **目标环境**：chrome 51+、firefox 54+、safari 10+、edge 15+

---

## 核心配置（.winrc）

关键配置项：

- **plugins**: 仅含 `@winner-fed/plugin-request`
- **appConfig**: 注入 `window.LOCAL_CONFIG`，常用键：`API_HOME`、`API_UPLOAD`（无 VConsole 相关）
- **request**: request 插件配置，在 `src/app.js` 中导出
- **history**: 按需配置 `{ type: 'browser' | 'hash' }`
- **lessLoader.modifyVars**: 注入 variable.less 与 magicless
- **targets**: `{ chrome: 51, firefox: 54, safari: 10, edge: 15 }`
- **jsMinifier/cssMinifier**: terser、cssnano

⚠️ 本模板不含 convertToRem、wconsole，如需移动端功能需自行添加。

完整配置见 [详细用法参考](./references/usage-reference.md) 或 [官方文档](https://winjs-dev.github.io/winjs-docs/config/config)。

---

## 应用入口（src/app.js）

关键导出配置：

- **request**: 配置 request 插件，对接 `services/request.js`
- **router**: 导出 `scrollBehavior` 等路由选项
- **onRouterCreated({ router })**: 注册路由守卫
- **onAppCreated / onMounted**: 应用创建和挂载后的钩子

⚠️ 修改 `modifyClientRenderOpts` 等 memo 钩子必须返回新对象。

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
| `win dev` | 开发服务器（Vite） |
| `win build` | 生产构建 |
| `win preview` | 预览构建 |
| `npm run lint` / `lint:fix` | Biome 检查/修复 |
| `win cache` | 清缓存 |

---

## 快速排错

常见问题：

- **请求 base URL 错误**: 检查 `appConfig` 配置与 `autoMatchBaseUrl` 映射
- **useAppData/getRoute 报错**: 仅在组件生命周期中调用
- **构建/HMR 异常**: 检查 `.winrc` 语法，执行 `win cache` 重试（使用 Vite）

详见 [常见问题与排错](./references/troubleshooting.md)。

---

## 参考文档

**本技能随模板下发，可独立使用：**

- [PC 模板速查](./references/app-reference.md) — 配置项、目录、request、Vite 说明
- [详细用法参考](./references/usage-reference.md) — 配置、钩子、路由、环境变量、CLI 等
- [常见问题与排错](./references/troubleshooting.md) — AppContext、守卫、preview 404 等排错
- [官方文档索引](./references/docs-index.md) — 快速定位官方文档主题

**在线资源：**

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [Request 插件](https://winjs-dev.github.io/winjs-docs/plugins/request) | [Vite 指南](https://winjs-dev.github.io/winjs-docs/guides/vite)
- 项目 README.md — PC 模板结构、模块联邦与开发说明
