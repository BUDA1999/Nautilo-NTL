# Changelog

## 0.3.0
- Menu abissal com banner, barra de quota e desenho adaptável ao terminal.
- Navegação por setas, j/k, Enter e teclas de atalho; opção `a` para a chave.
- Menu ligado às funções reais e testes dos três tamanhos em Linux.
- Teste no dispositivo e com chave real ainda pendente.

## 0.2.0
- Instalação Termux com dependências, permissões privadas e atalho `ntl` em `~/bin`.
- Retoma de sessões, e conversas gravadas apenas depois de resposta concluída.
- Streaming preserva quebras de linha; respostas interrompidas e erros não são aceites como sucesso.
- Chave não é passada como argumento ao processo curl; remoção do referer fictício.
- Testes automatizados sem rede e GitHub Actions; a validação em Linux não substitui o teste no Termux.
- Razões ocultas por defeito, quota local preventiva e dados locais excluídos do Git.

## 0.1.0
- Primeira versão do menu, presets, sessões e exportação.
