#!/bin/bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir "$TMP/notes"

(
    cd "$TMP/notes"
    EDITOR=true "$ROOT/papernote" "Test Paper" "https://example.com/paper.pdf" > /dev/null
)

grep -qx '## 1. What is the paper about as a whole?' "$TMP/notes/test_paper.md"
test -z "$(grep '^# ' "$TMP/notes/test_paper.md")"
