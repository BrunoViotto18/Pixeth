# 4. Banco de dados

O banco do processador tem seis tabelas:

| Tabela | Papel |
|---|---|
| `merchants` | Lojista, com uma carteira, uma chave Pix (referência e versão mascarada) e um *webhook* |
| `payments` | Pagamentos, com cotação, retenção e situação de MED; a chave única `(merchant_id, idempotency_key)` garante a idempotência da API |
| `transactions` | Cada movimento de dinheiro, com o identificador externo (`endToEndId` ou `txHash`) |
| `jobs` | Fila de tarefas e deduplicação: `dedup_key` único descarta eventos repetidos |
| `identity_stores` | IdentityStores inscritos, com o *token* de inscrição e o certificado vigente |
| `chain_cursor` | Último bloco lido da *blockchain* |

Credenciais de API e contas de acesso ficam no Keycloak; o desafio de assinatura da carteira (SIWE) não é guardado, porque volta assinado pelo próprio servidor.

## Processador

![ER do processador](diagrams/svg/banco-de-dados/er-processador.svg)

[Fonte](diagrams/src/banco-de-dados/er-processador.puml)

## IdentityStore

Guarda todos os dados pessoais do sistema (nome, CPF/CNPJ e chaves Pix), cifrados pela aplicação.

![ER do IdentityStore](diagrams/svg/banco-de-dados/er-identitystore.svg)

[Fonte](diagrams/src/banco-de-dados/er-identitystore.puml)
