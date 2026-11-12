# Uso

1. Obtém uma chave em [OpenRouter](https://openrouter.ai/keys).
2. Inicia `~/ntl/ntl` e guarda a chave na opção `a`.
3. Usa chat rápido para uma pergunta isolada, sessão para histórico retomável, ou Programação (`p`) para criar/rever código. As respostas ficam em `exports/`.
4. Em Ficheiros (`f`), importa ficheiros de texto/código (até 64 KiB) ou APKs. O envio de texto ao modelo é explícito e pede confirmação; nunca envia APKs.
5. A opção de exportar copia ficheiros para `~/storage/downloads/Nautilo`. APKs são apenas copiados; não são instalados nem analisados.
6. Para permitir acesso ao armazenamento Android, executa `termux-setup-storage` e concede a permissão.
7. A quota local limita as chamadas diárias a 45 por defeito; é um contador local, não uma garantia do limite do fornecedor.
8. As conversas são guardadas localmente em `sessions/`. Exportações Markdown aparecem em `exports/`.

A versão `:free` pode registar pedidos para melhoria/treino segundo os termos do fornecedor. Não envies dados confidenciais, chaves, credenciais, dados de clientes ou informação bancária.
