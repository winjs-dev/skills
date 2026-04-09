# Vant2 -> Vant4 迁移审计与修复 Skill

目标：根据 Vant 官方迁移文档，针对项目做静态审计并输出三类产物：
1. 检测报告（命中哪些主要迁移点）
2. 落地方案（按优先级执行）
3. 修复报告（已处理/待处理与验证记录）

规则来源：
- https://vant-ui.github.io/vant/#/zh-CN/migrate-from-v2
- https://vant-ui.github.io/vant/#/zh-CN/migrate-from-v3

## 输入
- 待扫描工程路径（默认当前目录）

## 输出
- `reports/vant_detection_report.md`
- `reports/vant_migration_plan.md`
- `reports/vant_fix_report.md`
- `reports/vant_detection_raw.tsv`

## 用法
在目标工程根目录执行：

```bash
bash skills/vant2to4_skill/scripts/build_vant_plan_and_fix_report.sh .
```

只做检测：

```bash
bash skills/vant2to4_skill/scripts/detect_vant2_to_vant4_changes.sh .
```

## 检测范围
- 依赖版本：`vant` 主版本非 4
- Vue2/Vant2 插件注册习惯：`Vue.use(...)`
- 旧 API 调用：`Dialog.alert`、`Notify(...)`、`ImagePreview(...)`、`Toast(...)`
- 旧实例方法：`this.$dialog`、`this.$toast`、`this.$notify`
- 旧样式/按需加载痕迹：`babel-plugin-import`、`vant/lib/*/style`
- 迁移阶段常见风险：`this.$set` / `this.$delete`（Vue2 依赖写法）

说明：检测是“风险定位”，不是机械替换。命中项先人工确认，再按方案分批修复。

## 执行顺序
1. 先处理依赖与入口（`vant` 版本、全局注册方式）
2. 再处理 API 调用替换（Dialog/Toast/Notify/ImagePreview）
3. 最后清理按需加载旧配置与 Vue2 遗留写法

