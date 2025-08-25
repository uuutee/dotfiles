#!/bin/bash

# Gemini CLI PR Review Script
# Usage: ./main.sh <pr-number> <prompt>

set -euo pipefail

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <pr-number> <prompt>"
    echo "Example: $0 123 \"コードの品質をレビューしてください\""
    exit 1
fi

PR_NUMBER="$1"
PROMPT="$2"

# Get PR diff using gh command
echo "Fetching PR #${PR_NUMBER} diff..."
PR_DIFF=$(gh pr diff "${PR_NUMBER}" || {
    echo "Error: Failed to fetch PR diff. Make sure you're in the correct repository and have access to PR #${PR_NUMBER}"
    exit 1
})

# Get PR title and body
PR_INFO=$(gh pr view "${PR_NUMBER}" --json title,body,url || {
    echo "Error: Failed to fetch PR information"
    exit 1
})

PR_TITLE=$(echo "${PR_INFO}" | jq -r '.title')
PR_BODY=$(echo "${PR_INFO}" | jq -r '.body // "No description"')
PR_URL=$(echo "${PR_INFO}" | jq -r '.url')

# Create the review prompt
REVIEW_PROMPT="Pull Request Review Request

PR #${PR_NUMBER}: ${PR_TITLE}
URL: ${PR_URL}

Description:
${PR_BODY}

---
Diff:
${PR_DIFF}

---
Review Instructions: ${PROMPT}

Please provide your review response in Japanese (日本語でレビュー結果を出力してください)."

# Run gemini with the prompt
echo "Running Gemini review..."
echo "---"
gemini -p "${REVIEW_PROMPT}"
