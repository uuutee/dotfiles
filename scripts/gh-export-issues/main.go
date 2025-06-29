package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
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

func main() {
	var outputDir string
	var repo string
	var help bool

	flag.StringVar(&outputDir, "o", "", "Output directory")
	flag.StringVar(&outputDir, "output", "", "Output directory")
	flag.StringVar(&repo, "r", "", "Repository (owner/repo)")
	flag.StringVar(&repo, "repo", "", "Repository (owner/repo)")
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

	fmt.Printf("Exporting issues from repository: %s\n", repo)
	fmt.Printf("Output directory: %s\n", outputDir)

	if err := exportIssues(repo, outputDir); err != nil {
		fmt.Printf("Error exporting issues: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Export completed! Issues saved to: %s\n", outputDir)
}

func showHelp() {
	fmt.Println("GitHub Issues to Markdown Exporter")
	fmt.Println("Usage: gh-export-issues [options]")
	fmt.Println()
	fmt.Println("Options:")
	fmt.Println("  -o, --output DIR       Output directory")
	fmt.Println("  -r, --repo OWNER/REPO  Repository to export (default: current repo)")
	fmt.Println("  -h, --help             Show this help message")
	fmt.Println()
	fmt.Println("Default output directories:")
	fmt.Println("  - Current repository: ./issues/")
	fmt.Println("  - Specified repository: ./[owner]/[repo]/issues/")
	fmt.Println()
	fmt.Println("Examples:")
	fmt.Println("  gh-export-issues                          # Export current repo to ./issues/")
	fmt.Println("  gh-export-issues -o .memo/issues          # Export current repo to .memo/issues/")
	fmt.Println("  gh-export-issues -r owner/repo            # Export specified repo to ./owner/repo/issues/")
	fmt.Println("  gh-export-issues -r owner/repo -o ~/docs  # Export specified repo to ~/docs/")
}

func getCurrentRepo() (string, error) {
	cmd := exec.Command("gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(output)), nil
}


func sanitizeTitle(title string) string {
	reg := regexp.MustCompile(`[^a-zA-Z0-9._-]`)
	sanitized := reg.ReplaceAllString(title, "_")
	if len(sanitized) > 50 {
		sanitized = sanitized[:50]
	}
	return sanitized
}

func exportIssues(repo, outputDir string) error {
	fmt.Println("Fetching issues...")
	
	cmd := exec.Command("gh", "issue", "list", "--repo", repo, "--state", "all", "--limit", "10000", 
		"--json", "number,title,body,state,createdAt,updatedAt,author,labels,assignees,comments")
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("failed to fetch issues: %w", err)
	}

	var issues []Issue
	if err := json.Unmarshal(output, &issues); err != nil {
		return fmt.Errorf("failed to parse issues: %w", err)
	}

	for _, issue := range issues {
		if err := exportIssue(repo, outputDir, issue); err != nil {
			fmt.Printf("Error exporting issue #%d: %v\n", issue.Number, err)
			continue
		}
		fmt.Printf("Exporting issue #%d: %s\n", issue.Number, issue.Title)
	}

	return nil
}

func exportIssue(repo, outputDir string, issue Issue) error {
	safeTitle := sanitizeTitle(issue.Title)
	filename := filepath.Join(outputDir, fmt.Sprintf("%d-%s.md", issue.Number, safeTitle))

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