# Vue2 -> Vue3 迁移审计与修复 Skill

目标：基于 Vue 3 迁移指南中的非兼容项，对项目进行自动检测，输出三类结果：
1. 检测报告（工程里有哪些主要变化点）
2. 迁移方案（可执行的落地步骤）
3. 修复报告（已处理/未处理项与证据）

参考规则来源：
- https://v3-migration.vuejs.org/zh/breaking-changes/

## 适用场景
- 旧项目从 Vue2 迁移到 Vue3
- 需要先盘点风险，再分批修复
- 需要可追踪、可复用的迁移报告流程

## 输入
- 一个待扫描工程目录（默认当前目录）

## 输出
- `reports/detection_report.md`
- `reports/migration_plan.md`
- `reports/fix_report.md`
- `reports/detection_raw.tsv`

## 使用方式
在目标工程根目录运行：

```bash
bash skills/vue3_migration_skill/scripts/build_migration_plan_and_fix_report.sh .
```

可选：只做检测

```bash
bash skills/vue3_migration_skill/scripts/detect_vue3_breaking_changes.sh .
```

## 检测范围（主要非兼容点）
- 事件总线 API：`$on/$off/$once`
- 过滤器：模板管道 `|`、`filters:` 选项
- `.native` 修饰符：`v-on:xxx.native` / `@xxx.native`
- `.sync`：`v-bind.sync` / `:prop.sync`
- keyCode 修饰符：`@keyup.13` 等
- 已废弃生命周期：`beforeDestroy/destroyed`
- Vue2 全局 API：`Vue.use / Vue.mixin / Vue.component / Vue.directive / Vue.filter / new Vue(`
- `$children`、`$destroy`、`$set/$delete`、`set/delete`
- `propsData`
- `functional: true`（旧函数式组件）

说明：该 Skill 先做“高置信的静态命中”，并在报告中标注“需要人工复核”的项，避免误报直接改坏代码。

## 报告结构约定
- 检测报告：按“风险级别 + 命中次数 + 文件列表”排序
- 迁移方案：按“先阻塞项，再兼容项，再清理项”给步骤
- 修复报告：记录“变更前后、影响范围、验证证据、遗留问题”

## 执行策略
1. 先跑检测，拿到全量命中
2. 生成迁移方案并分批处理（高风险优先）
3. 每一批改动后更新修复报告
4. 所有命中清零或确认豁免后结束

