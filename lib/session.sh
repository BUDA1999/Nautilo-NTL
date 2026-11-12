#!/usr/bin/env bash
new_session() {
  local id="s-$(date +%Y%m%d-%H%M%S)-$$"
  printf '[]\n' > "$BASE/sessions/$id.json"
  printf '%s\n' "$id"
}
append_msg() {
  local f="$1" role="$2" content="$3" tmp="$f.tmp"
  jq --arg r "$role" --arg c "$content" '. += [{role:$r,content:$c}]' "$f" > "$tmp" && mv "$tmp" "$f"
}
list_sessions() { find "$BASE/sessions" -maxdepth 1 -type f -name 's-*.json' -printf '%T@ %f\n' 2>/dev/null | sort -rn | head -20 | awk '{print $2}'; }
export_session() {
  local f="$BASE/sessions/$1" out="$BASE/exports/${1%.json}.md"
  [ -f "$f" ] || return 1
  jq -r '.[] | "## \(.role)\n\n\(.content)\n"' "$f" > "$out"
  printf '%s\n' "$out"
}
