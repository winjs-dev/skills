#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.}"
report_dir="${target_dir%/}/reports"
raw_file="${report_dir}/detection_raw.tsv"
md_file="${report_dir}/detection_report.md"

mkdir -p "$report_dir"
: > "$raw_file"

# 规则格式：id<TAB>severity<TAB>title<TAB>regex<TAB>glob
rules=$(cat <<'EOF'
EVENT_API	P0	实例事件API($on/$off/$once)已移除	\$on\(|\$off\(|\$once\(	*.{js,jsx,ts,tsx,vue}
FILTER_SYNTAX	P1	过滤器(filter)已移除：模板管道符	\|\s*[a-zA-Z_][a-zA-Z0-9_]*\b	*.vue
FILTER_OPTION	P1	过滤器(filter)已移除：filters选项	\bfilters\s*:\s*\{	*.{js,jsx,ts,tsx,vue}
NATIVE_MODIFIER	P0	v-on.native已移除	(@|v-on:)[^\s>]+\.native\b	*.vue
SYNC_MODIFIER	P1	v-bind.sync被新v-model参数替代	(:|v-bind:)[^\s>]+\.sync\b	*.vue
KEYCODE_MODIFIER	P1	keyCode修饰符已移除	@(key|keyup|keydown|keypress)\.[0-9]+\b	*.vue
LIFECYCLE_RENAME	P0	beforeDestroy/destroyed重命名	\bbeforeDestroy\b|\bdestroyed\b	*.{js,jsx,ts,tsx,vue}
VUE2_GLOBAL_API	P0	Vue2全局API改为app实例API	\bVue\.(use|mixin|component|directive|filter)\b	*.{js,jsx,ts,tsx}
NEW_VUE	P0	new Vue(...)入口方式已变更	\bnew\s+Vue\s*\(	*.{js,jsx,ts,tsx}
CHILDREN_REMOVED	P1	$children已移除	\$children\b	*.{js,jsx,ts,tsx,vue}
DESTROY_REMOVED	P0	$destroy已移除	\$destroy\s*\(	*.{js,jsx,ts,tsx,vue}
SET_DELETE_REMOVED	P0	$set/$delete或Vue.set/delete已移除	\$(set|delete)\s*\(|\bVue\.(set|delete)\s*\(	*.{js,jsx,ts,tsx,vue}
PROPS_DATA_REMOVED	P1	propsData选项已移除	\bpropsData\s*:\s*	*.{js,jsx,ts,tsx,vue}
FUNCTIONAL_SFC_REMOVED	P1	SFC functional选项/属性已移除	\bfunctional\s*:\s*true\b|<template\s+functional	*.{js,jsx,ts,tsx,vue}
EOF
)

scan_rule() {
  local id="$1" severity="$2" title="$3" regex="$4" glob_pattern="$5"
  local out
  out="$(
python3 - "$target_dir" "$glob_pattern" "$regex" <<'PY'
import fnmatch
import os
import re
import sys

root, glob_pattern, regex = sys.argv[1], sys.argv[2], sys.argv[3]

def expand_brace(pattern: str):
    if "{" not in pattern or "}" not in pattern:
        return [pattern]
    s = pattern.index("{")
    e = pattern.index("}", s)
    prefix = pattern[:s]
    suffix = pattern[e + 1 :]
    parts = pattern[s + 1 : e].split(",")
    res = []
    for p in parts:
        res.extend(expand_brace(prefix + p + suffix))
    return res

patterns = expand_brace(glob_pattern)
try:
    reg = re.compile(regex)
except re.error:
    print("", end="")
    sys.exit(0)

for dirpath, _, filenames in os.walk(root):
    for name in filenames:
        rel = os.path.relpath(os.path.join(dirpath, name), root)
        rel_unix = rel.replace(os.sep, "/")
        if not any(fnmatch.fnmatch(rel_unix, p) for p in patterns):
            continue
        abs_path = os.path.join(dirpath, name)
        try:
            with open(abs_path, "r", encoding="utf-8", errors="ignore") as f:
                for i, line in enumerate(f, 1):
                    if reg.search(line):
                        print(f"{abs_path}:{i}:{line.rstrip()}")
        except Exception:
            pass
PY
  )"
  if [ -n "$out" ]; then
    local count
    count="$(printf "%s\n" "$out" | awk 'NF>0' | wc -l | tr -d ' ')"
    local files
    files="$(printf "%s\n" "$out" | awk -F: '{print $1}' | awk '!seen[$0]++' | paste -sd ", " -)"
    printf "%s\t%s\t%s\t%s\t%s\n" "$id" "$severity" "$count" "$title" "$files" >> "$raw_file"
  else
    printf "%s\t%s\t0\t%s\t-\n" "$id" "$severity" "$title" >> "$raw_file"
  fi
}

while IFS=$'\t' read -r id severity title regex glob_pattern; do
  [ -z "${id:-}" ] && continue
  scan_rule "$id" "$severity" "$title" "$regex" "$glob_pattern"
done <<< "$rules"

{
  echo "# Vue3 迁移检测报告"
  echo
  echo "- 扫描目录：\`$target_dir\`"
  echo "- 规则来源：Vue 3 迁移指南（非兼容性改变）"
  echo "- 生成时间：$(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo "## 命中总览"
  echo
  echo "| 规则ID | 级别 | 命中数 | 说明 | 涉及文件 |"
  echo "|---|---|---:|---|---|"
  awk -F'\t' '{printf("| %s | %s | %s | %s | %s |\n",$1,$2,$3,$4,$5)}' "$raw_file"
  echo
  echo "## 结论"
  echo
  total_hits="$(awk -F'\t' '{sum+=$3} END {print sum+0}' "$raw_file")"
  p0_hits="$(awk -F'\t' '$2=="P0"{sum+=$3} END {print sum+0}' "$raw_file")"
  p1_hits="$(awk -F'\t' '$2=="P1"{sum+=$3} END {print sum+0}' "$raw_file")"
  echo "- 总命中：$total_hits"
  echo "- P0 命中：$p0_hits"
  echo "- P1 命中：$p1_hits"
  if [ "$total_hits" -eq 0 ]; then
    echo "- 当前未发现主要 Vue2->Vue3 非兼容语法命中。"
  else
    echo "- 建议先处理 P0，再处理 P1。"
  fi
} > "$md_file"

echo "已生成：$md_file"
echo "已生成：$raw_file"

