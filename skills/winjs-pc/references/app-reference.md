# PC 模板速查

本文档为 winjs-pc 技能的补充参考，仅针对 create-win **PC** 模板生成的项目，做配置、目录、请求与脚本速查。

---

## .winrc 本模板常用配置项

| 配置项 | 说明 | 模板默认/说明 |
|--------|------|----------------|
| `plugins` | 插件列表 | 仅 `@winner-fed/plugin-request`，无 wconsole |
| `request` | request 插件配置 | `{}`，具体在 `src/app.js` 中导出 `request` |
| `appConfig` | 多环境运行时配置 | `development` / `test` / `production`，注入到 `window.LOCAL_CONFIG`，无 IS_OPEN_VCONSOLE |
| `history` | 路由模式 | 模板未显式配置时由 preset 决定；可配置 `{ type: 'browser' }` 或 `{ type: 'hash' }` |
| `lessLoader.modifyVars` | Less 全局变量/混入 | 注入 `@/assets/style/variable.less` 与 magicless |
| `targets` | 浏览器兼容 | `{ chrome: 51, firefox: 54, safari: 10, edge: 15 }`，PC 端 |
| `jsMinifier` / `cssMinifier` | 压缩器 | terser、cssnano |
| `title`、`mountElementId` | 页面标题与挂载节点 ID | 由脚手架生成 |
| `alias`、`base`/`publicPath` | 路径别名与部署基础路径 | 按项目配置 |

本模板**不包含**：convertToRem、wconsole。若需 REM 或 VConsole，需在 `.winrc` 与依赖中自行添加。

---

## appConfig 与 window.LOCAL_CONFIG

- **配置位置**：`.winrc` 的 `appConfig.development` / `appConfig.test` / `appConfig.production`。
- **本模板常用键**：`API_HOME`、`API_UPLOAD`（无 VConsole 开关）。
- **使用**：在 `services/autoMatchBaseUrl.js` 中根据前缀返回 base URL；业务勿在模块顶层依赖未注入的 config。

---

## src/app.js 导出约定

| 导出 | 说明 | 备注 |
|------|------|------|
| `request` | request 插件配置 | timeout、requestInterceptors、responseInterceptors，已对接 services/request.js |
| `router` | 路由选项 | 如 scrollBehavior |
| `onRouterCreated` | 路由实例创建后 | 注册守卫等 |
| `onAppCreated` | 应用实例创建后 | 全局属性、插件 |
| `onMounted` | 应用挂载后 | 依赖 DOM 的初始化 |

---

## 构建与 Vite

- PC 模板使用 **Vite** 作为构建工具（通过 preset-vue），与 App 模板的默认构建链可能不同。
- 开发与构建命令与通用 WinJS 一致：`win dev`、`win build`、`win preview`。
- 模块联邦、代码分割等能力以 WinJS/Vite 文档与 preset 为准。

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

## 目录结构速查（src）

| 路径 | 说明 |
|------|------|
| `app.js` | 运行时入口，request/router/钩子 |
| `constant.js` | 全局常量 |
| `global.less` | 全局样式 |
| `assets/fonts`、`assets/img`、`assets/style` | 字体、图片、样式 |
| `layouts/index.vue` | 全局布局 |
| `pages/**` | 约定式路由页面 |
| `services/**` | 请求与接口封装 |
| `icons/` | SVG 图标 |

---

## 脚本速查

| 脚本 | 命令 | 说明 |
|------|------|------|
| 开发 | `npm run dev` | `win dev`（Vite） |
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
