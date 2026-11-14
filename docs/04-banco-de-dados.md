# 4. Banco de dados

O banco do processador não guarda dados pessoais: chaves Pix e carteiras ficam no IdentityStore, e o processador só registra os ids que ele gera. As tabelas ficam em *schemas*: `core` para o que vale para qualquer trilho e um *schema* por trilho de pagamento.

No diagrama, as tabelas aparecem agrupadas pelo papel que cumprem, e não pelo *schema*; o prefixo do nome (`core.`, `pix.`, `ethereum.`) continua mostrando a qual *schema* cada uma pertence.

**Tabelas imutáveis.** As tabelas marcadas como `«imutável»` (em verde no diagrama) nunca têm linhas alteradas nem apagadas: cada fato é gravado uma vez e permanece como registro. São o pagamento e suas extensões, o livro-razão com suas extensões e o MED com suas decisões. O banco garante isso por permissão: o papel da aplicação só recebe `SELECT` e `INSERT` nessas tabelas. As demais (`core.merchants`, `core.identity_stores`, `core.jobs`, `core.idempotency_keys` e `ethereum.chain_cursor`) guardam configuração ou estado operacional e podem ser atualizadas; nada do que aconteceu com um pagamento é sobrescrito.

**Datas.** `created_at` existe nas tabelas que registram algo por si (lojistas, IdentityStores, pagamentos, lançamentos, MEDs, tarefas e chaves de idempotência); as extensões e as partidas valem desde a criação da linha a que pertencem. `updated_at` só existe nas tabelas que mudam.

**Participantes** — quem participa dos pagamentos.

| Tabela | Papel |
|---|---|
| `core.merchants` | Lojista: usuário no Keycloak, nome de exibição, IdentityStore e titular onde estão seus dados |
| `core.identity_stores` | IdentityStores inscritos e o certificado vigente de cada um |

**Pagamento** — o pagamento e suas extensões por trilho. Cada extensão tem uma linha por pagamento (chave primária = `payment_id`), gravada uma vez, com o que aquele trilho precisa para executar o pagamento. Um gatilho confere no `COMMIT` que cada pagamento tem exatamente uma cobrança e um destino, nos *schemas* de `source_rail` e `destination_rail`.

| Tabela | Papel |
|---|---|
| `core.payments` | Dados comuns a todo pagamento, fixados na criação: trilhos de origem e de destino (qualquer combinação), valor do pagamento, ativo e validade. `amount` é inteiro, na menor unidade do ativo (centavos para BRL, wei para ETH) |
| `pix.charges` | Cobrança Pix (pagador em Pix): `txid`, BR Code e o valor a pagar, em BRL |
| `pix.payouts` | Envio Pix ao lojista: chave de destino escolhida na criação |
| `ethereum.charges` | Cobrança em ETH (pagador em ETH): `onchain_id` usado em `pay()` e o valor a pagar, em ETH |
| `ethereum.payouts` | Envio em ETH ao lojista: carteira de destino escolhida na criação |
| `ethereum.holds` | Retenção no contrato antes da liberação ao lojista. `release_at` é a data marcada na retenção; se um MED a congelar, o contrato adia a liberação pelo tempo congelado |

O valor do pagamento (`core.payments.amount`) pode estar em qualquer ativo. O valor a pagar fica na cobrança, sempre no ativo do trilho de origem: é o próprio valor do pagamento ou, quando o ativo é outro, o valor cotado na criação, válido até o `expires_at` do pagamento.

O estado do pagamento não é gravado: a visão `core.payment_current_status` o deriva, com o tipo `core.payment_status`, do livro-razão, das tarefas e do prazo, na ordem abaixo (vale a primeira regra que se aplica). Como as contas das partidas não dependem do trilho, as regras valem para qualquer trilho, e o estado nunca diverge do que aconteceu com o dinheiro; a única regra que olha para um trilho é a de `REVERSED`, porque o MED só existe no Pix.

| Estado | Regra |
|---|---|
| `FAILED` | o pagamento tem uma tarefa em `FAILED` (as tentativas automáticas se esgotaram) |
| `REVERSED` | o pagamento tem uma devolução por MED (`pix.transfers` com `MED_RETURNED`) |
| `REFUNDED` | alguma partida credita `PAYER` (o dinheiro voltou ao pagador) |
| `COMPLETED` | alguma partida credita `MERCHANT` |
| `PROCESSING` | alguma partida debita `PAYER` (o pagador pagou) |
| `EXPIRED` | não há partidas e `expires_at` já passou |
| `AWAITING_PAYMENT` | não há partidas e `expires_at` ainda não passou |

**Livro-razão** — como o dinheiro se moveu, por partidas dobradas, e a prova de cada movimento. Cada lançamento tem exatamente uma extensão, indicada por `source` (`PIX`, `ETHEREUM` ou `CONVERSION`); a chave primária da extensão é o próprio `entry_id`, e o pagamento é alcançado pelo lançamento. A regra é um fato externo por lançamento: um Pix, um evento do contrato ou um pedido ao provedor de conversão. As contas das partidas dizem o sentido do dinheiro (por exemplo, `GATEWAY` → `PAYER` é uma devolução), e a extensão diz o que aconteceu no trilho. A data do fato (`occurred_at`) fica só no lançamento.

| Tabela | Papel |
|---|---|
| `core.journal_entries` | Um lançamento por fato externo; `source` indica qual extensão o comprova |
| `core.postings` | Partidas de cada lançamento (conta, ativo, valor; positivo entra, negativo sai). Um gatilho `DEFERRABLE` confere no `COMMIT` que somam zero por ativo e que o lançamento tem exatamente uma extensão, a indicada por `source`. Neutralidade: ao fim de um pagamento, `GATEWAY` e `ESCROW` somam zero; um saldo diferente mostra uma perda ou sobra do *gateway* (por exemplo, um MED aceito depois da liberação) |
| `pix.transfers` | Extensão do lançamento: o Pix recebido, enviado ao lojista, encaminhado ao provedor de conversão, devolvido ou devolvido por MED (`RECEIVED`, `PAID_OUT`, `CONVERSION_FUNDED`, `RETURNED`, `MED_RETURNED`), com o `endToEndId` (numa devolução, o id da devolução) |
| `ethereum.transactions` | Extensão do lançamento: o evento do contrato que o comprova: pagamento, retenção, liberação, encaminhamento ao provedor de conversão, reembolso ou recuperação do valor retido por um MED aceito (`PAID`, `HELD`, `RELEASED`, `CONVERSION_FUNDED`, `REFUNDED`, `RECOVERED`), com `txHash` e `logIndex` |
| `core.conversions` | Extensão do lançamento: a entrega do provedor de conversão, isto é, o ativo convertido que ele devolve (`provider` e `provider_order_id`, o id que o provedor devolve). O valor enviado ao provedor é um lançamento à parte (`CONVERSION_FUNDED` ou `RECOVERED`, no trilho em que o valor estava). Uma tabela só para todos os provedores, porque a prova tem a mesma forma em todos |

**MED** — casos de devolução abertos pelo banco do pagador e a decisão do PSP sobre cada um.

| Tabela | Papel |
|---|---|
| `pix.meds` | Um MED aberto para um pagamento: o id da notificação de infração, a data de abertura no PSP e a de registro no Pixeth. Um pagamento pode ter mais de um |
| `pix.med_decisions` | A decisão do PSP sobre um MED (`ACCEPTED` ou `REJECTED`), no máximo uma por MED (chave primária = `med_id`). Um MED sem decisão está em aberto |

Os MEDs de um pagamento são tratados em conjunto, e a situação combinada é derivada dessas duas tabelas: aceito, se algum MED foi aceito; em aberto, se nenhum foi aceito e algum ainda não tem decisão; rejeitado, se todos foram rejeitados. O que foi feito a respeito (congelar, recuperar, devolver) está nas tarefas e no livro-razão.

**Processamento** — o que move os pagamentos adiante.

| Tabela | Papel |
|---|---|
| `core.jobs` | Fila de tarefas, uma linha por passo de um pagamento (`UNIQUE (payment_id, type)`, que também descarta *webhooks* e eventos repetidos). As réplicas buscam com `FOR UPDATE SKIP LOCKED`; uma falha atualiza a própria linha (`attempts`, `run_at` adiado, `last_error`) até virar `FAILED`. `RESOLVE_MED` é a única tarefa reativada: cada aviso de MED a devolve a `PENDING` |
| `core.idempotency_keys` | Idempotência de qualquer criação da API: `scope_id` é quem enviou a chave, `resource_id` o recurso criado e `request_hash` cobre método, caminho e corpo (a mesma chave com outro pedido dá 422). Apagada depois de `expires_at` (ex.: 24 h) |
| `ethereum.chain_cursor` | Último bloco lido da *blockchain* |

Ids entre serviços (o id do lojista no IdentityStore, o usuário no Keycloak) não são garantidos pelo banco: são referências lógicas que a aplicação mantém consistentes. Credenciais de API ficam no Keycloak; o desafio de assinatura da carteira (SIWE) não é guardado, porque volta assinado pelo próprio servidor.

## Processador

![ER do processador](diagrams/svg/banco-de-dados/er-processador.svg)

[Fonte](diagrams/src/banco-de-dados/er-processador.puml)

## IdentityStore

Guarda todos os dados pessoais do sistema, cifrados pela aplicação, e gera os próprios ids; o processador só os registra.

**Titulares** — `core.owners`: nome e CPF/CNPJ do titular.

**Destinos** — um *schema* por trilho de pagamento, cada um com os campos do seu trilho; um titular pode ter várias chaves Pix e várias carteiras.

| Tabela | Papel |
|---|---|
| `pix.keys` | Chaves Pix do titular. `pix.key_type` segue os tipos definidos pelo BCB: CPF, CNPJ, e-mail, celular (`PHONE`) e chave aleatória (`EVP`, um UUID gerado pela instituição) |
| `ethereum.wallets` | Carteiras do titular, com a mensagem SIWE e a assinatura que provam a posse do endereço |

**Processamento** — `core.idempotency_keys`: permite repetir com segurança uma criação (titular, chave, carteira) depois de uma falha de rede. `scope_id` é a identidade do processador que chamou, lida do certificado mTLS, para que processadores diferentes não colidam. A chave é guardada por 24 h e depois apagada, e não contém dados pessoais.

Toda coluna `bytea` é cifrada pela aplicação, com chave do operador do IdentityStore.

![ER do IdentityStore](diagrams/svg/banco-de-dados/er-identitystore.svg)

[Fonte](diagrams/src/banco-de-dados/er-identitystore.puml)
