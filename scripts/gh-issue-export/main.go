package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

type Issue struct {
	Number    int       `json:"number"`
	Title     string    `json:"title"`
	Body      *string   `json:"body"`
	State     string    `json:"state"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
	Author    struct {
		Login string `json:"login"`
	} `json:"author"`
	Labels []struct {
		Name string `json:"name"`
	} `json:"labels"`
	Assignees []struct {
		Login string `json:"login"`
	} `json:"assignees"`
	Comments []interface{} `json:"comments"`
}

type Comment struct {
	Author struct {
		Login string `json:"login"`
	} `json:"author"`
	CreatedAt time.Time `json:"createdAt"`
	Body      string    `json:"body"`
}

type CommentsResponse struct {
	Comments []Comment `json:"comments"`
}

type IssueFilters struct {
	ID       string
	Status   string
	Label    string
	Assignee string
	Author   string
}

func main() {
	var outputDir string
	var repo string
	var issueID string
	var status string
	var label string
	var assignee string
	var author string
	var overwrite bool
	var help bool

	flag.StringVar(&outputDir, "o", "", "Output directory")
	flag.StringVar(&outputDir, "output", "", "Output directory")
	flag.StringVar(&repo, "r", "", "Repository (owner/repo)")
	flag.StringVar(&repo, "repo", "", "Repository (owner/repo)")
	flag.StringVar(&issueID, "id", "", "Specific issue ID to export")
	flag.StringVar(&status, "status", "open", "Issue status: open, closed, or all (default: open)")
	flag.StringVar(&label, "label", "", "Filter by label")
	flag.StringVar(&assignee, "assignee", "", "Filter by assignee")
	flag.StringVar(&author, "author", "", "Filter by author")
	flag.BoolVar(&overwrite, "overwrite", false, "Overwrite existing files (default: skip)")
	flag.BoolVar(&help, "h", false, "Show help message")
	flag.BoolVar(&help, "help", false, "Show help message")
	flag.Parse()

	if help {
		showHelp()
		return
	}

	// Check for unnamed arguments
	if flag.NArg() > 0 {
		fmt.Println("Error: Unnamed arguments are not supported.")
		fmt.Println("Use -o/--output for output directory or -r/--repo for repository.")
		fmt.Println("Run with -h/--help for usage information.")
		os.Exit(1)
	}

	isCurrentRepo := false
	
	// If no repo specified, try to get current repo
	if repo == "" {
		currentRepo, err := getCurrentRepo()
		if err != nil {
			fmt.Println("Error: No repository specified and not in a git repository.")
			fmt.Println("Please specify a repository with -r/--repo or run from within a repository.")
			os.Exit(1)
		}
		repo = currentRepo
		isCurrentRepo = true
	}

	if outputDir == "" {
		if isCurrentRepo {
			outputDir = "./issues"
		} else {
			outputDir = fmt.Sprintf("./%s/issues", repo)
		}
	}

	if err := os.MkdirAll(outputDir, 0755); err != nil {
		fmt.Printf("Error creating output directory: %v\n", err)
		os.Exit(1)
	}

	// Create filter options
	filters := IssueFilters{
		ID:       issueID,
		Status:   status,
		Label:    label,
		Assignee: assignee,
		Author:   author,
	}

	fmt.Printf("Exporting issues from repository: %s\n", repo)
	fmt.Printf("Output directory: %s\n", outputDir)
	
	// Print active filters
	if filters.ID != "" {
		fmt.Printf("Filter - Issue ID: %s\n", filters.ID)
	}
	if filters.Status != "open" {
		fmt.Printf("Filter - Status: %s\n", filters.Status)
	}
	if filters.Label != "" {
		fmt.Printf("Filter - Label: %s\n", filters.Label)
	}
	if filters.Assignee != "" {
		fmt.Printf("Filter - Assignee: %s\n", filters.Assignee)
	}
	if filters.Author != "" {
		fmt.Printf("Filter - Author: %s\n", filters.Author)
	}
	if overwrite {
		fmt.Printf("Mode: Overwrite existing files\n")
	} else {
		fmt.Printf("Mode: Skip existing files\n")
	}

	if err := exportIssues(repo, outputDir, filters, overwrite); err != nil {
		fmt.Printf("Error exporting issues: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Export completed! Issues saved to: %s\n", outputDir)
}

func showHelp() {
	fmt.Println("GitHub Issues to Markdown Exporter")
	fmt.Println("Usage: gh-issue-export [options]")
	fmt.Println()
	fmt.Println("Options:")
	fmt.Println("  -o, --output DIR       Output directory")
	fmt.Println("  -r, --repo OWNER/REPO  Repository to export (default: current repo)")
	fmt.Println("  -id ID                 Export specific issue by ID")
	fmt.Println("  -status STATUS         Filter by status: open, closed, or all (default: open)")
	fmt.Println("  -label LABEL           Filter by label")
	fmt.Println("  -assignee USER         Filter by assignee")
	fmt.Println("  -author USER           Filter by author")
	fmt.Println("  -overwrite             Overwrite existing files (default: skip)")
	fmt.Println("  -h, --help             Show this help message")
	fmt.Println()
	fmt.Println("Default output directories:")
	fmt.Println("  - Current repository: ./issues/")
	fmt.Println("  - Specified repository: ./[owner]/[repo]/issues/")
	fmt.Println()
	fmt.Println("Examples:")
	fmt.Println("  gh-issue-export                          # Export all issues")
	fmt.Println("  gh-issue-export -status open             # Export only open issues")
	fmt.Println("  gh-issue-export -label bug               # Export issues with 'bug' label")
	fmt.Println("  gh-issue-export -author username         # Export issues by specific author")
	fmt.Println("  gh-issue-export -id 123                  # Export specific issue #123")
	fmt.Println("  gh-issue-export -r owner/repo -o ~/docs  # Export from other repo")
}

func getCurrentRepo() (string, error) {
	cmd := exec.Command("gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(output)), nil
}



func exportSingleIssue(repo, outputDir, issueID string, overwrite bool) error {
	fmt.Printf("Fetching issue #%s...\n", issueID)
	
	cmd := exec.Command("gh", "issue", "view", issueID, "--repo", repo,
		"--json", "number,title,body,state,createdAt,updatedAt,author,labels,assignees,comments")
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("failed to fetch issue #%s: %w", issueID, err)
	}

	var issue Issue
	if err := json.Unmarshal(output, &issue); err != nil {
		return fmt.Errorf("failed to parse issue: %w", err)
	}

	if err := exportIssue(repo, outputDir, issue, overwrite); err != nil {
		return fmt.Errorf("error exporting issue #%s: %w", issueID, err)
	}
	
	return nil
}

func exportIssues(repo, outputDir string, filters IssueFilters, overwrite bool) error {
	fmt.Println("Fetching issues...")
	
	// Build command arguments
	args := []string{"issue", "list", "--repo", repo, "--limit", "10000",
		"--json", "number,title,body,state,createdAt,updatedAt,author,labels,assignees,comments"}
	
	// Add filters
	if filters.Status != "all" && filters.Status != "" {
		args = append(args, "--state", filters.Status)
	} else {
		args = append(args, "--state", "all")
	}
	
	if filters.Label != "" {
		args = append(args, "--label", filters.Label)
	}
	
	if filters.Assignee != "" {
		args = append(args, "--assignee", filters.Assignee)
	}
	
	if filters.Author != "" {
		args = append(args, "--author", filters.Author)
	}
	
	// Handle specific issue ID
	if filters.ID != "" {
		// For specific issue, use 'gh issue view' instead
		return exportSingleIssue(repo, outputDir, filters.ID, overwrite)
	}
	
	cmd := exec.Command("gh", args...)
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("failed to fetch issues: %w", err)
	}

	var issues []Issue
	if err := json.Unmarshal(output, &issues); err != nil {
		return fmt.Errorf("failed to parse issues: %w", err)
	}

	if len(issues) == 0 {
		fmt.Println("No issues found matching the filters.")
		return nil
	}

	for _, issue := range issues {
		if err := exportIssue(repo, outputDir, issue, overwrite); err != nil {
			fmt.Printf("Error exporting issue #%d: %v\n", issue.Number, err)
			continue
		}
	}

	return nil
}

func sanitizeFilename(title string) string {
	// Replace filesystem unsafe characters
	replacer := strings.NewReplacer(
		"/", "-",
		"\\", "-",
		":", "-",
		"*", "-",
		"?", "-",
		"\"", "'",
		"<", "-",
		">", "-",
		"|", "-",
		"\n", " ",
		"\r", " ",
		"\t", " ",
	)
	
	sanitized := replacer.Replace(title)
	
	// Trim spaces and dots from the beginning and end
	sanitized = strings.TrimSpace(sanitized)
	sanitized = strings.Trim(sanitized, ".")
	
	// Limit length to 255 characters (common filesystem limit)
	if len(sanitized) > 255 {
		sanitized = sanitized[:255]
	}
	
	// If the title is empty after sanitization, use a default
	if sanitized == "" {
		return "untitled"
	}
	
	return sanitized
}

func exportIssue(repo, outputDir string, issue Issue, overwrite bool) error {
	sanitizedTitle := sanitizeFilename(issue.Title)
	filename := filepath.Join(outputDir, fmt.Sprintf("%d_%s.md", issue.Number, sanitizedTitle))
	
	// Check if file exists and handle overwrite behavior
	if !overwrite {
		if _, err := os.Stat(filename); err == nil {
			// File exists, skip it
			fmt.Printf("Skipping issue #%d: %s (file exists)\n", issue.Number, issue.Title)
			return nil
		}
	}
	
	fmt.Printf("Exporting issue #%d: %s\n", issue.Number, issue.Title)
	
	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	fmt.Fprintf(file, "# Issue #%d: %s\n\n", issue.Number, issue.Title)
	fmt.Fprintf(file, "**State:** %s  \n", issue.State)
	
	authorLogin := "unknown"
	if issue.Author.Login != "" {
		authorLogin = issue.Author.Login
	}
	fmt.Fprintf(file, "**Author:** @%s  \n", authorLogin)
	fmt.Fprintf(file, "**Created:** %s  \n", issue.CreatedAt.Format(time.RFC3339))
	fmt.Fprintf(file, "**Updated:** %s  \n", issue.UpdatedAt.Format(time.RFC3339))

	if len(issue.Labels) > 0 {
		var labelNames []string
		for _, label := range issue.Labels {
			labelNames = append(labelNames, label.Name)
		}
		fmt.Fprintf(file, "**Labels:** %s  \n", strings.Join(labelNames, ", "))
	}

	if len(issue.Assignees) > 0 {
		var assigneeNames []string
		for _, assignee := range issue.Assignees {
			assigneeNames = append(assigneeNames, "@"+assignee.Login)
		}
		fmt.Fprintf(file, "**Assignees:** %s  \n", strings.Join(assigneeNames, ", "))
	}

	fmt.Fprintln(file, "\n---\n")

	if issue.Body != nil && *issue.Body != "" {
		fmt.Fprintf(file, "## Description\n\n%s\n\n", *issue.Body)
	}

	if len(issue.Comments) > 0 {
		fmt.Fprintln(file, "## Comments\n")
		
		cmd := exec.Command("gh", "issue", "view", fmt.Sprintf("%d", issue.Number), 
			"--repo", repo, "--comments", "--json", "comments")
		output, err := cmd.Output()
		if err == nil {
			var response CommentsResponse
			if err := json.Unmarshal(output, &response); err == nil {
				for _, comment := range response.Comments {
					fmt.Fprintf(file, "### Comment by @%s on %s\n\n%s\n\n---\n\n",
						comment.Author.Login,
						comment.CreatedAt.Format(time.RFC3339),
						comment.Body)
				}
			}
		}
	}

	return nil
}