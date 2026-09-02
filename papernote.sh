#!/bin/bash

# Set the filename based on the first argument
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <filename> <link>"
    exit 1
fi

FILENAME="${1}.md"
TODAY=$(date +%F)
# Title from the filename: underscores to spaces, lowercase words capitalised
TITLE=$(echo "${1}" | tr '_' ' ' | sed -e 's/\b\([a-z]\)/\u\1/g')


# Create the file and load the questions
cat << EOF > "$FILENAME"
TITLE: $TITLE
LINK: ${2}
DATE: $TODAY

# 1. What is the paper about as a whole?

# 2. What is being said in detail, and how?

# 3. Is the paper true, in whole or part?

# 4. What of it?

EOF
