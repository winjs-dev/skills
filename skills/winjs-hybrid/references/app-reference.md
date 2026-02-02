# Hybrid 模板速查

本文档为 winjs-hybrid 技能的补充参考，仅针对 create-win **Hybrid** 模板生成的项目，做配置、app.js（render、原生桥接、路由守卫）、离线包与脚本速查。

---

## .winrc 本模板常用配置项

| 配置项 | 说明 | 模板默认/说明 |
|--------|------|----------------|
| `history.type` | 路由模式 | `'hash'`，适合 WebView |
| `plugins` | 插件列表 | 含 `@winner-fed/plugin-request`、`@winner-fed/plugin-wconsole` |
| `request` | request 插件配置 | `{}`，具体在 `src/app.js` 中导出 `request` |
| `wconsole` | wconsole 插件配置 | `{ vconsole: {} }`，开关由 `appConfig` 各环境 `IS_OPEN_VCONSOLE` 控制 |
| `appConfig` | 多环境运行时配置 | `development` / `test` / `production`，注入到 `window.LOCAL_CONFIG` |
| `convertToRem` | REM 适配 | `{}` 即开启 |
| `lessLoader.modifyVars` | Less 全局变量/混入 | 注入 `@/assets/style/variable.less` 与 magicless |
| `targets` | 浏览器/端兼容 | `{ ios: 10, android: 6, chrome: 80 }` |
| `publicPath` | 部署基础路径 | 开发 `/`，生产 `./` |
| `title`、`mountElementId` | 页面标题与挂载节点 ID | 由脚手架生成 |

---

## appConfig 与 window.LOCAL_CONFIG

- **配置位置**：`.winrc` 的 `appConfig.development` / `appConfig.test` / `appConfig.production`。
- **本模板常用键**：`API_HOME`、`API_UPLOAD`、`IS_OPEN_VCONSOLE`。
- **使用**：在 `services/autoMatchBaseUrl.js` 中根据前缀返回 base URL；业务勿在模块顶层依赖未注入的 config。

---

## src/app.js 导出约定

| 导出 | 说明 | 备注 |
|------|------|------|
| `render(oldRender)` | ** Hybrid 特有**：覆盖渲染时机 | 原生壳内先 `gmuJSAPI.nativeReady({ complete() { oldRender(); } })`，非原生直接 `oldRender()` |
| `request` | request 插件配置 | timeout、requestInterceptors、responseInterceptors，已对接 services/request.js |
| `onRouterCreated({ router })` | 路由实例创建后 | 模板中：`from.name && gmuJSAPI.isAppOS()` 时用 `gmuJSAPI.navigateTo` 做 WebView 跳转，否则 `next()` |
| `onAppCreated` | 应用实例创建后 | 全局属性、插件 |
| `onMounted` | 应用挂载后 | 依赖 DOM 的初始化 |

---

## 原生桥接（GmuJSAPI / Light SDK）

- **GmuJSAPI**（`@winner-fed/harmony-jsapi`）：模板中用于鸿蒙/券商桥接。
  - `gmuJSAPI.isAppOS()`：是否在原生壳内。
  - `gmuJSAPI.nativeReady({ complete })`：原生就绪后执行 `complete()`，在 `render(oldRender)` 中用于延迟 `oldRender()`。
  - `gmuJSAPI.navigateTo({ url, options })`：以 WebView 方式打开新页；url 一般为当前 origin + hash + 目标 path，options 如 navBarType、navBarStyle、statusBarStyle、webCacheEnabled 等（见模板注释与宿主文档）。
- **Light SDK**（`light-sdk`）：挂载到 `window.LightSDK`，供业务按需调用；轻量级移动端能力。
- 对接不同券商或宿主时，可替换/封装桥接实例，保持 `render` 与 `onRouterCreated` 的调用约定。

---

## 离线包配置（offlinePackage.json）

可选文件，用于声明离线包与宿主 APP 版本依赖：

| 字段 | 说明 |
|------|------|
| `id` | 离线包 ID |
| `name` | 离线包名称 |
| `appVersion` | 依赖的宿主版本：`{ ios: "6.0.0.0", android: "6.0.0.0" }`，可为具体版本或区间（如 `0.0.0.0~9.9.9.9`） |

构建或集成时由工具链读取，具体以项目使用的离线包方案为准。

---

## src/services 与目录约定

与 App 模板类似：

| 文件/导出 | 说明 |
|-----------|------|
| `constant.js` | TIMEOUT、PAGE_NUM、UPLOAD_PREFIX、HOME_PREFIX 等 |
| `autoMatchBaseUrl(prefix)` | 根据 prefix 返回 `window.LOCAL_CONFIG` 中的 API_UPLOAD 或 API_HOME |
| `request.js` | 默认导出封装请求；httpRequest/httpResponse 供 app.js 拦截器使用；uploadFile 上传 |

目录：`app.js`、`constant.js`、`global.less`、`assets/`、`layouts/`、`pages/`、`services/`、`icons/`。

---

## 脚本速查

| 脚本 | 命令 | 说明 |
|------|------|------|
| 开发 | `npm run dev` | `win dev` |
| 构建 | `npm run build` | `cross-env WIN_APP_ENV=production win build` |
| 预览 | `npm run preview` | `win preview` |
| 检查/修复/格式化 | `npm run lint` / `lint:fix` / `format` | Biome |
| F2ELint | `npm run f2elint-scan` / `f2elint-fix` | 扫描 / 修复 |
| 初始化/清缓存 | `npm run setup` / `win cache` | 项目初始化 / 清除缓存 |

---

## 环境变量（常用）

- **PORT**：开发端口。
- **WIN_APP_ENV**：构建环境（如 production）。
- **NODE_ENV**：development / production。

---

更多通用 WinJS 约定（运行时钩子、useAppData、插件 API）见本技能 [详细用法与规范参考](./usage-reference.md)、[常见问题与排错](./troubleshooting.md) 或 [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)。
