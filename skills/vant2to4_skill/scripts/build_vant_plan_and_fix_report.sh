#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
report_dir="${target_dir%/}/reports"
raw_file="${report_dir}/vant_detection_raw.tsv"
plan_file="${report_dir}/vant_migration_plan.md"
fix_file="${report_dir}/vant_fix_report.md"

mkdir -p "$report_dir"

bash "$script_dir/detect_vant2_to_vant4_changes.sh" "$target_dir" >/dev/null

total_hits="$(awk -F'\t' '{sum+=$3} END {print sum+0}' "$raw_file")"
p0_hits="$(awk -F'\t' '$2=="P0"{sum+=$3} END {print sum+0}' "$raw_file")"
p1_hits="$(awk -F'\t' '$2=="P1"{sum+=$3} END {print sum+0}' "$raw_file")"

{
  echo "# Vant2 -> Vant4 迁移方案"
  echo
  echo "- 扫描目录：\`$target_dir\`"
  echo "- 总命中：${total_hits}（P0: ${p0_hits}，P1: ${p1_hits}）"
  echo
  echo "## 执行顺序"
  echo
  echo "1. 依赖与入口先行：锁定 Vant4 与 Vue3 入口注册"
  echo "2. API 替换：Dialog/Toast/Notify/ImagePreview 统一改到新调用"
  echo "3. 清理旧构建痕迹：babel-plugin-import 与 vant/lib/*/style"
  echo "4. 复扫并记录修复证据"
  echo
  echo "## 分项建议"
  echo
  awk -F'\t' '
    $3+0>0 {
      printf("- `%s`（%s，命中%s）：\n", $1, $2, $3);
      if ($1=="VANT_VERSION_LT_4") print "  升级 package.json 中 vant 到 4.x，并锁定与 Vue3 兼容的生态版本。";
      else if ($1=="VUE_USE_VANT") print "  从 Vue.use(...) 迁移到 createApp(App).use(...) 的应用实例注册。";
      else if ($1=="DIALOG_STATIC_API") print "  优先改为 showDialog/showConfirmDialog 等函数式 API（按页面逐步替换）。";
      else if ($1=="TOAST_CALL") print "  统一评估并迁移到 showToast/closeToast 体系。";
      else if ($1=="NOTIFY_CALL") print "  统一评估并迁移到 showNotify/closeNotify。";
      else if ($1=="IMAGE_PREVIEW_CALL") print "  统一评估并迁移到 showImagePreview。";
      else if ($1=="INSTANCE_DIALOG" || $1=="INSTANCE_TOAST" || $1=="INSTANCE_NOTIFY") print "  移除 this.$xxx 调用，改为显式导入函数式 API。";
      else if ($1=="BABEL_IMPORT_VANT") print "  移除旧 babel-plugin-import 配置，改为 Vite/构建插件的自动按需方案。";
      else if ($1=="VANT_LIB_STYLE_PATH") print "  清理旧 vant/lib/*/style 引入路径，按当前构建方案统一样式入口。";
      else if ($1=="VUE2_SET_DELETE") print "  同步清理 Vue2 依赖写法，避免升级后响应式行为异常。";
      else print "  命中后逐文件确认，再执行替换。";
    }
  ' "$raw_file"
  echo
  echo "## 批次建议"
  echo
  if [ "$p0_hits" -gt 0 ]; then
    echo "- 批次A：`VANT_VERSION_LT_4` + `VUE_USE_VANT`"
  fi
  if [ "$p1_hits" -gt 0 ]; then
    echo "- 批次B：Dialog/Toast/Notify/ImagePreview API"
    echo "- 批次C：构建配置与样式路径清理"
  fi
  if [ "$total_hits" -eq 0 ]; then
    echo "- 当前无需迁移动作，保留定期扫描即可。"
  fi
} > "$plan_file"

{
  echo "# Vant2 -> Vant4 修复报告"
  echo
  echo "- 扫描目录：\`$target_dir\`"
  echo "- 生成时间：$(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo "## 统计"
  echo
  echo "- 总命中：$total_hits"
  echo "- P0 命中：$p0_hits"
  echo "- P1 命中：$p1_hits"
  echo
  echo "## 已处理项"
  echo
  echo "> 初始模板，执行真实代码修复后按条目补充。"
  echo
  echo "- [ ] 规则ID："
  echo "  - 变更文件："
  echo "  - 修复动作："
  echo "  - 风险说明："
  echo "  - 验证证据："
  echo
  echo "## 待处理项"
  echo
  awk -F'\t' '$3+0>0 {printf("- `%s`（%s）命中：%s，文件：%s，置信度：%s\n",$1,$2,$3,$5,$6)}' "$raw_file"
  if [ "$total_hits" -eq 0 ]; then
    echo "- 无待处理项。"
  fi
} > "$fix_file"

echo "已生成：$report_dir/vant_detection_report.md"
echo "已生成：$plan_file"
echo "已生成：$fix_file"

