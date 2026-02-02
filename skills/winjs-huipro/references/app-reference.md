# HuiPro 模板速查

本文档为 winjs-huipro 技能的补充参考，仅针对 create-win **HuiPro** 模板生成的项目，做配置、自定义路由、app.js、TabsManagement 与脚本速查。

---

## 配置入口（config/）

本模板使用 **config 目录** 作为 WinJS 配置入口（非根目录 `.winrc`）。

| 文件 | 说明 |
|------|------|
| `config/config.ts` | 主配置：defineConfig、routes、history、appConfig、plugins、proxy、hui、huipro、lessLoader、seeOptions 等 |
| `config/appConfig.ts` | 多环境配置（development / test / production），注入到 `window.LOCAL_CONFIG` |
| `config/proxy.ts` | 开发代理配置 |
| `config/routes.ts` | 若使用配置式路由时可在此维护；本模板使用自定义 router，主配置中 `routes: []`，路由在 `src/router/routes.js` |

---

## 本模板常用配置项（config/config.ts）

| 配置项 | 说明 | 模板说明 |
|--------|------|----------|
| `routes` | 路由配置数组 | 模板中为 `[]`，路由由 `src/router/routes.js` 提供 |
| `history.type` | 路由模式 | `'hash'` |
| `plugins` | 插件列表 | 含 plugin-hui、plugin-build-huipro、plugin-hui-micro-app 等 |
| `appConfig` | 多环境配置 | 从 `./appConfig` 引入 |
| `proxy` | 开发代理 | 从 `./proxy` 引入 |
| `hui` / `huipro` | HUI、HuiPro 配置 | prefix、routePrefix 等 |
| `lessLoader.modifyVars` | Less 全局变量/混入 | 注入 `@/assets/style/variable.less` 与 magicless |
| `seeOptions` | 构建预览/子系统相关 | system、type、configName、variables 等 |
| `publicPath` | 部署基础路径 | 开发 `/`，生产 `./` |
| `alias` | 路径别名 | 含 utils、mixins 等 |

---

## appConfig 与 window.LOCAL_CONFIG

- **配置位置**：`config/appConfig.ts` 或主配置中引入的 appConfig。
- **注入方式**：构建后生成 `config.local.js`，挂载到 `window.LOCAL_CONFIG`。
- **使用**：在 `services/autoMatchBaseUrl.js` 等处根据前缀返回 base URL；业务勿在模块顶层依赖未注入的 config。

---

## src/app.js 导出约定

| 导出 | 说明 | 备注 |
|------|------|------|
| `modifyClientRenderOpts(memo)` | 传入自定义 router 与 store | 必须返回 `{ ...memo, router: customRouter, store }`，不直接改 memo |
| `onRouterCreated({ router })` | 路由实例创建后 | 在此注册 `router.beforeEach` 等；守卫逻辑可来自 `router.interceptor.js`，以函数形式在 onRouterCreated 中调用 |
| `onAppCreated({ app })` | 应用实例创建后 | 全局属性、插件 |
| `onMounted({ app, router })` | 应用挂载后 | 模板中用于 `initTabsManagement(router)` |
| `request`（可选） | request 插件配置 | 若使用 @winner-fed/plugin-request |

---

## 自定义 Router 注意事项

1. **顺序**：在 `src/router/index.js` 中 **先** `Vue.use(Router)`，**再** `const router = new Router({ mode: 'hash', routes })`。顺序反了会导致路由或守卫异常。
2. **守卫注册时机**：不要在 `router.interceptor.js` 顶层直接 `router.beforeEach(...)` 并在 app.js 里仅 `import './router/router.interceptor'`，因为此时 router 可能尚未正确初始化。应改为：在 app.js 的 `onRouterCreated({ router })` 中调用守卫注册函数（如 `setupRouterGuards(router)`），该函数可定义在 router.interceptor.js 中并导出。
3. **Vue 2 动态路由**：使用 `router.addRoutes([...])` 和 `router.options.routes`，不要使用 Vue Router 4 的 `addRoute()` / `getRoutes()`。TabsManagement 的临时路由若调用了 `addRoute`，需改为 `addRoutes([route])`。

---

## index.pro.js（子系统入口）

当项目作为 **HuiPro 子系统** 被主应用加载时，使用 `src/index.pro.js` 作为入口（对应 `win huipro` / `npm run child` 构建）。

| 导出字段 | 说明 |
|----------|------|
| `router` | 路由模块映射，由 `@/utils/...` 与 `.huipro/routesForHui` 生成，供主应用注册子系统路由 |
| `store` | 状态模块（Vuex modules），可挂到主应用 store |
| `utils` | 实例方法 |
| `directives` | 自定义指令 |
| `components` | 全局组件 |
| `uses` | 插件（install） |
| `i18n` | 多语言包（如 `zh-CN`、`zh-TW`、`en-US`），主应用合并后使用 |
| `bootstrap({ store, tabs }, done)` | 引导函数：在子系统组件/语言等资源加载完毕、路由注册**之前**执行；可在此做权限拉取（如 `getUserPermissions(routes)`）；**必须**在结束时调用 `done()`，否则会阻塞路由注册。不建议在 bootstrap 内执行 tab 操作，易导致循环加载 |

多语言配置在 `index.pro.js` 的 `i18n` 中维护；也可通过 `mergeLocaleFromUrl` 等方式合并外部语言包（见文件内注释）。该文件兼容 HuiPro 框架 1.0 的主子系统开发模式。

---

## src/router 约定

| 文件 | 说明 |
|------|------|
| `router/index.js` | 创建并导出 router；先 Vue.use(Router)，再 new Router({ mode, routes, scrollBehavior }) |
| `router/routes.js` | 导出 `routes` 数组，与 Vue Router 3 格式一致（component、path、children、meta、redirect） |
| `router/router.interceptor.js` | 路由守卫；导出函数（如 `setupRouterGuards(router)`），在 app.js 的 onRouterCreated 中调用 |

---

## src/stores、TabsManagement、services

| 路径 | 说明 |
|------|------|
| `stores/index.js` | Vuex store 入口，在 app.js 中通过 modifyClientRenderOpts 传入 |
| `components/TabsManagement/` | 页签管理；useTabsManagement.js、route_guard.js、store/tabs_module.js；临时路由用 router.addRoutes() |
| `services/` | 请求封装（request.js、autoMatchBaseUrl、RESTFULURL）；与 App 模板类似 |
| `utils/` | 工具与权限相关（menuAuth、customerRouter、autoLogin、bizSecurity 等） |

---

## 目录结构速查（src）

| 路径 | 说明 |
|------|------|
| `app.js` | 主应用运行时入口；modifyClientRenderOpts(router, store)、onRouterCreated、onMounted(initTabsManagement) |
| `index.pro.js` | **子系统入口**；`win huipro` / `npm run child` 构建时使用；导出 router、store、i18n、bootstrap 等，见上文「index.pro.js（子系统入口）」 |
| `router/` | 自定义路由（index、routes、router.interceptor） |
| `stores/` | Vuex |
| `layouts/index.vue` | 全局布局 |
| `pages/` | 页面组件，与 router/routes.js 对应 |
| `components/` | 公共组件（含 TabsManagement、CustomLayout、CustomTable 等） |
| `services/`、`utils/` | 请求与工具 |
| `constant.js`、`global.less` | 常量与全局样式 |

---

## 脚本速查

| 脚本        | 命令 | 说明 |
|-----------|------|------|
| 开发        | `npm run dev` | `win dev` |
| 构建        | `npm run build` | `cross-env WIN_APP_ENV=production win build` |
| 构建SEE包    | `npm run build:see` | `npm run build && win see` |
| 预览        | `npm run preview` | `win preview` |
| 子系统构建     | `npm run child` | `win huipro` |
| 子系统构建SEE包 | `npm run build:see:child` | `npm run child && win see --hui-pro` |
| 检查/修复/格式化 | `npm run lint` / `lint:fix` / `format` | Biome |
| F2ELint   | `npm run f2elint-scan` / `f2elint-fix` | 扫描 / 修复 |
| 初始化/清缓存   | `npm run setup` / `win cache` | 项目初始化 / 清除缓存 |

---

## 环境变量（常用）

- **PORT**：开发端口。
- **WIN_APP_ENV**：构建环境（如 production）。
- **NODE_ENV**：development / production。

---

更多通用 WinJS 约定（运行时钩子、useAppData、插件 API）见本技能 [详细用法与规范参考](./usage-reference.md)、[常见问题与排错](./troubleshooting.md) 或 [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)。
