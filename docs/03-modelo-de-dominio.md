# 3. Modelo de domínio

`Payment` guarda a direção (`PIX_TO_ETH` ou `ETH_TO_PIX`), o valor em BRL e o estado. Cada movimento de dinheiro, em qualquer trilho, vira uma `Transaction` com o identificador externo (`endToEndId` ou `txHash`), o que forma a trilha de auditoria do pagamento. Cada lojista tem uma carteira e uma chave Pix. Nome, CPF/CNPJ e o valor da chave ficam no IdentityStore; o processador guarda só o `id` do lojista (usado como referência no IdentityStore), a referência da chave e a versão mascarada. Tarefas assíncronas (`Job`) também fazem a deduplicação.

![Modelo de domínio](diagrams/svg/dominio/classes-dominio.svg)

[Fonte](diagrams/src/dominio/classes-dominio.puml)
