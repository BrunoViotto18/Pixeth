#!/usr/bin/env bash
# Renderiza todos os diagramas PlantUML de docs/diagrams/src para SVG em docs/diagrams/svg,
# preservando a estrutura de pastas.
#
# Requisitos: Java 11+ e Graphviz (comando `dot`).
# Uso:        ./scripts/render-diagrams.sh
# Variáveis:  PLANTUML_VERSION (padrão abaixo) ou PLANTUML_JAR (caminho para um jar já baixado).
set -euo pipefail

PLANTUML_VERSION="${PLANTUML_VERSION:-1.2026.8}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/docs/diagrams/src"
OUT="$ROOT/docs/diagrams/svg"
JAR="${PLANTUML_JAR:-$ROOT/.tools/plantuml-$PLANTUML_VERSION.jar}"

if [[ ! -f "$JAR" ]]; then
  mkdir -p "$(dirname "$JAR")"
  echo "Baixando PlantUML $PLANTUML_VERSION..."
  curl -fsSL -o "$JAR" \
    "https://repo1.maven.org/maven2/net/sourceforge/plantuml/plantuml/$PLANTUML_VERSION/plantuml-$PLANTUML_VERSION.jar"
fi

if ! command -v dot >/dev/null 2>&1; then
  echo "Aviso: Graphviz (dot) não encontrado; diagramas de classe, estado, caso de uso e componentes podem falhar." >&2
fi

# Remove apenas os SVGs antigos, para que diagramas apagados ou renomeados não deixem renders órfãos.
mkdir -p "$OUT"
find "$OUT" -type f -name '*.svg' -delete

status=0
# Renderiza uma pasta por vez (uma JVM por pasta), espelhando src/ em svg/.
while IFS= read -r -d '' dir; do
  rel="${dir#"$SRC"}"
  files=("$dir"/*.puml)
  [[ -e "${files[0]}" ]] || continue
  mkdir -p "$OUT$rel"
  echo "Renderizando ${rel:-/} (${#files[@]} arquivo(s))"
  if ! java -Djava.awt.headless=true -jar "$JAR" -tsvg -charset UTF-8 -o "$OUT$rel" "${files[@]}"; then
    status=1
  fi
done < <(find "$SRC" -type d -print0 | sort -z)

if [[ $status -ne 0 ]]; then
  echo "Um ou mais diagramas têm erros. Veja a saída acima." >&2
fi
exit $status
