# 4. Banco de dados

O banco do processador não guarda dados pessoais: chaves Pix e carteiras ficam no IdentityStore, e o processador só registra os ids que ele gera. As tabelas ficam em *schemas*: `core` para o que vale para qualquer trilho e um *schema* por trilho de pagamento.

| Tabela | Papel |
|---|---|
| `core.merchants` | Lojista: usuário no Keycloak, nome de exibição, IdentityStore e titular onde estão seus dados |
| `core.payments` | Dados comuns a todo pagamento: trilhos de origem e de destino, valor e ativo, estado |
| `core.idempotency_keys` | Chaves de idempotência de qualquer criação da API (`resource_id` = recurso criado), apagadas depois de expirar |
| `core.journal_entries` | Livro-razão: um lançamento por movimento de dinheiro, com o identificador externo (`endToEndId` ou `txHash`) |
| `core.postings` | Partidas de cada lançamento (conta, ativo, valor); somam zero por ativo |
| `core.jobs` | Fila de tarefas e deduplicação: `dedup_key` único descarta eventos repetidos |
| `core.identity_stores` | IdentityStores inscritos e o certificado vigente de cada um |
| `pix.charges` | Cobrança Pix de um pagamento, com a situação de MED |
| `ethereum.charges` | Cobrança em ETH de um pagamento (valor cotado e validade) |
| `pix.payouts` | Envio Pix ao lojista: chave de destino escolhida na criação |
| `ethereum.payouts` | Envio em ETH ao lojista: carteira de destino escolhida na criação |
| `ethereum.holds` | Retenção no contrato antes da liberação ao lojista |
| `ethereum.chain_cursor` | Último bloco lido da *blockchain* |

Ids entre serviços (o id do lojista no IdentityStore, o usuário no Keycloak) não são garantidos pelo banco: são referências lógicas que a aplicação mantém consistentes. Credenciais de API ficam no Keycloak; o desafio de assinatura da carteira (SIWE) não é guardado, porque volta assinado pelo próprio servidor.

## Processador

![ER do processador](diagrams/svg/banco-de-dados/er-processador.svg)

[Fonte](diagrams/src/banco-de-dados/er-processador.puml)

## IdentityStore

Guarda todos os dados pessoais do sistema, cifrados pela aplicação, e gera os próprios ids: o titular (`core.owners`: nome e CPF/CNPJ) e um *schema* por trilho de pagamento (`pix.keys`, `ethereum.wallets`), cada um com as tabelas e os campos do seu trilho.

![ER do IdentityStore](diagrams/svg/banco-de-dados/er-identitystore.svg)

[Fonte](diagrams/src/banco-de-dados/er-identitystore.puml)
