#!/usr/bin/env bash
# SpecLeap — Wrapper para convertir documentos a Markdown.
#
# Usa Microsoft markitdown (https://github.com/microsoft/markitdown) por
# debajo. markitdown es una dependencia OPCIONAL: si no está instalada,
# este script muestra cómo instalarla y termina sin tocar nada.
#
# Formatos soportados (por markitdown): PDF, Word (.docx), PowerPoint
# (.pptx), Excel (.xlsx), HTML, imágenes (con OCR), audio (con
# transcripción), CSV, JSON, XML, ZIP, EPub, YouTube URLs.
#
# Uso:
#   bash scripts/convert-docs.sh <archivo-o-carpeta>
#
# Ejemplos:
#   bash scripts/convert-docs.sh brief.pdf
#   bash scripts/convert-docs.sh ./docs/
#   bash scripts/convert-docs.sh user-stories.docx

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Detectar idioma ──────────────────────────────────────────────────────
SPECLEAP_LANG="${SPECLEAP_LANG:-}"

if [ -z "$SPECLEAP_LANG" ] && [ -f "$SCRIPT_DIR/../.specleap/config.json" ]; then
    SPECLEAP_LANG=$(grep -o '"language": "[^"]*"' "$SCRIPT_DIR/../.specleap/config.json" 2>/dev/null | cut -d'"' -f4 || true)
fi
SPECLEAP_LANG="${SPECLEAP_LANG:-es}"

# ─── Mensajes bilingües ───────────────────────────────────────────────────
if [ "$SPECLEAP_LANG" = "en" ]; then
    MSG_USAGE="Usage: bash scripts/convert-docs.sh <file-or-directory>"
    MSG_NOT_INSTALLED="markitdown is not installed."
    MSG_INSTALL_TIP="Install with: pip install markitdown   (or: uv tool install markitdown)"
    MSG_PYTHON_REQ="Requires Python 3.10 or higher."
    MSG_DOCS="Docs: https://github.com/microsoft/markitdown"
    MSG_CONVERTING="Converting"
    MSG_DONE="Done"
    MSG_NOT_FOUND="File or directory not found"
    MSG_CONVERTED_TO="→"
    MSG_NO_FILES="No convertible files found in"
    MSG_SUMMARY="Summary"
    MSG_FAIL="FAIL"
    MSG_PROCESSING_DIR="Processing directory"
    MSG_HELP_INTRO="Convert documents (PDF, Word, Excel, HTML, etc.) to Markdown using markitdown."
    MSG_HELP_FORMATS="Supported formats: PDF, DOCX, PPTX, XLSX, HTML, CSV, JSON, XML, EPub, images, audio."
    MSG_HELP_EXAMPLES="Examples:"
else
    MSG_USAGE="Uso: bash scripts/convert-docs.sh <archivo-o-carpeta>"
    MSG_NOT_INSTALLED="markitdown no está instalado."
    MSG_INSTALL_TIP="Instala con: pip install markitdown   (o: uv tool install markitdown)"
    MSG_PYTHON_REQ="Requiere Python 3.10 o superior."
    MSG_DOCS="Docs: https://github.com/microsoft/markitdown"
    MSG_CONVERTING="Convirtiendo"
    MSG_DONE="Listo"
    MSG_NOT_FOUND="Archivo o carpeta no encontrado"
    MSG_CONVERTED_TO="→"
    MSG_NO_FILES="No se encontraron archivos convertibles en"
    MSG_SUMMARY="Resumen"
    MSG_FAIL="FALLO"
    MSG_PROCESSING_DIR="Procesando carpeta"
    MSG_HELP_INTRO="Convierte documentos (PDF, Word, Excel, HTML, etc.) a Markdown usando markitdown."
    MSG_HELP_FORMATS="Formatos soportados: PDF, DOCX, PPTX, XLSX, HTML, CSV, JSON, XML, EPub, imágenes, audio."
    MSG_HELP_EXAMPLES="Ejemplos:"
fi

# ─── Colores ──────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; NC=''
fi

# ─── Help ─────────────────────────────────────────────────────────────────
show_help() {
    echo "$MSG_HELP_INTRO"
    echo ""
    echo "$MSG_USAGE"
    echo ""
    echo "$MSG_HELP_FORMATS"
    echo ""
    echo "$MSG_HELP_EXAMPLES"
    echo "  bash scripts/convert-docs.sh brief.pdf"
    echo "  bash scripts/convert-docs.sh ./docs/"
    echo "  bash scripts/convert-docs.sh user-stories.docx"
    echo ""
    echo "$MSG_DOCS"
}

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# ─── Verificar markitdown instalado ───────────────────────────────────────
if ! command -v markitdown >/dev/null 2>&1; then
    echo -e "${RED}❌ $MSG_NOT_INSTALLED${NC}"
    echo ""
    echo -e "${YELLOW}💡 $MSG_INSTALL_TIP${NC}"
    echo -e "   $MSG_PYTHON_REQ"
    echo ""
    echo -e "${CYAN}📖 $MSG_DOCS${NC}"
    exit 1
fi

INPUT="$1"
if [ ! -e "$INPUT" ]; then
    echo -e "${RED}❌ $MSG_NOT_FOUND: $INPUT${NC}"
    exit 1
fi

# ─── Conversión ────────────────────────────────────────────────────────────
CONVERTED_OK=0
CONVERTED_FAIL=0

convert_one() {
    local file="$1"
    local base="${file%.*}"
    local out="${base}.md"

    echo -ne "  ${CYAN}→${NC} $MSG_CONVERTING $(basename "$file") ... "
    if markitdown "$file" > "$out" 2>/dev/null; then
        echo -e "${GREEN}✅${NC} $MSG_CONVERTED_TO $(basename "$out")"
        CONVERTED_OK=$((CONVERTED_OK + 1))
    else
        echo -e "${RED}❌ $MSG_FAIL${NC}"
        # No dejar archivo .md basura si falló
        rm -f "$out"
        CONVERTED_FAIL=$((CONVERTED_FAIL + 1))
    fi
}

if [ -f "$INPUT" ]; then
    convert_one "$INPUT"
elif [ -d "$INPUT" ]; then
    echo -e "${BOLD}📁 $MSG_PROCESSING_DIR: $INPUT${NC}"
    echo ""

    # Extensiones que markitdown soporta
    EXTENSIONS=(pdf docx xlsx pptx html htm csv json xml epub rtf odt ods odp txt)
    FOUND_ANY=0

    for ext in "${EXTENSIONS[@]}"; do
        while IFS= read -r -d '' file; do
            convert_one "$file"
            FOUND_ANY=1
        done < <(find "$INPUT" -maxdepth 3 -type f -iname "*.${ext}" -print0 2>/dev/null)
    done

    if [ $FOUND_ANY -eq 0 ]; then
        echo -e "${YELLOW}⚠️  $MSG_NO_FILES $INPUT${NC}"
        echo "   (pdf, docx, xlsx, pptx, html, csv, json, xml, epub, ...)"
        exit 0
    fi
fi

echo ""
echo -e "${GREEN}✅ $MSG_DONE${NC} — $MSG_SUMMARY: ${BOLD}$CONVERTED_OK${NC} OK, ${BOLD}$CONVERTED_FAIL${NC} $MSG_FAIL"
