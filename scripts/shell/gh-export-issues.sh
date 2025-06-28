#!/bin/bash

# GitHub Issues to Markdown Exporter
# Usage: gh-export-issues [options] [owner/repo]
# Options:
#   -o, --output DIR    Output directory
#   -h, --help          Show this help message

set -euo pipefail

# Default values
OUTPUT_DIR=""
REPO=""
HELP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            HELP=true
            shift
            ;;
        *)
            REPO="$1"
            shift
            ;;
    esac
done

# Show help
if [[ "$HELP" == true ]]; then
    echo "GitHub Issues to Markdown Exporter"
    echo "Usage: gh-export-issues [options] [owner/repo]"
    echo ""
    echo "Options:"
    echo "  -o, --output DIR    Output directory"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Default output directories:"
    echo "  - Current repository: ./issues/"
    echo "  - Specified repository: ./[repo-name]/issues/"
    echo ""
    echo "Examples:"
    echo "  gh-export-issues                     # Export to ./issues/"
    echo "  gh-export-issues owner/repo           # Export to ./repo/issues/"
    echo "  gh-export-issues -o ~/Documents/issues owner/repo"
    exit 0
fi

# Determine if we're using current repo or specified repo
IS_CURRENT_REPO=false
if [[ -z "$REPO" ]]; then
    # Try to get repo from current directory
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
    if [[ -z "$REPO" ]]; then
        echo "Error: No repository specified and not in a git repository."
        echo "Please specify a repository (e.g., owner/repo) or run from within a repository."
        exit 1
    fi
    IS_CURRENT_REPO=true
fi

# Extract repo name for directory
REPO_NAME=$(echo "$REPO" | sed 's/.*\///')

# Set output directory if not specified
if [[ -z "$OUTPUT_DIR" ]]; then
    if [[ "$IS_CURRENT_REPO" == true ]]; then
        OUTPUT_DIR="./issues"
    else
        OUTPUT_DIR="./${REPO_NAME}/issues"
    fi
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Exporting issues from repository: $REPO"
echo "Output directory: $OUTPUT_DIR"

# Export all issues (both open and closed)
echo "Fetching issues..."
gh issue list --repo "$REPO" --state all --limit 10000 --json number,title,body,state,createdAt,updatedAt,author,labels,assignees,comments | jq -r '.[] | @base64' | while read -r issue_data; do
    # Decode the issue data
    _jq() {
        echo "${issue_data}" | base64 -d | jq -r "${1}"
    }
    
    # Extract issue details
    number=$(_jq '.number')
    title=$(_jq '.title')
    body=$(_jq '.body // ""')
    state=$(_jq '.state')
    created_at=$(_jq '.createdAt')
    updated_at=$(_jq '.updatedAt')
    author=$(_jq '.author.login // "unknown"')
    
    # Format filename (sanitize title for filesystem)
    safe_title=$(echo "$title" | sed 's/[^a-zA-Z0-9._-]/_/g' | cut -c1-50)
    filename="${OUTPUT_DIR}/${number}-${safe_title}.md"
    
    echo "Exporting issue #${number}: ${title}"
    
    # Start writing the markdown file
    cat > "$filename" << EOF
# Issue #${number}: ${title}

**State:** ${state}  
**Author:** @${author}  
**Created:** ${created_at}  
**Updated:** ${updated_at}  

EOF
    
    # Add labels if any
    labels=$(_jq '[.labels[].name] | join(", ")')
    if [[ -n "$labels" && "$labels" != "null" ]]; then
        echo "**Labels:** ${labels}  " >> "$filename"
    fi
    
    # Add assignees if any
    assignees=$(_jq '[.assignees[].login] | map("@" + .) | join(", ")')
    if [[ -n "$assignees" && "$assignees" != "null" && "$assignees" != "[]" ]]; then
        echo "**Assignees:** ${assignees}  " >> "$filename"
    fi
    
    # Add separator
    echo -e "\n---\n" >> "$filename"
    
    # Add issue body
    if [[ -n "$body" && "$body" != "null" ]]; then
        echo -e "## Description\n\n${body}\n" >> "$filename"
    fi
    
    # Fetch and add comments
    comments_count=$(_jq '.comments | length')
    if [[ "$comments_count" -gt 0 ]]; then
        echo -e "## Comments\n" >> "$filename"
        
        # Fetch detailed comments for this issue
        gh issue view "$number" --repo "$REPO" --comments --json comments | jq -r '.comments[] | "### Comment by @\(.author.login) on \(.createdAt)\n\n\(.body)\n\n---\n"' >> "$filename"
    fi
done

echo "Export completed! Issues saved to: $OUTPUT_DIR"