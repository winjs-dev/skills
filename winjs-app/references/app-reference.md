# App 模板速查

本文档为 winjs-app 技能的补充参考，仅针对 create-win **App** 模板生成的项目，做配置、目录、请求与环境速查。

---

## .winrc 本模板常用配置项

| 配置项 | 说明 | 模板默认/说明 |
|--------|------|----------------|
| `history.type` | 路由模式 | `'hash'`，适合 H5 |
| `plugins` | 插件列表 | 含 `@winner-fed/plugin-request`、`@winner-fed/plugin-wconsole` |
| `request` | request 插件配置 | `{}`，具体在 `src/app.js` 中通过导出 `request` 配置 |
| `wconsole` | wconsole 插件配置 | `{ vconsole: {} }`，vConsole 开关由 `appConfig` 各环境 `IS_OPEN_VCONSOLE` 控制 |
| `appConfig` | 多环境运行时配置 | `development` / `test` / `production`，注入到 `window.LOCAL_CONFIG` |
| `convertToRem` | REM 适配 | `{}` 即开启 |
| `lessLoader.modifyVars` | Less 全局变量/混入 | 注入 `@/assets/style/variable.less` 与 magicless |
| `targets` | 浏览器兼容 | `{ ios: 10, android: 6, chrome: 80 }` |
| `title` | 页面标题 | 项目名 |
| `mountElementId` | 挂载节点 ID | 由脚手架生成 |
| `alias` | 路径别名 | 常用 `@` → `src` |
| `base` / `publicPath` | 部署基础路径 | 按部署环境配置 |
| `mock` / `proxy` | Mock 与代理 | 仅开发环境生效，见官方文档 |

---

## appConfig 与 window.LOCAL_CONFIG

- **配置位置**：`.winrc` 的 `appConfig.development` / `appConfig.test` / `appConfig.production`。
- **注入方式**：构建后生成 `config.local.js`，挂载到 `window.LOCAL_CONFIG`（或配置的 `appConfig.globalName`）。
- **本模板常用键**：`API_HOME`、`API_UPLOAD`、`IS_OPEN_VCONSOLE`。
- **使用**：在 `services/autoMatchBaseUrl.js` 中根据前缀返回对应 base URL；业务代码勿在模块顶层依赖未注入的 config。

---

## src/app.js 导出约定

| 导出 | 说明 | 备注 |
|------|------|------|
| `request` | request 插件配置 | `timeout`、`requestInterceptors`、`responseInterceptors`，模板已对接 `services/request.js` |
| `router` | 路由选项 | 如 `scrollBehavior` |
| `onRouterCreated` | 路由实例创建后 | 注册守卫等 |
| `onAppCreated` | 应用实例创建后 | 全局属性、插件 |
| `onMounted` | 应用挂载后 | 依赖 DOM 的初始化 |

---

## src/services 约定

| 文件/导出 | 说明 |
|-----------|------|
| `constant.js` | `TIMEOUT`、`PAGE_NUM`、`UPLOAD_PREFIX`、`HOME_PREFIX` 等，供 request 与 autoMatchBaseUrl 使用 |
| `autoMatchBaseUrl(prefix)` | 根据 prefix 返回 `window.LOCAL_CONFIG.API_UPLOAD` 或 `API_HOME`，可按项目扩展 |
| `request.js` | 默认导出：封装请求（url、method、timeout、prefix、data 等）；`httpRequest`/`httpResponse` 供 app.js 拦截器使用；`uploadFile` 上传封装 |
| `RESTFULURL.js` | 可选，集中维护 REST 路径模板，供 request 的 url 占位符替换 |

---

## 目录结构速查（src）

| 路径 | 说明 |
|------|------|
| `app.js` | 运行时入口，request/router/钩子 |
| `constant.js` | 全局常量 |
| `global.less` | 全局样式 |
| `assets/fonts`、`assets/img`、`assets/style` | 字体、图片、样式（如 variable.less） |
| `layouts/index.vue` | 全局布局 |
| `pages/**` | 约定式路由页面 |
| `services/**` | 请求与接口封装 |
| `icons/` | SVG 图标 |
| `components/` | 公共组件（可选） |
| `utils/` | 工具函数（可选） |

---

## 脚本速查

| 脚本 | 命令 | 说明 |
|------|------|------|
| 开发 | `npm run dev` | `win dev` |
| 构建 | `npm run build` | `cross-env WIN_APP_ENV=production win build` |
| 预览 | `npm run preview` | `win preview` |
| 检查 | `npm run lint` | Biome lint |
| 修复 | `npm run lint:fix` | Biome lint --write |
| 格式化 | `npm run format` | Biome format --write |
| F2ELint | `npm run f2elint-scan` / `f2elint-fix` | 扫描 / 修复 |
| 初始化 | `npm run setup` | `win setup` |
| 清缓存 | `win cache` | 清除构建缓存 |

---

## 环境变量（常用）

- **PORT**：开发端口，如 `PORT=3000 npm run dev`。
- **WIN_APP_ENV**：构建环境，如 `production`（模板 build 脚本已设）。
- **NODE_ENV**：`development` / `production`，由框架与构建工具使用。

---

更多通用 WinJS 约定（路由、运行时钩子、useAppData、插件 API）见本技能 [详细用法与规范参考](./usage-reference.md)、[常见问题与排错](./troubleshooting.md) 或 [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)。
