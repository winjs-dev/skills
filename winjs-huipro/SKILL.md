---
name: winjs-huipro
description: 基于 WinJS HuiPro 模板的企业级 Web 项目开发技能。在用户使用 create-win huipro 模板创建的项目中进行开发、配置、自定义路由、Vuex、标签页、权限与构建时使用。
license: MIT
---

本技能面向 **HuiPro 模板**（企业级 Web）生成的项目，在保持与 WinJS 框架约定一致的前提下，侧重本模板的配置、自定义 Router、Vuex、TabsManagement、权限与脚本。

**何时使用本技能**：在由 `create-win` 选择 **HuiPro** 模板创建的项目中做功能开发、修改 `config/`、扩展 `src/app.js`、维护 `src/router`、使用 TabsManagement/临时路由、配置权限/菜单、或排查路由/构建问题时，应优先应用本技能并查阅 References。

本技能及下方 References 随模板下发，创建后的项目可独立使用，无需访问 winjs 仓库。

---

## HuiPro 模板概览

- **定位**：企业级后台 / Web 应用；Vue 2.6 + Vue Router 3.x + Vuex，hash 路由。
- **构建**：WinJS + `@winner-fed/preset-vue2`、`@winner-fed/plugin-build-huipro` 等；Webpack，Less。
- **UI**：HUI（h_ui）企业级组件库。
- **路由**：**自定义 Router 实例**，在 `src/router/` 中维护，通过 `app.js` 的 `modifyClientRenderOpts` 传入；支持页签管理（TabsManagement）与临时路由。
- **状态**：Vuex（`src/stores`），通过 `modifyClientRenderOpts` 传入 `store`。
- **代码质量**：Biome、StyleLint、F2ELint；Husky + lint-staged + commitlint。
- **特色**：主子系统（`win huipro` / `build:see:child`）、**index.pro.js** 子系统入口、国际化、权限/菜单、config 目录配置。

---

## 本模板专用配置（config/）

- **入口**：配置来自 `config/config.ts`（或 `config.ts.tpl` 生成），不是根目录 `.winrc`；与 WinJS 约定一致处（如 `defineConfig`、`routes`、`history`、`appConfig`、`plugins`）在 config 中维护。
- **routes**：模板中设为 `[]`，因使用自定义 router，路由由 `src/router/routes.js` 定义。
- **plugins**：含 `@winner-fed/plugin-hui`、`@winner-fed/plugin-build-huipro`、`@winner-fed/plugin-hui-micro-app` 等；request 插件若使用需在 config 或 app.js 中配置。
- **appConfig**：多环境配置，通常从 `config/appConfig.ts` 引入，注入到 `window.LOCAL_CONFIG`。
- **proxy**：从 `config/proxy.ts` 引入，开发代理。
- **hui** / **huipro** / **microApp**：HuiPro 与微前端相关配置；`huipro.routePrefix`、`huipro.prefix` 等按业务配置。
- **lessLoader**：全局变量（如 `ROOT_CLASS`）、`modifyVars` 注入 `@/assets/style/variable.less` 与 magicless。

其余通用项见本技能 [详细用法与规范参考](./references/usage-reference.md) 或 [WinJS 官方配置](https://winjs-dev.github.io/winjs-docs/config/config)。

---

## 应用入口 src/app.js

- **modifyClientRenderOpts(memo)**：**必须**返回新对象，传入自定义 `router` 与 `store`，例如 `return { ...memo, router: customRouter, store }`。传入后框架使用该 router，`useAppData().clientRoutes` 取自 `router.options.routes`（Vue Router 3.x）。禁止直接修改 `memo` 后返回。
- **onRouterCreated({ router })**：路由实例创建后、挂载到 app 前；在此注册 `router.beforeEach` 等守卫。守卫逻辑若在单独文件（如 `router.interceptor.js`），应**导出函数**并在 `onRouterCreated` 中调用，避免在模块顶层对尚未创建完成的 router 调用 `beforeEach`。
- **onMounted({ app, router })**：应用挂载后；模板中用于 `initTabsManagement(router)`，初始化页签管理。
- **request**（若使用 request 插件）：可导出 `request` 配置，与 App 模板类似。

**Vue 2 / Vue Router 3 注意**：必须先 `Vue.use(Router)`，再 `new Router(...)`；动态路由使用 `router.addRoutes([...])` 与 `router.options.routes`，不要使用 Vue Router 4 的 `addRoute()` / `getRoutes()`。

---

## 自定义 Router 与目录约定（src）

- **src/router/index.js**：创建并导出 router 实例；**先** `Vue.use(Router)`，**再** `const router = new Router({ mode: 'hash', routes })`。
- **src/router/routes.js**：导出 `routes` 数组，与 Vue Router 3 格式一致（component、path、children、meta、redirect 等）。
- **src/router/router.interceptor.js**：路由守卫；应通过 `onRouterCreated` 中调用注册，不要在模块顶层直接对 `router` 调用 `beforeEach`（避免与 router 创建顺序冲突）。
- **src/stores**：Vuex store，在 app.js 中通过 `modifyClientRenderOpts` 传入。
- **src/layouts/index.vue**：全局布局。
- **src/pages/**：页面组件；与 `router/routes.js` 中配置的 component 对应。
- **src/components/TabsManagement**：页签管理；临时路由需使用 `router.addRoutes()`（Vue 2），并在路由 meta 中配置 `enableTempRoute` 等（见模板 README）。
- **src/services**、**src/utils**：请求封装、工具函数；含 `autoMatchBaseUrl`、权限（如 `menuAuth`、`customerRouter`）等可按项目扩展。
- **src/index.pro.js**：**HuiPro 子系统入口**。当项目作为子系统被主应用加载时使用（如 `npm run child` / `win huipro` 构建）。导出 `router`（由 `.huipro/routesForHui` 生成的路由模块映射）、`store`、`utils`、`directives`、`components`、`uses`、`i18n`、`bootstrap`；`bootstrap({ store, tabs }, done)` 在子系统资源加载完毕、路由注册前执行，可做权限拉取等，结束时需调用 `done()`。详见本技能 [HuiPro 模板速查](./references/app-reference.md#indexprojs-子系统入口)。

---

## 脚本与命令

| 命令 | 说明 |
|------|------|
| `win dev` / `npm run dev` | 开发服务器 |
| `win build` / `npm run build` | 生产构建 |
| `win preview` / `npm run preview` | 预览构建结果 |
| `win see` / `npm run build:see` | 构建并预览（见 seeOptions） |
| `win huipro` / `npm run child` | 子系统构建 |
| `npm run build:see:child` | 子系统构建并预览 |
| `npm run lint` / `lint:fix` | Biome 检查 / 自动修复 |
| `npm run format` | Biome 格式化 |
| `npm run f2elint-scan` / `f2elint-fix` | F2ELint 扫描 / 修复 |
| `win setup` | 项目初始化 |
| `win cache` | 清缓存 |

---

## 排错提示（HuiPro 相关）

- **路由不工作 / 守卫不触发**：确认 `src/router/index.js` 中 **先** `Vue.use(Router)` **再** `new Router()`；守卫在 `onRouterCreated` 中注册，不要只在 `router.interceptor.js` 顶层调用。
- **clientRoutes 只有 globalLayout**：确认 `app.js` 中 `modifyClientRenderOpts` 返回了 `{ ...memo, router: customRouter }`，且无其他插件覆盖 `memo.router`。
- **动态/临时路由报错**：Vue 2 使用 `router.addRoutes([...])`，不要用 `router.addRoute()`（Vue Router 4 才有）。
- **useAppData / getRoute 报错**：必须在组件生命周期或 setup 中调用，勿在模块顶层；见本技能 [常见问题与排错](./references/troubleshooting.md)。
- **构建或 HMR 异常**：检查 config 语法、依赖版本，执行 `win cache` 后重试。

更多通用排错见本技能 [常见问题与排错](./references/troubleshooting.md) 或 [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)。

---

## References

**本技能下**（随模板下发，创建项目后可独立使用）：

- [HuiPro 模板速查](./references/app-reference.md) — 本模板 config、app.js、router、TabsManagement、脚本与自定义路由注意事项。
- [WinJS 详细用法与规范参考](./references/usage-reference.md) — 配置、modifyClientRenderOpts、patchRoutes、运行时钩子、路由、Vue 2/3 差异、插件 API、.winrc 索引等。
- [WinJS 常见问题与排错](./references/troubleshooting.md) — AppContext、clientRoutes、守卫、Vue 2 addRoutes、preview 404、构建与 HMR 等。
- [WinJS 官方文档索引](./references/docs-index.md) — 官方文档主题索引。

**在线**：

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- 项目根 [README.md](../../../../README.md) — 自定义 Router 步骤、TabsManagement、权限与部署说明（从本技能目录回退到项目/模板根）。
