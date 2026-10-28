# 7. API

| Especificação | Descrição |
|---|---|
| [`api/processor.openapi.yaml`](api/processor.openapi.yaml) | API do processador: pagamentos, *checkout*, lojistas, destinos, credenciais, PSP e administração |
| [`api/identitystore.openapi.yaml`](api/identitystore.openapi.yaml) | Contrato que todo IdentityStore implementa, consumido pelo processador via mTLS |

Ambas seguem OpenAPI 3.1 e podem ser abertas no Swagger Editor ou no VS Code (extensão *OpenAPI (Swagger) Editor*).

- **Idempotência:** `POST /v1/payments` exige `Idempotency-Key`; `POST /v1/merchants` é idempotente pelo usuário autenticado.
- **Erros** no formato *Problem Details* (RFC 9457).
