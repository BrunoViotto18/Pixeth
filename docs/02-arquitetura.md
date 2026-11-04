# 2. Arquitetura

## Decisões principais

- **Arquitetura hexagonal.** O núcleo só conhece portas: trilhos de pagamento (`PaymentRail`), conversão (`ConversionProvider`), IdentityStore, notificação e persistência. Cada integração é um adaptador substituível.
- **Crescimento linear.** Um novo sistema de pagamento (Bitcoin, boleto, cartões) entra com um novo adaptador de `PaymentRail`, sem adaptadores por par de sistemas.
- **Criação síncrona, o resto assíncrono.** Criar o pagamento é uma chamada síncrona e idempotente (o `PUT /cob/{txid}` do PSP pode ser repetido com segurança). O que acontece depois do pagamento roda em tarefas gravadas no PostgreSQL na mesma transação do fato que as gerou e executadas por qualquer réplica (`FOR UPDATE SKIP LOCKED`). Não há *broker* de mensagens.
- **Conversão terceirizada e agnóstica.** A conversão BRL ⇄ ETH fica atrás de `ConversionProvider`; no TCC, uma implementação simulada. O Pixeth recebe o pagamento e encaminha ao provedor o valor de cada pagamento (Pix ou `forward()`), sem saldo pré-pago e sem depender de recursos de um PSP ou provedor específico.
- **Retenção fixa para MED.** No sentido Pix → Ethereum, o ETH fica retido no contrato por uma janela configurável antes de ser liberado ao lojista, para que um MED ainda possa ser atendido.

## Portas e adaptadores

![Arquitetura hexagonal](diagrams/svg/arquitetura/componentes-hexagonal.svg)

[Fonte](diagrams/src/arquitetura/componentes-hexagonal.puml)

![Portas e implementações](diagrams/svg/arquitetura/portas-e-adaptadores.svg)

[Fonte](diagrams/src/arquitetura/portas-e-adaptadores.puml)

Cada tipo de tarefa é um passo do pagamento, igual para qualquer trilho; o trilho vem do pagamento (`source_rail` ou `destination_rail`), e a tarefa chama o adaptador correspondente:

| Tarefa | Porta e operação | Trilho |
|---|---|---|
| `CONFIRM_PAYMENT` | `PaymentRail.confirmPayment` | origem |
| `FORWARD` | `ConversionProvider.createOrder` + `PaymentRail.forward` (paga a cobrança do provedor) | origem |
| `CONVERT` | `ConversionProvider.getOrder` (entrega do ativo convertido) | — |
| `PAY_OUT` | `PaymentRail.payOut` | destino |
| `RELEASE` | `HoldingRail.release` | destino, se retém |
| `RECOVER` | `HoldingRail.recover` | destino, se retém |
| `REFUND` | `PaymentRail.refund` | origem |
