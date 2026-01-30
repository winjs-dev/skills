---
name: winjs-hybrid
description: 基于 WinJS Hybrid 模板的混合式移动应用开发技能。在用户使用 create-win hybrid 模板创建的项目中进行开发、配置、原生桥接、REM/VConsole、鸿蒙/Light SDK 与构建时使用。
license: MIT
---
本技能面向 **Hybrid 模板**（混合式移动应用）生成的项目，在保持与 WinJS 框架约定一致的前提下，侧重本模板的配置、原生桥接（Harmony/统一桥接库、Light SDK）、render 与路由守卫、REM/VConsole 与脚本。

**何时使用本技能**：在由 `create-win` 选择 **Hybrid** 模板创建的项目中做功能开发、修改 `.winrc`、扩展 `src/app.js`、对接 GmuJSAPI/Light SDK、配置 REM/VConsole、或排查渲染/路由/构建问题时，应优先应用本技能并查阅 References。

本技能及下方 References 随模板下发，创建后的项目可独立使用，无需访问 winjs 仓库。

---

## Hybrid 模板概览

- **定位**：混合式移动应用；Vue 3 + Vue Router 4（或 Vue 2.7），默认 hash 路由，运行在 WebView/原生壳中。
- **构建**：WinJS + Vite（preset-vue），Less + PostCSS，支持 REM 适配。
- **插件**：`@winner-fed/plugin-request`（请求）、`@winner-fed/plugin-wconsole`（移动端调试 / vConsole）。
- **原生桥接**：**Harmony JSApi**（`@winner-fed/harmony-jsapi`，如 GmuJSAPI）、**Light SDK**（`light-sdk`，挂载到 `window.LightSDK`）；用于原生 ready、WebView 跳转（navigateTo）等。
- **app.js 特色**：`render(oldRender)` 中在原生环境等待 `gmuJSAPI.nativeReady()` 后再执行 `oldRender()`；`onRouterCreated` 中可根据 `gmuJSAPI.isAppOS()` 用 `navigateTo` 做 WebView 容器内跳转。
- **代码质量**：Biome、StyleLint、F2ELint；Husky + lint-staged + commitlint。
- **离线包**：可选 `offlinePackage.json` 配置离线包 id、name、appVersion（ios/android），用于依赖宿主 APP 版本。

---

## 本模板专用配置（.winrc）

- **入口**：项目根目录 `.winrc.ts`（或 `.winrc.js`），与 App 模板类似。
- **history**：默认 `{ type: 'hash' }`，适合 H5/WebView 部署。
- **plugins**：含 `@winner-fed/plugin-request`、`@winner-fed/plugin-wconsole`；新增插件在此数组追加。
- **appConfig**：多环境配置，注入到 `window.LOCAL_CONFIG`；常用键 `API_HOME`、`API_UPLOAD`、`IS_OPEN_VCONSOLE`。
- **request** / **wconsole**：request 与 wconsole 插件配置；vConsole 开关由 `appConfig` 各环境 `IS_OPEN_VCONSOLE` 控制。
- **convertToRem**：开启 REM 适配。
- **lessLoader.modifyVars**：注入 `@/assets/style/variable.less` 与 `@winner-fed/magicless/magicless.less`。
- **targets**：模板为 `{ ios: 10, android: 6, chrome: 80 }`。
- **publicPath**：开发 `/`，生产 `./`。

其余通用项见本技能 [详细用法与规范参考](./references/usage-reference.md) 或 [WinJS 官方配置](https://winjs-dev.github.io/winjs-docs/config/config)。

---

## 应用入口 src/app.js

- **render(oldRender)**：**本模板特有**。在原生壳内（`gmuJSAPI.isAppOS()`）时，先执行 `gmuJSAPI.nativeReady({ complete() { oldRender(); } })`，待原生就绪后再调用 `oldRender()`；非原生环境直接 `oldRender()`。确保页面在原生桥接就绪后再渲染，避免调用原生 API 时报错。
- **request**：导出给 request 插件；可配置 `timeout`、`requestInterceptors`、`responseInterceptors`，模板已对接 `services/request.js` 的 `httpRequest`/`httpResponse`。
- **onRouterCreated({ router })**：模板中注册 `router.beforeEach`：当 `from.name && gmuJSAPI.isAppOS()` 时，通过 `gmuJSAPI.navigateTo` 以 WebView 方式打开目标页；否则 `next()`。可根据业务调整是否全部走原生跳转或仅部分路由。
- **onAppCreated** / **onMounted**：与通用约定一致；可在此挂载全局属性或访问 `window.LightSDK` 等。

**GmuJSAPI / Light SDK**：模板中 `GmuJSAPI` 用于鸿蒙/券商桥接（nativeReady、isAppOS、navigateTo）；`LightSDK` 挂到 `window.LightSDK` 供业务按需使用。对接不同券商或宿主时，可替换或扩展桥接实例。

---

## 目录与请求约定（src）

- **layouts**：`layouts/index.vue` 为全局布局。
- **pages**：约定式路由，目录即路由；新增页面在 `pages` 下新建目录或 `.vue`。
- **assets**：`fonts`、`img`、`style`（variable.less、app.less、main.less）；样式通过 `.winrc` 的 `lessLoader.modifyVars` 注入。
- **services**：请求封装；`request.js`、`autoMatchBaseUrl.js`、`constant.js`、`RESTFULURL.js` 与 App 模板类似，供 request 插件与业务调用。
- **constant.js**、**global.less**：根级常量与全局样式。

---

## 脚本与命令

| 命令                                       | 说明                                                      |
| ------------------------------------------ | --------------------------------------------------------- |
| `win dev` / `npm run dev`              | 开发服务器                                                |
| `win build` / `npm run build`          | 生产构建（模板中带 `cross-env WIN_APP_ENV=production`） |
| `win preview` / `npm run preview`      | 预览构建结果                                              |
| `npm run lint` / `lint:fix`            | Biome 检查 / 自动修复                                     |
| `npm run format`                         | Biome 格式化                                              |
| `npm run f2elint-scan` / `f2elint-fix` | F2ELint 扫描 / 修复                                       |
| `win setup`                              | 项目初始化                                                |
| `win cache`                              | 清缓存                                                    |

---

## 排错提示（Hybrid 相关）

- **页面不渲染 / 白屏**：检查 `render(oldRender)` 是否在原生环境下正确调用了 `gmuJSAPI.nativeReady` 的 `complete` 回调并执行 `oldRender()`；非原生环境应直接 `oldRender()`。
- **原生 API 报错 / 未就绪**：确认在调用 GmuJSAPI/Light SDK 前已执行 `nativeReady` 或宿主已注入相应桥接。
- **路由跳转异常**：若使用模板的 `onRouterCreated` 逻辑，确认 `gmuJSAPI.isAppOS()` 与 `navigateTo` 的 url/options 符合宿主约定；需纯 H5 跳转时可改为直接 `next()`。
- **请求 base URL 不对**：检查 `appConfig` 当前环境的 `API_HOME`/`API_UPLOAD` 及 `services/autoMatchBaseUrl.js`。
- **VConsole 不出现**：确认 `appConfig` 中当前环境 `IS_OPEN_VCONSOLE` 为 true，且 wconsole 插件已启用。
- **useAppData / getRoute 报错**：必须在组件生命周期或 setup 中调用；见本技能 [常见问题与排错](./references/troubleshooting.md)。

更多通用排错见本技能 [常见问题与排错](./references/troubleshooting.md) 或 [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)。

---

## References

**本技能下**（随模板下发，创建项目后可独立使用）：

- [Hybrid 模板速查](./references/app-reference.md) — 本模板配置、app.js（render、GmuJSAPI、navigateTo）、离线包、脚本速查。
- [WinJS 详细用法与规范参考](./references/usage-reference.md) — 配置、运行时钩子、路由、环境变量、CLI、Vue 2/3 差异、插件 API、.winrc 索引等。
- [WinJS 常见问题与排错](./references/troubleshooting.md) — AppContext、守卫、preview 404、构建与 HMR 等。
- [WinJS 官方文档索引](./references/docs-index.md) — 官方文档主题索引。

**在线**：

- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [Request 插件](https://winjs-dev.github.io/winjs-docs/plugins/request)、[wconsole 插件](https://winjs-dev.github.io/winjs-docs/plugins/wconsole)、[REM 配置](https://winjs-dev.github.io/winjs-docs/config/config#converttorem)
- 项目根 [README.md](../../../../README.md) — 混合应用特性、鸿蒙/Light SDK 说明（从本技能目录回退到项目根）。
