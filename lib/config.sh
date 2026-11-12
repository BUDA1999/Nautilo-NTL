#!/usr/bin/env bash
BASE="${BASE:-$HOME/ntl}"
CFG="$BASE/config/config.env"
KEY_FILE="$BASE/secrets/key"
[ -f "$CFG" ] || { echo "Configuração não encontrada: $CFG" >&2; return 1; }
# shellcheck source=/dev/null
. "$CFG"
need_key() {
  [ -s "$KEY_FILE" ] || { echo "Sem chave da API. Usa a opção a no menu."; return 1; }
  chmod 600 "$KEY_FILE"
}
save_cfg() {
  local k="$1" v="$2"
  case "$k" in MODEL|TEMPERATURE|TOP_P|MAX_TOKENS|REASONING|REASONING_BUDGET|QUOTA_LIMIT|SHOW_REASONING|SYSTEM_PROMPT_FILE|BASE_URL) ;; *) echo "Campo de configuração inválido." >&2; return 1;; esac
  if grep -q "^${k}=.*" "$CFG"; then
    sed -i "s|^${k}=.*|${k}=\"${v//|/\\|}\"|" "$CFG"
  else
    printf '%s="%s"\n' "$k" "$v" >> "$CFG"
  fi
}
quota_file() { printf '%s/state/quota-%s\n' "$BASE" "$(date +%F)"; }
quota_used() { local f; f=$(quota_file); cat "$f" 2>/dev/null || printf '0'; }
quota_left() { echo $(( QUOTA_LIMIT - $(quota_used) )); }
quota_inc() { local f n; f=$(quota_file); n=$(quota_used); printf '%s\n' "$((n + 1))" > "$f"; }
