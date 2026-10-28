# 6. Segurança

## Fronteiras de confiança

Cada travessia numerada tem um controle explícito: OIDC com MFA, OAuth 2.0, mTLS, reconsulta de *webhooks*, privilégio mínimo ou regra do contrato. O processador mantém uma única autoridade certificadora; cada IdentityStore gera a própria chave, e o operador envia o CSR no console para receber o certificado (ver [IdentityStore](fluxos/identitystore.md)).

![Fronteiras de confiança](diagrams/svg/seguranca/fronteiras-de-confianca.svg)

[Fonte](diagrams/src/seguranca/fronteiras-de-confianca.puml)
