#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export HOME="$T/home" BASE="$T/home/ntl"; mkdir -p "$BASE" "$HOME/bin" "$T/mock"
cp -R "$ROOT"/. "$BASE/"
# Installer em Linux; mocks sem modificar o dispositivo.
printf '#!/usr/bin/env bash\nexit 0\n' > "$T/mock/pkg"; chmod +x "$T/mock/pkg"
export PATH="$T/mock:$PATH"
bash "$BASE/install.sh" >/dev/null
for f in "$BASE/ntl" "$BASE/install.sh" "$BASE"/lib/*.sh; do bash -n "$f"; done
jq -e '.primary and (.fallback|type == "array")' "$BASE/models.json" >/dev/null
[ "$(stat -c %a "$BASE/secrets")" = 700 ]
[ -f "$BASE/config/config.env" ] && [ "$(stat -c %a "$BASE/config/config.env")" = 600 ]
[ -L "$HOME/bin/ntl" ]
[ -d "$BASE/imports" ] && [ "$(stat -c %a "$BASE/imports")" = 700 ]
. "$BASE/lib/config.sh"; . "$BASE/lib/session.sh"; . "$BASE/lib/api.sh"; . "$BASE/lib/files.sh"; . "$BASE/lib/ui.sh"
# Importa código local e APK como cópias apenas; não inicia instalação nem execução.
mkdir -p "$T/source" "$HOME/storage/shared" "$HOME/storage/downloads"
printf 'print(42)\n' > "$T/source/demo.py"
printf 'fake-apk-bytes\000\377' > "$T/source/demo.apk"
printf 'not a supported file' > "$T/source/demo.exe"
FILE_MAX_TEXT_BYTES=64
# Importação interactiva exercitada com entrada predefinida.
cp "$T/source/demo.py" "$HOME/demo.py"
files_import <<<'~/demo.py' >/dev/null
files_import <<<"$T/source/demo.apk" >/dev/null
if files_import <<<"$T/source/demo.exe" >/dev/null 2>&1; then echo 'Extensão não permitida foi aceite' >&2; exit 1; fi
imp_py=$(find "$BASE/imports" -name '*.py' -type f); imp_apk=$(find "$BASE/imports" -name '*.apk' -type f)
cmp "$T/source/demo.py" "$imp_py"; cmp "$T/source/demo.apk" "$imp_apk"
# Exporta um APK para Downloads sem lhe alterar bytes nem instalá-lo.
printf '[]\\n' > "$BASE/state/empty-history.json"
files_select_import() { FILE_SELECTED="$imp_apk"; }
files_export <<<'1' >/dev/null
cmp "$T/source/demo.apk" "$HOME/storage/downloads/Nautilo/$(basename "$imp_apk")"
ui_items; [ "${UI_ITEMS[10]%%|*}" = p ] && [ "${UI_ITEMS[11]%%|*}" = f ]
. "$BASE/lib/config.sh"; . "$BASE/lib/session.sh"; . "$BASE/lib/api.sh"; . "$BASE/lib/files.sh"; . "$BASE/lib/ui.sh"
mkdir -p "$BASE/secrets"; printf 'fake-test-key' > "$KEY_FILE"
[ "$(quota_used)" = 0 ]; quota_inc; [ "$(quota_used)" = 1 ]
id=$(new_session); file="$BASE/sessions/$id.json"
append_msg "$file" user 'Olá'; append_msg "$file" assistant 'Resposta'
jq -e 'length==2 and .[1].content=="Resposta"' "$file" >/dev/null
out=$(export_session "$id.json"); grep -q Resposta "$out"
# Mock de streaming: preserva nova linha, inclui o histórico e devolve [DONE].
cat > "$T/mock/curl" <<'MOCK'
#!/usr/bin/env bash
if [ "${TEST_MODE:-ok}" = fail ]; then echo 'data: {"error":{"message":"limite"}}'; echo 'data: [DONE]'; exit 0; fi
printf '%s\n' 'data: {"choices":[{"delta":{"content":"Olá\n"}}]}' 'data: {"choices":[{"delta":{"content":"mundo"}}]}' 'data: [DONE]'
MOCK
chmod +x "$T/mock/curl"
# APK reject path must occur before confirmation and never reaches chat_stream.
files_select_import() { FILE_SELECTED="$imp_apk"; }
declare -f chat_stream > "$T/chat_stream.original"
chat_stream() { echo 'APK unexpectedly sent to model' >&2; return 99; }
if files_send_text '' </dev/null >/dev/null 2>&1; then echo 'APK aceito para envio ao modelo' >&2; exit 1; fi
unset -f chat_stream; . "$T/chat_stream.original"
chat_stream '' 'Como estás?' "$file" >/dev/null
printf 'Olá\nmundo' > "$T/expected"; cmp "$T/expected" "$LAST_RESPONSE_FILE"
export TEST_MODE=fail
if chat_stream '' 'erro' "$file" >/dev/null; then echo 'Erro SSE foi aceite como sucesso' >&2; exit 1; fi
[ "$(quota_used)" = 3 ]
QUOTA_LIMIT=3
if chat_stream '' 'sem quota' "$file" >/dev/null; then echo 'Trava de quota falhou' >&2; exit 1; fi
# Sem trava local: quota zero não bloqueia mesmo depois de 45 pedidos; o contador persiste.
QUOTA_LIMIT=0; TEST_MODE=ok
for _ in $(seq 1 45); do quota_inc; done
[ "$(quota_used)" -gt 45 ] && [ "$(quota_left)" -gt 1000 ]
chat_stream '' 'após 45 pedidos' "$file" >/dev/null
[ "$(quota_used)" -gt 45 ]
# Com QUOTA_LIMIT positivo, o bloqueio continua a funcionar.
QUOTA_LIMIT=2
if chat_stream '' 'limite reativado' "$file" >/dev/null; then echo 'Trava reativada falhou' >&2; exit 1; fi
# Interface desenhada e saída limpa em terminal não interativo.
TERM=xterm COLUMNS=44 LINES=36 bash "$BASE/ntl" <<<'0' > "$T/menu.txt"
grep -q 'nemotron no abismo' "$T/menu.txt"
grep -q 'reasoning' "$T/menu.txt"
grep -q 'sessão' "$T/menu.txt"
# Menus compact/minimal carregam e respondem também à tecla q.
TERM=xterm COLUMNS=36 LINES=24 bash "$BASE/ntl" <<<'q' > "$T/compact.txt"
TERM=dumb COLUMNS=28 LINES=10 bash "$BASE/ntl" <<<'q' > "$T/minimal.txt"
grep -q '550B' "$T/minimal.txt"
# Testa o fluxo real num pseudo-terminal, se Python estiver disponível.
if command -v python3 >/dev/null 2>&1; then
  python3 "$BASE/tests/test_pty.py" "$BASE"
fi
echo 'Testes concluídos: sintaxe, instalação, permissões, interface 3 modos, menu, sessões, exportação, SSE, erro e quota.'
