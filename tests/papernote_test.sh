#!/bin/bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir "$TMP/notes" "$TMP/bin"

# Keep title lookup deterministic and offline.
cat > "$TMP/bin/curl" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" > "$CURL_LOG"
if [ "${CURL_FAIL:-0}" = 1 ]; then
    echo 'curl: download failed' >&2
    exit 22
fi
printf '%s\n' "$PAPER_HTML"
EOF
chmod +x "$TMP/bin/curl"
export PATH="$TMP/bin:$PATH"
export CURL_LOG="$TMP/curl.log"
export PAPER_HTML='<html><head>
<meta content="Targeting Pivotal Decisions: A &amp; B"
      name="citation_title">
</head></html>'

(
    cd "$TMP/notes"
    EDITOR=true "$ROOT/papernote" "Test Paper" "https://example.com/paper.pdf" > /dev/null
)

grep -qx '## 1. What is the paper about as a whole?' "$TMP/notes/test_paper.md"
test -z "$(grep '^# ' "$TMP/notes/test_paper.md")"
test ! -e "$CURL_LOG"

(
    cd "$TMP/notes"
    EDITOR=true "$ROOT/papernote" 'https://arxiv.org/pdf/2609.36178' > /dev/null
)
AUTO_NOTE="$TMP/notes/targeting_pivotal_decisions_a_b.md"
grep -qx 'TITLE: Targeting Pivotal Decisions: A & B' "$AUTO_NOTE"
grep -qx 'LINK: https://arxiv.org/pdf/2609.36178' "$AUTO_NOTE"
grep -q 'https://arxiv.org/abs/2609.36178$' "$CURL_LOG"

# Versioned PDF URLs should resolve to the matching abstract page.
(
    cd "$TMP/notes"
    PAPER_HTML='<meta name="citation_title" content="Versioned Paper">' \
        EDITOR=true "$ROOT/papernote" 'https://arxiv.org/pdf/2609.36178v2.pdf' > /dev/null
)
grep -qx 'TITLE: Versioned Paper' "$TMP/notes/versioned_paper.md"
grep -q 'https://arxiv.org/abs/2609.36178v2$' "$CURL_LOG"

# Missing metadata and failed downloads must not create notes.
mkdir "$TMP/failures"
(
    cd "$TMP/failures"
    if PAPER_HTML='<html></html>' EDITOR=true "$ROOT/papernote" \
        'https://arxiv.org/abs/2609.36178' > /dev/null 2> "$TMP/missing.err"; then
        echo 'Expected missing title to fail' >&2
        exit 1
    fi
    grep -q 'Could not extract' "$TMP/missing.err"
    if CURL_FAIL=1 EDITOR=true "$ROOT/papernote" \
        'https://arxiv.org/pdf/2609.36178' > /dev/null 2> "$TMP/download.err"; then
        echo 'Expected failed download to fail' >&2
        exit 1
    fi
    grep -q 'download failed' "$TMP/download.err"
    test -z "$(ls -A)"
)

# Default opening must run mrk in the current terminal, not a desktop opener.
cat > "$TMP/bin/mrk" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$OPEN_LOG"
exit "${OPEN_STATUS:-0}"
EOF
cat > "$TMP/bin/xdg-open" <<'EOF'
#!/bin/bash
echo 'Unexpected desktop opener' >&2
exit 1
EOF
chmod +x "$TMP/bin/mrk" "$TMP/bin/xdg-open"
export OPEN_LOG="$TMP/open.log"
(
    cd "$TMP/notes"
    unset EDITOR VISUAL
    "$ROOT/papernote" 'Default Markdown App' 'https://example.com/paper.pdf' > /dev/null
)
grep -qx 'default_markdown_app.md' "$OPEN_LOG"

# An explicit editor override should bypass the default opener.
rm "$OPEN_LOG"
(
    cd "$TMP/notes"
    EDITOR=true "$ROOT/papernote" 'Editor Override' 'https://example.com/paper.pdf' > /dev/null
)
test ! -e "$OPEN_LOG"

# Opening errors must not be hidden.
(
    cd "$TMP/notes"
    unset EDITOR VISUAL
    if OPEN_STATUS=7 "$ROOT/papernote" 'Opening Failure' 'https://example.com/paper.pdf' > /dev/null; then
        echo 'Expected opening failure to propagate' >&2
        exit 1
    else
        test "$?" -eq 7
    fi
)

echo 'papernote tests passed'
