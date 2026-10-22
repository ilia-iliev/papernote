#!/bin/bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir "$TMP/notes" "$TMP/bin"

# Keep title lookup deterministic and offline.
cat > "$TMP/bin/curl" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$CURL_LOG"
if [ "${CURL_FAIL:-0}" = 1 ]; then
    echo 'curl: download failed' >&2
    exit 22
fi
if [[ "$*" == *'https://export.arxiv.org/api/query'* ]]; then
    printf '%s\n' "$PAPER_FEED"
else
    printf '%s\n' "$PAPER_HTML"
fi
EOF
chmod +x "$TMP/bin/curl"
export PATH="$TMP/bin:$PATH"
export CURL_LOG="$TMP/curl.log"
export PAPER_HTML='<html><head>
<meta content="Targeting Pivotal Decisions: A &amp; B"
      name="citation_title">
</head></html>'
export PAPER_FEED='<feed xmlns="http://www.w3.org/2005/Atom">
<entry>
<id>http://arxiv.org/abs/2609.36178v1</id>
<title>Targeting Pivotal Decisions: A &amp; B</title>
</entry>
</feed>'

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
grep -qx 'https://export.arxiv.org/api/query' "$CURL_LOG"
grep -qx 'id_list=2609.36178' "$CURL_LOG"

# Versioned PDF URLs should request the matching arXiv record.
(
    cd "$TMP/notes"
    PAPER_FEED='<feed xmlns="http://www.w3.org/2005/Atom"><entry>
        <id>http://arxiv.org/abs/2609.36178v2</id>
        <title>Versioned Paper</title></entry></feed>' \
        EDITOR=true "$ROOT/papernote" 'https://arxiv.org/pdf/2609.36178v2.pdf' > /dev/null
)
grep -qx 'TITLE: Versioned Paper' "$TMP/notes/versioned_paper.md"
grep -qx 'id_list=2609.36178v2' "$CURL_LOG"

# Search by title, but keep the user's short name rather than the full result title.
export PAPER_FEED='<feed xmlns="http://www.w3.org/2005/Atom"><entry>
<id>http://arxiv.org/abs/1811.06965v5</id>
<title>GPipe: Efficient Training of Giant Neural Networks using Pipeline Parallelism</title>
</entry></feed>'
(
    cd "$TMP/notes"
    EDITOR=true "$ROOT/papernote" Gpipe > /dev/null
)
grep -qx 'TITLE: Gpipe' "$TMP/notes/gpipe.md"
grep -qx 'LINK: https://arxiv.org/abs/1811.06965v5' "$TMP/notes/gpipe.md"
grep -qx 'search_query=ti:"Gpipe"' "$CURL_LOG"
grep -qx 'sortBy=relevance' "$CURL_LOG"

# Colons stay inside a quoted title query, not arXiv's field syntax.
(
    cd "$TMP/notes"
    EDITOR=true "$ROOT/papernote" 'Gpipe: Efficient training' > /dev/null
)
grep -qx 'TITLE: Gpipe: Efficient training' "$TMP/notes/gpipe_efficient_training.md"
grep -qx 'search_query=ti:"Gpipe: Efficient training"' "$CURL_LOG"

# Quotes in titles must also be escaped inside the search expression.
(
    cd "$TMP/notes"
    EDITOR=true "$ROOT/papernote" 'A "quoted" title' > /dev/null
)
grep -Fxq 'search_query=ti:"A \"quoted\" title"' "$CURL_LOG"

# Non-arXiv links still support citation metadata.
(
    cd "$TMP/notes"
    PAPER_HTML='<meta name="citation_title" content="Other Paper">' \
        EDITOR=true "$ROOT/papernote" 'https://example.com/paper' > /dev/null
)
grep -qx 'TITLE: Other Paper' "$TMP/notes/other_paper.md"

# Missing metadata, no search results, and failed downloads must not create notes.
mkdir "$TMP/failures"
(
    cd "$TMP/failures"
    if PAPER_FEED='<feed xmlns="http://www.w3.org/2005/Atom"/>' EDITOR=true "$ROOT/papernote" \
        'https://arxiv.org/abs/2609.36178' > /dev/null 2> "$TMP/missing.err"; then
        echo 'Expected missing title to fail' >&2
        exit 1
    fi
    grep -q 'Could not extract' "$TMP/missing.err"
    if PAPER_FEED='<feed xmlns="http://www.w3.org/2005/Atom"/>' EDITOR=true \
        "$ROOT/papernote" 'Unknown paper' > /dev/null 2> "$TMP/search.err"; then
        echo 'Expected no search results to fail' >&2
        exit 1
    fi
    grep -q 'No arXiv match' "$TMP/search.err"
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
