# Pix → Ethereum

O pagador paga um QR Code Pix ao Pixeth. O Pixeth cria um pedido no provedor de conversão, com o `paymentId` como referência, e paga a cobrança Pix do provedor (`FORWARDED`), como faz com `forward()` no sentido Ethereum → Pix. O provedor deposita o ETH no contrato com `hold()`, e o valor fica retido por uma janela configurável antes de ser liberado à carteira do lojista (ver [Retenção e MED](retencao-e-med.md)).

O Pixeth não depende de recursos de um PSP ou provedor específico: cada pagamento leva seu próprio dinheiro ao provedor, sem saldo pré-pago compartilhado, e qualquer PSP ou provedor que ofereça cobrança e envio de Pix pode ser plugado.

## Sequência

![Pagamento Pix para Ethereum](../diagrams/svg/fluxos/seq-pix-para-ethereum.svg)

[Fonte](../diagrams/src/fluxos/seq-pix-para-ethereum.puml)

## Processamento do Pix recebido

![Processamento do Pix recebido](../diagrams/svg/fluxos/atv-pix-recebido.svg)

[Fonte](../diagrams/src/fluxos/atv-pix-recebido.puml)
