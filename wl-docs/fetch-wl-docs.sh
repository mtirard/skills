#!/usr/bin/env bash
# Fetch WL reference docs from reference.devel.wolfram.com
# Usage: fetch-wl-docs.sh ref/FormFunction ref/Databin guide/CreatingFormsAndApps

BASE_URL="https://reference.devel.wolfram.com/language"
DOCS_DIR="/opt/wl-docs"

if [[ $# -eq 0 ]]; then
    echo "Usage: $(basename "$0") ref/SymbolName [ref/Another guide/Topic ...]" >&2
    echo "Example: $(basename "$0") ref/FormFunction ref/Databin guide/CreatingFormsAndApps" >&2
    exit 1
fi

declare -a saved_refs=()    # ref as actually saved (may be casing-corrected)
declare -a display_refs=()  # ref as given by user
declare -a corrections=()   # non-empty when casing was corrected
declare -a failed_refs=()

fetch_ref() {
    local given_ref="$1"
    local segment="${given_ref##*/}"
    local prefix="${given_ref%/*}"

    local dest="${DOCS_DIR}/${given_ref}.md"
    local url="${BASE_URL}/${given_ref}.en.md"

    mkdir -p "$(dirname "$dest")"

    # Try 1: exact as given
    if curl -sf "$url" -o "$dest" 2>/dev/null; then
        saved_refs+=("$given_ref")
        display_refs+=("$given_ref")
        corrections+=("")
        return 0
    fi
    rm -f "$dest"

    # Try 2: casing fallback — keep first char, lowercase the rest of the segment
    local corrected_segment="${segment:0:1}$(printf '%s' "${segment:1}" | tr '[:upper:]' '[:lower:]')"

    if [[ "$corrected_segment" == "$segment" ]]; then
        # Nothing changed, no point retrying
        failed_refs+=("$given_ref")
        return 1
    fi

    local corrected_ref="${prefix}/${corrected_segment}"
    local corrected_dest="${DOCS_DIR}/${corrected_ref}.md"
    local corrected_url="${BASE_URL}/${corrected_ref}.en.md"

    mkdir -p "$(dirname "$corrected_dest")"

    if curl -sf "$corrected_url" -o "$corrected_dest" 2>/dev/null; then
        saved_refs+=("$corrected_ref")
        display_refs+=("$given_ref")
        corrections+=("$corrected_segment")
        return 0
    fi
    rm -f "$corrected_dest"

    failed_refs+=("$given_ref")
    return 1
}

for arg in "$@"; do
    fetch_ref "$arg"
done

echo ""
echo "=== fetch summary ==="

for i in "${!saved_refs[@]}"; do
    ref="${saved_refs[$i]}"
    given="${display_refs[$i]}"
    correction="${corrections[$i]}"
    dest="${DOCS_DIR}/${ref}.md"

    kb=$(( ($(wc -c < "$dest" | tr -d ' ') + 1023) / 1024 ))
    [[ $kb -lt 1 ]] && kb=1
    lines=$(wc -l < "$dest" | tr -d ' ')

    if [[ -n "$correction" ]]; then
        printf "✓ %s  [casing corrected → %s]  (%d KB, %s lines)\n" \
            "$given" "$correction" "$kb" "$lines"
    else
        printf "✓ %s  (%d KB, %s lines)\n" "$given" "$kb" "$lines"
    fi
done

for ref in "${failed_refs[@]}"; do
    printf "✗ %s  (not found)\n" "$ref"
done

echo "==="
printf "%d refs: %d saved, %d failed\n" \
    "$(( ${#saved_refs[@]} + ${#failed_refs[@]} ))" \
    "${#saved_refs[@]}" "${#failed_refs[@]}"

[[ ${#failed_refs[@]} -eq 0 ]]
