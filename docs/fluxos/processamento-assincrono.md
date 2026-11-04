# Processamento assíncrono

O PostgreSQL faz o papel de fila: o fato (lançamento e extensão do trilho) e a próxima tarefa são gravados na mesma transação, e qualquer réplica pode executar qualquer tarefa. A deduplicação usa restrições únicas, sem travas distribuídas:

| Onde | Chave | Mecanismo |
|---|---|---|
| API | `Idempotency-Key` | chave primária `(scope_id, key)` em `core.idempotency_keys`; repetição devolve o recurso criado |
| *Webhooks* do PSP | `endToEndId` | tarefa com `dedup_key = pix:{endToEndId}` |
| Eventos da *blockchain* | `txHash:logIndex` | tarefa com `dedup_key = eth:{txHash}:{logIndex}` |
| Passos do pagamento | tipo + pagamento | tarefa com `dedup_key = {tipo}:{paymentId}`: cada passo roda uma vez por pagamento |
| Fatos no trilho | id do trilho | `end_to_end_id`, `(tx_hash, log_index)` e `(provider, provider_order_id)` únicos nas extensões |
| Chamadas externas | chave do sistema externo | `txid`, id da devolução, `paymentId` |

![Processamento assíncrono](../diagrams/svg/fluxos/seq-processamento-assincrono.svg)

[Fonte](../diagrams/src/fluxos/seq-processamento-assincrono.puml)
