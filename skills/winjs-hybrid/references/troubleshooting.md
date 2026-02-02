# WinJS 常见问题与排错

本文档汇总 WinJS 开发与构建中的常见问题、原因与处理方式，便于快速排错。更多见 [官方 FAQ](https://winjs-dev.github.io/winjs-docs/guides/faq)。

---

## AppContext is no provide

**现象**：运行时报错 `Uncaught Error: AppContext is no provide`，堆栈指向 `useAppData` 或 `getRoute`。

**原因**：在模块顶层（非 Vue 组件内部）调用了 `useAppData()` 或 `getRoute()`，此时 AppContext 尚未通过 Vue 的 provide/prototype 注入。

**处理**：将调用移到 **Vue 组件的生命周期或 setup 中**（如 `created`、`mounted`、`setup()`），确保在应用挂载后执行。

---

## 自定义 router 下 clientRoutes 不对

**现象**：通过 `modifyClientRenderOpts` 传入了自定义 router，但 `useAppData().clientRoutes` 仍是 WinJS 生成的路由（如只有 globalLayout）。

**原因**：未正确传入 `router`，或被其他插件的 `modifyClientRenderOpts` 覆盖；或 renderer 未按“有自定义 router 时从 `router.options.routes` 取 clientRoutes”实现。

**处理**：确认 `app.js` 中 `modifyClientRenderOpts` 返回 `{ ...memo, router: customRouter }`；确认无其他插件覆盖 `memo.router`；确认框架版本支持（renderer-vue2/renderer-vue 已支持）。

---

## 路由守卫不生效

**现象**：在 `router.beforeEach` 中注册的守卫没有执行或执行时机异常。

**原因**：常见为（1）`Vue.use(Router)` 在创建 router 实例之后才调用，导致 router 未正确初始化；（2）守卫在模块顶层注册（如 `router.interceptor.js` 里直接 `router.beforeEach`），此时若 router 来自 `./index`，而 `index` 里 `Vue.use(Router)` 在 `new Router()` 之后，会出问题。

**处理**：保证 **先 `Vue.use(Router)`，再 `new Router()`**；守卫逻辑改为导出函数（如 `setupRouterGuards(router)`），在 `app.js` 的 `onRouterCreated({ router })` 中调用，确保在 router 创建完成后注册。

---

## 动态路由在 Vue 2 下报错

**现象**：Vue 2 项目中使用 `router.addRoute()` 或 `router.getRoutes()` 报错（如 method 不存在）。

**原因**：Vue Router 3.x（Vue 2 配套）只有 `addRoutes()`（复数）和 `router.options.routes`，没有 `addRoute()` 和 `getRoutes()`（后者为 Vue Router 4+ API）。

**处理**：使用 `router.addRoutes([...])` 动态添加路由；使用 `router.options.routes` 获取路由列表；写通用逻辑时按 Vue 版本分支或做能力检测。

---

## Vue.use(Router) 与 new Router() 顺序错误

**现象**：路由不工作、守卫不触发、或控制台有 Vue Router 相关警告。

**原因**：在 `src/router/index.js` 中先执行了 `new Router(...)`，再执行 `Vue.use(Router)`；插件必须在创建实例前安装。

**处理**：在创建 router 实例 **之前** 调用 `Vue.use(Router)`，然后再 `const router = new Router({ ... })`。

---

## preview 资源 404

**现象**：`win preview` 或 `win preview --prefix /xxx` 时，页面能打开但 JS/CSS 等静态资源 404（如 `config.local.js`、`win.js` 等）。

**原因**：使用 `--prefix` 时，静态资源请求路径为 `http://localhost:port/xxx/...`，但构建时 `base`/`publicPath` 为 `./` 或 `/`，导致 HTML 中引用的是 `/config.local.js` 等，浏览器请求到根路径而非 prefix 下。

**处理**：（1）构建时与 preview 保持一致：若 preview 用 `--prefix /boilerplate`，则构建前在 `.winrc` 中设置 `base: '/boilerplate/'`、`publicPath: '/boilerplate/'`，再执行 `win build`；（2）或 preview 不加 prefix，直接访问根路径。不推荐在 preview 服务里重写 HTML 中的资源路径（维护成本高）。

---

## 构建失败 / HMR 不生效

**现象**：`win build` 报错，或 `win dev` 下修改代码后页面不更新。

**原因**：配置语法错误、依赖版本冲突、缓存损坏、或 Node 版本不匹配。

**处理**：检查 `.winrc.ts` 语法与配置项是否合法；执行 `win cache` 清除缓存后重试；确认 Node 版本（推荐 18+）；查看完整报错堆栈与官方 [错误与调试](https://winjs-dev.github.io/winjs-docs/guides/errors)、[调试](https://winjs-dev.github.io/winjs-docs/guides/debug) 文档。

---

## 插件/预设未生效

**现象**：在 `package.json` 中安装了 `@winner-fed/plugin-xxx` 或 `@winner-fed/preset-xxx`，但功能未生效。

**原因**：WinJS 不会自动注册以 `@winner-fed/preset-`、`@winner-fed/plugin-`、`win-preset-`、`win-plugin-` 开头的依赖，需在 `.winrc` 的 `presets` / `plugins` 中显式配置。

**处理**：在 `.winrc` 中添加对应项，例如 `plugins: ['@winner-fed/plugin-request']`、`presets: [require.resolve('@winner-fed/preset-vue')]`。

---

## 其他

- **TypeScript 类型报错**：确保使用 `defineConfig`、`defineApp` 等提供的类型；查看 [TypeScript 指南](https://winjs-dev.github.io/winjs-docs/guides/typescript)。
- **多环境构建**：使用 `WIN_APP_ENV` 或 `WIN_ENV` 区分环境，在 `.winrc` 或 `appConfig` 中按环境分支；见 [环境变量](https://winjs-dev.github.io/winjs-docs/guides/env-variables)。
- **官方 FAQ**：<https://winjs-dev.github.io/winjs-docs/guides/faq>。
