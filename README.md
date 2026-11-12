# NÁUTILO (`ntl`)

Cliente para Termux que conversa com modelos remotos através do OpenRouter. O modelo não corre no telemóvel: é necessário acesso à internet e uma chave OpenRouter.

## Instalar no Termux

O repositório é privado. O Git precisa de acesso à conta GitHub autorizada; se pedir autenticação, usa um método compatível com o GitHub (não escrevas a palavra-passe da conta no terminal).

```bash
pkg update && pkg install git -y
git clone https://github.com/BUDA1999/Nautilo-NTL.git ~/ntl
cd ~/ntl && bash install.sh
```

Inicia com `ntl` se `~/bin` estiver no PATH, ou com `~/ntl/ntl`. No menu `a` (chave), cola a chave OpenRouter; não a coloques no GitHub, em capturas de ecrã ou nesta conversa.

Se já tiveres uma pasta `~/ntl`, faz cópia dos dados antes de instalar ou atualizar. O instalador não substitui uma pasta existente quando iniciado a partir de outra localização. As atualizações via Git podem exigir resolução de conflitos; mantém chave e conversas fora do repositório.

## Funções

Chat rápido e sessões locais retomáveis; streaming; escolha manual de modelo, reasoning e preset; exportação Markdown; trava local de 45 pedidos/dia configurável. Esta trava não consulta os limites reais da conta nem sincroniza outros dispositivos. Os modelos gratuitos podem ficar indisponíveis ou mudar sem aviso. Não existe fallback automático.

## Navegação

Usa as setas ou `j`/`k` para mudar a opção e Enter para abrir; também podes usar as teclas indicadas diretamente. A tecla `a` abre a configuração da chave, `0` ou `q` sai. A interface é de terminal e não suporta toque direto nos itens. O menu adapta-se ao tamanho da janela; se o banner ficar cortado, diminui o tamanho da letra no Termux.

## Segurança

O fornecedor processa o texto remotamente e os termos de retenção variam por modelo e fornecedor: consulta as políticas atuais e não envies dados confidenciais. Chave, estado e sessões ficam no aparelho e são excluídos do Git. O cliente não executa comandos ou ferramentas sugeridos pelo modelo.

## Testes

`bash tests/test.sh` testa instalação simulada, sintaxe, sessões, streaming simulado e quota. O workflow `.github/workflows/test.yml` executa os testes no GitHub Actions em Linux, sem chave real. Não substitui um teste no Termux nem uma chamada real à API.
