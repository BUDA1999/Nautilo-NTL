#!/usr/bin/env bash
C_R='\033[0m'; C_D='\033[2m'; C_G='\033[38;5;118m'; C_Y='\033[33m'
hr() { printf '%b\n' "${C_D}────────────────────────────────────────${C_R}"; }
header() {
  clear
  printf '%b' "$C_G"
  cat <<'TXT'
  ◢◤ ntl — nemotron no abismo
TXT
  printf '%b' "$C_R"; hr
  printf '  modelo : %s\n' "$MODEL"
  printf '  reasoning: %s   quota: %s/%s   tokens: %s\n' "$REASONING" "$((QUOTA_LIMIT - $(quota_left)))" "$QUOTA_LIMIT" "$MAX_TOKENS"
  hr
}
confirm() { local a; read -rp "$1 [s/N] " a; [[ "${a,,}" == s* ]]; }
