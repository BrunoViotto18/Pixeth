# 3. Modelo de domínio

`Payment` guarda o trilho de origem e o de destino (`PIX` ou `ETHEREUM`, em qualquer combinação), o valor com o seu ativo e o estado. Cada movimento de dinheiro, em qualquer trilho, vira um lançamento no livro-razão (`JournalEntry`), com partidas (`Posting`) que somam zero por ativo e o identificador externo (`endToEndId` ou `txHash`). Nome, CPF/CNPJ, chaves Pix e carteiras do lojista ficam no IdentityStore, que gera os próprios ids; o processador só registra esses ids (`ownerId`, e em cada pagamento o `keyId` ou `walletId` de destino, sempre informado explicitamente). Tarefas assíncronas (`Job`) também fazem a deduplicação.

![Modelo de domínio](diagrams/svg/dominio/classes-dominio.svg)

[Fonte](diagrams/src/dominio/classes-dominio.puml)
