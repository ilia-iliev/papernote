#!/bin/bash

trim() {
    echo "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

NAME=$(trim "$1")
LINK=$(trim "$2")

if [ -z "$NAME" ] || [ -z "$LINK" ]; then
    echo "Usage: $0 <filename> <link>"
    exit 1
fi

FILENAME="$NAME.md"
TODAY=$(date +%F)
# Title from the filename: underscores to spaces, lowercase words capitalised
TITLE=$(echo "$NAME" | tr '_' ' ' | sed -e 's/\b\([a-z]\)/\u\1/g')


# Create the file and load the questions
cat << EOF > "$FILENAME"
TITLE: $TITLE
LINK: $LINK
DATE: $TODAY

# 1. What is the paper about as a whole?

# 2. What is being said in detail, and how?

# 3. Is the paper true, in whole or part?

# 4. What of it?

EOF

xdg-open "$FILENAME"
