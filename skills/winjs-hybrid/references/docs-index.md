# WinJS 官方文档索引

本文档索引 WinJS 官方文档（[winjs-docs](https://winjs-dev.github.io/winjs-docs/)）中的核心主题，便于在开发时快速定位。

## 配置

| 主题 | 说明 | 文档路径（winjs-docs 内） |
|------|------|---------------------------|
| 配置文件 | `.winrc.ts` / `config/config.ts`、defineConfig、配置项字母序列表 | `src/config/config.md`、`src/zh/config/config.md` |
| 运行时配置 | app.js 导出、modifyClientRenderOpts、onRouterCreated、onAppCreated、onMounted、patchRoutes、rootContainer 等 | `src/config/runtime-config.md`、`src/zh/config/runtime-config.md` |

## API

| 主题 | 说明 | 文档路径 |
|------|------|----------|
| 插件 API | applyPlugins、register、describe、registerMethod、registerCommand、ApplyPluginsType（add/modify/event） | `src/api/plugin-api.md`、`src/zh/api/plugin-api.md` |
| 运行时 API | 面向业务使用的 API 列表 | `src/api/api.md`、`src/zh/api/api.md` |

## 指南

| 主题 | 说明 | 文档路径 |
|------|------|----------|
| 快速上手 | 环境准备、创建项目、目录与脚本 | `src/guides/getting-started.md`、`src/zh/guides/getting-started.md` |
| 目录结构 | 约定目录、.win、layouts、pages、app、public、.env 等 | `src/guides/directory-structure.md`、`src/zh/guides/directory-structure.md` |
| 路由 | routes 配置、path/name/alias、嵌套、redirect、wrappers、约定式路由 | `src/guides/routes.md`、`src/zh/guides/routes.md` |
| 环境变量 | PORT、WIN_ENV、WIN_APP_ENV、.env、.env.local、cross-env | `src/guides/env-variables.md`、`src/zh/guides/env-variables.md` |
| 插件 | 使用插件、preset、plugins 配置 | `src/guides/plugins.md`、`src/zh/guides/plugins.md` |
| 构建与部署 | build、多环境、deploy | `src/guides/build.md`、`src/guides/deploy.md`、`src/zh/guides/deploy.md` |
| Mock、代理、请求 | mock、proxy、data-request | `src/guides/mock.md`、`src/guides/proxy.md`、`src/guides/data-request.md` |
| 样式与资源 | styling、assets、rem | `src/guides/styling.md`、`src/guides/assets.md`、`src/guides/rem.md` |
| Vue 2、Vite、Rsbuild | with-vue2、vite、rsbuild | `src/guides/with-vue2.md`、`src/guides/vite.md`、`src/guides/rsbuild.md` |
| TypeScript、Lint、FAQ | typescript、lint、f2elint、faq | `src/guides/typescript.md`、`src/guides/lint.md`、`src/guides/faq.md` |
| 错误与调试 | errors、debug | `src/guides/errors.md`、`src/guides/debug.md` |
| 性能与优化 | performance、optimize-bundle、code-splitting | `src/guides/performance.md`、`src/guides/optimize-bundle.md`、`src/guides/code-splitting.md` |

## 配置项（config 内字母序）

配置文档中选项按字母序排列，常用项包括：`alias`、`analyze`、`appConfig`、`base`、`publicPath`、`outputPath`、`history`、`mock`、`proxy`、`routes`、`plugins`、`presets`、`vite`、`rsbuild` 等。详见官方配置文档。

## CLI 命令

| 命令 | 说明 | 文档路径 |
|------|------|----------|
| win dev | 开发服务器 | `src/cli/commands.md`、`src/zh/cli/commands.md` |
| win build | 生产构建 | 同上 |
| win preview | 本地预览构建结果（支持 --dir、--prefix） | 同上 |
| win config | 查看/修改配置 | 同上 |
| win generate / g | 生成代码片段 | 同上 |
| win setup、win cache、win info 等 | 辅助命令 | 同上 |

## 插件文档（部分）

| 插件 | 说明 | 文档路径 |
|------|------|----------|
| request | 请求封装、拦截器、错误处理 | `src/plugins/request.md`、`src/zh/plugins/request.md` |
| wconsole | 移动端调试、vConsole | `src/plugins/wconsole.md`、`src/zh/plugins/wconsole.md` |
| statemanagement | 状态管理（Vuex/Pinia） | `src/plugins/statemanagement.md`、`src/zh/plugins/statemanagement.md` |
| qiankun | 微前端 | `src/plugins/qiankun.md`、`src/zh/plugins/qiankun.md` |
| access | 权限 | `src/plugins/access.md`、`src/zh/plugins/access.md` |
| i18n | 国际化 | `src/plugins/i18n.md`、`src/zh/plugins/i18n.md` |

在线文档：<https://winjs-dev.github.io/winjs-docs/>
