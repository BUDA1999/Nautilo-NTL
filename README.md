# NÁUTILO (`ntl`)

![Logótipo do NÁUTILO](assets/nautilo-logo.png)

Cliente para Termux que conversa com modelos remotos através do OpenRouter. O modelo não corre no telemóvel: é necessário acesso à internet e uma chave OpenRouter.

## Instalar no Termux

O repositório é público e pode ser clonado sem autenticação no GitHub.

```bash
pkg update && pkg install git -y
git clone https://github.com/BUDA1999/Nautilo-NTL.git ~/ntl
cd ~/ntl && bash install.sh
```

Inicia com `ntl` se `~/bin` estiver no PATH, ou com `~/ntl/ntl`. No menu `a` (chave), cola a chave OpenRouter; não a coloques no GitHub, em capturas de ecrã ou nesta conversa.

Se já tiveres uma pasta `~/ntl`, faz cópia dos dados antes de instalar ou atualizar. O instalador não substitui uma pasta existente quando iniciado a partir de outra localização. As atualizações via Git podem exigir resolução de conflitos; mantém chave e conversas fora do repositório.

## Funções

Chat rápido e sessões locais retomáveis; modo **Programação** (`p`) com prompt especializado para apps/código; menu **Ficheiros** (`f`) para importar ficheiros e APKs do armazenamento do Termux e exportar respostas/ficheiros para `Downloads/Nautilo`; streaming; escolha manual de modelo, reasoning e preset; trava local diária desativada por defeito (`QUOTA_LIMIT=0`); o contador de pedidos continua ativo. Podes ativar uma trava definindo `QUOTA_LIMIT` acima de zero no `config/config.env`. Isso não altera os limites, custos ou disponibilidade do OpenRouter: o uso continua sujeito às regras do fornecedor e pode gerar custos se escolheres modelos pagos. Esta trava não consulta os limites reais da conta nem sincroniza outros dispositivos. Os modelos gratuitos podem ficar indisponíveis ou mudar sem aviso. Não existe fallback automático.

## Navegação e ficheiros

Usa as setas ou `j`/`k` para mudar a opção e Enter para abrir; também podes usar as teclas indicadas diretamente. `a` abre a configuração da chave, `p` inicia o modo Programação, `f` abre Ficheiros, `0`/`q` sai. O menu é de terminal: não há toque direto nos itens.

Antes de importar/exportar entre Termux e Android, executa `termux-setup-storage` e concede a permissão. Importa pelo caminho completo, por exemplo `~/storage/shared/Download/projeto.py`. O programa copia o ficheiro para `~/ntl/imports`; ficheiros de texto/código estão limitados a 64 KiB. Só o envio explícito de texto ao modelo transmite o conteúdo ao OpenRouter, e pede confirmação antes; não seleciones APK para esse envio. Exportação copia respostas, textos ou APKs para `~/storage/downloads/Nautilo`. APKs são apenas copiados: não são inspecionados, instalados ou validados. Se o nome de destino existir, é pedida confirmação para substituir.

## Segurança

O fornecedor processa o texto remotamente e os termos de retenção variam por modelo e fornecedor: consulta as políticas atuais e não envies dados confidenciais. Chave, estado e sessões ficam no aparelho e são excluídos do Git. O cliente não executa comandos ou ferramentas sugeridos pelo modelo.

## Testes

`bash tests/test.sh` testa instalação simulada, sintaxe, sessões, streaming simulado e quota. O workflow `.github/workflows/test.yml` executa os testes no GitHub Actions em Linux, sem chave real. Não substitui um teste no Termux nem uma chamada real à API.
