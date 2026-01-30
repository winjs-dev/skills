---
name: winjs-app
description: 基于 WinJS App 模板的移动端 H5 项目开发技能。在用户使用 create-win app 模板创建的项目中进行开发、配置、请求与调试、REM/样式、路由与构建时使用。
license: MIT
---

本技能面向 **App 模板**（移动端 H5）生成的项目，在保持与 WinJS 框架约定一致的前提下，侧重本模板的配置、目录约定、请求与调试、样式与脚本。

**何时使用本技能**：在由 `create-win` 选择 **App** 模板创建的项目中做功能开发、修改 `.winrc`、扩展 `src/app.js`、编写/复用 `services` 请求、配置 REM/VConsole、或排查路由/构建问题时，应优先应用本技能并查阅 References。

本技能及下方 References 随模板下发，创建后的项目可独立使用，无需访问 winjs 仓库。

---

## App 模板概览

- **定位**：移动端 H5 应用；Vue 3 + Vue Router 4，默认 hash 路由。
- **构建**：WinJS 构建链（preset 决定），Less + PostCSS，支持 REM 适配、模块联邦。
- **插件**：`@winner-fed/plugin-request`（请求）、`@winner-fed/plugin-wconsole`（移动端调试 / vConsole）。
- **代码质量**：Biome（lint/format）、StyleLint、F2ELint；Husky + lint-staged + commitlint。

---

## 本模板专用配置（.winrc）

- **history**：默认 `{ type: 'hash' }`，适合 H5 部署。
- **plugins**：模板已包含 `@winner-fed/plugin-request`、`@winner-fed/plugin-wconsole`，勿删；新增插件在此数组追加。
- **appConfig**：多环境运行时配置，注入到 `window.LOCAL_CONFIG`。常用键：`API_HOME`、`API_UPLOAD`、`IS_OPEN_VCONSOLE`。业务通过 `window.LOCAL_CONFIG` 或项目封装的读取方式使用。
- **request** / **wconsole**：分别为 request 插件与 wconsole 插件的配置；wconsole 下可配 vConsole 开关（开发/测试可开，生产建议关）。
- **convertToRem**：开启 REM 适配，按设计稿与预设比例换算；详见官方文档。
- **lessLoader.modifyVars**：模板中通过 `hack` 注入 `@/assets/style/variable.less` 与 `@winner-fed/magicless/magicless.less`，页面与组件可直接使用变量和 mixins。
- **targets**：模板为 `{ ios: 10, android: 6, chrome: 80 }`，按需调整。
- **title**、**mountElementId**：项目名与挂载节点 ID，由脚手架生成。

其余通用项（`alias`、`base`/`publicPath`、`routes`、`mock`、`proxy` 等）见本技能 [详细用法与规范参考](./references/usage-reference.md) 或 [WinJS 官方配置](https://winjs-dev.github.io/winjs-docs/config/config)。

---

## 应用入口 src/app.js

- **request**：导出给 `@winner-fed/plugin-request` 使用。可配置 `timeout`、`requestInterceptors`、`responseInterceptors`；模板中已对接 `services/request.js` 的 `httpRequest`/`httpResponse`，用于统一鉴权、错误处理和日志。
- **router**：可导出 `scrollBehavior` 等，由 renderer 合并到路由选项。
- **onRouterCreated** / **onAppCreated** / **onMounted**：见 [详细用法与规范参考](./references/usage-reference.md)；守卫建议在 `onRouterCreated` 中注册，勿在模块顶层调用尚未创建完成的 router。

修改 `memo` 类钩子（如框架层的 `modifyClientRenderOpts`）必须返回新对象，不直接改入参。

---

## 目录与请求约定（src）

- **layouts**：`layouts/index.vue` 为全局布局，对应约定式路由的 `@@/global-layout`。
- **pages**：约定式路由，目录即路由；新增页面在 `pages` 下新建目录或 `.vue` 即可。
- **assets**：`fonts`、`img`、`style`（如 `variable.less`、`app.less`、`main.less`）；样式通过 `.winrc` 的 `lessLoader.modifyVars` 注入。
- **services**：请求与接口封装。模板提供：
  - `request.js`：封装请求实例、拦截器、错误处理、REST 占位符替换；导出默认函数及 `uploadFile`。
  - `autoMatchBaseUrl.js`：按前缀（如 `constant.js` 中的 `UPLOAD_PREFIX`、`HOME_PREFIX`）返回 `window.LOCAL_CONFIG` 中的 base URL。
  - `constant.js`：统一常量（如 `TIMEOUT`、`PAGE_NUM`、`UPLOAD_PREFIX`、`API_HOME` 前缀键）。
- **constant.js**：根级常量，供 `app.js` 与 `services` 使用。
- **global.less**：全局样式入口。

新增接口或环境时：在 `appConfig` 中增加键，在 `constant.js` 中增加前缀常量（如需），在 `autoMatchBaseUrl.js` 中扩展前缀与 `LOCAL_CONFIG` 的映射。

---

## 脚本与命令

| 命令 | 说明 |
|------|------|
| `win dev` / `npm run dev` | 开发服务器 |
| `win build` / `npm run build` | 生产构建（模板中带 `cross-env WIN_APP_ENV=production`） |
| `win preview` / `npm run preview` | 预览构建结果 |
| `npm run lint` / `lint:fix` | Biome 检查 / 自动修复 |
| `npm run format` | Biome 格式化 |
| `npm run f2elint-scan` / `f2elint-fix` | F2ELint 扫描 / 修复 |
| `win setup` | 项目初始化（如 postinstall） |
| `win cache` | 清缓存 |

---

## 排错提示（App 模板相关）

- **请求 base URL 不对**：检查 `appConfig` 当前环境（development/test/production）的 `API_HOME`/`API_UPLOAD` 及 `autoMatchBaseUrl` 中前缀与常量的对应关系。
- **VConsole 不出现**：确认 `appConfig` 中当前环境的 `IS_OPEN_VCONSOLE` 为 true，且 wconsole 插件已启用。
- **REM 不生效**：确认 `.winrc` 中已开启 `convertToRem`，并检查设计稿与 rootFontSize 等配置。
- **useAppData / getRoute 报错**：必须在组件生命周期或 setup 中调用，勿在模块顶层调用；见本技能 [常见问题与排错](./references/troubleshooting.md)。
- **构建或 HMR 异常**：检查 `.winrc` 语法、依赖版本，执行 `win cache` 后重试。

更多通用排错见本技能 [常见问题与排错](./references/troubleshooting.md) 或 [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)。

---

## References

**本技能下**（随模板下发，创建项目后可独立使用）：

- [App 模板速查](./references/app-reference.md) — 本模板配置项、目录、request/wconsole、环境变量与常量速查。
- [WinJS 详细用法与规范参考](./references/usage-reference.md) — 配置、modifyClientRenderOpts、patchRoutes、运行时钩子、路由、项目结构、环境变量、CLI、Vue 2/3 差异、插件 API 速查、模板差异对照表、.winrc 索引等。
- [WinJS 常见问题与排错](./references/troubleshooting.md) — AppContext、clientRoutes、守卫、动态路由、preview 资源 404、构建与 HMR 等排错清单。
- [WinJS 官方文档索引](./references/docs-index.md) — 官方文档（winjs-docs）主题索引，便于定位到具体文档页面。

**在线**：

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [Request 插件](https://winjs-dev.github.io/winjs-docs/plugins/request)、[wconsole 插件](https://winjs-dev.github.io/winjs-docs/plugins/wconsole)、[REM 配置](https://winjs-dev.github.io/winjs-docs/config/config#converttorem)
