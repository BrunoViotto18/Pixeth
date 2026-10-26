# Documentação do Pixeth

*Gateway* de pagamentos entre Pix e Ethereum com arquitetura *Zero Trust*. O pagador paga no sistema que conhece (Pix ou ETH) e o lojista recebe no sistema que escolheu, sem que nenhum dos dois precise conhecer o outro lado.

O escopo é o de um TCC: fechar a lacuna entre *Web2* e *Web3* de ponta a ponta, em ambiente de teste (PSP em homologação, rede Sepolia e provedor de conversão simulado). O que um sistema em produção precisaria a mais está em [Trabalhos futuros](docs/08-trabalhos-futuros.md).

## Índice

| Página | Conteúdo |
|---|---|
| [1. Casos de uso](docs/01-casos-de-uso.md) | Lojista, pagador e operador |
| [2. Arquitetura](docs/02-arquitetura.md) | Arquitetura hexagonal, portas e adaptadores |
| [3. Modelo de domínio](docs/03-modelo-de-dominio.md) | Classes do domínio |
| [4. Banco de dados](docs/04-banco-de-dados.md) | Modelos entidade-relacionamento |
| [5. Fluxos](docs/fluxos/README.md) | Sequências de cada operação e atividades dos dois pagamentos |
| [6. Segurança](docs/06-seguranca.md) | Fronteiras de confiança |
| [7. API](docs/07-api.md) | Especificações OpenAPI do processador e do IdentityStore |
| [8. Trabalhos futuros](docs/08-trabalhos-futuros.md) | O que ficou fora do escopo |

## Convenções

- **Identificadores em inglês, textos em português.** Classes, estados, tabelas e *endpoints* seguem o código; títulos, rótulos e notas estão em português.
- **Valores monetários** em unidades mínimas (centavos, *wei*) e inteiros, nunca em ponto flutuante.
- **Elementos em cinza** (`<<futuro>>`) são extensões previstas, fora do escopo.

## Diagramas

```
docs/diagrams/src/**/*.puml   fontes (o que se edita)
docs/diagrams/svg/**/*.svg    imagens geradas (o que o GitHub exibe)
```

- **No GitHub:** a cada *push* para `main` que altere as fontes, a *action* [`diagrams.yml`](.github/workflows/diagrams.yml) gera os SVGs e os versiona.
- **Localmente:** `./scripts/render-diagrams.sh` (Java 11+ e Graphviz; baixa o PlantUML na primeira execução).
- **No VS Code:** extensão **PlantUML** (`jebbs.plantuml`); `Alt+D` abre a pré-visualização.
