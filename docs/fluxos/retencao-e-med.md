# Retenção e MED

O Pix pode ser revertido por MED; a entrega na *blockchain* não. Por isso, um pagamento é retido quando o trilho de origem é reversível e o de destino retém: hoje, no sentido Pix → Ethereum, o ETH fica retido no contrato até `releaseAt`. Pagamentos com destino Pix não têm retenção.

**O *gateway* como terceiro de boa-fé.** O MED não alcança recursos destinados à conta de um terceiro de boa-fé. O Pixeth recebe o Pix em nome do lojista e não participa da fraude; por isso, não se espera que o PSP bloqueie ou devolva valores da conta dele. Ainda assim, o Pixeth colabora: quando é avisado de um MED, protege o valor que ainda controla e, se o MED for aceito, devolve ao pagador o que conseguir recuperar.

**Aviso sem padrão.** O MED não faz parte da API Pix padrão: cada PSP avisa o recebedor do seu jeito. O aviso de abertura e o de decisão entram pelo adaptador do PSP, que os traduz para o núcleo; a devolução usa a operação padrão da API Pix (`PUT /pix/{e2eid}/devolucao/{id}`), que aceita devoluções parciais até o valor do Pix original, em até 90 dias.

**Tratamento automático.** Não há operador: a tarefa `RESOLVE_MED` do pagamento é reativada a cada aviso e faz o que faltar.

| Situação dos MEDs do pagamento | O que acontece |
|---|---|
| Algum sem decisão, nenhum aceito | A retenção é congelada no contrato (`freeze`); as tarefas que entregam dinheiro ao lojista esperam |
| Todos rejeitados | A retenção é descongelada (`unfreeze`) e volta a valer com o prazo que restava |
| Algum aceito, com valor ainda retido | `RECOVER`: o Pixeth cria um pedido de conversão inversa e o contrato envia ao provedor só o ETH necessário para recomprar o valor do Pix original (`recover`). `REFUND`: com o BRL em conta, o Pixeth devolve o Pix ao pagador (`MED_RETURNED`) |
| Algum aceito, com valor já liberado | Não há o que recuperar; o MED fica registrado |

Um pagamento pode receber mais de um MED; eles são tratados como um só, e basta um aceito para o pagamento inteiro ser devolvido. A devolução vai até o valor do Pix original: se o retido não bastar (a cotação caiu), ela é parcial; se sobrar ETH (a cotação subiu), a sobra é liberada ao lojista. Se o próprio PSP já tiver devolvido o Pix, o Pixeth ainda recupera o valor retido, mas não devolve de novo.

O contrato só aceita `recover` com a retenção congelada e só envia a endereços da lista de provedores de conversão: o valor recuperado nunca passa por uma carteira do Pixeth.

![Liberação e MED](../diagrams/svg/fluxos/seq-liberacao-e-med.svg)

[Fonte](../diagrams/src/fluxos/seq-liberacao-e-med.puml)
