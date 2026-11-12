# Limites e privacidade

- O telemóvel faz pedidos HTTP; o modelo é executado remotamente. A latência e disponibilidade dependem da rede e do serviço.
- Por defeito, a trava local está desativada (`QUOTA_LIMIT=0`); o contador de pedidos continua ativo. Um valor positivo reativa a trava. O cliente não consulta a quota real da conta e o OpenRouter continua a impor limites, podendo haver custos em modelos pagos.
- Os modelos e limites do OpenRouter podem mudar. Confirma os valores atuais na documentação oficial antes de depender deles.
- Não guardamos a chave no Git: `secrets/key` tem permissões 600 e está excluída pelo `.gitignore`.
- A versão gratuita pode ter políticas de retenção/uso próprias do fornecedor. Trata cada pedido como não confidencial.
- O histórico das sessões fica em texto simples no aparelho. Protege o dispositivo e apaga as sessões sensíveis manualmente.
