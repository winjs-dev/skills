---
name: winjs-pc
description: 基于 WinJS PC 模板的 PC 端 Web 项目开发技能。在用户使用 create-win pc 模板创建的项目中进行开发、配置、请求、路由与构建时使用。
license: MIT
---

本技能面向 **PC 模板**（PC 端 Web）生成的项目，在保持与 WinJS 框架约定一致的前提下，侧重本模板的配置、请求、路由、Vite 构建与代码规范。

**何时使用本技能**：在由 `create-win` 选择 **PC** 模板创建的项目中做功能开发、修改 `.winrc`、扩展 `src/app.js`、编写/复用 `services` 请求、配置路由或构建、或排查构建问题时，应优先应用本技能并查阅 References。

本技能及下方 References 随模板下发，创建后的项目可独立使用，无需访问 winjs 仓库。

---

## PC 模板概览

- **定位**：PC 端 Web 应用；Vue 3 + Vue Router 4（或 Vue 2.7），非移动端，无 REM/VConsole 默认配置。
- **构建**：WinJS + **Vite**（preset-vue），Less，支持模块联邦、代码分割与构建优化。
- **插件**：`@winner-fed/plugin-request`（请求）；无 wconsole，无 convertToRem。
- **代码质量**：Biome（lint/format）、StyleLint、F2ELint；Husky + lint-staged + commitlint。
- **目标环境**：PC 浏览器（chrome 51+、firefox 54+、safari 10+、edge 15+），非移动端适配。

---

## 本模板专用配置（.winrc）

- **入口**：项目根目录 `.winrc.ts`（或 `.winrc.js`）。
- **plugins**：模板仅包含 `@winner-fed/plugin-request`；无 wconsole，新增插件在此数组追加。
- **appConfig**：多环境运行时配置，注入到 `window.LOCAL_CONFIG`；常用键 `API_HOME`、`API_UPLOAD`（无 `IS_OPEN_VCONSOLE`）。
- **request**：request 插件配置，具体在 `src/app.js` 中导出 `request`。
- **history**：未在模板中显式配置时，由 preset 决定（常为 browser 或 hash）；按部署方式在 `.winrc` 中可配置 `history: { type: 'browser' | 'hash' }`。
- **lessLoader.modifyVars**：注入 `@/assets/style/variable.less` 与 `@winner-fed/magicless/magicless.less`。
- **targets**：模板为 `{ chrome: 51, firefox: 54, safari: 10, edge: 15 }`，面向 PC 浏览器。
- **jsMinifier** / **cssMinifier**：模板为 terser、cssnano。
- **title**、**mountElementId**：项目名与挂载节点 ID，由脚手架生成。

本模板**不包含** convertToRem、wconsole；若需 REM 或移动端调试，需自行在 `.winrc` 与依赖中增加。其余通用项见本技能 [详细用法与规范参考](./references/usage-reference.md) 或 [WinJS 官方配置](https://winjs-dev.github.io/winjs-docs/config/config)。

---

## 应用入口 src/app.js

- **request**：导出给 `@winner-fed/plugin-request` 使用；可配置 `timeout`、`requestInterceptors`、`responseInterceptors`，模板已对接 `services/request.js` 的 `httpRequest`/`httpResponse`。
- **router**：可导出 `scrollBehavior` 等，由 renderer 合并到路由选项。
- **onRouterCreated** / **onAppCreated** / **onMounted**：见 [详细用法与规范参考](./references/usage-reference.md)；守卫建议在 `onRouterCreated` 中注册。

修改 `memo` 类钩子（如 `modifyClientRenderOpts`）必须返回新对象，不直接改入参。

---

## 目录与请求约定（src）

- **layouts**：`layouts/index.vue` 为全局布局。
- **pages**：约定式路由，目录即路由；新增页面在 `pages` 下新建目录或 `.vue`。
- **assets**：`fonts`、`img`、`style`（variable.less、app.less、main.less）；样式通过 `.winrc` 的 `lessLoader.modifyVars` 注入。
- **services**：请求封装；`request.js`、`autoMatchBaseUrl.js`、`constant.js`、`RESTFULURL.js` 与 App 模板类似。
- **constant.js**、**global.less**：根级常量与全局样式。

---

## 脚本与命令

| 命令 | 说明 |
|------|------|
| `win dev` / `npm run dev` | 开发服务器（Vite） |
| `win build` / `npm run build` | 生产构建（模板中带 `cross-env WIN_APP_ENV=production`） |
| `win preview` / `npm run preview` | 预览构建结果 |
| `npm run lint` / `lint:fix` | Biome 检查 / 自动修复 |
| `npm run format` | Biome 格式化 |
| `npm run f2elint-scan` / `f2elint-fix` | F2ELint 扫描 / 修复 |
| `win setup` | 项目初始化 |
| `win cache` | 清缓存 |

---

## 排错提示（PC 相关）

- **请求 base URL 不对**：检查 `appConfig` 当前环境的 `API_HOME`/`API_UPLOAD` 及 `services/autoMatchBaseUrl.js` 中前缀与常量的对应关系。
- **useAppData / getRoute 报错**：必须在组件生命周期或 setup 中调用，勿在模块顶层；见本技能 [常见问题与排错](./references/troubleshooting.md)。
- **构建或 HMR 异常**：检查 `.winrc` 语法、依赖版本，执行 `win cache` 后重试；PC 模板使用 Vite，与 webpack 项目排错略有不同。

更多通用排错见本技能 [常见问题与排错](./references/troubleshooting.md) 或 [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)。

---

## References

**本技能下**（随模板下发，创建项目后可独立使用）：

- [PC 模板速查](./references/app-reference.md) — 本模板配置项、目录、request、脚本与 Vite 说明。
- [WinJS 详细用法与规范参考](./references/usage-reference.md) — 配置、运行时钩子、路由、环境变量、CLI、Vue 2/3 差异、插件 API、.winrc 索引等。
- [WinJS 常见问题与排错](./references/troubleshooting.md) — AppContext、守卫、preview 404、构建与 HMR 等。
- [WinJS 官方文档索引](./references/docs-index.md) — 官方文档主题索引。

**在线**：

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [Request 插件](https://winjs-dev.github.io/winjs-docs/plugins/request)、[Vite 指南](https://winjs-dev.github.io/winjs-docs/guides/vite)
- 项目根 [README.md](../../../../README.md) — PC 模板结构、模块联邦与开发说明（从本技能目录回退到项目根）。
