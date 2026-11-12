# Limites e privacidade

- O telemóvel faz pedidos HTTP; o modelo é executado remotamente. A latência e disponibilidade dependem da rede e do serviço.
- A quota local (45/dia por defeito) é apenas uma trava preventiva deste cliente. Não representa nem consulta em tempo real a quota da conta.
- Os modelos e limites do OpenRouter podem mudar. Confirma os valores atuais na documentação oficial antes de depender deles.
- Não guardamos a chave no Git: `secrets/key` tem permissões 600 e está excluída pelo `.gitignore`.
- A versão gratuita pode ter políticas de retenção/uso próprias do fornecedor. Trata cada pedido como não confidencial.
- O histórico das sessões fica em texto simples no aparelho. Protege o dispositivo e apaga as sessões sensíveis manualmente.
