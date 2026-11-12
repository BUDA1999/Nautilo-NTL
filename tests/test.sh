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
. "$BASE/lib/config.sh"; . "$BASE/lib/session.sh"; . "$BASE/lib/api.sh"
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
chat_stream '' 'Como estás?' "$file" >/dev/null
printf 'Olá\nmundo' > "$T/expected"; cmp "$T/expected" "$LAST_RESPONSE_FILE"
export TEST_MODE=fail
if chat_stream '' 'erro' "$file" >/dev/null; then echo 'Erro SSE foi aceite como sucesso' >&2; exit 1; fi
[ "$(quota_used)" = 3 ]
QUOTA_LIMIT=3
if chat_stream '' 'sem quota' "$file" >/dev/null; then echo 'Trava de quota falhou' >&2; exit 1; fi
# O menu arranca e sai em Linux sem executar o shebang de Termux.
TERM=xterm bash "$BASE/ntl" <<<'0' > "$T/menu.txt"
grep -q 'ntl — nemotron' "$T/menu.txt"
echo 'Testes concluídos: sintaxe, instalação, permissões, menu, sessões, exportação, SSE, erro e quota.'
