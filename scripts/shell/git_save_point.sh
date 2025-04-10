#!/bin/bash

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not a git repository"
    exit 1
fi

# Stage all changes
git add -A

# Get the diff of staged changes
DIFF_OUTPUT=$(git diff --cached)

if [ -z "$DIFF_OUTPUT" ]; then
    echo "No changes to commit"
    exit 0
fi

# Generate commit message using git diff
COMMIT_MSG=$(git diff --cached | awk '
    BEGIN { message = "" }
    /^diff --git/ { 
        file = $0
        sub(/^diff --git a\//, "", file)
        sub(/ b\/.*$/, "", file)
        files = files ? files ", " file : file
    }
    /^\+[^+]/ { additions++ }
    /^-[^-]/ { deletions++ }
    END {
        if (additions && deletions) {
            message = "Update " files ": "
            message = message sprintf("(+%d/-%d changes)", additions, deletions)
        } else if (additions) {
            message = "Add new changes to " files
        } else if (deletions) {
            message = "Remove content from " files
        } else {
            message = "Update " files
        }
        print message
    }
')

# Commit with generated message
git commit -m "$COMMIT_MSG"

echo "Committed with message: $COMMIT_MSG"
