---
name: winjs-app
description: WinJS App 模板（移动端 H5）开发指南。包含 Vue 3 配置、REM 适配、VConsole 调试、请求封装、路由与构建。适用于：(1) create-win app 模板创建的项目 (2) 修改 .winrc 配置 (3) 扩展 src/app.js (4) 编写 services 请求 (5) 配置 REM/VConsole (6) 排查移动端 H5 问题。
---

# WinJS App 模板开发指南

面向移动端 H5 应用（Vue 3 + Vue Router 4 + Vite），提供配置、目录约定、请求与调试、REM 适配等核心功能。

---

## 模板概览

- **技术栈**：Vue 3 + Vue Router 4，hash 路由
- **构建**：WinJS + Vite，Less + PostCSS，支持 REM 适配、模块联邦
- **插件**：`@winner-fed/plugin-request`（请求）、`@winner-fed/plugin-wconsole`（VConsole）
- **代码质量**：Biome、StyleLint、F2ELint + Husky

---

## 核心配置（.winrc）

关键配置项说明：

- **history**: `{ type: 'hash' }` 适合 H5 部署
- **plugins**: 已含 request、wconsole 插件，新增追加到数组
- **appConfig**: 多环境配置注入 `window.LOCAL_CONFIG`，常用键：`API_HOME`、`API_UPLOAD`、`IS_OPEN_VCONSOLE`
- **request/wconsole**: 插件配置，wconsole 控制 vConsole 开关
- **convertToRem**: 开启 REM 适配
- **lessLoader.modifyVars**: 注入 `@/assets/style/variable.less` 与 `@winner-fed/magicless/magicless.less`
- **targets**: `{ ios: 10, android: 6, chrome: 80 }`

完整配置见 [详细用法参考](./references/usage-reference.md) 或 [官方文档](https://winjs-dev.github.io/winjs-docs/config/config)。

---

## 应用入口（src/app.js）

关键导出配置：

- **request**: 配置 `timeout`、`requestInterceptors`、`responseInterceptors`，对接 `services/request.js`
- **router**: 导出 `scrollBehavior` 等路由选项
- **onRouterCreated({ router })**: 注册路由守卫，勿在模块顶层调用
- **onAppCreated / onMounted**: 应用创建和挂载后的钩子

⚠️ 修改 `modifyClientRenderOpts` 等 memo 钩子必须返回新对象。

详见 [详细用法参考](./references/usage-reference.md)。

---

## 目录结构（src）

- **layouts/index.vue**: 全局布局，对应 `@@/global-layout`
- **pages/**: 约定式路由，目录即路由
- **assets/**: fonts、img、style（variable.less、app.less、main.less）
- **services/**: 请求封装
  - `request.js`: 请求实例、拦截器、错误处理
  - `autoMatchBaseUrl.js`: 按前缀返回 base URL
  - `constant.js`: 统一常量（TIMEOUT、PAGE_NUM、前缀等）
- **constant.js**: 根级常量
- **global.less**: 全局样式

**新增接口**：在 `appConfig` 增加键 → `constant.js` 增加前缀 → `autoMatchBaseUrl.js` 扩展映射。

---

## 常用命令

| 命令 | 说明 |
|------|------|
| `win dev` | 开发服务器 |
| `win build` | 生产构建 |
| `win preview` | 预览构建 |
| `npm run lint` / `lint:fix` | Biome 检查/修复 |
| `npm run format` | Biome 格式化 |
| `win cache` | 清缓存 |

---

## 快速排错

常见问题：

- **请求 base URL 错误**: 检查 `appConfig` 环境配置与 `autoMatchBaseUrl` 映射
- **VConsole 不显示**: 确认 `IS_OPEN_VCONSOLE: true` 且 wconsole 插件已启用
- **REM 不生效**: 检查 `.winrc` 中 `convertToRem` 配置
- **useAppData/getRoute 报错**: 仅在组件生命周期中调用
- **构建/HMR 异常**: 检查 `.winrc` 语法，执行 `win cache` 重试

详见 [常见问题与排错](./references/troubleshooting.md)。

---

## 参考文档

**本技能随模板下发，可独立使用：**

- [App 模板速查](./references/app-reference.md) — 配置项、目录、request/wconsole 速查
- [详细用法参考](./references/usage-reference.md) — 配置、钩子、路由、环境变量、CLI 等
- [常见问题与排错](./references/troubleshooting.md) — AppContext、clientRoutes、守卫等排错
- [官方文档索引](./references/docs-index.md) — 快速定位官方文档主题

**在线资源：**

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [Request 插件](https://winjs-dev.github.io/winjs-docs/plugins/request) | [wconsole 插件](https://winjs-dev.github.io/winjs-docs/plugins/wconsole) | [REM 配置](https://winjs-dev.github.io/winjs-docs/config/config#converttorem)
