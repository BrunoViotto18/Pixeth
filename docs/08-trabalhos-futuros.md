# 8. Trabalhos futuros

Itens que um sistema em produção precisaria e que ficaram fora do escopo do TCC:

| Tema | O que ficou de fora |
|---|---|
| Contabilidade | Reconciliação do livro-razão com o saldo no PSP e na *blockchain* |
| MED | Reserva do lojista e compensação em recebíveis para MEDs aceitos depois da liberação, retenção quando o destino é Pix, defesa do *gateway* como terceiro de boa-fé na análise do PSP e contestação de devoluções indevidas (até 80 dias) |
| Conversão | Integração com um provedor real e roteamento entre vários provedores |
| Risco e conformidade | Verificação completa de lojistas (KYB: validar o CPF/CNPJ em bases oficiais), triagem de endereços, pontuação de risco, limites por lojista |
| Reembolsos | Reembolsos solicitados pelo lojista (hoje: apenas estornos automáticos) |
| Contas | Vários usuários e papéis por lojista, recuperação assistida, período de carência ao trocar destinos |
| Integração | Certificados de cliente e *tokens* vinculados (RFC 8705) para os sistemas dos lojistas, modo de teste separado |
| Notificações | *Webhooks* assinados para o sistema do lojista a cada mudança de estado de um pagamento (hoje o lojista consulta a API) |
| Operação | Tratamento de pagamentos em `FAILED` (reexecução ou devolução automática depois que as tentativas se esgotam), conferência de cobranças Pix cujo *webhook* se perdeu, pausa graduada, limitação de taxa compartilhada entre réplicas, mensageria com Kafka |
| IdentityStores | Inscrição automática com *token* de uso único (hoje o operador envia o CSR manualmente) |
| Ativos e trilhos | *Tokens* ERC-20, outras redes EVM, Bitcoin, boleto e cartões |
| Pagamento em ETH | Endereço por pagamento (CREATE2 ou carteira HD) para aceitar envios de *exchanges*, que não chamam `pay(paymentId)` |
