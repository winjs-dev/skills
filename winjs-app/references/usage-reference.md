# WinJS 详细用法与规范参考

本文档为 WinJS 框架的详细用法与规范参考，结合 [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)（winjs-docs）整理，包含配置、运行时钩子、路由、项目结构、环境变量、CLI 与 Vue 版本差异等。随 winjs-app 技能一并下发，供创建后的项目独立查阅。

---

## 配置文件位置与优先级

- **配置文件**：项目根目录 `.winrc.ts`（或 `.winrc.js`）与 `config/config.ts` 功能相同，**二选一**；`.winrc.ts` 优先级更高。
- **执行环境**：配置在 Node 侧执行（CLI / 构建时），不会被打包到浏览器；浏览器侧需要的“运行时配置”在 `src/app.js` 中通过导出钩子注册。
- **defineConfig**：使用 `defineConfig` 包裹可获得更好的类型提示；也可直接 `export default {}`。

---

## modifyClientRenderOpts 详细用法

**调用时机**：在 `renderClient` 执行前，由插件系统对上下文做最后一次合并；多个插件会按顺序依次 modify，最终传入 `renderClient`。

**参数 `memo` 结构**（与 render 上下文一致）：

- `routes`、`routeComponents`：当前路由与组件映射
- `pluginManager`、`rootElement`、`publicPath`、`runtimePublicPath`
- `history`、`historyType`、`basename`
- `callback`：旧版用于返回 `{ store, pinia }`，仍兼容；优先使用直接传 `store` / `pinia`

**可安全传入的字段**（会覆盖或合并到最终 context）：

- `router`：自定义 Vue Router 实例（Vue 2/3 皆可）；传入后 `clientRoutes` 取自 `router.options.routes`
- `store`：Vuex store 实例（Vue 2）
- `pinia`：Pinia 实例（Vue 2.7+ / Vue 3）

**规范**：

- 必须返回新对象，例如 `return { ...memo, router: customRouter }`，禁止直接修改 `memo` 后返回。
- 未传入的字段不要写 `undefined`，不传即可；框架会做“未传入”的兼容，避免把 `undefined` 传给 Vue 构造函数。

---

## patchRoutes 详细用法

**类型**：`ApplyPluginsType.event`，非 modify；插件只接收参数，不返回值。

**参数**：`args` 为 `{ routes, routeComponents }`：

- `routes`：键为 route id 的对象（如 `{ '1': { path: '/', ... }, '@@/global-layout': { ... } }`）
- `routeComponents`：键为 route id，值为动态 import 函数（如 `() => import('@/pages/xxx.vue')`）

**用途**：在路由已从 `.win/core/route.tsx` 生成、尚未交给 render 前，增删或改写路由及对应组件。

**规范**：

- 直接修改传入的 `routes` / `routeComponents` 对象即可，无需 return。
- 新增路由时要同时维护 `routes` 与 `routeComponents`，且 id 与 layout 的 parentId 对应关系要正确。
- 不要在此钩子里依赖尚未就绪的 Vue 实例或 DOM。

---

## 其他运行时钩子（app.js）

| 钩子 | 说明 | 典型用途 |
|------|------|----------|
| `onRouterCreated({ router })` | 路由实例创建后、挂载到 app 前 | 注册 `router.beforeEach`、`router.afterEach` 等全局守卫 |
| `onAppCreated({ app })` | Vue 应用实例创建后 | 挂载全局属性、`app.provide`、注册全局组件 |
| `onMounted({ app, router })` | 应用挂载到 DOM 后 | 依赖 DOM 的初始化、全局组件注册、再次访问 router |
| `modifyContextOpts(memo)` | 修改渲染上下文 | 动态 basename、historyOpts、rootElement 等 |
| `rootContainer(lastRootContainer, args)` | 修改根组件 | 包裹 ThemeProvider、多语言 Provider 等 |
| `render(oldRender)` | 覆盖渲染方法 | 权限校验后再执行 `oldRender()` |

**规范**：`onRouterCreated` 中注册守卫时，确保 `Vue.use(Router)` 已在创建 router 之前执行；若守卫逻辑在单独文件，应导出函数并在 `onRouterCreated` 中调用，避免在模块顶层对尚未创建完成的 router 调用 `beforeEach`。

---

## 路由 path 支持与不支持形式

**支持**的 path 形式（官方文档 routes 约定）：

- `/groups`、`/groups/admin`（静态与嵌套）
- `/users/:id`、`/users/:id/messages`（动态参数）
- `/files/*`、`/files/:id/*`（通配符 `*` 仅出现在末尾）

**不支持**的形式示例：

- `/users/:id?`（可选参数）
- `/tweets/:id(\d+)`（正则）
- `/files/*/cat.jpg`（`*` 非末尾）
- `/files-*`（`*` 非独立段）

约定式路由由 `src/pages` 目录推导，动态段以 preset 实现为准（如 `$id`、`$slug`）。

---

## 项目结构约定

- **页面**：`src/pages/` 下文件与约定式路由一一对应；目录即嵌套路由（如 `pages/list/foo.vue` → `/list/foo`）。
- **布局**：`src/layouts/index.vue` 为全局布局，对应 `@@/global-layout`；可在路由配置中指定其他 layout。
- **应用入口**：`src/app.js` 或 `src/app.ts` 为运行时插件入口；仅此文件（或通过 preset 注册的路径）会作为 app 插件参与 `createPluginManager`。
- **临时目录**：默认 `src/.win`（开发）或 `src/.win-production`（生产）；`tmpDir` 可在配置中改，业务代码不要引用 `.win` 内路径。
- **根目录**：`.env` / `.env.local` 环境变量；`package.json` 中以 `@winner-fed/preset-`、`@winner-fed/plugin-`、`win-preset-`、`win-plugin-` 开头的依赖不会自动注册为插件/预设，需在 `.winrc` 的 `plugins` / `presets` 中显式配置。
- **public**：静态资源，构建时拷贝到输出目录；勿放需要构建处理的脚本。

---

## 环境变量与 appConfig

**常用环境变量**（官方文档 env-variables）：

- **PORT**：开发服务器端口，如 `PORT=3000 win dev`。
- **WIN_ENV** / **WIN_APP_ENV**：区分环境（如 dev / test / pre / production），用于多环境构建与配置分支。
- **NODE_ENV**：`development` | `production`，由框架与构建工具使用。
- **COMPRESS**、**BABEL_CACHE**、**ANALYZE** 等：构建与调试相关，见官方文档。

**设置方式**：执行命令时传入（如 `cross-env WIN_ENV=test win dev`）、或写在项目根目录 `.env`、`.env.local`（本地覆盖 `.env`）。跨平台推荐使用 `cross-env`。

**appConfig**：在 `.winrc` 中配置 `appConfig.development` / `appConfig.test` / `appConfig.production`，运行时通过生成的 `config.local.js` 或框架提供的方式读取；默认挂载到 `window.LOCAL_CONFIG`（可配置 `appConfig.globalName`）。不要在模块顶层依赖未注入的 config。

---

## CLI 命令摘要

| 命令 | 说明 |
|------|------|
| `win dev` | 启动开发服务器 |
| `win build` | 生产构建 |
| `win preview` | 本地预览构建结果（支持 `--dir`、`--prefix`、`--port`、`--host`） |
| `win config list/get/set/remove` | 查看或修改配置 |
| `win generate` / `win g` | 生成代码片段 |
| `win setup` | 项目初始化（如 postinstall 时调用） |
| `win cache` | 清除缓存（如 `node_modules/.cache`） |
| `win info` | 打印环境与调试信息 |
| `win help` / `win help <command>` | 查看命令列表或单命令帮助 |

更多命令与选项见官方文档 [CLI 命令](https://winjs-dev.github.io/winjs-docs/cli/commands)。

---

## 脚手架模板差异对照表

`create-win`（`npm create win@latest` 或 `create-win <项目名>`）提供的模板及差异概览：

| 模板 | 适用场景 | Vue / Router | 构建工具 | 技术栈与特性摘要 |
|------|----------|--------------|----------|------------------|
| **App** | 移动端 H5 | Vue 3 + Router 4 | WinJS 构建链 | Less、PostCSS、REM 适配、VConsole、模块联邦 |
| **HuiPro** | 企业级后台 | Vue 2 + Router 3 | Webpack | HUI 组件库、主子系统、权限/菜单/路由、国际化、标签页 |
| **PC** | PC 端 Web | Vue 3 + Router 4 | Vite | TypeScript、Less、Biome/StyleLint/F2ELint、模块联邦 |
| **Hybrid** | 混合移动应用 | Vue 3 + Router 4 | Vite | REM、VConsole、鸿蒙/Harmony、Light SDK |
| **Sample** | 学习与快速原型 | Vue 3 | 最小配置 | 约定式路由、最小依赖、无 Husky/commitlint |
| **Plugin** | WinJS 插件开发 | — | — | TypeScript、插件 API、测试与文档模板，非应用项目 |

各模板由 create-win 提供（如 App、PC、HuiPro、Hybrid、Sample、Plugin）。创建时可选包管理器（npm/yarn/pnpm/bun）、是否初始化 Git、是否安装依赖、是否启用 Husky 等。

---

## Vue 2 与 Vue 3 差异对照

| 能力 | Vue 2 | Vue 3 |
|------|--------|--------|
| Preset | `@winner-fed/preset-vue2` | `@winner-fed/preset-vue` |
| Renderer | `renderer-vue2` | `renderer-vue` |
| Vue Router | 3.x：`addRoutes()`、`router.options.routes` | 4.x：`addRoute()`、`getRoutes()` |
| 状态管理 | Vuex（`store`）或 Pinia（2.7+） | Pinia 或 Vuex（兼容） |
| useAppData 注入方式 | `Vue.prototype[AppContextKey]` | `app.provide(AppContextKey, ...)` |

写与路由或渲染相关的通用逻辑时，需按 Vue 版本分支或做能力检测，避免混用 3.x/4.x 专属 API。

---

## 插件与 Preset 约定

- **Plugin**：单能力扩展，在 `.winrc` 的 `plugins` 中声明；可提供运行时钩子（如 `modifyClientRenderOpts`、`onRouterCreated`）或构建时 API（如 `api.modifyConfig`）。
- **Preset**：一组插件与默认配置的集合，在 `presets` 中声明，决定框架能力（如 Vue 2/3、构建工具）；通常包含 renderer、路由生成、babel 等。
- 业务项目只配置 `presets` + `plugins`，不要直接改 preset 内部包代码；需要新能力时优先考虑新增 plugin 或扩展现有 plugin。

---

## 插件 API 速查

面向 **构建时插件**（preset/plugin 包内）的 `api` 常用方法；运行时钩子见上文「modifyClientRenderOpts、patchRoutes、其他运行时钩子」。

| API | 说明 | 典型用法 |
|-----|------|----------|
| `api.describe(opts)` | 描述插件：`key`、`config`、`enableBy`（如 `api.EnableBy.register` / `api.EnableBy.config`） | 插件入口内声明启用方式与配置项 |
| `api.register({ key, fn, stage?, before? })` | 注册钩子，供 `applyPlugins` 调用 | 与 `applyPlugins` 的 `key` 对应；`fn` 签名依 type 不同 |
| `api.applyPlugins(opts)` | 执行已注册的钩子；`opts`: `key`, `type?`, `initialValue?`, `args?`, `sync?` | 触发 event / 串行 modify / 串行 add 收集 |
| `api.registerCommand(opts)` | 注册 CLI 命令：`name`、`description`、`fn`、可选 `alias` | 如 `win demo` 对应 `name: 'demo'` |
| `api.registerMethod({ name, fn? })` | 注册“方法名”，其他插件可对该 key 再 `api.register` 或直接调用 | 定义可扩展的插件方法 |
| `api.registerPresets` / `api.registerPlugins` | 在 preset 内动态注册子 preset / 插件 | 仅在各 preset/plugin 的注册阶段使用 |

**ApplyPluginsType**（`api.ApplyPluginsType`）：

- **event**：无返回值，按顺序执行；`fn(args)`；若 `sync: true` 则同步执行。
- **modify**：串行瀑布，上一棒返回值作为下一棒 `memo`；`fn(memo, args)`，需返回新值；可传 `initialValue`。
- **add**：串行合并，`initialValue` 须为数组，各 hook 返回项拼到数组；`fn(args)` 返回要追加的项（数组）。

未传 `type` 时会按 `key` 前缀推断：`on*` → event，`modify*` → modify，`add*` → add；否则必须显式传 `type`。

详见官方 [插件 API](https://winjs-dev.github.io/winjs-docs/api/plugin-api)。

---

## 路由配置项（name、alias、redirect、wrappers）

- **name**：命名路由，便于 `router.push({ name: 'user', params: { id } })` 与 `<router-link :to="{ name: 'user' }">`。
- **alias**：别名，访问 alias 路径时 URL 不变、匹配到该路由；可数组多别名；嵌套时 alias 以 `/` 开头表示绝对路径。
- **redirect**：重定向，访问该 path 时跳转到目标 path 或 `{ name }`。
- **wrappers**：包装路由，先渲染 wrappers 中的布局/高阶组件，再渲染 component；用于权限、布局嵌套等。
- **routes**（嵌套）：子路由数组，与 Vue Router 的 children 对应。
- 详见官方 [路由指南](https://winjs-dev.github.io/winjs-docs/guides/routes)。

---

## Mock 与 Proxy

- **mock**：在 `.winrc` 中配置 `mock`，或使用 `mock/` 目录；开发时拦截匹配的请求并返回 mock 数据；生产构建不包含 mock。详见 [Mock 指南](https://winjs-dev.github.io/winjs-docs/guides/mock)。
- **proxy**：在 `.winrc` 中配置 `proxy`，将指定路径代理到后端地址；仅开发环境生效。详见 [代理指南](https://winjs-dev.github.io/winjs-docs/guides/proxy)。

---

## .winrc 常用配置项索引

| 配置项 | 说明 | 文档 |
|--------|------|------|
| `alias` | 导入路径别名 | config#alias |
| `base` / `publicPath` | 部署基础路径 | config#base, config#publicPath |
| `outputPath` | 构建输出目录 | config#outputPath |
| `routes` | 路由配置数组 | config#routes, guides/routes |
| `history` | 路由模式 browser/hash | config#history |
| `appConfig` | 多环境运行时配置 | config#appConfig |
| `mock` | Mock 配置 | config#mock, guides/mock |
| `proxy` | 开发代理 | config#proxy, guides/proxy |
| `plugins` | 插件列表 | config#plugins |
| `presets` | 预设列表 | config#presets |
| `vite` / `rsbuild` | 构建工具配置 | guides/vite, guides/rsbuild |

完整配置项见官方 [配置文档](https://winjs-dev.github.io/winjs-docs/config/config)（按字母序）。

---

## 文件与路由命名约定

- **约定式路由 path**：由 `src/pages` 的文件路径推导；`index.vue` 对应目录 path，其余文件对应同名 path。
- **动态段**：目录或文件名使用 `$id`、`$slug` 等形式（以 preset 实现为准），会生成为路由参数。
- **404**：由框架或 404 插件注册 `path: '*'` 或等价匹配；勿与业务路由冲突。

---

## 其他规范摘要

- **导入 winjs**：从 `winjs` 或 `winjs/xxx` 引用框架导出（如 `useAppData`、`getRoute`），不要从 `.win/` 内部路径引用。
- **SSR**：启用 SSR 时会有 `win.server.ts` 等生成文件，上下文与客户端略有不同，钩子内避免假定仅运行在浏览器。
- **构建工具**：同一项目只启用一种主构建工具（webpack / vite / rsbuild）；通过 preset 选择，不要在配置中混用多套 entry 或 dev server。
