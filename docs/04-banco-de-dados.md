# 4. Banco de dados

O banco do processador não guarda dados pessoais: chaves Pix e carteiras ficam no IdentityStore, e o processador só registra os ids que ele gera. As tabelas ficam em *schemas*: `core` para o que vale para qualquer trilho e um *schema* por trilho de pagamento.

No diagrama, as tabelas aparecem agrupadas pelo papel que cumprem, e não pelo *schema*; o prefixo do nome (`core.`, `pix.`, `ethereum.`) continua mostrando a qual *schema* cada uma pertence.

**Tabelas imutáveis.** As tabelas marcadas como `«imutável»` (em verde no diagrama) nunca têm linhas alteradas nem apagadas: cada fato é gravado uma vez e permanece como registro. São as extensões do pagamento, o livro-razão com suas extensões e o MED. O banco garante isso por permissão: o papel da aplicação só recebe `SELECT` e `INSERT` nessas tabelas. As demais (`core.merchants`, `core.identity_stores`, `core.payments`, `core.jobs`, `core.idempotency_keys` e `ethereum.chain_cursor`) guardam estado corrente e podem ser atualizadas; o histórico do pagamento fica nas tabelas imutáveis.

**Participantes** — quem participa dos pagamentos.

| Tabela | Papel |
|---|---|
| `core.merchants` | Lojista: usuário no Keycloak, nome de exibição, IdentityStore e titular onde estão seus dados |
| `core.identity_stores` | IdentityStores inscritos e o certificado vigente de cada um |

**Pagamento** — o pagamento e suas extensões por trilho. Cada extensão tem uma linha por pagamento (chave primária = `payment_id`), gravada uma vez, com o que aquele trilho precisa para executar o pagamento.

| Tabela | Papel |
|---|---|
| `core.payments` | Dados comuns a todo pagamento: trilhos de origem e de destino (qualquer combinação), valor, ativo, estado e validade. `amount` é inteiro, na menor unidade do ativo (centavos para BRL, wei para ETH) |
| `pix.charges` | Cobrança Pix (pagador em Pix): `txid` e BR Code |
| `pix.payouts` | Envio Pix ao lojista: chave de destino escolhida na criação |
| `ethereum.charges` | Cobrança em ETH (pagador em ETH): `onchain_id` usado em `pay()` e valor cotado; a validade da cotação é o `expires_at` do pagamento |
| `ethereum.payouts` | Envio em ETH ao lojista: carteira de destino escolhida na criação |
| `ethereum.holds` | Retenção no contrato antes da liberação ao lojista |

**Livro-razão** — como o dinheiro se moveu, por partidas dobradas, e a prova de cada movimento no trilho. As extensões apontam só para o lançamento (`entry_id`); o pagamento é alcançado por ele.

| Tabela | Papel |
|---|---|
| `core.journal_entries` | Um lançamento por movimento de dinheiro, com um tipo que não depende do trilho |
| `core.postings` | Partidas de cada lançamento (conta, ativo, valor; positivo entra, negativo sai). Um gatilho `DEFERRABLE` confere no `COMMIT` que somam zero por ativo. Neutralidade: ao fim de cada pagamento, `GATEWAY` e `ESCROW` somam zero |
| `pix.transfers` | Extensão do lançamento: o Pix recebido, enviado ou devolvido que o comprova, com o `endToEndId` |
| `ethereum.transactions` | Extensão do lançamento: o evento do contrato que o comprova (pagamento, retenção, liberação, encaminhamento, reembolso, recuperação), com `txHash` e `logIndex` |

**MED** — casos de devolução abertos pelo banco do pagador.

| Tabela | Papel |
|---|---|
| `pix.meds` | Um MED aberto para um pagamento |
| `pix.med_events` | Cada mudança de situação do MED; a situação atual é o evento mais recente |

**Processamento** — o que move os pagamentos adiante.

| Tabela | Papel |
|---|---|
| `core.jobs` | Fila de tarefas: as réplicas buscam com `FOR UPDATE SKIP LOCKED`; `dedup_key` único descarta eventos repetidos (`pix:{endToEndId}`, `eth:{txHash}:{logIndex}`) |
| `core.idempotency_keys` | Idempotência de qualquer criação da API: `scope_id` é quem enviou a chave, `resource_id` o recurso criado e `request_hash` cobre método, caminho e corpo (a mesma chave com outro pedido dá 422). Apagada depois de `expires_at` (ex.: 24 h) |
| `ethereum.chain_cursor` | Último bloco lido da *blockchain* |

Ids entre serviços (o id do lojista no IdentityStore, o usuário no Keycloak) não são garantidos pelo banco: são referências lógicas que a aplicação mantém consistentes. Credenciais de API ficam no Keycloak; o desafio de assinatura da carteira (SIWE) não é guardado, porque volta assinado pelo próprio servidor.

## Processador

![ER do processador](diagrams/svg/banco-de-dados/er-processador.svg)

[Fonte](diagrams/src/banco-de-dados/er-processador.puml)

## IdentityStore

Guarda todos os dados pessoais do sistema, cifrados pela aplicação, e gera os próprios ids: o titular (`core.owners`: nome e CPF/CNPJ) e um *schema* por trilho de pagamento (`pix.keys`, `ethereum.wallets`), cada um com as tabelas e os campos do seu trilho.

![ER do IdentityStore](diagrams/svg/banco-de-dados/er-identitystore.svg)

[Fonte](diagrams/src/banco-de-dados/er-identitystore.puml)
