# 3. Modelo de domínio

`Payment` guarda o trilho de origem e o de destino (`PIX` ou `ETHEREUM`, em qualquer combinação), o valor com o seu ativo e o estado. Cada movimento de dinheiro vira um lançamento no livro-razão (`JournalEntry`), com partidas (`Posting`) que somam zero por ativo; tipos e contas não dependem do trilho. O identificador externo fica na extensão do lançamento no trilho (`PixTransfer` com o `endToEndId`, `EthereumTransaction` com o `txHash`), que pertence ao lançamento e não diretamente ao pagamento. Nome, CPF/CNPJ, chaves Pix e carteiras do lojista ficam no IdentityStore, que gera os próprios ids; o processador só registra esses ids (`ownerId`, e em cada pagamento o `keyId` ou `walletId` de destino, sempre informado explicitamente). Tarefas assíncronas (`Job`) também fazem a deduplicação. Classes marcadas como `«imutável»` (as extensões do pagamento, os lançamentos e suas partidas e extensões, e o MED) nunca mudam depois de criadas: uma correção é sempre um novo registro, nunca a alteração de um antigo.

![Modelo de domínio](diagrams/svg/dominio/classes-dominio.svg)

[Fonte](diagrams/src/dominio/classes-dominio.puml)
