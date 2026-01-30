# WinJS Skills - Agent Guide

本文档为 AI 编码代理提供项目上下文和指导，帮助代理理解和使用本项目中的 WinJS 相关技能。

## 项目概述

本项目包含多个 WinJS 框架相关的 Cursor Agent Skills，每个技能针对不同的 WinJS 项目模板，提供专门的开发指导、配置说明和最佳实践。

## 可用技能

本项目包含以下技能：

### 1. winjs-app
- **路径**: `winjs-app/SKILL.md`
- **用途**: 基于 WinJS App 模板的移动端 H5 项目开发
- **适用场景**: 
  - 使用 `create-win app` 模板创建的项目
  - 移动端 H5 应用开发
  - Vue 3 + Vue Router 4 项目
  - 需要配置 REM 适配、VConsole 调试的项目

### 2. winjs-huipro
- **路径**: `winjs-huipro/SKILL.md`
- **用途**: 基于 WinJS HuiPro 模板的项目开发
- **适用场景**: HuiPro 模板相关的项目开发

### 3. winjs-hybrid
- **路径**: `winjs-hybrid/SKILL.md`
- **用途**: 基于 WinJS Hybrid 模板的项目开发
- **适用场景**: Hybrid 混合应用开发

### 4. winjs-pc
- **路径**: `winjs-pc/SKILL.md`
- **用途**: 基于 WinJS PC 模板的项目开发
- **适用场景**: PC 端项目开发

## 技能结构

每个技能目录包含以下结构：

```
skill-name/
├── SKILL.md                    # 主要技能文档
└── references/                 # 参考文档
    ├── app-reference.md        # 模板配置速查
    ├── usage-reference.md      # 详细用法与规范参考
    ├── troubleshooting.md      # 常见问题与排错
    └── docs-index.md           # WinJS 官方文档索引
```

## 使用指南

### 何时使用技能

1. **识别项目模板**: 首先确定用户项目使用的 WinJS 模板类型（app/huipro/hybrid/pc）
2. **应用对应技能**: 根据模板类型，应用相应的技能
3. **查阅参考文档**: 技能中的 references 目录包含详细的配置、用法和排错信息

### 技能应用原则

- **优先使用项目技能**: 如果用户项目是基于 WinJS 模板创建的，优先使用对应的技能
- **保持一致性**: 遵循技能中定义的配置约定和目录结构
- **参考官方文档**: 技能中的 `docs-index.md` 提供了 WinJS 官方文档的快速索引

### 常见任务

#### 配置修改
- 修改 `.winrc.ts` 或 `config/config.ts` 时，参考对应技能的 `app-reference.md`
- 运行时配置修改参考 `usage-reference.md`

#### 问题排查
- 遇到问题时，先查阅对应技能的 `troubleshooting.md`
- 参考 `docs-index.md` 定位官方文档

#### 代码开发
- 遵循技能中定义的目录约定
- 使用技能推荐的插件和工具
- 遵循代码质量工具配置（Biome、StyleLint、F2ELint）

## 项目约定

### 文档格式
- 所有技能使用 Markdown 格式
- 技能文件包含 YAML frontmatter（name、description、license）
- 参考文档使用中文编写

### 技能命名
- 技能目录名使用小写字母和连字符（kebab-case）
- 技能名称与 WinJS 模板名称对应

### 文档组织
- 主要指导放在 `SKILL.md`
- 详细参考放在 `references/` 目录
- 保持文档的渐进式披露（progressive disclosure）

## 开发环境

### 前置要求
- Node.js 环境
- WinJS 框架知识
- Vue.js 开发经验（根据模板类型）

### 相关资源
- [WinJS 官方文档](https://winjs-dev.github.io/winjs-docs/)
- [WinJS GitHub](https://github.com/winjs-dev)

## 注意事项

1. **模板识别**: 准确识别用户项目使用的模板类型，应用正确的技能
2. **配置一致性**: 确保配置修改符合模板约定
3. **文档引用**: 优先使用技能内的参考文档，必要时链接到官方文档
4. **问题排查**: 按照 troubleshooting.md 中的步骤进行问题排查

## 更新日志

技能文档会随 WinJS 框架更新而更新，请定期检查是否有新版本。

---

**提示**: 当用户询问 WinJS 项目相关问题时，首先确定项目模板类型，然后应用对应的技能并查阅相关参考文档。
