#!/usr/bin/env bash
# Fetch WL reference docs from reference.wolfram.com
# Usage: fetch-wl-docs.sh ref/FormFunction ref/Databin guide/CreatingFormsAndApps

BASE_URL="https://reference.wolfram.com/language"
DOCS_DIR="/opt/wl-docs"

if [[ $# -eq 0 ]]; then
    echo "Usage: $(basename "$0") ref/SymbolName [ref/Another guide/Topic ...]" >&2
    echo "Example: $(basename "$0") ref/FormFunction ref/Databin guide/CreatingFormsAndApps" >&2
    exit 1
fi

declare -a saved_refs=()    # ref as actually saved (may be casing-corrected)
declare -a display_refs=()  # ref as given by user
declare -a corrections=()   # non-empty when casing was corrected
declare -a cached=()        # "1" when served from cache, "" when fetched
declare -a failed_refs=()

fetch_ref() {
    local given_ref="$1"
    local segment="${given_ref##*/}"
    local prefix="${given_ref%/*}"

    local dest="${DOCS_DIR}/${given_ref}.md"
    local url="${BASE_URL}/${given_ref}.en.md"

    # Casing fallback candidate — keep first char, lowercase the rest of the segment
    local corrected_segment="${segment:0:1}$(printf '%s' "${segment:1}" | tr '[:upper:]' '[:lower:]')"
    local corrected_ref=""
    local corrected_dest=""
    if [[ "$corrected_segment" != "$segment" ]]; then
        corrected_ref="${prefix}/${corrected_segment}"
        corrected_dest="${DOCS_DIR}/${corrected_ref}.md"
    fi

    # Cache hit at given path
    if [[ -f "$dest" ]]; then
        saved_refs+=("$given_ref")
        display_refs+=("$given_ref")
        corrections+=("")
        cached+=("1")
        return 0
    fi

    # Cache hit at casing-corrected path
    if [[ -n "$corrected_dest" && -f "$corrected_dest" ]]; then
        saved_refs+=("$corrected_ref")
        display_refs+=("$given_ref")
        corrections+=("$corrected_segment")
        cached+=("1")
        return 0
    fi

    mkdir -p "$(dirname "$dest")"

    # Try 1: exact as given
    if curl -sf "$url" -o "$dest" 2>/dev/null; then
        saved_refs+=("$given_ref")
        display_refs+=("$given_ref")
        corrections+=("")
        cached+=("")
        return 0
    fi
    rm -f "$dest"

    # Try 2: casing fallback
    if [[ -z "$corrected_ref" ]]; then
        failed_refs+=("$given_ref")
        return 1
    fi

    local corrected_url="${BASE_URL}/${corrected_ref}.en.md"
    mkdir -p "$(dirname "$corrected_dest")"

    if curl -sf "$corrected_url" -o "$corrected_dest" 2>/dev/null; then
        saved_refs+=("$corrected_ref")
        display_refs+=("$given_ref")
        corrections+=("$corrected_segment")
        cached+=("")
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
    is_cached="${cached[$i]}"
    dest="${DOCS_DIR}/${ref}.md"

    kb=$(( ($(wc -c < "$dest" | tr -d ' ') + 1023) / 1024 ))
    [[ $kb -lt 1 ]] && kb=1
    lines=$(wc -l < "$dest" | tr -d ' ')

    cache_tag=""
    [[ -n "$is_cached" ]] && cache_tag=" [cached]"

    if [[ -n "$correction" ]]; then
        printf "✓ %s  [casing corrected → %s]%s  (%d KB, %s lines)\n" \
            "$given" "$correction" "$cache_tag" "$kb" "$lines"
    else
        printf "✓ %s%s  (%d KB, %s lines)\n" "$given" "$cache_tag" "$kb" "$lines"
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
