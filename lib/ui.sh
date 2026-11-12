#!/usr/bin/env bash
# NTL · interface abissal para Termux
# Pode ser carregado pelo launcher ou executado como `bash lib/ui.sh` para demo.
shopt -s extglob
[[ ${LANG:-}${LC_ALL:-} == *UTF-8* ]] || export LANG=C.UTF-8

: "${MODEL:=ultra:free}" "${REASONING:=off}" "${USED:=0}" "${QUOTA_LIMIT:=45}" "${FALLBACK_N:=0}"
ESC=$'\033'

ui_detect() {
  local c l
  c=$(tput cols 2>/dev/null) || c=${COLUMNS:-40}
  l=$(tput lines 2>/dev/null) || l=${LINES:-24}
  [[ $c =~ ^[0-9]+$ ]] || c=40; [[ $l =~ ^[0-9]+$ ]] || l=24
  UI_W=$(( c > 44 ? 44 : c )); (( UI_W < 20 )) && UI_W=20
  if (( c >= 38 && l >= 36 )); then UI_MODE=full
  elif (( c >= 34 && l >= 23 )); then UI_MODE=compact
  else UI_MODE=minimal; fi
  if [[ -n ${NO_COLOR:-} || ${TERM:-} == dumb ]]; then UI_COLOR=none
  elif [[ ${COLORTERM:-} == @(truecolor|24bit) ]]; then UI_COLOR=24
  else UI_COLOR=256; fi
  ui_palette
}
ui_palette() {
  case $UI_COLOR in
    24)
      A=$'\033[38;2;51;226;194m'; A2=$'\033[38;2;143;232;214m'; BONE=$'\033[38;2;234;255;251m'
      DIM=$'\033[38;2;86;130;146m'; DIM2=$'\033[38;2;49;80;92m'; AMB=$'\033[38;2;232;179;65m'
      RED=$'\033[38;2;240;100;100m'; BG=$'\033[48;2;13;42;53m'
      GR=(169\;255\;238 120\;246\;222 70\;232\;204 51\;226\;194 38\;190\;164 28\;152\;132 22\;124\;110 18\;102\;92 14\;84\;77 12\;66\;62)
      GR=("${GR[@]/#/$'\033[38;2;'}"); GR=("${GR[@]/%/m}") ;;
    256)
      A=$'\033[38;5;43m'; A2=$'\033[38;5;79m'; BONE=$'\033[38;5;195m'; DIM=$'\033[38;5;66m'
      DIM2=$'\033[38;5;23m'; AMB=$'\033[38;5;179m'; RED=$'\033[38;5;167m'; BG=$'\033[48;5;236m'
      GR=(159 122 86 43 37 36 30 29 23 23); GR=("${GR[@]/#/$'\033[38;5;'}"); GR=("${GR[@]/%/m}") ;;
    *) A= A2= BONE= DIM= DIM2= AMB= RED= BG=; GR=('' '' '' '' '' '' '' '' '' '') ;;
  esac
  RST=$'\033[0m'; CLR=$'\033[K'
}
L() { OUT+="$1${RST}${CLR}"$'\n'; }
ui_rep() { local s; printf -v s '%*s' "$2" ''; REPLY=${s// /$1}; }
ui_top() {
  [[ $UI_MODE == minimal ]] && return
  local n=$(( UI_W - 5 - ${#1} )); (( n < 1 )) && n=1; ui_rep ─ "$n"
  L "${DIM2}╭─ ${A2}$1${DIM2} ${REPLY}╮"
}
ui_bot() { [[ $UI_MODE == minimal ]] && return; ui_rep ─ $(( UI_W - 2 )); L "${DIM2}╰${REPLY}╯"; }
ui_row() {
  local p=${1//$ESC\[*([0-9;])m/} n sp
  if [[ $UI_MODE == minimal ]]; then L " $1"; return; fi
  n=$(( UI_W - 4 - ${#p} )); (( n < 0 )) && n=0; printf -v sp '%*s' "$n" ''
  L "${DIM2}│${RST} $1${sp} ${DIM2}│"
}
ui_banner() {
  local art=( '      ▄▄█████▄▄' '   ▄████▀▀ ▀▀████▄' '  ████▀  ▄▄▄  ▀████' ' ███▀  ▄██▀▀██▄  ▀███'
    ' ██▀  ██▀ ▄▄ ▀██  ▀██' ' ██▄  ██▄ ▀▀ ▄██  ▄██' ' ███▄  ▀██▄▄██▀  ▄███' '  ████▄   ▀▀▀   ▄████'
    '   ▀████▄▄  ▄▄████▀' '      ▀▀█████▀▀' )
  local i pad sp
  case $UI_MODE in
    full)
      pad=$(( (UI_W - 22) / 2 )); (( pad < 0 )) && pad=0; printf -v sp '%*s' "$pad" ''
      for i in "${!art[@]}"; do L "${sp}${GR[i]}${art[i]}"; done
      L ''; printf -v sp '%*s' $(( (UI_W - 12) / 2 )) ''; L "${sp}${BONE}N T L ${DIM2}· v0.3"
      printf -v sp '%*s' $(( (UI_W - 29) / 2 )) ''; L "${sp}${DIM}nemotron no abismo · 550B"; L '' ;;
    compact)
      L " ${GR[2]}▄██▀▀██▄   ${BONE}N T L ${DIM2}· v0.3"; L " ${GR[3]}██ ▄▄ ██   ${DIM}nemotron no abismo"
      L " ${GR[5]}▀██▄▄██▀   ${DIM2}550B · 1M ctx"; L '' ;;
    *) L " ${A}◢◤ ${BONE}NTL ${DIM2}· 550B · 1M ctx" ;;
  esac
}
ui_quota_bar() {
  local w=$1 f i pct col out=''
  (( w < 1 )) && w=1
  pct=$(( QUOTA_LIMIT > 0 ? USED * 100 / QUOTA_LIMIT : 0 )); (( pct < 0 )) && pct=0
  f=$(( pct * w / 100 )); (( f > w )) && f=$w
  col=$A; (( pct >= 60 )) && col=$AMB; (( pct >= 85 )) && col=$RED
  for ((i=0; i<w; i++)); do if (( i < f )); then out+="${col}━"; else out+="${DIM2}╌"; fi; done
  REPLY=$out
}
ui_status() {
  local cnt="${USED}/${QUOTA_LIMIT}" bw
  if [[ $UI_MODE == minimal ]]; then
    L " ${A2}${MODEL:0:18} ${DIM2}· ${A}${REASONING} ${DIM2}· fb ${FALLBACK_N}"
    bw=$(( UI_W - 3 - ${#cnt} )); ui_quota_bar "$bw"; L " ${REPLY} ${DIM}${cnt}"; return
  fi
  ui_top status
  ui_row "${DIM}modelo     ${A2}${MODEL:0:$(( UI_W - 15 ))}"
  ui_row "${DIM}reasoning  ${A}${REASONING}   ${DIM}fallback ${A2}${FALLBACK_N}"
  bw=$(( UI_W - 4 - 11 - 1 - ${#cnt} )); ui_quota_bar "$bw"; ui_row "${DIM}quota      ${REPLY} ${DIM}${cnt}"
  ui_bot
}
# O launcher pode substituir UI_ITEMS. A chave `a` abre a gestão da chave.
ui_items() {
  UI_ITEMS=( "1|chat rápido|stream" "2|sessão|nova/retomar" "3|preset|system prompt"
    "4|reasoning|$REASONING" "5|parâmetros|temp/tokens" "6|modelo|${MODEL%%:*}"
    "7|sessões|exportar" "8|quota|$USED/$QUOTA_LIMIT" "9|diagnóstico|verificar" "a|chave|OpenRouter" "p|programação|criar/rever apps" "f|ficheiros|importar/exportar" "0|sair|" )
}
ui_menu() {
  local sel=$1 i it key r lab hint cell plen tail sp bl='' br=''
  local C=$(( UI_W - 2 )); [[ $UI_MODE == minimal ]] && C=$UI_W
  ui_top menu
  for i in "${!UI_ITEMS[@]}"; do
    it=${UI_ITEMS[i]}; key=${it%%|*}; r=${it#*|}; lab=${r%%|*}; hint=${r#*|}
    [[ $UI_MODE == minimal ]] && hint=
    lab=${lab:0:14}; printf -v sp '%*s' $(( 14 - ${#lab} )) ''; lab+=$sp
    local maxhint=$(( C - 20 )); (( maxhint < 0 )) && maxhint=0; hint=${hint:0:maxhint}
    plen=$(( 20 + ${#hint} )); tail=$(( C - plen )); (( tail < 0 )) && tail=0; printf -v sp '%*s' "$tail" ''
    [[ $UI_MODE != minimal ]] && { bl="${DIM2}│${RST}"; br="${DIM2}│"; }
    if (( i == sel )); then L "${bl}${BG}${A}▌ ${A2}${key}${BONE}  ${lab} ${A2}${hint}${sp}${RST}${br}"
    else L "${bl}  ${DIM2}${key}${DIM}  ${lab} ${DIM2}${hint}${sp}${br}"; fi
  done
  ui_bot
}
ui_draw() { OUT=; ui_items; ui_banner; ui_status; ui_menu "$1"; L " ${DIM2}↑↓/j k mover · enter abre · 0 sai"; printf '%s' "${ESC}[H${OUT}${ESC}[J"; }
ui_readkey() {
  local k s1 s2 s3 rc; KEY=
  IFS= read -rsn1 k; rc=$?
  (( rc > 128 )) && { KEY=RESIZE; return; }; (( rc )) && { KEY=EOF; return; }
  if [[ $k == "$ESC" ]]; then
    if IFS= read -rsn1 -t 0.05 s1; then
      if [[ $s1 == '[' || $s1 == O ]]; then
        IFS= read -rsn1 -t 0.05 s2
        case $s2 in A) KEY=UP;; B) KEY=DOWN;; 5) IFS= read -rsn1 -t 0.05 s3; KEY=PGUP;; 6) IFS= read -rsn1 -t 0.05 s3; KEY=PGDN;; *) KEY=X;; esac
      else KEY=X; fi
    else KEY=ESC; fi
  elif [[ -z $k ]]; then KEY=ENTER; else KEY=$k; fi
}
ui_pick() {
  local sel=${UI_SEL:-0} n i
  while :; do
    ui_items; n=${#UI_ITEMS[@]}; ui_draw "$sel"; ui_readkey
    case $KEY in
      j|DOWN) sel=$(( (sel + 1) % n ));; k|UP) sel=$(( (sel + n - 1) % n ));;
      PGUP) sel=0;; PGDN) sel=$((n-1));; ENTER) CHOICE=${UI_ITEMS[sel]%%|*}; UI_SEL=$sel; return 0;;
      q|EOF) return 1;; RESIZE|ESC|X) ;;
      *) for i in "${!UI_ITEMS[@]}"; do [[ ${UI_ITEMS[i]%%|*} == "$KEY" ]] && { CHOICE=$KEY; UI_SEL=$i; return 0; }; done ;;
    esac
  done
}
confirm() { local a; read -rp "$1 [s/N] " a; [[ "${a,,}" == s* ]]; }
ui_start() { ui_detect; trap ui_detect WINCH; trap 'ui_stop; exit 130' INT TERM; trap ui_stop EXIT; printf '%s' "${ESC}[?1049h${ESC}[?25l"; UI_ON=1; }
ui_stop() { [[ ${UI_ON:-0} == 1 ]] || return 0; UI_ON=0; printf '%s' "${ESC}[?25h${ESC}[?1049l${RST}"; }
# Executa uma função no ecrã normal, aguardando Enter antes de voltar ao menu.
ui_run() {
  printf '%s' "${ESC}[?25h${ESC}[H${ESC}[J"; trap ':' INT
  "$@"; local rc=$?; trap 'ui_stop; exit 130' INT
  printf '\n%s↵ enter para voltar%s' "$DIM2" "$RST"; read -rs _ || :
  printf '%s' "${ESC}[?25l"; return "$rc"
}
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  USED=${USED:-23}; ui_start
  while ui_pick; do case $CHOICE in 0) break;; *) ui_run echo "opção $CHOICE (demo)";; esac; done
  ui_stop
fi
