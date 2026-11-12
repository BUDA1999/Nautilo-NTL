# Estrutura do NÁUTILO

- `ntl`: menu e launcher (`~/ntl/ntl`)
- `lib/api.sh`: pedidos streaming ao endpoint OpenAI-compatible
- `lib/session.sh`: histórico JSON e exportação Markdown
- `lib/config.sh`: configuração, chave e quota diária local
- `config/config.env`: preferências locais (ignorada pelo Git)
- `secrets/key`: chave OpenRouter (ignorada pelo Git, permissões 600)
- `models.json`: modelo principal e alternativas
- `prompts/`: presets de sistema
- `sessions/`, `exports/`, `logs/`, `state/`: dados locais

`X-Title` enviado ao OpenRouter é `ntl`. Não é enviado `HTTP-Referer` de domínio fictício.
