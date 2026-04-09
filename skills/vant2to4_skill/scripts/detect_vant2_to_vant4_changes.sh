#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.}"
report_dir="${target_dir%/}/reports"
raw_file="${report_dir}/vant_detection_raw.tsv"
md_file="${report_dir}/vant_detection_report.md"

mkdir -p "$report_dir"
: > "$raw_file"

# 规则格式：id<TAB>severity<TAB>title<TAB>regex<TAB>glob<TAB>review
rules=$(cat <<'EOF'
VANT_VERSION_LT_4	P0	vant版本小于4	"vant"\s*:\s*"[~^]?[0-3]\.	package.json	高置信
VUE_USE_VANT	P0	Vue2式插件注册（Vue.use）	\bVue\.use\s*\(	*.{js,jsx,ts,tsx,vue}	高置信
DIALOG_STATIC_API	P1	Dialog.alert/confirm等旧静态调用	\bDialog\.(alert|confirm|prompt)\s*\(	*.{js,jsx,ts,tsx,vue}	需人工复核
TOAST_CALL	P1	Toast旧调用形态	\bToast\s*\(	*.{js,jsx,ts,tsx,vue}	需人工复核
NOTIFY_CALL	P1	Notify旧调用形态	\bNotify\s*\(	*.{js,jsx,ts,tsx,vue}	需人工复核
IMAGE_PREVIEW_CALL	P1	ImagePreview旧调用形态	\bImagePreview\s*\(	*.{js,jsx,ts,tsx,vue}	需人工复核
INSTANCE_DIALOG	P1	this.$dialog实例方法	\$\s*dialog\b	*.{js,jsx,ts,tsx,vue}	需人工复核
INSTANCE_TOAST	P1	this.$toast实例方法	\$\s*toast\b	*.{js,jsx,ts,tsx,vue}	需人工复核
INSTANCE_NOTIFY	P1	this.$notify实例方法	\$\s*notify\b	*.{js,jsx,ts,tsx,vue}	需人工复核
BABEL_IMPORT_VANT	P1	babel-plugin-import按需加载痕迹	\b"babel-plugin-import"\b|libraryName"\s*:\s*"vant"	*.{json,js,cjs,mjs}	高置信
VANT_LIB_STYLE_PATH	P1	vant/lib/*/style路径用法	\bvant/lib/.*/style\b	*.{js,jsx,ts,tsx,vue}	高置信
VUE2_SET_DELETE	P1	Vue2响应式旧写法($set/$delete)	\$(set|delete)\s*\(	*.{js,jsx,ts,tsx,vue}	高置信
EOF
)

scan_rule() {
  local id="$1" severity="$2" title="$3" regex="$4" glob_pattern="$5" review="$6"
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
    local count files
    count="$(printf "%s\n" "$out" | awk 'NF>0' | wc -l | tr -d ' ')"
    files="$(printf "%s\n" "$out" | awk -F: '{print $1}' | awk '!seen[$0]++' | paste -sd ", " -)"
    printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$id" "$severity" "$count" "$title" "$files" "$review" >> "$raw_file"
  else
    printf "%s\t%s\t0\t%s\t-\t%s\n" "$id" "$severity" "$title" "$review" >> "$raw_file"
  fi
}

while IFS=$'\t' read -r id severity title regex glob_pattern review; do
  [ -z "${id:-}" ] && continue
  scan_rule "$id" "$severity" "$title" "$regex" "$glob_pattern" "$review"
done <<< "$rules"

{
  echo "# Vant2 -> Vant4 检测报告"
  echo
  echo "- 扫描目录：\`$target_dir\`"
  echo "- 规则来源：Vant 迁移文档（v2->v4、v3->v4）"
  echo "- 生成时间：$(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo "## 命中总览"
  echo
  echo "| 规则ID | 级别 | 命中数 | 说明 | 涉及文件 | 置信度 |"
  echo "|---|---|---:|---|---|---|"
  awk -F'\t' '{printf("| %s | %s | %s | %s | %s | %s |\n",$1,$2,$3,$4,$5,$6)}' "$raw_file"
  echo
  total_hits="$(awk -F'\t' '{sum+=$3} END {print sum+0}' "$raw_file")"
  p0_hits="$(awk -F'\t' '$2=="P0"{sum+=$3} END {print sum+0}' "$raw_file")"
  p1_hits="$(awk -F'\t' '$2=="P1"{sum+=$3} END {print sum+0}' "$raw_file")"
  echo "## 结论"
  echo
  echo "- 总命中：$total_hits"
  echo "- P0 命中：$p0_hits"
  echo "- P1 命中：$p1_hits"
  if [ "$total_hits" -eq 0 ]; then
    echo "- 当前未命中主要 Vant2/Vant3 到 Vant4 的迁移风险点。"
  else
    echo "- 建议先修 P0（版本与注册方式），再处理 API 与样式路径迁移。"
  fi
} > "$md_file"

echo "已生成：$md_file"
echo "已生成：$raw_file"

