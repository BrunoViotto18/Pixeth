# IdentityStore

O operador emite um *token* de uso único; o IdentityStore gera a própria chave, envia um CSR e recebe um certificado da AC do processador. A partir daí, toda comunicação entre os dois usa mTLS.

![Inscrição de IdentityStore](../diagrams/svg/fluxos/seq-inscricao-identitystore.svg)

[Fonte](../diagrams/src/fluxos/seq-inscricao-identitystore.puml)
