#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
report_dir="${target_dir%/}/reports"
raw_file="${report_dir}/detection_raw.tsv"
plan_file="${report_dir}/migration_plan.md"
fix_file="${report_dir}/fix_report.md"

mkdir -p "$report_dir"

bash "$script_dir/detect_vue3_breaking_changes.sh" "$target_dir" >/dev/null

total_hits="$(awk -F'\t' '{sum+=$3} END {print sum+0}' "$raw_file")"
p0_hits="$(awk -F'\t' '$2=="P0"{sum+=$3} END {print sum+0}' "$raw_file")"
p1_hits="$(awk -F'\t' '$2=="P1"{sum+=$3} END {print sum+0}' "$raw_file")"

{
  echo "# Vue3 迁移方案"
  echo
  echo "- 扫描目录：\`$target_dir\`"
  echo "- 总命中：${total_hits}（P0: ${p0_hits}，P1: ${p1_hits}）"
  echo
  echo "## 执行顺序"
  echo
  echo "1. 先处理 P0 阻塞项（运行期会直接出错或行为变化明显）"
  echo "2. 再处理 P1 兼容项（语法替换与生命周期调整）"
  echo "3. 每处理一批，重新跑检测并更新修复报告"
  echo
  echo "## 分项落地建议"
  echo
  awk -F'\t' '
    $3+0>0 {
      printf("- `%s`（%s，命中%s）：\n", $1, $2, $3);
      if ($1=="EVENT_API") print "  用 mitt 或自定义事件中心替代 $on/$off/$once，并把订阅解绑迁到 onUnmounted。";
      else if ($1=="NATIVE_MODIFIER") print "  移除 .native，改为子组件声明 emits，并在组件根节点透传原生事件。";
      else if ($1=="VUE2_GLOBAL_API" || $1=="NEW_VUE") print "  入口改为 createApp(App).use(...).mount(...)，全局注册迁移到 app 实例。";
      else if ($1=="DESTROY_REMOVED") print "  删除手动 $destroy 调用，改由条件渲染与组件生命周期管理。";
      else if ($1=="SET_DELETE_REMOVED") print "  直接对响应式对象赋值/删除（delete）并确保对象由 reactive/ref 托管。";
      else if ($1=="LIFECYCLE_RENAME") print "  beforeDestroy/destroyed 改成 beforeUnmount/unmounted。";
      else if ($1=="SYNC_MODIFIER") print "  .sync 改为 v-model:prop，并实现 update:prop 事件。";
      else if ($1=="FILTER_SYNTAX" || $1=="FILTER_OPTION") print "  过滤器改为 methods/computed/普通函数调用。";
      else if ($1=="KEYCODE_MODIFIER") print "  keyCode 修饰符改为按键别名（如 @keyup.enter）或显式判断 event.key。";
      else if ($1=="PROPS_DATA_REMOVED") print "  测试挂载场景改为 props。";
      else if ($1=="FUNCTIONAL_SFC_REMOVED") print "  函数式组件改为普通组件或函数式写法（不再使用 functional 选项）。";
      else if ($1=="CHILDREN_REMOVED") print "  避免依赖 $children，改用 ref + emits 或 provide/inject。";
      else print "  结合该规则逐文件替换，替换后回归验证。";
    }
  ' "$raw_file"
  echo
  echo "## 批次建议"
  echo
  if [ "$p0_hits" -gt 0 ]; then
    echo "- 批次A：入口与全局API（`NEW_VUE` + `VUE2_GLOBAL_API`）"
    echo "- 批次B：事件系统与生命周期（`EVENT_API` + `LIFECYCLE_RENAME` + `DESTROY_REMOVED`）"
  fi
  if [ "$p1_hits" -gt 0 ]; then
    echo "- 批次C：模板语法替换（`.native`、`.sync`、过滤器、keyCode）"
    echo "- 批次D：清理遗留（`$children`、`propsData`、`functional`）"
  fi
  if [ "$total_hits" -eq 0 ]; then
    echo "- 当前无需迁移语法替换，建议仅保留周期性扫描。"
  fi
} > "$plan_file"

{
  echo "# Vue3 修复报告"
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
  echo "> 本次为自动初始报告，默认未执行代码修复。请在每次改动后按如下格式追加。"
  echo
  echo "- [ ] 规则ID："
  echo "  - 变更文件："
  echo "  - 修复动作："
  echo "  - 修复前风险："
  echo "  - 修复后验证："
  echo
  echo "## 待处理项（来自检测）"
  echo
  awk -F'\t' '$3+0>0 {printf("- `%s`（%s）命中：%s，文件：%s\n",$1,$2,$3,$5)}' "$raw_file"
  if [ "$total_hits" -eq 0 ]; then
    echo "- 无待处理项。"
  fi
} > "$fix_file"

echo "已生成：$report_dir/detection_report.md"
echo "已生成：$plan_file"
echo "已生成：$fix_file"

