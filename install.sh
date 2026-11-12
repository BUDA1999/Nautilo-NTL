#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
BASE="$HOME/ntl"
cd "$(dirname "$0")"
SOURCE="$PWD"
if [ "$SOURCE" != "$BASE" ]; then
  if [ -e "$BASE" ]; then echo "A pasta $BASE já existe; não vou sobrescrever os seus dados." >&2; exit 1; fi
  mkdir -p "$BASE"
  cp -R "$SOURCE"/. "$BASE/"
fi
if command -v pkg >/dev/null 2>&1; then pkg install -y curl jq; fi
for cmd in bash curl jq; do command -v "$cmd" >/dev/null || { echo "Dependência não encontrada: $cmd" >&2; exit 1; }; done
umask 077
mkdir -p "$BASE"/{lib,prompts,config,secrets,sessions,exports,imports,logs,state,docs} "$HOME/bin"
chmod 700 "$BASE/secrets" "$BASE/state" "$BASE/sessions" "$BASE/exports" "$BASE/imports" "$BASE/logs"
[ -f "$BASE/config/config.env" ] || cp "$BASE/config/config.env.example" "$BASE/config/config.env"
chmod 600 "$BASE/config/config.env"
chmod +x "$BASE/ntl"
if [ ! -e "$HOME/bin/ntl" ] || [ "$(readlink "$HOME/bin/ntl" 2>/dev/null || true)" = "$BASE/ntl" ]; then
  ln -sf "$BASE/ntl" "$HOME/bin/ntl"
  echo 'Comando instalado: ntl (se ~/bin estiver no PATH).'
else
  echo "Já existe $HOME/bin/ntl: não foi substituído."
fi
echo "Inicia com: ~/ntl/ntl"
