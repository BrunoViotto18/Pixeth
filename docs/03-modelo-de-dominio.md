# 3. Modelo de domínio

`Payment` guarda o trilho de origem e o de destino (`PIX` ou `ETHEREUM`, em qualquer combinação) e o valor com o seu ativo, e não muda depois de criado; o estado (`/status`) é derivado do livro-razão, das tarefas e do prazo, e não é gravado. Cada fato externo que move dinheiro vira um lançamento no livro-razão (`JournalEntry`), com partidas (`Posting`) que somam zero por ativo; as contas não dependem do trilho. O que aconteceu e o identificador externo ficam na única extensão do lançamento, indicada por `source`: `PixTransfer` (com o `endToEndId`), `EthereumTransaction` (com o `txHash`) ou `Conversion` (com o id do pedido no provedor de conversão). Nome, CPF/CNPJ, chaves Pix e carteiras do lojista ficam no IdentityStore, que gera os próprios ids; o processador só registra esses ids (`ownerId`, e em cada pagamento o `keyId` ou `walletId` de destino, sempre informado explicitamente). Tarefas assíncronas (`Job`) também fazem a deduplicação. Classes marcadas como `«imutável»` (o pagamento e suas extensões, os lançamentos e suas partidas e extensões, e o MED) nunca mudam depois de criadas: uma correção é sempre um novo registro, nunca a alteração de um antigo.

![Modelo de domínio](diagrams/svg/dominio/classes-dominio.svg)

[Fonte](diagrams/src/dominio/classes-dominio.puml)
